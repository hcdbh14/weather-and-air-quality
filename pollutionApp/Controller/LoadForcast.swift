import UIKit
import CoreLocation

private enum DayOfTheWeek: Int8 {
    
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
 
    public var dayName: String {
        
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}

private struct Constants {
    static let metricText = "metric"
    static let forcastURL = "https://api.openweathermap.org/data/2.5/forecast"
}

class LoadForcast: UIViewController {
    
    @IBOutlet weak var loadingScreen: UIView!
    
    var latitude = ""
    var longitude = ""
    var chosenCountry = ""
    var chosenState = ""
    var chosenCity = ""
    var degreeType = true
    var pickedLocation: Bool = false
    var gradient = Gradient()
    private var locationTimeStampHour: [Int] = []
    private var hourArray: [String] = []
    private var timestampUTC: [Int] = []
    private var offSetUTC: Int = 0
    private var arrangeDataForCells = ForcastDataModel.init()
    override open var shouldAutorotate: Bool { return false }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradient.setBackgroundGradient(view: view)
        getDateFromLocation()
        setUpLoadingScreen(view: view)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.forcastRequest()
        }
    }
    
    
    private func forcastRequest () {
        let apiRequestInstance = ApiRequest.init()
        let celsiusOrFahrenheit = decideDegreeType()
        
        apiRequestInstance.getRequest(requestUrl: Constants.forcastURL + "?lat=\(latitude)&lon=\(longitude)&APPID=\(Keys.openWeatherKey.rawValue)&units=\(celsiusOrFahrenheit)&", personalKey: "") { [unowned self] (result) in
            
            switch result {
            case .failure(let error):
                print("error: \(error)")
                switchFromLoadingToErrorMessage()
                
            case .success(let response):
                let decoder = JSONDecoder()
                do {
                    let decodedResponse = try decoder.decode(ForcastData.self, from: response)
                    
                    if let decodedList = decodedResponse.list {
                        let arrayedTempeture = decodedList.map {$0.main?.temp} as! [Double]
                        let arrayedTempetureConverted = self.convertDoublesToInts(arrayOfDoubles: arrayedTempeture)
                        let weatherIconId = decodedList.map {$0.weather![0].icon} as! [String]
                        let timestamps = decodedList.map {$0.dt} as! [Int]
                        self.timestampUTC = timestamps
                        let day = self.getDayFromTimeStamp()
                        self.arrangeDataForCells.tempeture = arrayedTempetureConverted
                        self.arrangeDataForCells.weatherIconId = weatherIconId
                        self.arrangeDataForCells.day = day
                        self.arrangeDataForCells.timeText = self.hourArray
                        self.performSegue(withIdentifier: "loadingFinished", sender: nil)
                    }
                } catch let error {
                    print("error: \(error)")
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "loadingFinished" {
            if let controller = segue.destination as? Forcast {
                controller.arrangeDataForCells = arrangeDataForCells
                controller.degreeType = degreeType
                controller.chosenCountry = chosenCountry
                controller.chosenState = chosenState
                controller.chosenCity = chosenCity
                controller.pickedLocation = pickedLocation
                controller.gradient = gradient
            }
        }
    }
    
    
    private func stringFromTimeInterval(interval: Double) -> NSString {
        
        let hours = (Int(interval) / 3600)
        let minutes = Int(interval / 60) - Int(hours * 60)
        let seconds = Int(interval) - (Int(interval / 60) * 60)
        return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }
    
    
    private func decideDateFromLocation () {
        var count = 0
        
        for _ in timestampUTC {
            let newTimeInterval = timestampUTC[count] + offSetUTC
            locationTimeStampHour.append(newTimeInterval)
            count += 1
        }
    }
    
    
    private func getDayFromTimeStamp () -> [String] {
        decideDateFromLocation()
        var dayNames: [String] = []
        
        for i in locationTimeStampHour {
            
            let date = NSDate(timeIntervalSince1970: Double(i))
            let weekday = Calendar.current.component(.weekday, from: date as Date)
            let dayNum = Int8(weekday)
            let day = DayOfTheWeek.init(rawValue: dayNum)
            dayNames.append(day?.dayName ?? "")
            
            let hourOnlyFromDate = date.description
            let start = hourOnlyFromDate.index(hourOnlyFromDate.startIndex, offsetBy: 11)
            let end = hourOnlyFromDate.index(hourOnlyFromDate.endIndex, offsetBy: -9)
            let result = hourOnlyFromDate[start..<end]
            
            hourArray.append(String(result))
        }
        return dayNames
    }
    
    
    private func convertDoublesToInts (arrayOfDoubles: [Double]) -> [Int] {
        
        var intArray: [Int] = []
        var newInt = 0
        
        for i in arrayOfDoubles {
            
            newInt = Int(i)
            intArray.append(newInt)
        }
        return intArray
    }
    
    
    private func decideDegreeType () -> String {
        if degreeType == true {
            return Constants.metricText
        } else {
            return ""
        }
    }
    
    
    private func getDateFromLocation () {
        
        let location = CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!)
        let coder = CLGeocoder();
        coder.reverseGeocodeLocation(location) { (placemarks, error) in
            let place = placemarks?.last;
            
            if let newOffset = place?.timeZone?.secondsFromGMT() {
                self.offSetUTC = newOffset
            }
        }
    }
}



