//
//  AppSettings+CoreDataProperties.swift
//  MobileApp16
//
//  Created by Manan Tariq on 11/01/17.
//
//

import Foundation
import CoreData


extension AppSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppSettings> {
        return NSFetchRequest<AppSettings>(entityName: "AppSettings");
    }

    @NSManaged public var music: Bool
    @NSManaged public var sounds: Bool
    @NSManaged public var tutorial: Bool
    @NSManaged public var serverRoom: String?

}
