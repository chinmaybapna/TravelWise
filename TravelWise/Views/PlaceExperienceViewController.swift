//
//  PlaceExperienceViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 11/05/21.
//

import UIKit

class PlaceExperienceViewController: UIViewController {
    
    var placeDescription: String?
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if placeDescription == "" {
            descriptionLabel.text = "No description provided."
        }
        else {
            if let description = placeDescription {
                descriptionLabel.text = description
            }
        }
    }
}
