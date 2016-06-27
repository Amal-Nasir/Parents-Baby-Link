//
//  ParentDetailMsgTableViewCell.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 2/23/16.
//  Copyright © 2016 Amal Almansour. All rights reserved.
//

import UIKit

class ParentDetailMsgTableViewCell: UITableViewCell {

    @IBOutlet weak var activityandBabyName1: UILabel!
    @IBOutlet weak var timeLabel1: UILabel!
    @IBOutlet weak var type: UILabel!
  //  @IBOutlet weak var comments: UILabel!
    
    @IBOutlet weak var comments: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
