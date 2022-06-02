//
//  RegisterViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 11/04/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
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
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    let attributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 14),
        .foregroundColor: UIColor.black,
        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
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
        let attributeString = NSMutableAttributedString(
            string: "New to TravelWise? Register now",
            attributes: attributes
        )
        registerButton.setAttributedTitle(attributeString, for: .normal)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            db.collection("registeredEmails").whereField("email", isEqualTo: email).getDocuments(completion: { (querySnapshot, error) in
               if querySnapshot!.documents.count == 0 {
//                if querySnapshot == nil {
              //  if let query = querySnapshot {
            //       if query.documents.count == 0 {
                        let alert = UIAlertController(title: "Account does not exist", message: "No account with the given username exists.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    
                }
                else {
                    if self.emailTextField.text == "" || self.passwordTextField.text == "" {
                        let alert = UIAlertController(title: "Fields can't be empty", message: "", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                            guard self != nil else { return }
                            if error != nil {
                                print("login failed.")
                            }
                            else {
                                print("success in logging in the user.")
                                UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
                                UserDefaults.standard.setValue(Auth.auth().currentUser?.uid, forKey: "uid")
                                self?.performSegue(withIdentifier: "login_successful", sender: nil)
                            }
                        }
                    }
                }
            })
        }
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
