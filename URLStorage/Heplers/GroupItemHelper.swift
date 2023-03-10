//
//  GroupItemHelper.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import Foundation
import CoreData

final class GroupItemHelper {
    let persistentContainer: NSPersistentContainer
    init() {
        persistentContainer = NSPersistentContainer(name: "URLStorage")
        
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Core Data Store failed \(error.localizedDescription)")
            }
        }
    }
    
    func saveData(title: String, image: Data?, url: String?, impression: String?, group: Groups) {
        let newitem = GroupItem(context: persistentContainer.viewContext)
        newitem.itemtimestamp = Date()
        newitem.itemtitle = title
        newitem.itemimage = image
        newitem.url = url
        newitem.impression = impression
        newitem.group = group
        
        do {
            try persistentContainer.viewContext.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
