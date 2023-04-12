//
//  GroupsHelper.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import Foundation
import CoreData

final class CoreDataHelper {
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
            print("item取得")
            return groupItems.sorted(by: { $0.itemtimestamp ?? Date() > $1.itemtimestamp ?? Date() })
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
        
        if group.groupimage == nil {
            group.groupimage = image
        }
        
        group.grouptimestamp = Date()
        
        do {
            print("item作成完了")
            try context.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func groupDelete(context: NSManagedObjectContext, group: Groups) {
        context.delete(group)
        do {
            print("group削除完了")
            try context.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func itemDelete(context: NSManagedObjectContext, items: [GroupItem]) {
        for item in items {
            context.delete(item)
        }
        do {
            print("item削除完了")
            try context.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func groupEdit(context: NSManagedObjectContext, group: Groups, title: String, color: String, image: Data?) {
        group.grouptimestamp = Date()
        group.grouptitle = title
        group.color = color
        group.groupimage = image
        
        do {
            try context.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func itemEdit(context: NSManagedObjectContext, item: GroupItem, title: String, image: Data?, url: String?, impression: String?) {
        item.itemtimestamp = Date()
        item.itemtitle = title
        item.itemimage = image
        item.url = url
        item.impression = impression
        
        item.group?.grouptimestamp = Date()
        do {
            try context.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
