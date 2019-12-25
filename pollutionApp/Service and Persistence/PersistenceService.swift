import Foundation
import CoreData

class PersistenceService {
    
    private init() {}
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    
    static var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "pollutionApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    
    static  func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("SAVED")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

 func checkIfCacheExists (storedCache: [StoredCache] ) -> Bool {
    
    if storedCache.count == 0 {
        return false
    }
    
    guard storedCache[0].nearMeCacheResponse != nil  else {
        print("nearMeCacheResponse was nil")
        return false
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    let catchedDate = formatter.date(from: formatter.string(from: storedCache[0].nearMeDate! as Date))
    let timestamp = NSDate().timeIntervalSince(catchedDate!)
    if timestamp < 300 {
        return true
    }
    return false
}
