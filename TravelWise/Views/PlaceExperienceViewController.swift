//
//  PlaceExperienceViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 11/05/21.
//

import UIKit
import Firebase

class PlaceExperienceViewController: UIViewController, EditExperienceDelegate {
    
    let db = Firestore.firestore()
    
    var uid: String?
    var placeID: String?
    var placeName: String?
    var currentTripID: String?
    var date: String?
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let locationName = placeName {
            addressLabel.text = locationName
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let placeID = placeID {
            db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("trips").document(self.currentTripID!).collection("placesVisited").document(placeID).getDocument { querySnapshot, error in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    let data = querySnapshot?.data()
                    
                    if let data = data {
                        let description = data["description"] as! String
                        
                        if description == "" {
                            self.descriptionLabel.text = "No description provided."
                        }
                        else {
                            self.descriptionLabel.text = description
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        if let placeID = placeID {
            db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("trips").document(self.currentTripID!).collection("placesVisited").document(placeID).delete { error in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    self.dismiss(animated: true) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
                    }
                }
            }
        }
    }
    
    func updateExperience(description: String) {
        descriptionLabel.text = description
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let editExpVC = segue.destination as! EditExperienceViewController
        editExpVC.locationName = self.placeName
        editExpVC.placeID = self.placeID
        editExpVC.currentTripID = self.currentTripID
        
        editExpVC.delegate = self
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
    }
}
