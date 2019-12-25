import UIKit
import Alamofire

class StatesTableViewController: UITableViewController {
    
    @IBOutlet var statesTableView: UITableView!
    
    var stateList: [String] = []
    var chosenCountry: String = ""
    var chosenState: String = ""
    private var encodedCountry: String = ""
    
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLoadingScreen(view: self.view)
        tableView.tableFooterView = UIView()
        statesRequest()
        
    }

    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateList.count
    }
    
  
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath) as? StateCell else {
            return UITableViewCell()
        }
        cell.stateLabel.text = stateList[indexPath.row]
        return cell
    }
    
    
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! StateCell
        self.chosenState = cell.stateLabel.text!
        performSegue(withIdentifier: "userChoseState", sender: nil)
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userChoseState" {
            if self.tableView.indexPathForSelectedRow != nil {
                let controller = segue.destination as! CityTableView
                controller.chosenState = chosenState
                controller.chosenCountry = chosenCountry
                print(self.chosenState)
            }
        }
    }
    
    
    
    private func statesRequest () {
        
        self.encodedCountry = chosenCountry.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let apiRequestInstance = ApiRequest.init()
        
        apiRequestInstance.getRequest(requestUrl: "https://api.airvisual.com/v2/states?country=\(encodedCountry)&", personalKey: "d5124c42-f5de-4a46-b117-3f08a4514d57") { (result) in
            
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
                    self.tableView.reloadData()
                    closeLoadingScreen()
                    
                } catch let error {
                    print("error: \(error)")
                }
                
            }
        }
    }
}


