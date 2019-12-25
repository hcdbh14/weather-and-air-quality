import Foundation
import CoreData


extension StoredCache {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredCache> {
        return NSFetchRequest<StoredCache>(entityName: "StoredCache")
    }
    
    @NSManaged public var cachedLocation: [[String]]?
    @NSManaged public var cachedCountries: [String]?
    @NSManaged public var date: NSDate?
    @NSManaged public var degreeFlag: Bool
    @NSManaged public var nearMeCacheResponse: NSData?
    @NSManaged public var nearMeDate: NSDate?
    
}
