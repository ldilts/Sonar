//
//  Log.h
//  Sonar
//
//  Created by Lucas Michael Dilts on 11/24/15.
//  Copyright © 2015 Lucas Dilts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Log : NSManagedObject


@property (nonatomic, retain) NSDate *log_date;
@property (nonatomic, retain) NSNumber *log_id;
@property (nonatomic, retain) NSNumber *log_open;
@end

