//
//  TripViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 14/04/21.
//

import UIKit
import Firebase
import SDWebImage
import FirebaseStorage

class TripViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var upvoted = false
    
    var uid = UserDefaults.standard.string(forKey: "uid")!
    let db = Firestore.firestore()
    var dates: [String] = []
    var showCurrentTrip = true
    
    @IBOutlet weak var tableView: UITableView!
    
    var tripName: String?
    var tripProfileImageURL: String?
    var currentTripID: String?
    var delete = false
//    var tripUserID: String?
    
    @IBOutlet weak var upvotesLabel: UILabel!
    @IBOutlet weak var upvotesText: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var endTripButton: UIButton!
    @IBOutlet weak var tripProfileImageView: UIImageView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var chooseTripProfileImageButton: UIButton!
    @IBOutlet weak var expenseInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(showCurrentTrip) {
            upvotesLabel.removeFromSuperview()
            upvoteButton.removeFromSuperview()
            upvotesText.removeFromSuperview()
            expenseInfoLabel.removeFromSuperview()
            tableView.topAnchor.constraint(equalTo: tripNameLabel.bottomAnchor, constant: 30).isActive = true
        }
        
        self.navigationItem.hidesBackButton = true
        chooseTripProfileImageButton.layer.cornerRadius = 20
        endTripButton.layer.cornerRadius = 5
        if(uid != UserDefaults.standard.string(forKey: "uid")! || !showCurrentTrip)
        {
            chooseTripProfileImageButton.isHidden = true
            title = ""
            self.navigationItem.rightBarButtonItem = nil
            navigationItem.hidesBackButton = false
            
            endTripButton.isHidden = true
            endTripButton.isEnabled = false
        }
        
        if(uid == UserDefaults.standard.string(forKey: "uid")! && !showCurrentTrip) {
            let deleteBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteTrip))
            deleteBarButtonItem.tintColor = .white
            self.navigationItem.rightBarButtonItem  = deleteBarButtonItem
            navigationItem.hidesBackButton = false
            self.delete = true
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "DayTableViewCell", bundle: nil), forCellReuseIdentifier: "day_cell")
        
        self.tableView.tableFooterView = UIView()
    }
    
    @objc func deleteTrip() {
        self.db.collection("users").document(self.uid).collection("trips").document(self.currentTripID!).delete { error in
            if(error != nil) {
                print("erorr in deleting the document")
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dates = []
        getTripInfo {
            self.db.collection("users").document(self.uid).collection("trips").document(self.currentTripID!).collection("placesVisited").order(by: "timeStamp").getDocuments { (querySnapshot, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        
                        let date = data["date"] as! String
                        
                        if self.dates.count > 0 && self.dates.last !=  date {
                            self.dates.append(date)
                        }
                        else if self.dates.count == 0 {
                            self.dates.append(date)
                        }
                    }
                    print(self.dates)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            
            self.db.collection("users").document(self.uid).collection("trips").document(self.currentTripID!).collection("upvotes").whereField("uid", isEqualTo: UserDefaults.standard.string(forKey: "uid")!).getDocuments { (querySnapshot, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    if querySnapshot?.documents.count == 1 {
                        self.upvoteButton.setImage(#imageLiteral(resourceName: "like-3"), for: .normal)
                        self.upvoted = true
                    }
                }
            }
        }
    }
    
    func getTripInfo(getPlacesVisited: @escaping () -> Void) {
        if(showCurrentTrip) {
            db.collection("users").document(self.uid).collection("trips").whereField("isCurrentTrip", isEqualTo: true).getDocuments { [self] (querySnapshot, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        
                        self.currentTripID = document.documentID
                        print(self.currentTripID)
                        self.tripName = data["tripName"] as? String
                        self.tripProfileImageURL = data["tripProfileImageURL"] as? String
                        self.tripNameLabel.text = self.tripName
                        self.tripProfileImageView.sd_setImage(with: URL(string: self.tripProfileImageURL!), placeholderImage: UIImage(named: "rowan-heuvel-U6t80TWJ1DM-unsplash"))
                    }
                    
                    getPlacesVisited()
                }
            }
        }
        else {
            db.collection("users").document(self.uid).collection("trips").document(currentTripID!).getDocument { [self] (querySnapshot, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    let data = querySnapshot!.data()
                    
                    if let data = data {
                        self.currentTripID = querySnapshot!.documentID
                        print(self.currentTripID)
                        self.tripName = data["tripName"] as? String
                        self.tripProfileImageURL = data["tripProfileImageURL"] as? String
                        self.upvotesLabel.text = "\(data["upvotes"] as! Int)"
                        self.tripNameLabel.text = self.tripName
                        self.tripProfileImageView.sd_setImage(with: URL(string: self.tripProfileImageURL!), placeholderImage: UIImage(named: "rowan-heuvel-U6t80TWJ1DM-unsplash"))
                        let minExpense = data["minExpenseValue"] as! Int
                        let maxExpense = data["maxExpenseValue"] as! Int
                        print(minExpense)
                        print(maxExpense)
                        expenseInfoLabel.text = "₹ \(minExpense) - ₹ \(maxExpense)"
                        self.upvotesLabel.text = "\(data["upvotes"] as! Int)"
                        getPlacesVisited()
                    }
                }
            }
        }
    }
    
    @IBAction func upvoteButtonCliked(_ sender: Any) {
        if !upvoted {
            self.db.collection("users").document(self.uid).collection("trips").document(self.currentTripID!).updateData([
                "upvotes": FieldValue.increment(Int64(1))
            ])
            upvotesLabel.text = "\(Int(self.upvotesLabel.text!)! + 1)"
            upvoteButton.setImage(#imageLiteral(resourceName: "like-3"), for: .normal)
            upvoted = true
            self.db.collection("users").document(self.uid).collection("trips").document(self.currentTripID!).collection("upvotes").document(UserDefaults.standard.string(forKey: "uid")!).setData([
                "uid": UserDefaults.standard.string(forKey: "uid")!
            ])
        }
        else {
            self.db.collection("users").document(self.uid).collection("trips").document(self.currentTripID!).updateData([
                "upvotes": FieldValue.increment(Int64(-1))
            ])
            upvotesLabel.text = "\(Int(self.upvotesLabel.text!)! - 1)"
            upvoteButton.setImage(#imageLiteral(resourceName: "like-2"), for: .normal)
            upvoted = false
            self.db.collection("users").document(self.uid).collection("trips").document(self.currentTripID!).collection("upvotes").document(UserDefaults.standard.string(forKey: "uid")!).delete()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "day_cell") as! DayTableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.dayLabel.text = "Day \(indexPath.row + 1)"
        cell.dateLabel.text = dates[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "show_places_visited", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func addImage(_ sender: UIButton) {
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
        guard let coverImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else
        {
            // upload image from here
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        guard let optimizedCoverImage = coverImage.jpegData(compressionQuality: 1) else {
            print("error in covering it to jpegdata")
            return
        }
//        tripProfileImageView.image = coverImage
        uploadTripCoverImage(imageData: optimizedCoverImage)
        picker.dismiss(animated: true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion:nil)
    }
    
    func uploadTripCoverImage(imageData: Data)
        {
            let storageReference = Storage.storage().reference()
            let coverImageRef = storageReference.child("trips").child(uid).child("\(String(describing: currentTripID))-tripCoverImage.jpg")
            let uploadMetaData = StorageMetadata()
            uploadMetaData.contentType = "image/jpeg"
            coverImageRef.putData(imageData, metadata: uploadMetaData) { (uploadedImageMeta, error) in
                if error != nil
                {
                    print("Error took place \(String(describing: error?.localizedDescription))")
                    return
                } else {
                    self.tripProfileImageView.image = UIImage(data: imageData)
                    coverImageRef.downloadURL{ (url, error)  in
                        guard let downloadURL = url else {
                            print(error?.localizedDescription)
                            return
                        }
                    self.db.collection("users").document(self.uid).collection("trips").document(self.currentTripID!).updateData([
                        "tripProfileImageURL": "\(downloadURL)"
                    ])

                    print("Meta data of uploaded image \(String(describing: uploadedImageMeta))")
                }
            }
        }
    }
    
    @IBAction func endTripButtonPressed(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "show_places_visited") {
            let placesVisitedVC = segue.destination as! PlacesVisitedViewController
            placesVisitedVC.date = dates[tableView.indexPathForSelectedRow!.row]
            placesVisitedVC.uid = self.uid
            placesVisitedVC.showCurrentTrip = self.showCurrentTrip
            placesVisitedVC.currentTripID = self.currentTripID
//            let placesListContentVC = PlacesListContentViewController()
//            placesListContentVC.date = dates[tableView.indexPathForSelectedRow!.row]
        }
        
        if(segue.identifier == "end_trip") {
            let endTripVC = segue.destination as! EndTripViewController
            endTripVC.currentTripID = self.currentTripID
            endTripVC.tripName = self.tripName
            endTripVC.tripProfileImageURL = self.tripProfileImageURL
        }
    }
}
