//
//  EditExperienceViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 13/05/21.
//

import UIKit
import Cosmos
import Firebase

protocol EditExperienceDelegate {
    func updateExperience(description: String, rating: Double)
}

class EditExperienceViewController: UIViewController, UITextViewDelegate {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!
    
    var locationName: String?
    var placeDescription: String?
    var placeID: String?
    var currentTripID: String?
    
    var delegate: EditExperienceDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionTextView.delegate = self
        
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        descriptionTextView.layer.cornerRadius = 5
        
        descriptionTextView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        
        cosmosView.settings.starSize = 30
        cosmosView.settings.starMargin = 10
        
        if let locationName = locationName {
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
                        let rating = data["rating"] as! Double
                        self.cosmosView.rating = rating
                        
                        if description == "" {
                            self.descriptionTextView.text = "No description provided."
                        }
                        else {
                            self.descriptionTextView.text = description
                        }
                        self.descriptionTextView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    }
                }
            }
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true) {
            if let placeID = self.placeID, let description = self.descriptionTextView.text {
                self.db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("trips").document(self.currentTripID!).collection("placesVisited").document(placeID).setData([
                    "description": description,
                    "rating": self.cosmosView.rating
                ], merge: true)
                
                if let delegate = self.delegate {
                    delegate.updateExperience(description: description, rating: self.cosmosView.rating)
                }
            }
        }
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tell us about your experience at this place"
            textView.textColor = UIColor.lightGray
        }
    }
}
