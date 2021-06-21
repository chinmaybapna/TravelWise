//
//  EditProfileViewController.swift
//  TravelWise
//
//  Created by Nidhi Bhat G on 18/06/21.
//

import UIKit
import Firebase
import SDWebImage
import FirebaseStorage

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let db = Firestore.firestore()
    var uid = UserDefaults.standard.string(forKey: "uid")!
    
    var name = ""
    var dob = ""
    var hometown = ""
    
    @IBOutlet weak var profileImage: UIImageView! 
    @IBOutlet weak var nameTextField: UITextField!{
        didSet {
            let blackPlaceholderText = NSAttributedString(string: "Name",
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            
            nameTextField.attributedPlaceholder = blackPlaceholderText
        }
    }
    @IBOutlet weak var dobTextField: UITextField! {
        didSet {
            let blackPlaceholderText = NSAttributedString(string: "Date of Birth",
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            
            dobTextField.attributedPlaceholder = blackPlaceholderText
        }
    }
    @IBOutlet weak var hometownTextField: UITextField! {
        didSet {
            let blackPlaceholderText = NSAttributedString(string: "Hometown",
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            
            hometownTextField.attributedPlaceholder = blackPlaceholderText
        }
    }
    
    private var datePicker : UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        dobTextField.inputView = datePicker
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        
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
    }
    
    @objc func dateChanged(datePicker : UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dobTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    func fetchUserData()
    {
        db.collection("users").document(uid).getDocument { (querySnapshot, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                let data = querySnapshot?.data()
                if let data = data {
                    self.name = data["name"] as! String
                    self.hometown = data["hometown"] as! String
                    let profileImageURL = data["profileImageURL"] as! String
                    self.dob = data["dob"] as! String
                    self.nameTextField.text = self.name
                    self.dobTextField.text = self.dob
                    self.hometownTextField.text = self.hometown
                    self.profileImage.sd_setImage(with: URL(string: profileImageURL), placeholderImage: UIImage(named: "atikh-bana-FtBS0p23fcc-unsplash"))
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchUserData()
    }
    

    @IBAction func editProfileImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Choose Photo Source", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            imagePickerController.sourceType = .camera
            imagePickerController.cameraCaptureMode = .photo
            imagePickerController.modalPresentationStyle = .fullScreen
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction((UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        })))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        guard let profileImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else
        {
            // upload image from here
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        guard let optimizedProfileImage = profileImage.jpegData(compressionQuality: 1) else {
            print("error in covering it to jpegdata")
            return
        }
//        tripProfileImageView.image = coverImage
        uploadProfileImage(imageData: optimizedProfileImage)
        picker.dismiss(animated: true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion:nil)
    }
    
    func uploadProfileImage(imageData: Data)
    {
            let storageReference = Storage.storage().reference()
            let profileImageRef = storageReference.child("users").child(uid).child("\(String(describing: uid))-profileImage.jpg")
            let uploadMetaData = StorageMetadata()
            uploadMetaData.contentType = "image/jpeg"
            profileImageRef.putData(imageData, metadata: uploadMetaData) { (uploadedImageMeta, error) in
                if error != nil
                {
                    print("Error took place \(String(describing: error?.localizedDescription))")
                    return
                } else {
                    self.profileImage.image = UIImage(data: imageData)
                    profileImageRef.downloadURL{ (url, error)  in
                        guard let downloadURL = url else {
                            print(error?.localizedDescription)
                            return
                        }
                    self.db.collection("users").document(self.uid).updateData([
                        "profileImageURL": "\(downloadURL)"
                    ])

                    print("Meta data of uploaded image \(String(describing: uploadedImageMeta))")
                }
            }
        }
    }
    
    @IBAction func finishEditProfile(_ sender: Any) {
        if self.nameTextField.text == "" || self.hometownTextField.text == "" || self.dobTextField.text == "" {
            let alert = UIAlertController(title: "Fields can't be empty", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        } else {
        db.collection("users").document(self.uid).updateData([
            "name": nameTextField.text as String? ?? self.name,
            "hometown": hometownTextField.text as String? ?? hometown,
            "dob" : dobTextField.text as String? ?? dob
        ])
            self.performSegue(withIdentifier: "finishEditProfile", sender: nil)
        }
    }
}
