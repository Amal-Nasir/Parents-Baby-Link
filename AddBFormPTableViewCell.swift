//
//  AddBFormPTableViewCell.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 3/2/16.
//  Copyright © 2016 Amal Almansour. All rights reserved.
//

import UIKit

class AddBFormPTableViewCell: UITableViewCell {

    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    
    
    override func prepareForReuse()
    {
        self.userNameLabel.text = nil
        self.userImage.image = nil
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
