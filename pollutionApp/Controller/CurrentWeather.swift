import UIKit
import Alamofire

private struct Constants {
    static let fahrenheit = " °F"
    static let celsius = " °c"
    static let fahrenheitButtonText = "show °F"
    static let celsiusButtonText = "show °c"
    static let airQualityText = "Air quality: "
    static let percentSymbol = "%"
    static let kilometrePerHourSymbol = "km/h"
    static let pressureUnitSymbol = "hPa"
    static let nearestCityURL = "https://api.airvisual.com/v2/nearest_city"
    static let cityURL = "https://api.airvisual.com/v2/city"
}

class CurrentWeather: UIViewController {
    
    @IBOutlet weak var forcastButton: UIButton!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempetureLabel: UILabel!
    @IBOutlet weak var pollutionLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDirection: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var airQualityProgress: UIProgressView!
    @IBOutlet weak var maxBar: UILabel!
    @IBOutlet weak var minBar: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var windDirectionDescLabel: UILabel!
    @IBOutlet weak var windSpeedDescLabel: UILabel!
    @IBOutlet weak var humidityDescLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var changeDegree: UIButton!
    @IBOutlet weak var clockLabel: UILabel!
    
    var chosenCountry: String = ""
    var chosenState: String = ""
    var chosenCity: String = ""
    var pickedLocation: Bool = false
    var latitude = ""
    var longitude = ""
    var gradient = Gradient()
    private var timeStamp: Double = 0
    private var value = 0.0
    private var degreeType = true
    private let cacheHandler = CacheHandler.init()
    override open var shouldAutorotate: Bool { return false }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setFirstUI()
        setUpLoadingScreen(view: self.view)
        designButtons()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if pickedLocation == true {
            
            cacheHandler.savePickedLocation(country: chosenCountry, state: chosenState, city: chosenCity)
            locationRequest()
        } else {
            nearMeRequest()
        }
        decideDegreeType()
    }
    
    
    private func nearMeRequest() {
        
        if checkIfCacheExists(storedCache: cacheHandler.loadCache()) == true {
            useCache()
            
        } else {
            let apiRequestInstance = ApiRequest.init()
            apiRequestInstance.getRequest(requestUrl: Constants.nearestCityURL + "?lon=\(longitude)&lat=\(latitude)&", personalKey: Keys.airVisualKey.rawValue) { [unowned self] (result) in
                
                switch result {
                    
                case .failure(let error):
                    print("error: \(error)")
                    switchFromLoadingToErrorMessage()
                    
                case .success(let response):
                    let decoder = JSONDecoder()
                    
                    do {
                        var decodedResponse: NearMe
                        self.cacheHandler.saveToDataBase(response: response, saveType: "currentWeather")
                        decodedResponse = try decoder.decode(NearMe.self, from: response)
                        
                        if let savedInt = decodedResponse.data?.current?.weather?.tp {
                            if self.cacheHandler.DegreeType() != true {
                                self.changeDegree.setTitle(Constants.celsiusButtonText, for: UIControl.State.normal)
                                var savedFloat = Float(savedInt)
                                savedFloat = round((savedFloat * 9/5) + 32)
                                self.tempetureLabel.text =   String(Int(savedFloat)) + Constants.fahrenheit
                            } else {
                                self.tempetureLabel.text =   String(savedInt) + Constants.celsius
                            }
                        }
                        if let savedInt = decodedResponse.data?.current?.pollution?.aqius {
                            self.pollutionLabel.text = Constants.airQualityText + String(savedInt)
                            self.switchBarColor(airQualityIndex: savedInt)
                        }
                        if let savedInt = decodedResponse.data?.current?.weather?.hu {
                            self.humidityLabel.text = String(savedInt) + Constants.percentSymbol
                        }
                        if let savedInt = decodedResponse.data?.current?.weather?.ws {
                            let wholeNumber = Float(savedInt * 3.6)
                            self.windSpeedLabel.text = String(wholeNumber) + Constants.kilometrePerHourSymbol
                        }
                        if let savedInt = decodedResponse.data?.location?.coordinates {
                            self.longitude = String(savedInt[0])
                            self.latitude = String(savedInt[1])
                        }
                        if let savedInt = decodedResponse.data?.current?.weather?.pr {
                            self.pressureLabel.text = String(savedInt) + Constants.pressureUnitSymbol
                        }
                        if let savedText = decodedResponse.data?.city {
                            self.cityLabel.text = savedText
                            self.chosenCity = savedText
                        }
                        if let savedInt = decodedResponse.data?.current?.weather?.wd {
                            self.decideWindDirection(directionIndex: savedInt)
                        }
                        if let weatherIconIndecation = decodedResponse.data?.current?.weather?.ic {
                            self.weatherIcon.image = UIImage.init(named: setWeatherIcon(iconName: weatherIconIndecation))
                        }
                        closeLoadingScreen()
                        self.fadeInAnimation()
                        
                    } catch let error {
                        print("error: \(error)")
                    }
                }
            }
        }
    }
    
    private func locationRequest () {
        
        let encodedCountry = chosenCountry.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let encodedState = chosenState.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let encodedCity = chosenCity.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        let apiRequestInstance = ApiRequest.init()
        
        apiRequestInstance.getRequest(requestUrl: Constants.cityURL + "?city=\(encodedCity)&state=\(encodedState)&country=\(encodedCountry)&", personalKey: Keys.airVisualKey.rawValue) { [unowned self] (result) in
            
            switch result {
                
            case .failure(let error):
                print("error: \(error)")
                switchFromLoadingToErrorMessage()
                
            case .success(let response):
                let decoder = JSONDecoder()
                
                do {
                    var decodedResponse: NearMe
                    decodedResponse = try decoder.decode(NearMe.self, from: response)
                    
                    if self.cacheHandler.checkIfCacheExists() == false {
                        let responseCache = StoredCache(context: PersistenceService.context)
                        responseCache.degreeFlag = true
                        
                        PersistenceService.saveContext()
                    }
                    
                    if let savedInt = decodedResponse.data?.current?.weather?.tp {
                        if self.cacheHandler.DegreeType() ==  false {
                            self.changeDegree.setTitle(Constants.celsiusButtonText, for: UIControl.State.normal)
                            var savedFloat = Float(savedInt)
                            savedFloat = round((savedFloat * 9/5) + 32)
                            self.tempetureLabel.text =   String(Int(savedFloat)) + Constants.fahrenheit
                        } else {
                            self.tempetureLabel.text =   String(savedInt) + Constants.celsius
                        }
                    }
                    if let savedInt = decodedResponse.data?.current?.pollution?.aqius {
                        self.pollutionLabel.text = Constants.airQualityText + String(savedInt)
                        self.switchBarColor(airQualityIndex: savedInt)
                    }
                    if let savedInt = decodedResponse.data?.current?.weather?.hu {
                        self.humidityLabel.text = String(savedInt) + Constants.percentSymbol
                    }
                    if let savedInt = decodedResponse.data?.current?.weather?.ws {
                        let wholeNumber = Float(savedInt * 3.6)
                        self.windSpeedLabel.text = String(wholeNumber) + Constants.kilometrePerHourSymbol
                    }
                    if let savedInt = decodedResponse.data?.location?.coordinates {
                        self.longitude = String(savedInt[0])
                        self.latitude = String(savedInt[1])
                        let dateHandler = DateHandler.init(latitude: self.latitude, longitude: self.longitude)
                        dateHandler.getDateFromLocation(completion: { (result) in
                            self.clockLabel.text = result
                        })
                    }
                    if let savedInt = decodedResponse.data?.current?.weather?.pr {
                        self.pressureLabel.text = String(savedInt) + Constants.pressureUnitSymbol
                    }
                    if let savedText = decodedResponse.data?.city {
                        self.cityLabel.text = savedText
                        self.chosenCity = savedText
                    }
                    if let savedInt = decodedResponse.data?.current?.weather?.wd {
                        self.decideWindDirection(directionIndex: savedInt)
                    }
                    if let weatherIconIndecation = decodedResponse.data?.current?.weather?.ic {
                        self.weatherIcon.image = UIImage.init(named: setWeatherIcon(iconName: weatherIconIndecation))
                    }
                    closeLoadingScreen()
                    self.fadeInAnimation()
                    
                } catch let error {
                    print("error: \(error)")
                }
            }
        }
    }
    
    private func useCache () {
        let decoder = JSONDecoder()
        
        do {
            let cache = cacheHandler.loadCache()
            let decodedResponse =  try decoder.decode(NearMe.self, from: cache[0].nearMeCacheResponse! as Data)
            
            if let savedInt = decodedResponse.data?.current?.weather?.tp {
                if cacheHandler.DegreeType() == false {
                    changeDegree.setTitle(Constants.fahrenheitButtonText, for: UIControl.State.normal)
                    var savedFloat = Float(savedInt)
                    savedFloat = round((savedFloat * 9/5) + 32)
                    tempetureLabel.text =   String(Int(savedFloat)) + Constants.fahrenheit
                } else {
                    tempetureLabel.text =   String(savedInt) + Constants.celsius
                }
            }
            if let savedInt = decodedResponse.data?.current?.pollution?.aqius {
                pollutionLabel.text = Constants.airQualityText + String(savedInt)
                switchBarColor(airQualityIndex: savedInt)
            }
            if let savedInt = decodedResponse.data?.current?.weather?.hu {
                humidityLabel.text = String(savedInt) + Constants.percentSymbol
            }
            if let savedInt = decodedResponse.data?.current?.weather?.ws {
                let wholeNumber = Float(savedInt * 3.6)
                windSpeedLabel.text = String(wholeNumber) + Constants.kilometrePerHourSymbol
            }
            
            if cache[0].degreeFlag == false {
                changeDegree.setTitle(Constants.celsiusButtonText, for: UIControl.State.normal)
            }
            
            if let savedInt = decodedResponse.data?.location?.coordinates {
                longitude = String(savedInt[0])
                latitude = String(savedInt[1])
            }
            if let savedInt = decodedResponse.data?.current?.weather?.pr {
                pressureLabel.text = String(savedInt) + Constants.pressureUnitSymbol
            }
            if let savedText = decodedResponse.data?.city {
                cityLabel.text = savedText
                chosenCity = savedText
            }
            if let savedInt = decodedResponse.data?.current?.weather?.wd {
                decideWindDirection(directionIndex: savedInt)
            }
            if let weatherIconIndecation = decodedResponse.data?.current?.weather?.ic {
                weatherIcon.image = UIImage.init(named: setWeatherIcon(iconName: weatherIconIndecation))
            }
            closeLoadingScreen()
            fadeInAnimation()
        } catch {
            print("Fetch Failed")
        }
    }
    
    
    @IBAction func changeDegreeType(_ sender: Any) {
        if cacheHandler.loadCache()[0].degreeFlag == true {
            cacheHandler.loadCache()[0].setValue(false, forKey: "degreeFlag")
            let string = tempetureLabel.text
            
            if (string?.contains("-"))! {
                if var number = Float(string!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                    number = number * -1
                    number = round((number * 9/5) + 32)
                    tempetureLabel.text =  String(Int(number)) + Constants.fahrenheit
                    changeDegree.setTitle(Constants.celsiusButtonText, for: UIControl.State.normal)
                    
                }
            } else {
                if var number = Float(string!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                    number = round((number * 9/5) + 32)
                    tempetureLabel.text =  String(Int(number)) + Constants.fahrenheit
                    changeDegree.setTitle(Constants.celsiusButtonText, for: UIControl.State.normal)
                }
            }
        } else {
            cacheHandler.loadCache()[0].setValue(true, forKey: "degreeFlag")
            let string = self.tempetureLabel.text
            if (string?.contains("-"))! {
                if var number = Float(string!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                    number = number * -1
                    number = round((number - 32) * 5/9)
                    tempetureLabel.text =  String(Int(number)) + Constants.celsius
                    changeDegree.setTitle(Constants.fahrenheitButtonText, for: UIControl.State.normal)
                }
            } else {
                if var number = Float(string!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                    number = round((number - 32) * 5/9)
                    tempetureLabel.text =  String(Int(number)) + Constants.celsius
                    changeDegree.setTitle(Constants.fahrenheitButtonText, for: UIControl.State.normal)
                }
            }
        }
        degreeType = cacheHandler.loadCache()[0].degreeFlag
    }
    
    
    private func decideWindDirection (directionIndex: Int) {
        switch directionIndex {
        case 0 ... 20 :
            self.windDirection.text = "North"
        case 21 ... 70 :
            self.windDirection.text = "North East"
        case 71 ... 110 :
            self.windDirection.text = "East"
        case 111 ... 160 :
            self.windDirection.text = "South East"
        case 161 ... 200 :
            self.windDirection.text = "South"
        case 201 ... 250 :
            self.windDirection.text = "South West"
        case 251 ... 290 :
            self.windDirection.text = "West"
        case 291 ... 340 :
            self.windDirection.text = "North West"
        case 341 ... 360 :
            self.windDirection.text = "North"
        default :
            self.windDirection.text = "no data"
        }
    }
    
    
    private func fadeInAnimation () {
        let firstUIElements = [cityLabel as UILabel, tempetureLabel as UILabel, weatherIcon as UIImageView, changeDegree as UIButton, forcastButton as UIButton ]
        let secondUiElements = [pollutionLabel as UILabel, maxBar as UILabel, minBar as UILabel, detailsLabel as UILabel, humidityDescLabel as UILabel, humidityLabel as UILabel, windSpeedLabel as UILabel, windSpeedDescLabel as UILabel, windDirection as UILabel, windSpeedDescLabel as UILabel, windDirectionDescLabel as UILabel, windSpeedDescLabel as UILabel, pressure as UILabel, pressureLabel as UILabel, clockLabel as UILabel, infoButton as UIButton, airQualityProgress as UIProgressView]
        
        for i in firstUIElements {
            i.isHidden = false
            i.alpha = 0.0
        }
        for i in secondUiElements {
            i.isHidden = false
            i.alpha = 0.0
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveLinear, animations: {
            
            for i in firstUIElements {
                i.alpha = 1.0
            }
            if self.pickedLocation == true {
                self.clockLabel.alpha = 1.0
            }
        }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0.8, options: .curveLinear, animations: {
            
            for i in secondUiElements {
                i.alpha = 1.0
            }
        }, completion: nil)
    }
    
    
    private func designButtons () {
        
        forcastButton.backgroundColor = UIColor(red: 40/255, green: 44/255, blue: 53/255, alpha: 0.5)
        forcastButton.layer.cornerRadius = 20
        forcastButton.layer.borderWidth = 0.5
        forcastButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        forcastButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        forcastButton.layer.shadowOpacity = 1.0
        forcastButton.layer.shadowRadius = 0.0
        forcastButton.layer.masksToBounds = false
        weatherIcon.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        weatherIcon.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        weatherIcon.layer.shadowOpacity = 1.0
        weatherIcon.layer.shadowRadius = 0.0
        weatherIcon.layer.masksToBounds = false
        airQualityProgress.layer.cornerRadius = 5
        airQualityProgress.layer.borderWidth = 0.4
    }
    
    
    private func switchBarColor(airQualityIndex: Int) {
        let  xMax = 1.0;
        let  xMin = 0.0;
        var  yMax: Double
        var  yMin = 0.0
        var   percent: Double
        var   outputX = 0.0
        
        switch airQualityIndex {
        case let airQualityIndex where airQualityIndex <= 50:
            yMax = 50
            airQualityProgress.progressTintColor = UIColor.init(named: "green")
            
        case let airQualityIndex where 51 ... 100 ~= airQualityIndex:
            yMax = 100
            yMin = 51
            airQualityProgress.progressTintColor = UIColor.init(named: "yellow")
            
        case let airQualityIndex where 101...150 ~= airQualityIndex:
            yMax = 150.0
            yMin = 101.0
            airQualityProgress.progressTintColor = UIColor.init(named: "orange")
            
        case let airQualityIndex where 151...200 ~= airQualityIndex:
            yMax = 200.0
            yMin = 151.0
            airQualityProgress.progressTintColor = UIColor.init(named: "red")
            
        case let airQualityIndex where 201...300 ~= airQualityIndex:
            yMax = 300.0
            yMin = 201.0
            airQualityProgress.progressTintColor = UIColor.init(named: "purple")
            
        case let airQualityIndex where 301...500 ~= airQualityIndex :
            yMax = 500.0
            yMin = 301.0
            airQualityProgress.progressTintColor = UIColor.init(named: "bordo")
        default:
            return
        }
        maxBar.text = String(format: "%.0f", yMax)
        minBar.text = String(format: "%.0f", yMin)
        percent = (Double(airQualityIndex) - yMin) / (yMax - yMin)
        outputX = percent * (xMax - xMin) + xMin
        airQualityProgress.setProgress(Float(outputX), animated: false)
    }
    
    
    private func ResizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        var newSize: CGSize
        
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    private func setFirstUI () {
        
        let uiElements = [cityLabel as UILabel, tempetureLabel as UILabel, weatherIcon as UIImageView, pollutionLabel as UILabel, maxBar as UILabel, minBar as UILabel, detailsLabel as UILabel, humidityDescLabel as UILabel, humidityLabel as UILabel, windSpeedLabel as UILabel, windSpeedDescLabel as UILabel, windDirection as UILabel, windSpeedDescLabel as UILabel, windDirectionDescLabel as UILabel, windSpeedDescLabel as UILabel, pressure as UILabel, pressureLabel as UILabel, clockLabel as UILabel, infoButton as UIButton, changeDegree as UIButton, forcastButton as UIButton, airQualityProgress as UIProgressView]
        
        for i in uiElements {
            i.isHidden = true
        }
        
        gradient.setBackgroundGradient(view: self.view)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Refresh", comment: "Refresh"), style: .plain, target: self, action: #selector(refresh(_:)))
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage = nil
        
        let menuButton: UIButton = UIButton(type: UIButton.ButtonType.custom)
        menuButton.setImage(UIImage(systemName: "plus"), for: .normal)
        menuButton.addTarget(self, action: #selector(openMenu(_:)), for: UIControl.Event.touchUpInside)
        let barButton = UIBarButtonItem(customView: menuButton)
        navigationItem.leftBarButtonItem = barButton
    }
    
    
    private func decideDegreeType () {
        if cacheHandler.checkIfCacheExists() == false {
            return
        } else {
            degreeType = cacheHandler.loadCache()[0].degreeFlag
        }
    }
    
    
    @objc private func openMenu(_ sender: Any) {
        performSegue(withIdentifier: "openMenu", sender: self)
    }
    
    
    @objc private func refresh(_ sender: Any) {
        performSegue(withIdentifier: "refresh", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToLoadForcast" {
            
            if let controller = segue.destination as? LoadForcast {
                controller.latitude = latitude
                controller.longitude = longitude
                controller.degreeType = degreeType
                controller.chosenCountry = chosenCountry
                controller.chosenState = chosenState
                controller.chosenCity = chosenCity
                controller.pickedLocation = pickedLocation
                controller.gradient = gradient
                
            }
        }
        if segue.identifier == "openMenu" {
            
            if let controller = segue.destination as? Menu {
                controller.gradient = gradient
                let trans = CATransition()
                trans.type = CATransitionType.push
                trans.subtype = CATransitionSubtype.fromLeft
                trans.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
                trans.duration = 0.35
                self.navigationController?.view.layer.add(trans, forKey: nil)
            }
        }
    }
}
