//
//  ListTableViewCell.swift
//  CookBook
//
//  Created by Deepika Kudaka on 19/12/17.
//  Copyright © 2017 Deepika Kudaka. All rights reserved.
//

import UIKit
/**
class for CustomizedCell in ItemListTableView
 Contains oulets for itemListImage and itemNameLabel for image and mealname to cell in tableview.
 */
class ListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var itemListImage: UIImageView!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
