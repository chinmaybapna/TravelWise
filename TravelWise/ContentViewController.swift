//
//  ContentViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 23/04/21.
//

import UIKit
import Cosmos

class ContentViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var cosmosView: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.delegate = self
        
        descriptionTextView.text = "Tell us about your experience at this place"
        descriptionTextView.textColor = UIColor.lightGray
        
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        descriptionTextView.layer.cornerRadius = 5
        
        descriptionTextView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        
        cosmosView.settings.starSize = 30
        cosmosView.settings.starMargin = 10
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tell us about your experience at this place"
            textView.textColor = UIColor.lightGray
        }
    }
}


