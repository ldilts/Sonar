//
//  TMRestkitSetup.swift
//  Sonar
//
//  Created by Lucas Michael Dilts on 11/24/15.
//  Copyright © 2015 Lucas Dilts. All rights reserved.
//

import Foundation
import SystemConfiguration

private let APIDocumentation = ""


func startRestkitWithBaseURL(baseURL: NSURL) {
    
    configureRestkitWithBaseURL(baseURL)
}

private func configureRestkitWithBaseURL (baseURL: NSURL) {
    
    RKObjectManager.setSharedManager(RKObjectManager(baseURL: baseURL))
    
    let objectStore = RKManagedObjectStore(managedObjectModel: managedObjectModel())
    
    let dataPath = RKApplicationDataDirectory() + "/Sonar.sqlite"
    
    do {
        
        try objectStore.addSQLitePersistentStoreAtPath(dataPath, fromSeedDatabaseAtPath: nil, withConfiguration: nil, options: optionsForSqliteStore() as [NSObject: AnyObject])
        
    } catch  {
        
        print(error)
    }
    
    objectStore.createManagedObjectContexts()
    
    objectStore.managedObjectCache = RKInMemoryManagedObjectCache(managedObjectContext: objectStore.persistentStoreManagedObjectContext)
    
    RKObjectManager.sharedManager().managedObjectStore = objectStore
}

private func managedObjectModel () -> NSManagedObjectModel {
    
    return  NSManagedObjectModel.mergedModelFromBundles(nil)!
}

private func optionsForSqliteStore () -> NSDictionary {
    
    return [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
}

func fetchRequestBlock(relativePath: String, entityName: String) -> RKFetchRequestBlock? {
    
    let fetchRequestBlock: RKFetchRequestBlock = { (url: NSURL!) -> NSFetchRequest! in
        
        let pathMatcher = RKPathMatcher(pattern: relativePath)
        
        let match = pathMatcher.matchesPath(url.relativePath, tokenizeQueryStrings: true, parsedArguments: nil)
        
        if(match) {
            
            let fetchRequest = NSFetchRequest(entityName: entityName)
            
            return fetchRequest
            
        } else {
            
            return nil
        }
    }
    
    return fetchRequestBlock
}