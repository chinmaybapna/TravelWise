//
//  RegisterViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 11/04/21.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var emailTextField: UITextField!  {
        didSet {
            let blackPlaceholderText = NSAttributedString(string: "Email",
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            
            emailTextField.attributedPlaceholder = blackPlaceholderText
        }
    }
    @IBOutlet weak var passwordTextField:  UITextField! {
        didSet {
            let blackPlaceholderText = NSAttributedString(string: "Password",
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            
            passwordTextField.attributedPlaceholder = blackPlaceholderText
        }
    }
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.layer.cornerRadius = 10
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        
        emailTextField.layer.borderWidth = 0.5
        emailTextField.layer.cornerRadius = 5
        emailTextField.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        emailTextField.setLeftPaddingPoints(10)
        emailTextField.setRightPaddingPoints(10)
        
        passwordTextField.layer.borderWidth = 0.5
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        passwordTextField.setLeftPaddingPoints(10)
        passwordTextField.setRightPaddingPoints(10)
        
        nextButton.layer.cornerRadius = 5
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            db.collection("registeredEmails").whereField("email", isEqualTo: email).getDocuments(completion: { (querySnapshot, error) in
                if querySnapshot!.documents.count > 0 {
                    let alert = UIAlertController(title: "Email already in use", message: "", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    if email == "" || password == "" {
                        let alert = UIAlertController(title: "Fields can't be empty", message: "", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
//                        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//                            if error != nil {
//                                print("registration failed.")
//                            }
//                            else {
//                                print("success in creating the user.")
//                            }
//                        }
                        UserDefaults.standard.setValue(email, forKey: "email")
                        UserDefaults.standard.setValue(password, forKey: "password")
                        
                        self.performSegue(withIdentifier: "registration_details", sender: nil)
                    }
                }
            })
        }
    }
}
