//
//  PostScheduleTableViewCell.swift
//  CultureChatApp
//
//  Created by Shilin Ni on 11/19/17.
//  Copyright © 2017 Shilin Ni. All rights reserved.
//

import UIKit

class PostScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var coins: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
