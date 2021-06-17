//
//  MapViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 23/04/21.
//

import UIKit
import FloatingPanel
import MapKit
import CoreLocation
import Firebase

class MapViewController: UIViewController, FloatingPanelControllerDelegate, UISearchBarDelegate {
    
    var fpc: FloatingPanelController!
    @IBOutlet private var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 500
    var previousLocation: CLLocation?
    @IBOutlet weak var searchBar: UISearchBar!
    
    var uid = UserDefaults.standard.string(forKey: "uid")!

    var currentLocation: String?
    var lat: Double?
    var long: Double?
    
    var currentTripID: String?
    
    let db = Firestore.firestore()
    
    let date = Date()
    let formatter = DateFormatter()
    
    var desc: String = ""
    var rating: Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        mapView.delegate = self
        searchBar.delegate = self
        checkLocationServices()
        
        fpc = FloatingPanelController()
        fpc.delegate = self
        let contentVC = storyboard?.instantiateViewController(identifier: "content_vc") as! ContentViewController
        fpc.set(contentViewController: contentVC)
        fpc.addPanel(toParent: self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setDescription),
                                               name: Notification.Name("DescriptionChanged"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setRating),
                                               name: Notification.Name("RatingChanged"),
                                               object: nil)
    }
    
    @objc func setDescription(notification: NSNotification) {
        if let dict = notification.object as? NSDictionary {
            if let desc = dict["description"] as? String {
                print(desc)
                self.desc = desc
            }
        }
    }

    @objc func setRating(notification: NSNotification) {
        if let dict = notification.object as? NSDictionary {
            if let rating = dict["rating"] as? Int {
                print(rating)
                self.rating = rating
            }
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
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
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        formatter.dateFormat = "dd/MM/yyyy"
        let currentDate = formatter.string(from: date)

        if let lat = self.lat, let long = self.long, let locationName = self.currentLocation {
            db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("trips").document(currentTripID!).collection("placesVisited").document().setData([
                "locationName": locationName,
                "lat": lat,
                "long": long,
                "rating": rating,
                "description": desc,
                "date": currentDate,
                "timeStamp": Date()
            ])

            navigationController?.popViewController(animated: true)
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTackingUserLocation()
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    
    func startTackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        self.lat = latitude
        self.long = longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        print("SEARCH BITCHES")
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { response, error in
            if response == nil {
                let alert = UIAlertController(title: "Invalid search", message: "Please enter a valid place name", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                
                let lat = response?.boundingRegion.center.latitude
                let long = response?.boundingRegion.center.longitude
                
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                self.mapView.addAnnotation(annotation)
                
                let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: self.regionInMeters, longitudinalMeters: self.regionInMeters)
                self.mapView.setRegion(region, animated: true)
            }
        }
        searchBar.endEditing(true)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}


extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        
//        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard self != nil else { return }
            
            if let _ = error {
                //TODO: Show alert informing the user
                return
            }
            
            guard let placemark = placemarks?.first else {
                //TODO: Show alert informing the user
                return
            }
            
            let name = placemark.name
            
            DispatchQueue.main.async {
                if let name = name {
                    self?.currentLocation = name
                    print("==========\(name)==========")
                    let contentVC = self?.storyboard?.instantiateViewController(identifier: "content_vc") as! ContentViewController
                    contentVC.locationName = name
                    self!.fpc.set(contentViewController: contentVC)
                    self!.fpc.addPanel(toParent: self!)
                }
            }
        }
    }
}
