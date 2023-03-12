//
//  GroupsHelper.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import Foundation
import CoreData

final class CoreDataHelper {
//    let persistentContainer: NSPersistentContainer
//
//    init() {
//        persistentContainer = NSPersistentContainer(name: "URLStorage")
//
////        let description = NSPersistentStoreDescription()
////        description.shouldMigrateStoreAutomatically = true
////        description.shouldInferMappingModelAutomatically = true
////        persistentContainer.persistentStoreDescriptions = [description]
////
//        persistentContainer.loadPersistentStores { (description, error) in
//            if let error = error {
//                fatalError("Core Data Store failed \(error.localizedDescription)")
//            }
//        }
//    }
    
    func getFolder(context: NSManagedObjectContext) -> [Groups] {
        let fetchRequest: NSFetchRequest<Groups> = Groups.fetchRequest()
        
        do {
            print("Folder取得")
            return try context.fetch(fetchRequest).sorted(by: {$0.grouptimestamp ?? Date() > $1.grouptimestamp ?? Date()})
        } catch {
            return []
        }
    }
    
    func getItem(groups: Groups) -> [GroupItem] {
        if let groupItems = groups.item?.allObjects as? [GroupItem] {
            let sortedGroupItems = groupItems.sorted(by: { $0.itemtimestamp ?? Date() > $1.itemtimestamp ?? Date() })
            return sortedGroupItems
        } else {
            return [GroupItem]()
        }
    }
    
    func groupSave(context: NSManagedObjectContext,title: String, color: String, image: Data?) {
        let newitem = Groups(context: context)
        newitem.id = UUID()
        newitem.grouptimestamp = Date()
        newitem.grouptitle = title
        newitem.color = color
        newitem.groupimage = image
        
        do {
            print("Folder作成完了")
            try context.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func itemSave(context: NSManagedObjectContext, title: String, image: Data?, url: String?, impression: String?, group: Groups) {
        let newitem = GroupItem(context: context)
        newitem.itemtimestamp = Date()
        newitem.itemtitle = title
        newitem.itemimage = image
        newitem.url = url
        newitem.impression = impression
        newitem.group = group
        
        group.grouptimestamp = Date()
        
        do {
            print("item作成完了")
            try context.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
}