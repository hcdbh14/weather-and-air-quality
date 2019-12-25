import CoreData

struct CacheHandler {
    
    func saveToDataBase(response: Data? = nil, saveType: String, countryArray: [String]? = nil) {

        var storedCache: [StoredCache] = []
        storedCache = FetchCache.fetchCache(&storedCache)
        let date = Date()
        
        if saveType == "currentWeather" {
            if storedCache.count == 0 {
                let responseCache = StoredCache(context: PersistenceService.context)
                responseCache.nearMeCacheResponse = response as NSData?
                responseCache.nearMeDate = date as NSDate
                responseCache.degreeFlag = true
                responseCache.cachedLocation = [[]]
                
                PersistenceService.saveContext()
                storedCache = FetchCache.fetchCache(&storedCache)
                
            } else {
                
                for  item in storedCache {
                    item.setValue(response as NSData?, forKey: "nearMeCacheResponse")
                    item.setValue( date as NSDate, forKey: "nearMeDate")
                    if storedCache[0].cachedLocation?.count == 0 {
                        item.setValue(true, forKey: "degreeFlag")
                        item.setValue([[]], forKey: "cachedLocation")
                    }
                }
            }
        } else if saveType == "locationSelection" {
            
            let date = Date()
            if checkIfCacheExists() != true {
                let countryCache = StoredCache(context: PersistenceService.context)
                countryCache.cachedCountries = countryArray
                countryCache.date = date as NSDate
                PersistenceService.saveContext()
                
            } else {
                for  item in storedCache {
                    item.setValue(countryArray, forKey: "cachedCountries")
                    item.setValue(date as NSDate, forKey: "date")
                }
            }
        }
    }
    
    
    func DegreeType () -> Bool {
        var storedCache: [StoredCache] = []
        storedCache = FetchCache.fetchCache(&storedCache)
        
        if storedCache[0].degreeFlag == false {
            return false
        } else {
            return true
        }
    }
    
    
    func checkIfCacheExists () -> Bool {
        var storedCache: [StoredCache] = []
        storedCache = FetchCache.fetchCache(&storedCache)
        
        if storedCache.count != 0 {
            return true
        } else {
            return false
        }
    }
    
    
    func loadCache () -> [StoredCache] {
        
        var storedCache: [StoredCache] = []
        storedCache = FetchCache.fetchCache(&storedCache)
        return storedCache
    }
    
    
    func savePickedLocation (country: String, state: String, city: String) {
        
        guard var newArray = loadCache()[0].cachedLocation else {
            loadCache()[0].setValue(true, forKey: "degreeFlag")
            loadCache()[0].setValue([[]], forKey: "cachedLocation")
            return
        }
        
        if (newArray.contains([country, state, city])) {
            return
        } else {
            if loadCache()[0].cachedLocation?.count == 0 {
                return
            }
            newArray.append([country, state, city])
            loadCache()[0].setValue(newArray, forKey: "cachedLocation")
        }
    }
}
    

