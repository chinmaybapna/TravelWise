//
//  EndTripViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 17/06/21.
//

import UIKit
import Firebase
import RangeSeekSlider

class EndTripViewController: UIViewController {

    @IBOutlet weak var rangeSlider: RangeSeekSlider!
    @IBOutlet weak var shareTrip: UISwitch!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripProfileImageView: UIImageView!
    
    var currentTripID: String?
    var uid = UserDefaults.standard.string(forKey: "uid")
    var tripName: String?
    var tripImageURL: String?
    var tripProfileImageURL: String?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tripNameLabel.text = tripName
        self.tripProfileImageView.sd_setImage(with: URL(string: self.tripProfileImageURL!), placeholderImage: UIImage(named: "rowan-heuvel-U6t80TWJ1DM-unsplash"))
        rangeSlider.minLabelFont = UIFont.systemFont(ofSize: 15)
        rangeSlider.maxLabelFont = UIFont.systemFont(ofSize: 15)
        
    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        var privateTrip = false
        if !shareTrip.isOn {
            privateTrip = true
        }
        self.db.collection("users").document(self.uid!).collection("trips").document(self.currentTripID!).setData([
            "isCurrentTrip": false,
            "minExpenseValue": rangeSlider.selectedMinValue,
            "maxExpenseValue": rangeSlider.selectedMaxValue,
            "privateTrip": privateTrip
        ], merge: true)
        navigationController?.popToRootViewController(animated: false)
    }
}
