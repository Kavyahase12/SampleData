//
//  scannerTableViewCell.swift
//  EPOCHBLE1
//
//  Created by MAC Developers on 15/04/2017.
//  Copyright © 2017 MAC Developers. All rights reserved.
//

import UIKit

class scannerTableViewCell: UITableViewCell {

    @IBOutlet weak var imageRSSI: UIImageView!
    @IBOutlet weak var IdnLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    
    @IBAction func onConnectClicl(_ sender: Any)
    {
        
        
    }
    
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
