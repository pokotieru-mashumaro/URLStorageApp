//
//  Groups+CoreDataProperties.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//
//

import Foundation
import CoreData


extension Groups {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Groups> {
        return NSFetchRequest<Groups>(entityName: "Groups")
    }

    @NSManaged public var grouptimestamp: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var grouptitle: String?
    @NSManaged public var groupimage: Data?
    @NSManaged public var category: String?
    @NSManaged public var item: NSSet?

}

// MARK: Generated accessors for item
extension Groups {

    @objc(addItemObject:)
    @NSManaged public func addToItem(_ value: GroupItem)

    @objc(removeItemObject:)
    @NSManaged public func removeFromItem(_ value: GroupItem)

    @objc(addItem:)
    @NSManaged public func addToItem(_ values: NSSet)

    @objc(removeItem:)
    @NSManaged public func removeFromItem(_ values: NSSet)

}

extension Groups : Identifiable {

}
