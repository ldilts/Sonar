//
//  LogTableViewController.swift
//  Sonar
//
//  Created by Lucas Michael Dilts on 11/22/15.
//  Copyright © 2015 Lucas Dilts. All rights reserved.
//

import UIKit

class LogTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var logs = [Log]()
    var sortedLogs: [String: [Log]] = [String: [Log]]()
    var keys: [String] = [String]()
    var selectedLog: Log!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for log in logs {
            print("\n\(log.log_id) \(log.log_open) \(log.log_date)\n")
        }
        
        // Empty State Set up
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.tableView.tableFooterView = UIView();
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .ShortStyle
        formatter.dateFormat = "dd/MM/yyyy"
        
        for log in logs {
            let dateString = formatter.stringFromDate((log as! Log).log_date!)
            
            if let _ = sortedLogs[dateString] {
                var logsArray: [Log] = sortedLogs[dateString]! as [Log]
                logsArray.append((log as! Log))
                sortedLogs[dateString] = logsArray
            } else {
                sortedLogs[dateString] = [(log as! Log)]
                keys.append(dateString)
            }
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.keys.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let logsArray: [Log] = self.sortedLogs[self.keys[section]]! as [Log]
        return logsArray.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LogCell", forIndexPath: indexPath) as! LogTableViewCell

        // Configure the cell...
//        cell.log = self.logs[indexPath.row] as! Log
        var logsArray: [Log] = self.sortedLogs[self.keys[indexPath.section]]! as [Log]
        
        cell.log = logsArray[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.keys[section]
    }
    
//    MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var logsArray: [Log] = self.sortedLogs[self.keys[indexPath.section]]! as [Log]
        self.selectedLog = logsArray[indexPath.row]
        
        self.performSegueWithIdentifier("LogSegue", sender: self)
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
//    MARK: - Empty State DataSet Source
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "Door Icon")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        return NSAttributedString(string: "Oops.")
        
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "These are not the logs you are looking for!")
    }
    
//    MARK: - Empty State Delegate
    
    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
//    MARK: - Actions
    
    @IBAction func backButtonTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("UnwindToHome", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "LogSegue" {
            let destinatioViewController: LogViewController = segue.destinationViewController as! LogViewController
            
            destinatioViewController.log = selectedLog
        }
    }

    @IBAction func unwindToLogTableViewController(segue: UIStoryboardSegue) {
        
    }

}
