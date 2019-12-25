struct ForcastDataModel {
    
    var tempeture: [Int] = []
    var weatherIconId: [String] = []
    var day: [String] = []
    var filteredDays: [String] = []
    var occurrenceDays: [String: Int] = [:]
    var timeText: [String] = []
    
    
    mutating func giveOnlyFiveDays () {
        
        var set = Set<String>()
        let result = day.filter {
            guard !set.contains($0) else {
                
                return false
            }
            set.insert($0)
            
            return true
        }
        filteredDays = result
    }
    
    
    mutating func getDayOccurrence () {
        
        var dayDictionary: [String: Int] = [:]
        
        day.forEach { dayDictionary[$0, default: 0] += 1 }
        occurrenceDays = dayDictionary
    }
}
    

