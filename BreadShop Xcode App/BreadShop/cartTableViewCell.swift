//
//  cartTableViewCell.swift
//  BreadShop
//
//  Created by Ben Garman on 05/12/2019.
//  Copyright © 2019 Ben GarmaAll rights reserved.
//

import UIKit

class cartTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //Items in the cart table view
    //Pretty simple
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var bottomSlide: UIView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
