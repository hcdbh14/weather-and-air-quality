import CoreLocation

struct DateHandler {
    var latitude = ""
    var longitude = ""
    
    func getDateFromLocation (completion: @escaping (_ result: String) -> ()) {
        
        let location = CLLocation(latitude: Double(latitude) ?? 0, longitude: Double(longitude) ?? 0)
        let coder = CLGeocoder()
        var finalDate = ""
        coder.reverseGeocodeLocation(location) { (placemarks, error) in
            let place = placemarks?.last;
            if let timeStampFromPlace = place?.timeZone?.secondsFromGMT() {
                
                let UTCDate = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yy/MM/dd HH:mm"
                formatter.timeZone = TimeZone(identifier:"GMT")
                
                let defaultTimeZoneStr = formatter.string(from: UTCDate)
                
                guard let date = formatter.date(from: defaultTimeZoneStr) else {return}
                
                let dateInLocation = date.advanced(by: TimeInterval(timeStampFromPlace))
                
                finalDate = formatter.string(from: dateInLocation)
                completion(finalDate)
            }
        }
    }
}
