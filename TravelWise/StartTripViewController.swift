//
//  StartTripViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 14/04/21.
//

import UIKit
import Firebase

class StartTripViewController: UIViewController {

    let db = Firestore.firestore()
    
    let date = Date()
    let formatter = DateFormatter()
    
    @IBOutlet weak var tripNameTextField: UITextField!  {
        didSet {
            let blackPlaceholderText = NSAttributedString(string: "Trip name",
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            
            tripNameTextField.attributedPlaceholder = blackPlaceholderText
        }
    }
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.layer.cornerRadius = 10
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        
        tripNameTextField.layer.borderWidth = 0.5
        tripNameTextField.layer.cornerRadius = 5
        tripNameTextField.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        tripNameTextField.setLeftPaddingPoints(10)
        tripNameTextField.setRightPaddingPoints(10)
        
        startButton.layer.cornerRadius = 5
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("trips").whereField("isCurrentTrip", isEqualTo: true).getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                if querySnapshot!.documents.count == 1 {
                    self.performSegue(withIdentifier: "trip_created", sender: nil)
                }
            }
        }
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }

    @IBAction func startButtonPressed(_ sender: Any) {
        formatter.dateFormat = "dd/MM/yyyy"
        if let tripName = tripNameTextField.text {
            db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("trips").addDocument(data: [
                "tripName": tripName,
                "isCurrentTrip": true,
                "tripProfileImageURL": "",
                "startDate": formatter.string(from: date),
                "upvotes": 0,
                "numberOfTrips": FieldValue.increment(Int64(1))
            ])
        }
        
        performSegue(withIdentifier: "trip_created", sender: nil)
    }
}
