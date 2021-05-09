//
//  ProfileViewController.swift
//  TravelWise
//
//  Created by Nidhi Bhat G on 29/04/21.
//

import UIKit

class ProfileViewController : UIViewController{
    
    var trips = [
        [   "profileImage": "christopher-campbell-rDEOVtE7vOs-unsplash" , "profileName" : "Nidhi Bhat G", "tripImage" : "Paris" , "tripName" : "Summer time at Paris", "tripUpvotes" : "1678 upvotes"
        ],
        [   "profileImage": "atikh-bana-FtBS0p23fcc-unsplash" , "profileName" : "Nidhi Bhat G", "tripImage" : "pantheon-rome-dome-635x422" , "tripName" : "France trip with friends", "tripUpvotes" : "1231 upvotes"
        ],
        [   "profileImage": "clayton-cardinalli-ZqmmwcE1DQ8-unsplash" , "profileName" : "Nidhi Bhat G", "tripImage" : "rowan-heuvel-U6t80TWJ1DM-unsplash" , "tripName" : "Beach days in Australia", "tripUpvotes" : "1534 upvotes"
        ],
        [   "profileImage": "dave-goudreau-bB_zWnlenwQ-unsplash" , "profileName" : "Nidhi Bhat G", "tripImage" : "HERO_UltimateRome_Hero_shutterstock789412159" , "tripName" : "Work trip to Rome turned into vacation", "tripUpvotes" : "5322 upvotes"
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
        profileTableView.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableHomeCell")
        userProfileImage.image = UIImage(named: "christopher-campbell-rDEOVtE7vOs-unsplash")
        userProfileImage.layer.cornerRadius = userProfileImage.frame.size.height / 2
        userProfileName.text = "Nidhi Bhat"
        userProfilePlace.text = "Bangalore"
        tripsLabel.text = "12"
        followersLabel.text = "1K"
        followingLabel.text = "245"
    }
    
}

extension ProfileViewController :UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableHomeCell", for: indexPath) as! ProfileTableViewCell
        let trip = trips[indexPath.row]
        cell.tripName.text = trip["tripName"]
        cell.tripUpvotes.text = trip["tripUpvotes"]
        cell.tripImage.image = UIImage(named: trip["tripImage"]!)
        return cell
    }
    
    
}
