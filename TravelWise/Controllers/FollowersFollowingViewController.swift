//
//  FollowersFollowingViewController.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 10/05/21.
//

import UIKit
import Firebase
import SDWebImage

class FollowersFollowingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let db = Firestore.firestore()
    
    var users: [User] = []
    var uids: [String] = []
    
    var showFollowers: Bool?
    var showFollowing: Bool?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "FollowersFollowingTableViewCell", bundle: nil), forCellReuseIdentifier: "followers_following_cell")
        
        if let showFollowers = showFollowers, let showFollowing = showFollowing {
            if showFollowers && !showFollowing {
                getUIDsForFollowers {
                    self.fetchUsers()
                }
            }
            else if !showFollowers && showFollowing {
                getUIDsForFollowing {
                    self.fetchUsers()
                }
            }
            else {
                //alert box
            }
        }
    }
    
    func getUIDsForFollowers(completion: @escaping () -> ()) {
        db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("followers").getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                for document in querySnapshot!.documents {
                    self.uids.append(document.documentID)
                }
                print(self.uids)
                completion()
            }
        }
    }
    
    func getUIDsForFollowing(completion: @escaping () -> ()) {
        db.collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("following").getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                for document in querySnapshot!.documents {
                    self.uids.append(document.documentID)
                }
                print(self.uids)
                completion()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func fetchUsers() {
        for uid in self.uids {
            self.db.collection("users").document(uid).getDocument { (querySnapshot, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    let data = querySnapshot?.data()
                    if let data = data {
                        let name = data["name"] as! String
                        let profileImageURL = data["profileImageURL"] as! String
                        let hometown = data["hometown"] as! String
                        let uid = data["uid"] as! String
                        
                        let tempUser = User(name: name, hometown: hometown, uid: uid, profileImageURL: profileImageURL)
                        self.users.append(tempUser)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followers_following_cell", for: indexPath) as! FollowersFollowingTableViewCell
        cell.nameLabel.text = users[indexPath.row].name
        cell.profileImageView.sd_setImage(with: URL(string: users[indexPath.row].profileImageURL), placeholderImage: UIImage(named: "defaultProfileImage"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "show_user_profile", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let userProfileVC = segue.destination as! SearchProfileViewController
        userProfileVC.uid = users[tableView.indexPathForSelectedRow!.row].uid
    }
}
