//
//  RegistrationDetailsViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 12/04/21.
//

import UIKit
import Firebase

class RegistrationDetailsViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var nameTextField: UITextField!  {
        didSet {
            let blackPlaceholderText = NSAttributedString(string: "Name",
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            
            nameTextField.attributedPlaceholder = blackPlaceholderText
        }
    }
    @IBOutlet weak var dobTextField:  UITextField! {
        didSet {
            let blackPlaceholderText = NSAttributedString(string: "Date of Birth",
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            
            dobTextField.attributedPlaceholder = blackPlaceholderText
        }
    }
    @IBOutlet weak var hometownTextField:  UITextField! {
        didSet {
            let blackPlaceholderText = NSAttributedString(string: "Hometown",
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            
            hometownTextField.attributedPlaceholder = blackPlaceholderText
        }
    }
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    private var datePicker : UIDatePicker?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        dobTextField.inputView = datePicker
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
        containerView.layer.cornerRadius = 10
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        
        nameTextField.layer.borderWidth = 0.5
        nameTextField.layer.cornerRadius = 5
        nameTextField.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        nameTextField.setLeftPaddingPoints(10)
        nameTextField.setRightPaddingPoints(10)
        
        dobTextField.layer.borderWidth = 0.5
        dobTextField.layer.cornerRadius = 5
        dobTextField.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        dobTextField.setLeftPaddingPoints(10)
        dobTextField.setRightPaddingPoints(10)
        
        hometownTextField.layer.borderWidth = 0.5
        hometownTextField.layer.cornerRadius = 5
        hometownTextField.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        hometownTextField.setLeftPaddingPoints(10)
        hometownTextField.setRightPaddingPoints(10)
        
        registerButton.layer.cornerRadius = 5
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker : UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dobTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        Auth.auth().createUser(withEmail: UserDefaults.standard.string(forKey: "email")!, password: UserDefaults.standard.string(forKey: "password")!) { (authResult, error) in
            if error != nil {
                print("registration failed.")
                let alert = UIAlertController(title: "Registration Failed", message: error?.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                print("success in creating the user.")
                if let name = self.nameTextField.text, let dob = self.dobTextField.text, let hometown = self.hometownTextField.text, let uid = Auth.auth().currentUser?.uid {
                    
                    self.db.collection("registeredEmails").addDocument(data: [
                        "email": UserDefaults.standard.string(forKey: "email")!
                    ])
                    
                    self.db.collection("users").document(uid).setData([
                        "name": name,
                        "dob": dob,
                        "hometown": hometown,
                        "uid": uid,
                        "followers": 0,
                        "following": 0,
                        "numberOfTrips": 0,
                        "profileImageURL": ""
                    ])
                }
            }
        }
    }
}
