//
//  SearchViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 09/05/21.
//

import UIKit
import Firebase
import SDWebImage

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segments: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchedUsers: [User] = []
    var searchedPlaces: [HomeTrips] = []
    
    var segment = 0
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "PeopleSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "people_search_cell")
        tableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableHomeCell")
        self.tableView.tableFooterView = UIView()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            print(segments.selectedSegmentIndex)
            if segments.selectedSegmentIndex == 0 {
                segment = 0
                let placeName = searchText.lowercased().trimmingCharacters(in: .whitespaces)
                searchForPlaces(place: placeName)
            }
            else {
                segment = 1
                searchForPeople(name: searchText)
            }
        }
    }
    
//    var uid = ""
//    var tripID = ""
//    var tripDate = ""
//    var tripName = ""
//    var tripProfileImageURL = ""
//    var startDate = ""
//    var upvotes = 0
//    var name = ""
//    var profileImageURL = ""
//    var isCurrentTrip = false
//    var isPrivate = false
//    var tempHomeTrip: HomeTrips = HomeTrips(profileImageURL: "", name: "", tripName: "", tripProfileImageURL: "", upvotes: 0, startDate: "", userId: "", tripId: "")
    
    func searchForPlaces(place: String) {
        searchedPlaces = []
        db.collection("searchPlacesTags").document("tags").collection(place).order(by: "timeStamp").getDocuments { [self] (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else if querySnapshot!.documents.count == 0 {
                print("no such places")
            }
            else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let uid = data["uid"] as! String
                    let tripID = data["tripID"] as! String
                    let name = data["name"] as! String
                    let profileImageURL = data["profileImageURL"] as! String
                    print(uid)
                    print(tripID)
                    self.db.collection("users").document(uid).collection("trips").document(tripID).getDocument { (snapshot, error) in
                        if error != nil {
                            print(error!.localizedDescription)
                        }
                        else {
                            guard let document = snapshot else {
                                return
                            }
                            let tripData = document.data()
                            let tripName = tripData!["tripName"] as! String
                            let tripProfileImageURL = tripData!["tripProfileImageURL"] as! String
                            let startDate = tripData!["startDate"] as! String
                            let upvotes = tripData!["upvotes"] as! Int
                            let isCurrentTrip = tripData!["isCurrentTrip"] as! Bool
                            let isPrivate = tripData!["privateTrip"] as! Bool
                            if(!isPrivate && !isCurrentTrip)
                            {
                                let tempHomeTrip = HomeTrips(profileImageURL: profileImageURL, name: name, tripName: tripName, tripProfileImageURL: tripProfileImageURL, upvotes: upvotes, startDate: startDate, userId: uid, tripId: tripID)
                                if searchedPlaces.count>0 && searchedPlaces.last?.tripId != tripID {
                                    searchedPlaces.append(tempHomeTrip)
                                } else if searchedPlaces.count == 0 {
                                    searchedPlaces.append(tempHomeTrip)
                                }
                            }
                            
                        }
                        print(searchedPlaces)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                } //for ends
               
            } //else ends
        }
    }

    
    func searchForPeople(name: String) {
        self.db.collection("users").whereField("name", isEqualTo: name).getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    let name = data["name"] as! String
                    let hometown = data["hometown"] as! String
                    let uid = data["uid"] as! String
                    let profileImageURL = data["profileImageURL"] as! String
                    
                    let searchedUser = User(name: name, hometown: hometown, uid: uid, profileImageURL: profileImageURL)
                    self.searchedUsers.append(searchedUser)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchedPlaces = []
        self.searchedUsers = []
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(segment == 0)
        {
//            print("count : ")
//            print("count: \(searchedPlaces.count)")
            return searchedPlaces.count
        } else {
            return searchedUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(segment == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableHomeCell", for: indexPath) as! HomeTableViewCell
            let trip = searchedPlaces[indexPath.row]
            print("trip: \(trip)")
            cell.tripName.text = trip.tripName
            cell.profileName.text = trip.name
            cell.tripUpvotes.text = "\(trip.upvotes) upvotes"
            cell.tripImage.sd_setImage(with: URL(string: trip.tripProfileImageURL), placeholderImage: UIImage(named: "Paris"))
            cell.profileImage.sd_setImage(with: URL(string: trip.profileImageURL), placeholderImage: UIImage(named: "Paris"))
            print(trip.name)
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "people_search_cell", for: indexPath) as! PeopleSearchTableViewCell
            cell.name.text = searchedUsers[indexPath.row].name
            cell.hometown.text = searchedUsers[indexPath.row].hometown
            cell.profileImageView.sd_setImage(with: URL(string: searchedUsers[indexPath.row].profileImageURL), placeholderImage: UIImage(named: "atikh-bana-FtBS0p23fcc-unsplash"))
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(segment == 0)
        {
            performSegue(withIdentifier: "view_trip", sender: self)
            print(indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            performSegue(withIdentifier: "show_user_profile", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "view_trip") {
            let tripViewVC = segue.destination as! TripViewController
            tripViewVC.currentTripID = searchedPlaces[tableView.indexPathForSelectedRow!.row].tripId
            tripViewVC.uid = searchedPlaces[tableView.indexPathForSelectedRow!.row].userId
            tripViewVC.showCurrentTrip = false
        }
        if(segue.identifier == "show_user_profile") {
            let userProfileVC = segue.destination as! SearchProfileViewController
            userProfileVC.uid = searchedUsers[tableView.indexPathForSelectedRow!.row].uid
        }
    }
}
