//
//  TMDatabaseQueryAssistant.h
//  Lifekey
//
//  Created by Thiago MagalhÃ£es on 01/10/14.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Restkit/RestKit.h>

@interface TMDatabaseQueryAssistant : NSObject

+ (NSManagedObjectContext *) moc;

+ (void) generateMockObjectsIfNeeded;

+ (NSArray *) queryForEntity: (NSString *) entityName predicate: (NSPredicate *) predicate;

+ (NSArray *) queryForEntity: (NSString *) entityName;

+ (id) queryForSingleObjectWithEntity: (NSString *) entityName predicate: (NSPredicate *) predicate;

+ (id) queryForSingleObjectWithEntity: (NSString *) entityName;

+ (NSArray *) queryForDistinctObjectsWithEntity: (NSString *) entityName property: (NSString *) property;

+ (NSArray *) queryForDistinctKeysWithEntity: (NSString *) entityName property: (NSString *) property predicate: (NSPredicate *) predicate;

+ (NSArray *) queryForDistinctKeysWithEntity: (NSString *) entityName property: (NSString *) property predicate: (NSPredicate *) predicate sortedBy:(NSString *) sortingProperty ascending: (BOOL) ascending;

+ (void) clearDatabaseOnLogout;

+ (void) clearTableWithEntityName : (NSString *) entityName;

+ (void) clearDatabaseFromOldData: (NSString *) entityName;

@end