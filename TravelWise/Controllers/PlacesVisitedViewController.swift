//
//  PlacesVisitedViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 11/05/21.
//

import UIKit
import FloatingPanel
import Firebase
import MapKit

class PlacesVisitedViewController: UIViewController, FloatingPanelControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var date: String?
    var currentTripID: String?
    var showCurrentTrip = false
    
    var uid = UserDefaults.standard.string(forKey: "uid")!

    var placesVisited: [PlaceVisited] = []
    
    let db = Firestore.firestore()

    var fpc: FloatingPanelController!
    
    var distanceSpan: CLLocationDistance = 5000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        placesVisited = []
        self.fetchPlacesVisited {
            self.setDistanceSpan {
                self.createAnnotations {
                    self.zoomLevel(location: self.middlePointOfListMarkers(placesList: self.placesVisited))
                    self.fpc = FloatingPanelController()
                    self.fpc.delegate = self
                    let placesVisitedVC = self.storyboard?.instantiateViewController(identifier: "places_list_vc") as! PlacesListContentViewController
                    placesVisitedVC.date = self.date
                    placesVisitedVC.placesVisited = self.placesVisited
                    placesVisitedVC.currentTripID = self.currentTripID
                    placesVisitedVC.uid = self.uid
                    self.fpc.set(contentViewController: placesVisitedVC)
                    self.fpc.addPanel(toParent: self)
                }
            }
        }
    }
    
    @objc func reload() {
        placesVisited = []
        self.fetchPlacesVisited {
            self.setDistanceSpan {
                if(self.placesVisited.count == 0) {
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.createAnnotations {
                        self.zoomLevel(location: self.middlePointOfListMarkers(placesList: self.placesVisited))
                        let placesVisitedVC = self.storyboard?.instantiateViewController(identifier: "places_list_vc") as! PlacesListContentViewController
                        placesVisitedVC.date = self.date
                        placesVisitedVC.placesVisited = self.placesVisited
                        placesVisitedVC.currentTripID = self.currentTripID
                        placesVisitedVC.uid = self.uid
                        self.fpc.set(contentViewController: placesVisitedVC)
                        self.fpc.addPanel(toParent: self)
                    }
                }
            }
        }
    }
    
    func zoomLevel(location: CLLocation) {
        let mapCoordinates = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distanceSpan, longitudinalMeters: distanceSpan)
        mapView.setRegion(mapCoordinates, animated: true)
    }
    
    func createAnnotations(completion: @escaping () -> ()) {
        for location in placesVisited {
            let annotation = MKPointAnnotation()
            annotation.title = location.locationName
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.lat , longitude: location.long )
            mapView.addAnnotation(annotation)
        }
        completion()
    }
    
    func fetchPlacesVisited(completion: @escaping () -> ()) {
        if let currentTripID = self.currentTripID, let date = self.date {
            self.db.collection("users").document(self.uid).collection("trips").document(currentTripID).collection("placesVisited").whereField("date", isEqualTo: date).getDocuments { [self] (querySnapshot, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        
                        let placeID = document.documentID
                        let latitude = data["lat"] as! Double
                        let longitude = data["long"] as! Double
                        let locationName = data["locationName"] as! String
                        let description = data["description"] as! String
                        
                        let placeVisited = PlaceVisited(placeID: placeID, lat: latitude, long: longitude, locationName: locationName, description: description)
                        placesVisited.append(placeVisited)
                    }
                    completion()
//                    print(placesVisited)
                }
            }
        }
    }
    
    func getCurrentTripID(completion: @escaping () -> ()) {
        if(showCurrentTrip) {
            db.collection("users").document(self.uid).collection("trips").whereField("isCurrentTrip", isEqualTo: true).getDocuments { [self] (querySnapshot, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    for document in querySnapshot!.documents {
                        self.currentTripID = document.documentID
                        print(self.currentTripID)
                    }
                }
            }
        }
        completion()
    }
    
    func degreeToRadian(angle:CLLocationDegrees) -> CGFloat {
        return (  (CGFloat(angle)) / 180.0 * CGFloat(Double.pi)  )
    }

    //        /** Radians to Degrees **/
    func radianToDegree(radian:CGFloat) -> CLLocationDegrees {
        return CLLocationDegrees(  radian * CGFloat(180.0 / Double.pi)  )
    }

    func middlePointOfListMarkers(placesList: [PlaceVisited]) -> CLLocation {

        var x = 0.0 as CGFloat
        var y = 0.0 as CGFloat
        var z = 0.0 as CGFloat

        for coordinate in placesList {
            let lat:CGFloat = degreeToRadian(angle: coordinate.lat)
            let lon:CGFloat = degreeToRadian(angle: coordinate.long)
            x = x + cos(lat) * cos(lon)
            y = y + cos(lat) * sin(lon)
            z = z + sin(lat)
        }

        x = x/CGFloat(placesList.count)
        y = y/CGFloat(placesList.count)
        z = z/CGFloat(placesList.count)

        let resultLon: CGFloat = atan2(y, x)
        let resultHyp: CGFloat = sqrt(x*x+y*y)
        let resultLat:CGFloat = atan2(z, resultHyp)

        let newLat = radianToDegree(radian: resultLat)
        let newLon = radianToDegree(radian: resultLon)
        let result:CLLocation = CLLocation(latitude: newLat, longitude: newLon)

        return result

    }
    
    func setDistanceSpan(completion: @escaping () -> ()) {
        if placesVisited.count <= 1 {
            self.distanceSpan = 3000
        }
        else {
            var max: Double = 0
            for i in 0...placesVisited.count-2 {
                for j in i+1...placesVisited.count-1 {
                    let coordinate1 = CLLocation(latitude: placesVisited[i].lat, longitude: placesVisited[i].long)
                    let coordinate2 = CLLocation(latitude: placesVisited[j].lat, longitude: placesVisited[j].long)
                    let dist = coordinate1.distance(from: coordinate2)
                    if dist > max {
                        max = dist
                    }
                }
            }
            self.distanceSpan = max + 0.35*max
        }
        completion()
    }
}
