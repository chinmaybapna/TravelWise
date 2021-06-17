//
//  EndTripViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 17/06/21.
//

import UIKit
import Firebase
import RangeSeekSlider

class EndTripViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var rangeSlider: RangeSeekSlider!
    @IBOutlet weak var shareTrip: UISwitch!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripProfileImageView: UIImageView!
    @IBOutlet weak var hashtagTextView: UITextView!
    
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
        
        hashtagTextView.delegate = self
        
        hashtagTextView.text = "Add hashtags"
        hashtagTextView.textColor = UIColor.lightGray
        
        hashtagTextView.layer.borderWidth = 0.5
        hashtagTextView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        hashtagTextView.layer.cornerRadius = 5
        
        hashtagTextView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
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
