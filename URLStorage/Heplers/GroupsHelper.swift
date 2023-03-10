//
//  GroupsHelper.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import Foundation
import CoreData

final class GroupsHelper {
    let persistentContainer: NSPersistentContainer
    init() {
        persistentContainer = NSPersistentContainer(name: "URLStorage")

//        let description = NSPersistentStoreDescription()
//        description.shouldMigrateStoreAutomatically = true
//        description.shouldInferMappingModelAutomatically = true
//        persistentContainer.persistentStoreDescriptions = [description]
//
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Core Data Store failed \(error.localizedDescription)")
            }
        }
    }
    
    func getFolder() -> [Groups] {
        let fetchRequest: NSFetchRequest<Groups> = Groups.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "grouptimestamp", ascending: true)]
        
        do {
            print("Folder取得")
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    func saveData(title: String, category: String, image: Data?) {
        let newitem = Groups(context: persistentContainer.viewContext)
        newitem.id = UUID()
        newitem.grouptimestamp = Date()
        newitem.grouptitle = title
        newitem.category = category
        newitem.groupimage = image
        
        do {
            print("Folder作成完了")
            try persistentContainer.viewContext.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
}
