//
//  LogViewController.swift
//  Sonar
//
//  Created by Lucas Michael Dilts on 11/23/15.
//  Copyright © 2015 Lucas Dilts. All rights reserved.
//

import UIKit

class LogViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    
    var log: Log!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = .MediumStyle
        
        let dateString = formatter.stringFromDate(log.log_date!)

        // Do any additional setup after loading the view.
        self.imageView.image = UIImage(named: (log.log_open == 1 ? "Open Door Icon" : "Closed Door Icon"))
        self.detailLabel.text = "The door was " + (log.log_open == 1 ? "opened" : "closed") + " on " + dateString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
