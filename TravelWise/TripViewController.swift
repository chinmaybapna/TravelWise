//
//  TripViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 14/04/21.
//

import UIKit
import Firebase
import SDWebImage

class TripViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    let db = Firestore.firestore()
    var dates: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    var tripName: String?
    var tripProfileImageURL: String?
    var currentTripID: String?
    
    @IBOutlet weak var tripProfileImageView: UIImageView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var chooseTripProfileImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        chooseTripProfileImageButton.layer.cornerRadius = 20
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "DayTableViewCell", bundle: nil), forCellReuseIdentifier: "day_cell")
        
        self.tableView.tableFooterView = UIView()
        
        getTripInfo {
            self.db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("trips").document(self.currentTripID!).collection("placesVisited").order(by: "timeStamp").getDocuments { (querySnapshot, error) in
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
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func getTripInfo(getPlacesVisited: @escaping () -> Void) {
        db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("trips").whereField("isCurrentTrip", isEqualTo: true).getDocuments { [self] (querySnapshot, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    self.currentTripID = document.documentID
                    print(self.currentTripID)
                    self.tripName = data["tripName"] as! String
                    self.tripProfileImageURL = data["tripProfileImageURL"] as! String
                    
                    self.tripNameLabel.text = self.tripName
                    self.tripProfileImageView.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: "rowan-heuvel-U6t80TWJ1DM-unsplash"))
                }
                
                getPlacesVisited()
            }
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
    
    
    @IBAction func addImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Choose Photo Source", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction((UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        })))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
}
