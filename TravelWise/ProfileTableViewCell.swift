//
//  ProfileTableViewCell.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 09/05/21.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var tripUpvotes: UILabel!
    @IBOutlet weak var tripName: UILabel!
    @IBOutlet weak var tripImage: UIImageView!
    @IBOutlet weak var tripView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tripView.layer.cornerRadius = tripView.frame.size.height / 15
        tripView.layer.borderWidth = 0.25
        tripView.layer.masksToBounds = true
        tripView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
//        tripView.backgroundColor = .red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
