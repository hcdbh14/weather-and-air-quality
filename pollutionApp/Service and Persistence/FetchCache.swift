import CoreData

class FetchCache {
    
    static func fetchCache (_ catchArray: inout [StoredCache]) -> [StoredCache] {
        
        let fetchRequest: NSFetchRequest<StoredCache> = StoredCache.fetchRequest()
        do {  let fetchData = try PersistenceService.context.fetch(fetchRequest)
            catchArray = fetchData
        } catch {
            print("Fetch Failed")
        }
        return catchArray
    }
}
