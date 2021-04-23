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
    
    var days = ["Day 1", "Day 2", "Day 3", "Day 4", "Day 5"]
    var dates = ["22/04/2021", "23/04/2021", "24/04/2021", "25/04/2021", "26/04/2021"]
    
    @IBOutlet weak var tableView: UITableView!
    
    var tripName: String?
    var tripProfileImageURL: String?
    

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("trips").whereField("isCurrentTrip", isEqualTo: true).getDocuments { [self] (querySnapshot, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    self.tripName = data["tripName"] as! String
                    self.tripProfileImageURL = data["tripProfileImageURL"] as! String
                    
                    self.tripNameLabel.text = self.tripName
                    self.tripProfileImageView.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: "Paris"))
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "day_cell") as! DayTableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.dayLabel.text = days[indexPath.row]
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
