//
//  PlanItineraryViewController.swift
//  TravelWise
//
//  Created by Nidhi Bhat G on 02/06/22.
//

import UIKit

class PlanItineraryViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cityLabel: UILabel!
    var dates: [String] = []
    var dayDetails: [DayDetail] = []
    var morningDayDetails: [DayDetail] = []
    var eveningDayDetails: [DayDetail] = []
    
    @IBOutlet weak var planItineraryDatesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        planItineraryDatesTableView.delegate = self
        planItineraryDatesTableView.dataSource = self
        
        planItineraryDatesTableView.register(UINib(nibName: "DayTableViewCell", bundle: nil), forCellReuseIdentifier: "day_cell")
        
        self.planItineraryDatesTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cityLabel.text = UserDefaults.standard.string(forKey: "i_city")! + " Itinerary"
        let start = UserDefaults.standard.string(forKey: "i_start_date")!
        let days = UserDefaults.standard.integer(forKey: "i_days")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = dateFormatter.date(from: start)
        
        var curr = startDate!
        var newDate = Calendar.current.date(byAdding: .day, value: 0, to: curr)!
        dates.append(dateFormatter.string(from: newDate))
        for _ in 0...days {
            newDate = Calendar.current.date(byAdding: .day, value: 1, to: curr)!
            dates.append(dateFormatter.string(from: newDate))
            curr = newDate
        }
        
        var i = 0
        while(i+1 < dayDetails.count) {
            morningDayDetails.append(dayDetails[i])
            eveningDayDetails.append(dayDetails[i+1])
            i+=2
        }
    }
    
    func tableView(_ planItineraryDatesTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eveningDayDetails.count
    }
    
    func tableView(_ planItineraryDatesTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = planItineraryDatesTableView.dequeueReusableCell(withIdentifier: "day_cell") as! DayTableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.dayLabel.text = "Day \(indexPath.row + 1)"
        cell.dateLabel.text = dates[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "show_itinerary_day_details", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "show_itinerary_day_details") {
            let pddVC = segue.destination as! PlanDetailedDisplayViewController
            pddVC.morningDetail = morningDayDetails[planItineraryDatesTableView.indexPathForSelectedRow!.row]
            pddVC.eveningDetail = eveningDayDetails[planItineraryDatesTableView.indexPathForSelectedRow!.row+1]
        }
    }
}
