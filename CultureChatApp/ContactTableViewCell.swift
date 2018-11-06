//
//  ContactTableViewCell.swift
//  CultureChatApp
//
//  Created by Shilin Ni on 12/10/17.
//  Copyright © 2017 Shilin Ni. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var language: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    var uid = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
