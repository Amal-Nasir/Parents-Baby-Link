//
//  ParentMsgTableViewCell.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 2/23/16.
//  Copyright © 2016 Amal Almansour. All rights reserved.
//

import UIKit

class ParentMsgTableViewCell: UITableViewCell {

    @IBOutlet weak var careProviderImage: UIImageView!
    
    @IBOutlet weak var careProviderName: UILabel!
    
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
