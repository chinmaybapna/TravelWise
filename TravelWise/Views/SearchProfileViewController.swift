//
//  SearchProfileViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 10/05/21.
//

import UIKit
import Firebase
import SDWebImage

class SearchProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let db = Firestore.firestore()
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hometownLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var tripsLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var followButton: UIBarButtonItem!
    
    var uid: String?
    var trips: [Trip] = []
    var following = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableHomeCell")
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        trips = []
        if let uid = uid {
            if UserDefaults.standard.string(forKey: "uid") == uid {
                self.navigationItem.rightBarButtonItem = nil
            }
            db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("following").whereField("uid", isEqualTo: uid).getDocuments { [self] (querySnapshot, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    if querySnapshot?.documents.count == 1 {
                        self.followButton.title = "Following"
                        self.following = true
                    }
                }
            }
            
            db.collection("users").document(uid).getDocument { (querySnapshot, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    let data = querySnapshot?.data()
                    
                    if let data = data {
                        let name = data["name"] as! String
                        let hometown = data["hometown"] as! String
                        let profileImageURL = data["profileImageURL"] as! String
                        let followers = data["followers"] as! Int
                        let following = data["following"] as! Int
            
                        self.nameLabel.text = name
                        self.hometownLabel.text = hometown
                        self.profileImageView.sd_setImage(with: URL(string: profileImageURL), placeholderImage: UIImage(named: "defaultProfileImage"))
                        self.followersLabel.text = "\(followers)"
                        self.followingLabel.text = "\(following)"
                    }
                }
            }
            
            db.collection("users").document(uid).collection("trips").getDocuments { (querySnapshot, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    let numberOfTrips = querySnapshot!.documents.count
                    self.tripsLabel.text = "\(numberOfTrips)"
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if( data["isCurrentTrip"] as! Bool || data["privateTrip"] as! Bool ) { continue }
                        let tripID = document.documentID
                        let tripName = data["tripName"] as! String
                        let tripProfileImageURL = data["tripProfileImageURL"] as! String
                        let upvotes = data["upvotes"] as! Int
                        
                        let tempTrip = Trip(name: tripName, tripImageURL: tripProfileImageURL, upvotes: upvotes, tripID: tripID)
                        self.trips.append(tempTrip)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableHomeCell", for: indexPath) as! ProfileTableViewCell
        let trip = trips[indexPath.row]
        cell.tripName.text = trip.name
        cell.tripUpvotes.text = "\(trip.upvotes) upvotes"
        cell.tripImage.sd_setImage(with: URL(string: trip.tripImageURL), placeholderImage: UIImage(named: "Paris"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "profile_trip_details", sender: self)
        print(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func followButtonClicked(_ sender: Any) {
        if let uid = uid {
            if following == false {
                followButton.title = "Following"
                following = true
                self.followersLabel.text = "\(Int(self.followersLabel.text!)! + 1)"
                
                db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("following").document(uid).setData([
                    "uid": uid
                ])
                
                db.collection("users").document(uid).collection("followers").document(UserDefaults.standard.string(forKey: "uid")!).setData([
                    "uid": UserDefaults.standard.string(forKey: "uid")!
                ])
                
                db.collection("users").document(uid).updateData([
                    "followers": FieldValue.increment(Int64(1))
                ])
                
                db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).updateData([
                    "following": FieldValue.increment(Int64(1))
                ])
            }
            else {
                followButton.title = "Follow"
                following = false
                self.followersLabel.text = "\(Int(self.followersLabel.text!)! - 1)"
                
                db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("following").document(uid).delete()
                
                db.collection("users").document(uid).collection("followers").document(UserDefaults.standard.string(forKey: "uid")!).delete()
                
                db.collection("users").document(uid).updateData([
                    "followers": FieldValue.increment(Int64(-1))
                ])
                
                db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).updateData([
                    "following": FieldValue.increment(Int64(-1))
                ])
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "show_followers") {
            let ffVC = segue.destination as! FollowersFollowingViewController
            ffVC.showFollowers = true
            ffVC.showFollowing = false
        }
        
        if(segue.identifier == "show_following") {
            let ffVC = segue.destination as! FollowersFollowingViewController
            ffVC.showFollowers = false
            ffVC.showFollowing = true
        }
        
        if(segue.identifier == "profile_trip_details") {
            let tripViewVC = segue.destination as! TripViewController
            tripViewVC.currentTripID = trips[tableView.indexPathForSelectedRow!.row].tripID
//            print(trips[homeTableView.indexPathForSelectedRow!.row].tripID)
            tripViewVC.uid = self.uid!
            tripViewVC.showCurrentTrip = false
//            print(trips[homeTableView.indexPathForSelectedRow!.row].userId)
        }
    }
}
