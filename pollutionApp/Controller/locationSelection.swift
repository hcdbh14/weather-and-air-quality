import UIKit
import Alamofire

protocol userChosenLocationDataDelegate: class {
    
    func sendArrayToMenu(dataArray:[String])
}

private struct Constants {
    static let chooseCountryText = "Choose Country"
    static let chooseStateText = "Choose State"
    static let chooseCityText = "Choose City"
    static let countryListURL = "https://api.airvisual.com/v2/countries?"
    static let stateListURL = "https://api.airvisual.com/v2/states"
    static let cityListURL = "https://api.airvisual.com/v2/cities"
}

class locationSelection: UITableViewController {
    
    @IBOutlet weak var helpTitle: UILabel!
    @IBOutlet var countriesTableView: UITableView!
    
    weak var mDelegate: userChosenLocationDataDelegate?
    private var countries: [String] = []
    private var chosenCountry: String = ""
    private let calendar = Calendar.current
    private var encodedCountry: String = ""
    private var encodedState: String = ""
    private var stateList: [String] = []
    private var chosenState: String = ""
    private var cityList: [String] = []
    private var flowCount: Int = 0
    private var chosenCity: String = ""
    private let cacheHandler = CacheHandler.init()
    override open var shouldAutorotate: Bool { return false }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLoadingScreen(view: view, isChooseLocation: true)
        tableView.tableFooterView = UIView()
        countriesRequest()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch flowCount {
            
        case 0:
            return countries.count
        case 1:
            return stateList.count
        case 2:
            return cityList.count
        default:
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch flowCount {
        case 0:
            guard  let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell") as? CountryCell else {
                return UITableViewCell()
            }
            cell.countryLabel.text = countries[indexPath.row]
            return cell
            
        case 1:
            guard  let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath) as? StateCell else {
                return UITableViewCell()
            }
            cell.stateLabel.text = stateList[indexPath.row]
            return cell
            
        case 2:
            guard  let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as? CityCell else {
                return UITableViewCell()
            }
            cell.cityLabel.text = cityList[indexPath.row]
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch flowCount {
            
        case 0:
            let cell = tableView.cellForRow(at: indexPath) as! CountryCell
            chosenCountry = cell.countryLabel.text ?? ""
            flowCount += 1
            statesRequest()
            
        case 1:
            let cell = tableView.cellForRow(at: indexPath) as! StateCell
            chosenState = cell.stateLabel.text ?? ""
            flowCount += 1
            citiesRequest()
            
        case 2:
            tableView.isUserInteractionEnabled = false
            let cell = tableView.cellForRow(at: indexPath) as! CityCell
            chosenCity = cell.cityLabel.text ?? ""
            mDelegate?.sendArrayToMenu(dataArray: [chosenCountry, chosenState, chosenCity])
            dismiss(animated: true, completion: nil)
            
        default:
            return
        }
    }
    
    
    private func isToday () -> Bool {
        
        if cacheHandler.checkIfCacheExists() == false {
            return false
        }
        guard let safeCachedDate = cacheHandler.loadCache()[0].date as Date? else {
            return false
        }
        let isToday = calendar.isDateInToday(safeCachedDate)
        return isToday
    }
    
    
    private func fixDataForService () {
        
        if chosenCountry.contains("SAR") == true {
            
            chosenCountry.removeLast(4)
            
        } else if chosenCountry == "United Kingdom" {
            
            chosenCountry = "UK"
        }
    }
    
    
    private func countriesRequest () {
        
        helpTitle.text = Constants.chooseCountryText
        setUpLoadingScreen(view: view, isChooseLocation: true)
        
        if  isToday() != false {
            countries = cacheHandler.loadCache()[0].cachedCountries ?? []
            closeLoadingScreen()
            
        } else {
            
            let apiRequestInstance = ApiRequest.init()
            apiRequestInstance.getRequest(requestUrl: Constants.countryListURL, personalKey: Keys.airVisualKey.rawValue) { [unowned self] (result) in
                
                switch result {
                    
                case .failure(let error):
                    print("error: \(error)")
                    switchFromLoadingToErrorMessage()
                    
                case .success(let response):
                    let decoder = JSONDecoder()
                    do {
                        let decodedResponse = try decoder.decode(Countries.self, from: response)
                        
                        if let downloadedCountries = decodedResponse.data {
                            self.countries = downloadedCountries.map {$0.country} as! [String]
                            self.cacheHandler.saveToDataBase(saveType: "locationSelection", countryArray: self.countries)
                        }
                        self.tableView.reloadData()
                        closeLoadingScreen()
                    } catch let error {
                        print("error: \(error)")
                    }
                }
            }
        }
    }
    
    
    private func statesRequest () {
        
        helpTitle.text = ""
        countries.removeAll()
        tableView.reloadData()
        setUpLoadingScreen(view: self.view, isChooseLocation: true)
        
        fixDataForService()
        
        encodedCountry = chosenCountry.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let apiRequestInstance = ApiRequest.init()
        
        apiRequestInstance.getRequest(requestUrl: Constants.stateListURL + "?country=\(encodedCountry)&", personalKey: Keys.airVisualKey.rawValue) { [unowned self] (result) in
            
            switch result {
                
            case .failure(let error):
                print("error: \(error)")
                switchFromLoadingToErrorMessage()
                
            case .success(let response):
                let decoder = JSONDecoder()
                do {
                    let decodedResponse = try decoder.decode(States.self, from: response)
                    
                    if let downloadedStates = decodedResponse.data {
                        
                        let arrayedStates = downloadedStates.map {$0.state} as! [String]
                        print(arrayedStates)
                        self.stateList = arrayedStates
                    }
                    DispatchQueue.main.async {
                        self.helpTitle.text = Constants.chooseStateText
                        self.tableView.reloadData()
                        closeLoadingScreen()
                    }
                } catch let error {
                    print("error: \(error)")
                }
            }
        }
    }
    
    
    private func citiesRequest () {
        
        helpTitle.text = ""
        stateList.removeAll()
        tableView.reloadData()
        setUpLoadingScreen(view: self.view, isChooseLocation: true)
        
        encodedState = chosenState.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        encodedCountry = chosenCountry.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let apiRequestInstance = ApiRequest.init()
        
        apiRequestInstance.getRequest(requestUrl: Constants.cityListURL + "?country=\(encodedCountry)&state=\(encodedState)&", personalKey: Keys.airVisualKey.rawValue) { [unowned self] (result) in
            
            switch result {
                
            case .failure(let error):
                print("error: \(error)")
                switchFromLoadingToErrorMessage()
            
            case .success(let response):
                let decoder = JSONDecoder()
                do {
                    let decodedResponse = try decoder.decode(Cities.self, from: response)
                    
                    if let downloadedCities = decodedResponse.data {
                        
                        let arrayedCities = downloadedCities.map {$0.city} as! [String]
                        print(arrayedCities)
                        self.cityList = arrayedCities
                    }
                    DispatchQueue.main.async {
                        self.helpTitle.text = Constants.chooseCityText
                        self.tableView.reloadData()
                        closeLoadingScreen()
                    }
                } catch let error {
                    print("error: \(error)")
                }
            }
        }
    }
}



