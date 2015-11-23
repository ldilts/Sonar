//
//  LogTableViewCell.swift
//  Sonar
//
//  Created by Lucas Michael Dilts on 11/22/15.
//  Copyright © 2015 Lucas Dilts. All rights reserved.
//

import UIKit

class LogTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    
    var log: Log! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle
        
//        formattersetDateFormat:@"HH:mm:ss"
        formatter.dateFormat = "HH:mm:ss a"
        
        let dateString = formatter.stringFromDate(log.log_date!)
        
        self.dateLabel.text = dateString
        self.stateLabel.text = log.log_open == 1 ? "Open" : "Closed"
        
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
