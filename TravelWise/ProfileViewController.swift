//
//  ProfileViewController.swift
//  TravelWise
//
//  Created by Nidhi Bhat G on 29/04/21.
//

import UIKit

class ProfileViewController : UIViewController{
    
    var trips = [
        [   "profileImage": "ProfileImage" , "profileName" : "Nidhi Bhat G", "tripImage" : "Paris" , "tripName" : "Summer time at Paris", "tripUpvotes" : "1678 upvotes"
        ],
        [   "profileImage": "ProfileImage" , "profileName" : "Nidhi Bhat G", "tripImage" : "Paris" , "tripName" : "Summer time at Paris", "tripUpvotes" : "1678 upvotes"
        ],
        [   "profileImage": "ProfileImage" , "profileName" : "Nidhi Bhat G", "tripImage" : "Paris" , "tripName" : "Summer time at Paris", "tripUpvotes" : "1678 upvotes"
        ],
        [   "profileImage": "ProfileImage" , "profileName" : "Nidhi Bhat G", "tripImage" : "Paris" , "tripName" : "Summer time at Paris", "tripUpvotes" : "1678 upvotes"
        ]
    ]
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userProfileName: UILabel!
    @IBOutlet weak var userProfilePlace: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var tripsLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var profileTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileTableView.dataSource = self
        profileTableView.register(UINib(nibName: "HomeAndProfileCell", bundle: nil), forCellReuseIdentifier: "ReusableHomeCell")
        userProfileImage.image = UIImage(named: "Chinmay")
        userProfileImage.layer.cornerRadius = userProfileImage.frame.size.height / 2
        userProfileName.text = "Chinmay Bapna"
        userProfilePlace.text = "Udaipur"
        tripsLabel.text = "120"
        followersLabel.text = "1K"
        followingLabel.text = "245"
    }
    
}

extension ProfileViewController :UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableHomeCell", for: indexPath) as! HomeAndProfileCell
        let trip = trips[indexPath.row]
        cell.tripName.text = trip["tripName"]
        cell.profileName.text = trip["profileName"]
        cell.tripUpvotes.text = trip["tripUpvotes"]
        cell.tripImage.image = UIImage(named: trip["tripImage"]!)
        cell.profileImage.image = UIImage(named: trip["profileImage"]!)
        return cell
    }
    
    
}
