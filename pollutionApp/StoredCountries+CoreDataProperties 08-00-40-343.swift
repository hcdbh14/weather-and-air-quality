//
//  StoredCountries+CoreDataProperties.swift
//  
//
//  Created by Kenny Kurochkin on 17/09/2019.
//
//

import Foundation
import CoreData


extension StoredCountries {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredCountries> {
        return NSFetchRequest<StoredCountries>(entityName: "StoredCountries")
    }

    @NSManaged public var country: String?

}
