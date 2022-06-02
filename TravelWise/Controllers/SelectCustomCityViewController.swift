//
//  SelectCustomCityViewController.swift
//  TravelWise
//
//  Created by Nidhi Bhat G on 30/05/22.
//

import UIKit

class SelectCustomCityViewController: UIViewController {


    @IBOutlet weak var cityNameTextField: UITextField! {
        didSet {
            let blackPlaceholderText = NSAttributedString(string: "Enter city name",
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            
            cityNameTextField.attributedPlaceholder = blackPlaceholderText
        }
    }
    
    @IBOutlet weak var nextButton: UIButton!
    override func viewDidLoad() {
         super.viewDidLoad()
        
         cityNameTextField.layer.borderWidth = 0.5
         cityNameTextField.layer.cornerRadius = 5
         cityNameTextField.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
         cityNameTextField.setLeftPaddingPoints(10)
         cityNameTextField.setRightPaddingPoints(10)
         
         nextButton.layer.cornerRadius = 5
         
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
         view.addGestureRecognizer(tapGesture)

         // Do any additional setup after loading the view.
     }
    @objc func viewTapped() {
        view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
