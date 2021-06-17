//
//  PlaceExperienceViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 11/05/21.
//

import UIKit
import Firebase
import Cosmos

class PlaceExperienceViewController: UIViewController, EditExperienceDelegate {
    let db = Firestore.firestore()
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cosmosView: CosmosView!
    var uid: String?
    var placeID: String?
    var placeName: String?
    var currentTripID: String?
    var date: String?
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(uid != UserDefaults.standard.string(forKey: "uid")!)
        {
            deleteButton.isHidden = true
            editButton.isHidden = true
        }
        
        if let locationName = placeName {
            addressLabel.text = locationName
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let placeID = placeID, let uid = uid {
            db.collection("users").document(uid).collection("trips").document(self.currentTripID!).collection("placesVisited").document(placeID).getDocument { [self] querySnapshot, error in
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
                        
                        let rating = data["rating"] as! Double
                        self.cosmosView.rating = rating
                        cosmosView.settings.updateOnTouch = false
                    }
                }
            }
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        if let placeID = placeID {
            db.collection("users").document(self.uid!).collection("trips").document(self.currentTripID!).collection("placesVisited").document(placeID).delete { error in
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
    
    func updateExperience(description: String, rating: Double) {
        descriptionLabel.text = description
        cosmosView.rating = rating
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
