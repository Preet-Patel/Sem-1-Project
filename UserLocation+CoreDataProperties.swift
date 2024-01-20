//
//  UserLocation+CoreDataProperties.swift
//  Preet_Pambhar_FE_8942790
//
//  Created by user238091 on 12/3/23.
//
//

import Foundation
import CoreData


extension UserLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserLocation> {
        return NSFetchRequest<UserLocation>(entityName: "UserLocation")
    }

    @NSManaged public var location: String?
    @NSManaged public var source: String?
    @NSManaged public var newsDescription: String?
    @NSManaged public var author: String?
    @NSManaged public var title: String?

}

extension UserLocation : Identifiable {

}
