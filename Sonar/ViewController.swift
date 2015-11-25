//
//  ViewController.swift
//  Sonar
//
//  Created by Lucas Michael Dilts on 11/22/15.
//  Copyright © 2015 Lucas Dilts. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var circularView: UIView!
    
    var logs: [Log]!
    
    var distance = 0.0
    
    var startTransform: CGAffineTransform!
    var deltaAngle: CGFloat!
    
//    MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let data = TMDatabaseQueryAssistant.queryForEntity("Log") as? [Log] {
            
            self.logs = data
        }
        
        
        self.activityIndicator.startAnimating()
        self.statusLabel.alpha = 0.0
        self.statusLabel.hidden = true
        self.distanceLabel.text = "\(self.distance)"
        self.circularView.layer.cornerRadius = ((UIScreen.mainScreen().bounds.size.width + 100.0) / 2.0)
        
        self.configureRestKit()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadLogs()
//        [[NSNotificationCenter defaultCenter]addObserver:myView selector:@selector(NotificationReceived:) name:@"notification" object:nil];
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadLogs"), name: "ReloadDataNotification", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        initializeNotificationServices()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ReloadDataNotification", object: nil)
    }
    
//    MARK: - Actions
    
    @IBAction func viewLogsButtonTapped(sender: UIButton) {
        performSegueWithIdentifier("LogsSegue", sender: self)
    }
    
    @IBAction func resetButtonTapped(sender: UIButton) {
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
            self.circularView.transform = CGAffineTransformIdentity
            self.distanceLabel.text = "0.0"
        }, completion: { (success: Bool) -> Void in
            self.deltaAngle = 0.0
        })
        
    }
    
    @IBAction func fetchButtonTapped(sender: UIButton) {
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidden = false
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.statusLabel.alpha = 0.0
            self.activityIndicator.alpha = 1.0
            
        }, completion: { (success: Bool) -> Void in
            
            self.statusLabel.hidden = true
            self.loadLogs()
            
        })
        
    }
    
    @IBAction func handlePan(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(self.view)
        
        if sender.state == UIGestureRecognizerState.Began {
            if let view = sender.view {
                let dx = translation.x - view.center.x
                let dy = translation.y - view.center.y
                self.deltaAngle = atan2(dy, dx)
                
                self.startTransform = view.transform
            }
        }
        else if sender.state == UIGestureRecognizerState.Changed {
            
            
            
            if let view = sender.view {
                let dx = translation.x - view.center.x
                let dy = translation.y - view.center.y
                let ang = atan2(dy, dx)
                
                let angleDifference = self.deltaAngle - ang
                
                // Current Angle
                view.transform = CGAffineTransformRotate(startTransform, -angleDifference)
                
                let radians: CGFloat = atan2(view.transform.b, view.transform.a)

                let text =  String(format: "%.2f", radians < 0 ? (CGFloat(M_PI) + CGFloat(M_PI) + radians).radiansToDegrees : radians.radiansToDegrees)
                
                self.distanceLabel.text = "\(text)"
                
            }
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            
            if let view = sender.view {
                let dx = translation.x - view.center.x
                let dy = translation.y - view.center.y
                let ang = atan2(dy, dx)
                
                let angleDifference = self.deltaAngle - ang
                
                self.distance += Double((((-angleDifference).radiansToDegrees) / 360.0) * 4.0)
                
//                self.distanceLabel.text = "\(self.distance)"
            }
        }
    }
    
//    MARK: - Helper Methods
    
    func calculateDistanceFromCenter(point: CGPoint) -> CGFloat {
        let center: CGPoint = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0)
        let dx = point.x - center.x
        let dy = point.y - center.y
        return sqrt(dx * dx + dy * dy)
    }
    
    func configureRestKit() {
        // initialize AFNetworking HTTPClient
        
        
        
        
        // setup object mappings
        let logMapping: RKEntityMapping = RKEntityMapping(forEntityForName: "Log", inManagedObjectStore: RKManagedObjectStore.defaultStore())
        
        let attribute = ["log_date": "log_date",
            "log_open": "log_open",
            "log_id": "log_id"]
        
        logMapping.addAttributeMappingsFromDictionary(attribute)
        
        let responseDescriptor: RKResponseDescriptor! = RKResponseDescriptor(mapping: logMapping, method: RKRequestMethod.GET, pathPattern: "log/", keyPath: "results", statusCodes: NSIndexSet(index: 200))
        
        RKObjectManager.sharedManager().addResponseDescriptor(responseDescriptor)
    }
    
    func loadLogs() {
        

        
        RKObjectManager.sharedManager().getObjectsAtPath("log/", parameters: nil, success: { (operation: RKObjectRequestOperation!, mappingResult: RKMappingResult!) -> Void in
            
            self.logs = mappingResult.array() as! [Log]
            
//            self.tableView.reloadData()
            
//            for log in self.logs {
//                print("\nReceived: \((log as! Log).log_date)\n")
//            }
            if self.logs.count > 0 {
                self.activityIndicator.stopAnimating()
                self.statusLabel.hidden = false
                self.statusLabel.alpha = 0.0
                self.statusLabel.text = (self.logs[0] as! Log).log_open == 1 ? "Open" : "Closed"
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.activityIndicator.alpha = 0.0
                    self.statusLabel.alpha = 1.0
                }, completion: { (success: Bool) -> Void in
                    self.activityIndicator.hidden = true
                })
                
            }
            
            }, failure: { (operation: RKObjectRequestOperation!, error: NSError!) -> Void in
                NSLog("What do you mean by 'there is no coffee?': %@", error)
                
                self.activityIndicator.stopAnimating()
                self.statusLabel.hidden = false
                self.statusLabel.alpha = 0.0
                self.statusLabel.text = "\(error.localizedDescription)"
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.activityIndicator.alpha = 0.0
                    self.statusLabel.alpha = 1.0
                    }, completion: { (success: Bool) -> Void in
                        self.activityIndicator.hidden = true
                })
        })
    }
    
//    MARK: - Navigation
    
    @IBAction func unwindTohome(segue: UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LogsSegue" {
            
            let navigationViewController = segue.destinationViewController as! UINavigationController
            let destinationViewController = navigationViewController.viewControllers[0] as! LogTableViewController
            
            destinationViewController.logs = self.logs
        }
    }
    
//    MARK: - Other

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func initializeNotificationServices() -> Void {
//        let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge], categories: nil)
//        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
//        
//        // This is an asynchronous method to retrieve a Device Token
//        // Callbacks are in AppDelegate.swift
//        // Success = didRegisterForRemoteNotificationsWithDeviceToken
//        // Fail = didFailToRegisterForRemoteNotificationsWithError
//        UIApplication.sharedApplication().registerForRemoteNotifications()
//    }


}

extension CGFloat {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
    
    var radiansToDegrees: CGFloat {
        return CGFloat(self) * 180.0 / CGFloat(M_PI)
    }
}

