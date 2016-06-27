//
//  CPMsgTableViewCell.swift
//  
//
//  Created by Amal Almansour on 2/29/16.
//
//

import UIKit
import Parse

class CPMsgTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ParentImage: UIImageView!
    
    @IBOutlet weak var ParentName: UILabel!
    
    @IBOutlet weak var activityandBabyname: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var HiddenLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
