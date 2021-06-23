//
//  ProfileViewController.swift
//  TravelWise
//
//  Created by Nidhi Bhat G on 29/04/21.
//

import UIKit
import Firebase

class ProfileViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hometownLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var tripsLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var uid = UserDefaults.standard.string(forKey: "uid")!
    var trips: [Trip] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableHomeCell")
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        
        followersLabel.isUserInteractionEnabled = true
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(showFollowers))
        followersLabel.addGestureRecognizer(tapGesture1)
        
        followingLabel.isUserInteractionEnabled = true
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(showFollowing))
        followingLabel.addGestureRecognizer(tapGesture2)
    }
    
    @IBAction func settingsActions(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
        
        let editProfileAction = UIAlertAction(title: "Edit Profile", style: .default) { (action) in
            self.performSegue(withIdentifier: "editProfileSegue", sender: nil)
        }
        actionSheet.addAction(editProfileAction)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { (action) in
            do {
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "logout_successful", sender: nil)
            }
            catch { print("already logged out") }
        }
        actionSheet.addAction(logoutAction)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.view.tintColor = UIColor.black
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func fetchUserData() {
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
                    if(data["isCurrentTrip"] as! Bool) { continue }
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
    
    override func viewWillAppear(_ animated: Bool) {
        trips = []
        fetchUserData()
    }
    
    @objc
    func showFollowers() {
        performSegue(withIdentifier: "show_followers", sender: nil)
    }
    
    @objc
    func showFollowing() {
        performSegue(withIdentifier: "show_following", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableHomeCell", for: indexPath) as! ProfileTableViewCell
        let trip = trips[indexPath.row]
        cell.tripName.text = trip.name
        cell.tripUpvotes.text = "\(trip.upvotes) upvotes"
        cell.tripImage.sd_setImage(with: URL(string: trip.tripImageURL), placeholderImage: UIImage(named: "defaultTripProfileImage"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "profile_trip_details", sender: self)
        print(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
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
            tripViewVC.uid = self.uid
            tripViewVC.showCurrentTrip = false
//            print(trips[homeTableView.indexPathForSelectedRow!.row].userId)
        }
    }
}
