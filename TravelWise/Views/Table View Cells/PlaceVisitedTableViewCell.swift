//
//  PlaceVisitedTableViewCell.swift
//  TravelWise
//
//  Created by Chinmay Bapna on 11/05/21.
//

import UIKit

class PlaceVisitedTableViewCell: UITableViewCell {

    @IBOutlet weak var snoLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
