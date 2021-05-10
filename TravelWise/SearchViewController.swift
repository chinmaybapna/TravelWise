//
//  SearchViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 09/05/21.
//

import UIKit
import Firebase
import SDWebImage

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segments: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchedUsers: [User] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "PeopleSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "people_search_cell")
        self.tableView.tableFooterView = UIView()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            print(segments.selectedSegmentIndex)
            if segments.selectedSegmentIndex == 0 {
                searchForPlaces(name: searchText)
            }
            else {
                searchForPeople(name: searchText)
            }
        }
    }
    
    func searchForPlaces(name: String) {
        
    }
    
    func searchForPeople(name: String) {
        db.collection("users").whereField("name", isEqualTo: name).getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    let name = data["name"] as! String
                    let hometown = data["hometown"] as! String
                    let uid = data["uid"] as! String
                    
                    let searchedUser = User(name: name, hometown: hometown, uid: uid)
                    self.searchedUsers.append(searchedUser)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedUsers = []
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "people_search_cell", for: indexPath) as! PeopleSearchTableViewCell
        cell.name.text = searchedUsers[indexPath.row].name
        cell.hometown.text = searchedUsers[indexPath.row].hometown
        cell.profileImageView.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: "atikh-bana-FtBS0p23fcc-unsplash"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "show_user_profile", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "show_user_profile") {
            let userProfileVC = segue.destination as! SearchProfileViewController
            userProfileVC.uid = searchedUsers[tableView.indexPathForSelectedRow!.row].uid
        }
    }
}
