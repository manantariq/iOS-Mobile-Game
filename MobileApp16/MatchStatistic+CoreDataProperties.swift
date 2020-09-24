//
//  MatchStatistic+CoreDataProperties.swift
//  MobileApp16
//
//  Created by Manan Tariq on 31/12/16.
//
//

import Foundation
import CoreData


extension MatchStatistic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchStatistic> {
        return NSFetchRequest<MatchStatistic>(entityName: "MatchStatistic");
    }

    @NSManaged public var playerOne: String?
    @NSManaged public var playerTwo: String?
    @NSManaged public var winner: String?
    @NSManaged public var turns: Int32
    @NSManaged public var date: NSDate?

}
