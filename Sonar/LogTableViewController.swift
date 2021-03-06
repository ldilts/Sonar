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
    
    var page: Int = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Empty State Set up
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.tableView.tableFooterView = UIView();
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .ShortStyle
        formatter.dateFormat = "dd/MM/yyyy"
        
        for log in logs {
            let dateString = formatter.stringFromDate(log.log_date!)
            
            if let _ = sortedLogs[dateString] {
                var logsArray: [Log] = sortedLogs[dateString]! as [Log]
                logsArray.append(log)
                sortedLogs[dateString] = logsArray
            } else {
                sortedLogs[dateString] = [log]
                keys.append(dateString)
            }
        }
        
        self.configureRestKit()

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
    
//    MARK: - ZBTableViewDataSource
//    func fetchMoreWithCompletion(aCompletion: ((NSError!) -> Void)!) {
//        self.page++
//
//        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
//        dispatch_async(dispatch_get_global_queue(priority, 0)) {
//            // do some task
//            self.loadLogs()
//            dispatch_async(dispatch_get_main_queue()) {
//                // update some UI
//                self.tableView.reloadData()
//                aCompletion(nil)
//            }
//        }
//    }
    
//    MARK: - Helper Methods
    
    func configureRestKit() {
        // initialize AFNetworking HTTPClient
        let baseURL: NSURL = NSURL(string: "http://dilts.koding.io:8000/")!
        let client: AFHTTPClient = AFHTTPClient(baseURL: baseURL)
        
        // initialize RestKit
        let objectManager: RKObjectManager = RKObjectManager(HTTPClient: client)
        
        // setup object mappings
        let logMapping: RKObjectMapping = RKObjectMapping(forClass: Log.self)
        logMapping.addAttributeMappingsFromArray(["log_date", "log_open", "log_id"])
        
        let responseDescriptor: RKResponseDescriptor! = RKResponseDescriptor(mapping: logMapping, method: RKRequestMethod.GET, pathPattern: "log/?page=", keyPath: "results", statusCodes: NSIndexSet(index: 200))
        
        objectManager.addResponseDescriptor(responseDescriptor)
    }
    
    func loadLogs() {
        
        RKObjectManager.sharedManager().getObjectsAtPath("log/?page=\(self.page)", parameters: nil, success: { (operation: RKObjectRequestOperation!, mappingResult: RKMappingResult!) -> Void in
            
            print("\nPage: \(self.page)\n")
            
            self.logs += mappingResult.array() as! [Log]
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            formatter.timeStyle = .ShortStyle
            formatter.dateFormat = "dd/MM/yyyy"
            
            for log in self.logs {
                let dateString = formatter.stringFromDate(log.log_date!)
                
                if let _ = self.sortedLogs[dateString] {
                    var logsArray: [Log] = self.sortedLogs[dateString]! as [Log]
                    logsArray.append(log)
                    self.sortedLogs[dateString] = logsArray
                } else {
                    self.sortedLogs[dateString] = [log]
                    self.keys.append(dateString)
                }
            }
            
            }, failure: { (operation: RKObjectRequestOperation!, error: NSError!) -> Void in
                NSLog("What do you mean by 'there is no coffee?': %@", error)
                
        })
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
