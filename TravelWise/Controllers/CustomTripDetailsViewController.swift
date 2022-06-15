//
//  CustomTripDetailsViewController.swift
//  TravelWise
//
//  Created by Nidhi Bhat G on 02/06/22.
//

import UIKit
import RangeSeekSlider

class CustomTripDetailsViewController: UIViewController, RangeSeekSliderDelegate {

    
    @IBOutlet weak var startDateTextField: UITextField! {
        didSet {
            let blackPlaceholderText = NSAttributedString(string: "YYYY-MM-DD",
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            
            startDateTextField.attributedPlaceholder = blackPlaceholderText
        }
    }
    @IBOutlet weak var endDateTextField: UITextField! {
        didSet {
            let blackPlaceholderText = NSAttributedString(string: "YYYY-MM-DD",
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            
            endDateTextField.attributedPlaceholder = blackPlaceholderText
        }
    }
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var rangeSlider: RangeSeekSlider!
    @IBOutlet weak var rangeLabel: UILabel! {
        didSet {
            rangeLabel.text = "$ 5 - $ 999"
        }
    }
    
    private var datePicker : UIDatePicker?
    private var datePicker1 : UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rangeSlider.minLabelFont = UIFont.systemFont(ofSize: 15)
        rangeSlider.maxLabelFont = UIFont.systemFont(ofSize: 15)

        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        startDateTextField.inputView = datePicker
        datePicker?.addTarget(self, action: #selector(startDateChanged(datePicker:)), for: .valueChanged)
        
        datePicker1 = UIDatePicker()
        datePicker1?.datePickerMode = .date
        endDateTextField.inputView = datePicker1
        datePicker1?.addTarget(self, action: #selector(endDateChanged(datePicker1:)), for: .valueChanged)
        
        startDateTextField.layer.borderWidth = 0.5
        startDateTextField.layer.cornerRadius = 5
        startDateTextField.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        startDateTextField.setLeftPaddingPoints(10)
        startDateTextField.setRightPaddingPoints(10)
        
        endDateTextField.layer.borderWidth = 0.5
        endDateTextField.layer.cornerRadius = 5
        endDateTextField.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        endDateTextField.setLeftPaddingPoints(10)
        endDateTextField.setRightPaddingPoints(10)
        
        nextButton.layer.cornerRadius = 5
        
        rangeSlider.delegate = self
        
//        rangeSlider.addTarget(self, action: #selector(rangeChanged(rangeSlider:)), for: UIControl.Event)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        rangeLabel.text = "$ \(rangeSlider.selectedMinValue) - $ \(rangeSlider.selectedMaxValue)"
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    @objc func startDateChanged(datePicker : UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        startDateTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
//    @objc func rangeChanged(rangeSlider: RangeSeekSlider) {
//        rangeLabel.text = "₹ \(rangeSlider.selectedMinValue)- ₹ \(rangeSlider.selectedMaxValue)"
//    }
    
    @objc func endDateChanged(datePicker1 : UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        endDateTextField.text = dateFormatter.string(from: datePicker1.date)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if(startDateTextField.text == "" || endDateTextField.text == "") {
            let alert = UIAlertController(title: "Please choose start date and end date", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        let calendar = Calendar.current
        let fromDate = calendar.startOfDay(for: datePicker!.date)
        let toDate = calendar.startOfDay(for: datePicker1!.date)
        let numberOfDays = calendar.dateComponents([.day], from: fromDate, to: toDate)
        UserDefaults.standard.setValue(startDateTextField.text, forKey: "i_start_date")
        UserDefaults.standard.setValue(startDateTextField.text, forKey: "i_end_date")
        UserDefaults.standard.setValue(numberOfDays.day!+1, forKey: "i_days")
        UserDefaults.standard.setValue(rangeSlider.selectedMinValue, forKey: "i_budget_low")
        UserDefaults.standard.setValue(rangeSlider.selectedMaxValue, forKey: "i_budget_high")
        
        performSegue(withIdentifier: "trip_info_given", sender: self)
    }
}
