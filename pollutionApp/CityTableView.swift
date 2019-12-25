import UIKit
import Alamofire

class CityTableView: UITableViewController {
    
    var cityList: [String] = []
    var chosenCountry: String = ""
    var chosenState: String = ""
    var chosenCity: String = ""
    private var encodedState: String = ""
    private var encodedCountry: String = ""

    
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLoadingScreen(view: self.view)
        tableView.tableFooterView = UIView()
        citiesRequest()
        
    }
    

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityList.count
    }
    
  
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as? CityCell else {
            return UITableViewCell()
        }
        cell.cityLabel.text = cityList[indexPath.row]
        return cell
    }
    
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CityCell
        self.chosenCity = cell.cityLabel.text!
        
        self.dismiss(animated: true, completion: nil)
      
        performSegue(withIdentifier: "userChoseCity", sender: nil)
    }
    
 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userChoseCity" {
            if self.tableView.indexPathForSelectedRow != nil {
                let controller = segue.destination as! NearMeWeather
                controller.chosenCountry = chosenCountry
                controller.chosenState = chosenState
                controller.chosenCity = chosenCity
                controller.pickedLocation = true
                print(self.chosenCity)
            }
        }
    }
    
    
    
    private func citiesRequest () {
        
        self.encodedState = chosenState.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        self.encodedCountry = chosenCountry.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let apiRequestInstance = ApiRequest.init()
        
        apiRequestInstance.getRequest(requestUrl: "https://api.airvisual.com/v2/cities?country=\(encodedCountry)&state=\(encodedState)&", personalKey: "d5124c42-f5de-4a46-b117-3f08a4514d57") { (result) in
            
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
                    self.tableView.reloadData()
                    closeLoadingScreen()
                    
                } catch let error {
                    print("error: \(error)")
                }
                
            }
        }
    }
}



