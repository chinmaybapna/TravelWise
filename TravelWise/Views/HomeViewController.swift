//
//  HomeViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 15/04/21.
//

import UIKit

class HomeViewController: UIViewController {

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
    @IBOutlet weak var homeTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.dataSource = self
        homeTableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableHomeCell")
        
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableHomeCell", for: indexPath) as! HomeTableViewCell
        let trip = trips[indexPath.row]
        cell.tripName.text = trip["tripName"]
        cell.profileName.text = trip["profileName"]
        cell.tripUpvotes.text = trip["tripUpvotes"]
        cell.tripImage.image = UIImage(named: trip["tripImage"]!)
        cell.profileImage.image = UIImage(named: trip["profileImage"]!)
        return cell
        
    }
    
    
}
