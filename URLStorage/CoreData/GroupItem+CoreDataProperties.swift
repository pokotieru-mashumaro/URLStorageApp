//
//  GroupItem+CoreDataProperties.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//
//

import Foundation
import CoreData


extension GroupItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupItem> {
        return NSFetchRequest<GroupItem>(entityName: "GroupItem")
    }

    @NSManaged public var itemtitle: String?
    @NSManaged public var itemimage: Data?
    @NSManaged public var url: String?
    @NSManaged public var impression: String?
    @NSManaged public var itemtimestamp: Date?
    @NSManaged public var group: Groups?

}

extension GroupItem : Identifiable {

}
