//
//  PlanDetailedDisplayViewController.swift
//  TravelWise
//
//  Created by Nidhi Bhat G on 02/06/22.
//

import UIKit
import MapKit

class PlanDetailedDisplayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var detailTableView: UITableView!
    
    var morningDetail: DayDetail?
    var eveningDetail: DayDetail?

    override func viewDidLoad() {
        super.viewDidLoad()

        detailTableView.delegate = self
        detailTableView.dataSource = self
        
        detailTableView.tableFooterView = UIView()
        detailTableView.register(UINib(nibName: "TripSuggestionsTableViewCell", bundle: nil), forCellReuseIdentifier: "day_detail_cell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "day_detail_cell", for: indexPath) as! TripSuggestionsTableViewCell
        cell.selectionStyle = .none
        
        if(indexPath.row == 0) {
            cell.timeofday.text = "Morning"
            cell.name.text = morningDetail!.name
            cell.price.text = "$ \(morningDetail!.price)"
            cell.category.text = morningDetail!.category
            cell.ratingStars.rating = morningDetail!.rating
            cell.ratingStars.settings.updateOnTouch = false
            
            let annotation = MKPointAnnotation()
            annotation.title = morningDetail!.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: morningDetail!.lat , longitude: morningDetail!.long )
            cell.mapView.addAnnotation(annotation)
            let mapCoordinates = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 2500, longitudinalMeters: 2500)
            cell.mapView.setRegion(mapCoordinates, animated: true)
        }
        else {
            cell.timeofday.text = "Evening"
            cell.name.text = eveningDetail!.name
            cell.price.text = "$ \(eveningDetail!.price)"
            cell.category.text = eveningDetail!.category
            cell.ratingStars.rating = eveningDetail!.rating
            cell.ratingStars.settings.updateOnTouch = false
            
            let annotation = MKPointAnnotation()
            annotation.title = eveningDetail!.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: eveningDetail!.lat , longitude: eveningDetail!.long )
            cell.mapView.addAnnotation(annotation)
            let mapCoordinates = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 2500, longitudinalMeters: 2500)
            cell.mapView.setRegion(mapCoordinates, animated: true)
        }
        return cell
    }
}
