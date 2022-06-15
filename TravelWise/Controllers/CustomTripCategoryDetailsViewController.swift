//
//  CustomTripCategoryDetailsViewController.swift
//  TravelWise
//
//  Created by Nidhi Bhat G on 02/06/22.
//

import UIKit
import Alamofire
import SwiftyJSON

class CustomTripCategoryDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    var vSpinner : UIView?
    
    var dayDetails: [DayDetail] = []
    var selectedCells: [Int] = []
    var cats: [String] = ["tours_&_sightseeing", "food,_wine_&_nightlife", "outdoor_activities", "walking_&_biking_tours", "cultural_&_theme_tours", "day_trips_&_excursions", "cruises,_sailing_&_water_tours", "multi-day_&_extended_tours", "luxury_&_special_occasions", "air,_helicopter_&_balloon_tours", "holiday_&_seasonal_tours", "shows,_concerts_&_sports", "classes_&_workshops", "private_&_custom_tours", "recommended_experiences"]
    
    var categories: [String] = []
    var rating: [String: Float] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        categoryTableView.tableFooterView = UIView()
        categoryTableView.register(UINib(nibName: "TripCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "category_cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for category in cats {
            var cat = ""
            let categoryArr = category.components(separatedBy: "_")
            for word in categoryArr {
                cat += word + " "
            }
            cat = cat.trimmingCharacters(in: .whitespacesAndNewlines)
            cat = cat.capitalized(with: NSLocale.current)
            
            categories.append(cat)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "category_cell", for: indexPath) as! TripCategoryTableViewCell
        if(selectedCells.contains(indexPath.row)) {
            cell.accessoryType = .checkmark
        }
        cell.categoryLabel.text = categories[indexPath.row]
        cell.categoryImageView.image = UIImage(named: cats[indexPath.row])
        cell.selectionStyle = .none
        cell.tintColor = .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
            
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if cell.accessoryType == .checkmark {
                if(selectedCells.contains(indexPath.row)) {
                    let indx = selectedCells.firstIndex(of: indexPath.row)
                    selectedCells.remove(at: indx!)
                }
                cell.accessoryType = .none
            }
            else{
                cell.accessoryType = .checkmark
                selectedCells.append(indexPath.row)
            }
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if selectedCells.count < 5 {
            let alert = UIAlertController(title: "Please select at least 5 categories", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        self.showSpinner(onView: self.view)
        
        for i in selectedCells {
            rating[cats[i]] = 5.0
        }
        
        var rangeChanged = false
        
        let url = "http://127.0.0.1:8888/getPlaces"
        let parameters : [String: Any] = [
            "name": "Nidhi",
            "province": UserDefaults.standard.string(forKey: "i_city")!,
            "begin_date": UserDefaults.standard.string(forKey: "i_start_date")!,
            "end_date": UserDefaults.standard.string(forKey: "i_end_date")!,
            "days": UserDefaults.standard.integer(forKey: "i_days"),
            "budget_low": UserDefaults.standard.integer(forKey: "i_budget_low"),
            "budget_high": UserDefaults.standard.integer(forKey: "i_budget_high"),
            "cat_rating": rating
        ]
        AF.request(URL(string: url)!, method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default).responseString { (response) in
            if let data = response.data {
                let json = try! JSON(data: data)
                var range = json["timeofday"].count-1
                if(range > json["name"].count-1) {
                    range = json["name"].count-1
                    rangeChanged = true
                }
                for i in 0...range {
                    let timeofday = json["timeofday"][i].string!
                    
                    var name = json["name"][i].string!
                    let nameArr = name.components(separatedBy: "_")
                    name = ""
                    for word in nameArr {
                        name += word + " "
                    }
                    name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    name = name.capitalized(with: NSLocale.current)
                    
                    var category = json["category"][i].string!
                    let categoryArr = category.components(separatedBy: "_")
                    category = ""
                    for word in categoryArr {
                        category += word + " "
                    }
                    category = category.trimmingCharacters(in: .whitespacesAndNewlines)
                    category = category.capitalized(with: NSLocale.current)
                    
                    let rating = json["rating"][i].double!
                    let price = json["price"][i].float!
                    let lat = json["location"][i][0].double!
                    let long = json["location"][i][1].double!
                    
                    let dayDetail = DayDetail(timeofday: timeofday, name: name, category: category, price: price, rating: rating, lat: lat, long: long)
                    self.dayDetails.append(dayDetail)
                }
            }
            
            let days = self.dayDetails.count/2
            UserDefaults.standard.set(days, forKey: "i_days")
            
            switch response.result {
            case .success(_):
                self.removeSpinner()
                if rangeChanged {
                    let alert = UIAlertController(title: "Looks like you have entered too many days. We have generated an itinerary for maximum days as per your preferances.", message: "", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true) {
                        self.performSegue(withIdentifier: "itinerary_generated", sender: self)
                    }
                    return
                }
                else {
                    self.performSegue(withIdentifier: "itinerary_generated", sender: self)
                    print("success")
                }
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "itinerary_generated") {
            let piVC = segue.destination as! PlanItineraryViewController
            piVC.dayDetails = self.dayDetails
        }
    }
}

extension CustomTripCategoryDetailsViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
        }
    }
}
