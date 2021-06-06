//
//  HomeViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 15/04/21.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    var following: [String] = []
    let uid = UserDefaults.standard.string(forKey: "uid")!
    let db = Firestore.firestore()
    var trips : [HomeTrips] = []

    @IBOutlet weak var homeTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.dataSource = self
        homeTableView.delegate = self
        homeTableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableHomeCell")
        homeTableView.tableFooterView = UIView()
        
    }
    
    func fetchFollowingIds(completion: @escaping () -> ()) {
        self.following = []
        self.db.collection("users").document(self.uid).collection("following").getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let followingId = data["uid"] as! String
                    if self.following.count > 0 && self.following.last !=  followingId {
                        self.following.append(followingId)
                    }
                    else if self.following.count == 0 {
                        self.following.append(followingId)
                    }
                }
                completion()
                }
            }
    }
    
    func fetchTrips(completion: @escaping () -> ()) {
        self.trips = []
        for follId in following {
            self.db.collection("users").document(follId).getDocument { (querySnapshot, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    let data = querySnapshot?.data()
                    if let data = data {
                        let name = data["name"] as! String
                        let profileImageURL = data["profileImageURL"] as! String
                        let userId = follId
                        self.db.collection("users").document(follId).collection("trips").getDocuments{ (tripQuerySnapshot, error) in
                            if error != nil {
                                print(error?.localizedDescription)
                            } else {
                                for document in tripQuerySnapshot!.documents {
                                    let tripData = document.data()
                                    let tripId = document.documentID
                                    let tripName = tripData["tripName"] as! String
                                    let tripProfileImageURL = tripData["tripProfileImageURL"] as! String
                                    let startDate = tripData["startDate"] as! String
                                    let upvotes = tripData["upvotes"] as! Int
                                    let tempHomeTrip = HomeTrips(profileImageURL: profileImageURL, name: name, tripName: tripName, tripProfileImageURL: tripProfileImageURL, upvotes: upvotes, startDate: startDate, userId: userId, tripId: tripId)
                                    if self.trips.count > 0 && self.trips.last?.tripId !=  tripId {
                                        self.trips.append(tempHomeTrip)
                                    }
                                    else if self.trips.count == 0 {
                                        self.trips.append(tempHomeTrip)
                                    }
                                }
                                completion()
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFollowingIds {
            self.fetchTrips {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let sortedArray = self.trips.sorted { dateFormatter.date(from: $0.startDate)! > dateFormatter.date(from: $1.startDate)! }
                self.trips = sortedArray
                print(self.trips)
                DispatchQueue.main.async {
                    self.homeTableView.reloadData()
                }
            }
        }
    }
    
   
}


extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableHomeCell", for: indexPath) as! HomeTableViewCell
        let trip = trips[indexPath.row]
        cell.tripName.text = trip.tripName
        cell.profileName.text = trip.name
        cell.tripUpvotes.text = "\(trip.upvotes) upvotes"
        cell.tripImage.sd_setImage(with: URL(string: trip.tripProfileImageURL), placeholderImage: UIImage(named: "Paris"))
        cell.profileImage.sd_setImage(with: URL(string: trip.profileImageURL), placeholderImage: UIImage(named: "Paris"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "view_trip_details", sender: self)
        print(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "view_trip_details") {
            let tripViewVC = segue.destination as! TripViewController
            tripViewVC.currentTripID = trips[homeTableView.indexPathForSelectedRow!.row].tripId
            print(trips[homeTableView.indexPathForSelectedRow!.row].tripId)
            tripViewVC.uid = trips[homeTableView.indexPathForSelectedRow!.row].userId
            print(trips[homeTableView.indexPathForSelectedRow!.row].userId)
        }
    }
    
    
}
