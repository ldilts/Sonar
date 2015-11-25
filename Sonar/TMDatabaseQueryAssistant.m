//
//  TMDatabaseQueryAssistant.m
//  Lifekey
//
//  Created by Thiago MagalhÃ£es on 01/10/14.
//

#import "TMDatabaseQueryAssistant.h"

@implementation TMDatabaseQueryAssistant

+ (NSManagedObjectContext *) moc
{

    return [RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext;
}

+ (void) generateMockObjectsIfNeeded
{
    NSArray * entitiesNames = @[];
    
    BOOL shouldGenerateMockObjects = YES;
    
    for (NSString * entityName in entitiesNames) {
        
        NSArray * managedObjects = [self queryForEntity:entityName];
        
        if (managedObjects.count > 0) {
            shouldGenerateMockObjects = NO;
            break;
        }
        
    }
    
    if (shouldGenerateMockObjects) {
        
        NSManagedObjectContext * moc = [RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext;
        
        [moc save:nil];
        
    }
}

+ (NSArray *) queryForEntity: (NSString *) entityName predicate: (NSPredicate *) predicate
{
    NSManagedObjectContext * moc = [RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext;
    
    
    NSEntityDescription * entityDescription = [NSEntityDescription
                                               entityForName:entityName inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    request.entity = entityDescription;
    
    if (predicate) {
        
        request.predicate = predicate;
        
    }
    
    NSError * error;
    
    NSArray * array = [moc executeFetchRequest:request error:&error];
    
    NSAssert(array, @"Array == nil");
    
    return array;
}

+ (NSArray *) queryForEntity: (NSString *) entityName
{
    return  [self queryForEntity:entityName predicate:nil];
}

+ (id) queryForSingleObjectWithEntity: (NSString *) entityName predicate: (NSPredicate *) predicate
{
    return [self queryForEntity:entityName predicate:predicate].lastObject;
}

+ (id) queryForSingleObjectWithEntity: (NSString *) entityName
{
    return [self queryForEntity:entityName].lastObject;
}

+ (NSArray *) queryForDistinctObjectsWithEntity: (NSString *) entityName property: (NSString *) property
{
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription  entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entity];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[property]];
    
    // Execute the fetch.
    
    NSError *error = nil;
    
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if (objects == nil) {
        
    }
    
    return objects;
    
}

+ (NSArray *) queryForDistinctKeysWithEntity: (NSString *) entityName property: (NSString *) property predicate: (NSPredicate *) predicate
{
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription  entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entity];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[property]];
    [request setPredicate:predicate];
    
    // Execute the fetch.
    
    NSError *error = nil;
    
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    NSMutableArray * keys = [NSMutableArray new];
    
    for (NSObject * object in objects) {
        
        [keys addObject:[object valueForKey:property]];
    }
    
    if (keys == nil) {
        
    }
    
    return keys;
}

+ (NSArray *) queryForDistinctKeysWithEntity: (NSString *) entityName property: (NSString *) property predicate: (NSPredicate *) predicate sortedBy:(NSString *) sortingProperty ascending: (BOOL) ascending
{
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription  entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortingProperty ascending:ascending];
    
    [request setEntity:entity];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[property]];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sortDescriptor]];
    
    // Execute the fetch.
    
    NSError *error = nil;
    
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    NSMutableArray * keys = [NSMutableArray new];
    
    for (NSObject * object in objects) {
        
        [keys addObject:[object valueForKey:property]];
    }
    
    if (keys == nil) {
        
    }
    
    return keys;
}

+ (void) clearDatabaseOnLogout
{
    
    NSArray * entities = [[RKManagedObjectStore defaultStore].managedObjectModel.entities valueForKey:@"name"];
    
    for (NSString * entityName in entities) {
        @try {
            
            [self clearTableWithEntityName:entityName];
        }
        @catch (NSException *exception) {
            
        }
    }
}

+ (void) clearTableWithEntityName : (NSString *) entityName
{
    NSManagedObjectContext *moc = [RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:entityName inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSError *error;
    
    NSArray *array = [moc executeFetchRequest:request error:&error];
    
    if (array == nil)
    {
        
    } else {
        
        for (id object in array) {
            
            [moc deleteObject:object];
            
        }
        
        [moc save:nil];
        
    }
}

+ (void) clearDatabaseFromOldData: (NSString *) entityName
{
    NSManagedObjectContext *moc = [RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:entityName inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSError *error;
    
    NSArray *array = [moc executeFetchRequest:request error:&error];
    
    
    if (array == nil)
    {
        
    } else  if(array.count > 10) {
        
        NSSortDescriptor * sortByID = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:NO];
        
        array = [array sortedArrayUsingDescriptors:@[sortByID]];
        
        for (NSManagedObject * object in array) {
            
            if([array indexOfObject:object] > 9) {
                [moc deleteObject:object];
            }
            
        }
        
        [moc save:nil];
        
    }
    
}



@end
