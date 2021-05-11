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
    
    var placesVisited: [PlaceVisited] = []
    
    let db = Firestore.firestore()

    var fpc: FloatingPanelController!
    
    let distanceSpan: CLLocationDistance = 5000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fpc = FloatingPanelController()
        fpc.delegate = self
        let placesVisitedVC = storyboard?.instantiateViewController(identifier: "places_list_vc") as! PlacesListContentViewController
        fpc.set(contentViewController: placesVisitedVC)
        fpc.addPanel(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getCurrentTripID {
            self.fetchPlacesVisited {
                self.createAnnotations {
                    self.zoomLevel(location: self.middlePointOfListMarkers(placesList: self.placesVisited))
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
            self.db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("trips").document(currentTripID).collection("placesVisited").whereField("date", isEqualTo: date).getDocuments { [self] (querySnapshot, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        
                        let latitude = data["lat"] as! Double
                        let longitude = data["long"] as! Double
                        let locationName = data["locationName"] as! String
                        
                        let placeVisited = PlaceVisited(lat: latitude, long: longitude, locationName: locationName)
                        placesVisited.append(placeVisited)
                    }
                    completion()
                    print(placesVisited)
                }
            }
        }
    }
    
    func getCurrentTripID(completion: @escaping () -> ()) {
        db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("trips").whereField("isCurrentTrip", isEqualTo: true).getDocuments { [self] (querySnapshot, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                for document in querySnapshot!.documents {
                    self.currentTripID = document.documentID
                    print(self.currentTripID)
                }
                
                completion()
            }
        }
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
}
