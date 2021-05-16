//
//  PlacesListContentViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 11/05/21.
//

import UIKit
import Firebase

class PlacesListContentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var date: String?
    let db = Firestore.firestore()
    
    @IBOutlet weak var tableView: UITableView!
    var placesVisited: [PlaceVisited] = []
    var currentTripID: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "PlaceVisitedTableViewCell", bundle: nil), forCellReuseIdentifier: "place_visited_cell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesVisited.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "place_visited_cell", for: indexPath) as! PlaceVisitedTableViewCell
        cell.snoLabel.text = "\(indexPath.row + 1)."
        cell.placeNameLabel.text = placesVisited[indexPath.row].locationName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "show_visit_experience", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "show_visit_experience") {
            let placeExpVC = segue.destination as! PlaceExperienceViewController
            placeExpVC.placeID = placesVisited[tableView.indexPathForSelectedRow!.row].placeID
            placeExpVC.placeName = placesVisited[tableView.indexPathForSelectedRow!.row].locationName
            placeExpVC.currentTripID = self.currentTripID
            placeExpVC.date = self.date
        }
    }
}
