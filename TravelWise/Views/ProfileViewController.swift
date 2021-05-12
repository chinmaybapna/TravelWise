//
//  ProfileViewController.swift
//  TravelWise
//
//  Created by Nidhi Bhat G on 29/04/21.
//

import UIKit
import Firebase

class ProfileViewController : UIViewController, UITableViewDataSource {
    
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
        
        tableView.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableHomeCell")
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        
        followersLabel.isUserInteractionEnabled = true
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(showFollowers))
        followersLabel.addGestureRecognizer(tapGesture1)
        
        followingLabel.isUserInteractionEnabled = true
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(showFollowing))
        followingLabel.addGestureRecognizer(tapGesture2)
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
                    let numberOfTrips = data["numberOfTrips"] as! Int
                    
                    self.nameLabel.text = name
                    self.hometownLabel.text = hometown
                    self.profileImageView.sd_setImage(with: URL(string: profileImageURL), placeholderImage: UIImage(named: "atikh-bana-FtBS0p23fcc-unsplash"))
                    self.followersLabel.text = "\(followers)"
                    self.followingLabel.text = "\(following)"
                    self.tripsLabel.text = "\(numberOfTrips)"
                }
            }
        }
        
        db.collection("users").document(uid).collection("trips").getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    let tripName = data["tripName"] as! String
                    let tripProfileImageURL = data["tripProfileImageURL"] as! String
                    let upvotes = data["upvotes"] as! Int
                    
                    let tempTrip = Trip(name: tripName, tripImageURL: tripProfileImageURL, upvotes: upvotes)
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
        cell.tripImage.sd_setImage(with: URL(string: trip.tripImageURL), placeholderImage: UIImage(named: "Paris"))
        return cell
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
    }
}