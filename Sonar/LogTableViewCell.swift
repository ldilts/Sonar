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
        
        self.backgroundColor = log.log_open == 1 ? UIColor(red: (170.0/255.0), green: (207.0/255.0), blue: (208.0/255.0), alpha: 0.25) : UIColor(red: (121.0/255.0), green: (168.0/255.0), blue: (169.0/255.0), alpha: 0.25)
        
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
