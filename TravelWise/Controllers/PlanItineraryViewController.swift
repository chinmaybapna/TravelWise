//
//  PlanItineraryViewController.swift
//  TravelWise
//
//  Created by Nidhi Bhat G on 02/06/22.
//

import UIKit

class PlanItineraryViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var dates: [String] = ["03/03/2023", "04/03/2023", "05/03/2023", "06/03/2023","07/03/2023"]

    @IBOutlet weak var planItineraryDatesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        planItineraryDatesTableView.delegate = self
        planItineraryDatesTableView.dataSource = self
        
        planItineraryDatesTableView.register(UINib(nibName: "DayTableViewCell", bundle: nil), forCellReuseIdentifier: "day_cell")
        
        self.planItineraryDatesTableView.tableFooterView = UIView()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        dates = ["03/03/2023", "04/03/2023", "05/03/2023", "06/03/2023","07/03/2023"]
        DispatchQueue.main.async {
            self.planItineraryDatesTableView.reloadData()
        }
    }
    
    func tableView(_ planItineraryDatesTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    func tableView(_ planItineraryDatesTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = planItineraryDatesTableView.dequeueReusableCell(withIdentifier: "day_cell") as! DayTableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.dayLabel.text = "Day \(indexPath.row + 1)"
        cell.dateLabel.text = dates[indexPath.row]
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "", sender: self)
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
