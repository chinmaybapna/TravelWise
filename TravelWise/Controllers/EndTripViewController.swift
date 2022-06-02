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
    
    let formatter = DateFormatter()

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
    var name = ""
    var profileImageURL = ""
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        db.collection("users").document(self.uid!).getDocument { q, e in
            if e != nil {
                print(e!.localizedDescription)
            } else {
                let udata = q!.data()
                self.name = udata!["name"] as! String
                self.profileImageURL = udata!["profileImageURL"] as! String
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        tripNameLabel.text = tripName
        self.tripProfileImageView.sd_setImage(with: URL(string: self.tripProfileImageURL!), placeholderImage: UIImage(named: "defaultTripProfileImage"))
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
        let hashtagText = hashtagTextView.text as String? ?? ""
        let hashtags = hashtagText.components(separatedBy: "#")
        let trimmedTags = hashtags.map { $0.trimmingCharacters(in: .whitespaces) }
        var tagSet = Set<String>()
        var flag = true
        for tag in trimmedTags {
            let arr = tag.components(separatedBy: " ")
            if(arr.count > 1)
            {
                flag = false
                let alert = UIAlertController(title: "Invalid Tags", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                break
            } else if(arr[0] == ""){
                continue
            }else {
                tagSet.insert(arr[0].lowercased())
            }
        }
        print(tagSet)
        if(flag)
        {
            for tag in tagSet {
                self.db.collection("searchPlacesTags").document("tags").collection(tag).document(self.currentTripID!).setData([
                    "uid": self.uid!,
                    "tripID": self.currentTripID!,
                    "timeStamp": Date(),
                    "name": self.name,
                    "profileImageURL": self.profileImageURL
                ])
            }
        }
        
        self.db.collection("users").document(self.uid!).collection("trips").document(self.currentTripID!).setData([
            "isCurrentTrip": false,
            "minExpenseValue": rangeSlider.selectedMinValue,
            "maxExpenseValue": rangeSlider.selectedMaxValue,
            "privateTrip": privateTrip
        ], merge: true)
        navigationController?.popToRootViewController(animated: false)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add hashtags"
            textView.textColor = UIColor.lightGray
        }
    }
}
