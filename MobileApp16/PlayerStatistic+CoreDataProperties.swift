//
//  PlayerStatistic+CoreDataProperties.swift
//  MobileApp16
//
//  Created by Manan Tariq on 14/12/16.
//
//

import Foundation
import CoreData


extension PlayerStatistic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayerStatistic> {
        return NSFetchRequest<PlayerStatistic>(entityName: "PlayerStatistic");
    }

    @NSManaged public var name: String?
    @NSManaged public var win: Int32
    @NSManaged public var lost: Int32
    @NSManaged public var total: Int32
    @NSManaged public var whiteSide: Int32
    @NSManaged public var darkSide: Int32
    @NSManaged public var tutorial: Bool

}
