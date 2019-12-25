import UIKit
import CoreData

private struct menuCellHandler: tableCellReturn {
    
    let indexPath: IndexPath
    let tableView: UITableView
    let lastRow: Int
    let tableData: [[String]]
    let firstRow = 0
    
    func returnCell() -> UITableViewCell {
        
        switch indexPath.row {
            
        case firstRow:
            guard let firstCell = tableView.dequeueReusableCell(withIdentifier: "firstCell", for: indexPath) as? firstCell else {
                return UITableViewCell()
            }
            return firstCell
            
        case lastRow:
            guard let lastCell = tableView.dequeueReusableCell(withIdentifier: "addLocationCell", for: indexPath) as? addLocationCell else {
                return UITableViewCell()
            }
            return lastCell
            
        default:
            guard  let locationCell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as? locationCell else {
                return UITableViewCell()
            }
            
            locationCell.countryLabel.text = tableData[indexPath.row][0]
            locationCell.cityLabel.text = tableData[indexPath.row][2]
            
            return locationCell
        }
    }
}


private struct MenuConstants {
    static let numberOfExtraCells = 1
    static let secondRow = 1
}


class Menu: UITableViewController {
    
    var gradient = Gradient()
    private var storedCache: [StoredCache] = []
    private var chosenCountry: String = ""
    private var chosenState: String = ""
    private var chosenCity: String = ""
    private var savedLocations: [[String]] = [[]]
    override open var shouldAutorotate: Bool { return false }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradient.setBackgroundGradient(view: view, onTableView: self)
        checkIfCacheNotEmpty()
        tableView.tableFooterView = UIView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (savedLocations.count) + MenuConstants.numberOfExtraCells
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = menuCellHandler.init(indexPath: indexPath, tableView: tableView, lastRow: savedLocations.count, tableData: savedLocations)
        
        return cell.returnCell()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            performSegue(withIdentifier: "nearestLocation", sender: nil)
            
        } else if indexPath.row == savedLocations.count {
            performSegue(withIdentifier: "chooseLocation", sender: nil)
            
        } else {
            prepareChosenLocationDetails(arrayOfLocation: savedLocations[indexPath.row])
            performSegue(withIdentifier: "locationIsChosen", sender: nil)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexpath: IndexPath) {
        if editingStyle == .delete {
            
            var newArray =  storedCache[0].cachedLocation!
            newArray.remove(at: indexpath.row)
            storedCache[0].setValue(newArray, forKey: "cachedLocation")
            savedLocations.remove(at: indexpath.row)
            tableView.deleteRows(at: [indexpath], with: .left)
        }
    }
    
    
    public override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        if MenuConstants.secondRow ... savedLocations.count ~= indexPath.row && indexPath.row < savedLocations.count {
            return UITableViewCell.EditingStyle.delete
            
        } else {
            return UITableViewCell.EditingStyle.none
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "chooseLocation" {
            if let controller = segue.destination as? locationSelection {
                controller.mDelegate = self
            }
            
        } else if  segue.identifier == "locationIsChosen" {
            if let controller = segue.destination as? CurrentWeather {
                controller.chosenCountry = chosenCountry
                controller.chosenState = chosenState
                controller.chosenCity = chosenCity
                controller.pickedLocation = true
                controller.gradient = gradient
            }
        }
    }
    
    
    private func prepareChosenLocationDetails (arrayOfLocation: [String]) {
        
        let country = 0
        let state = 1
        let city = 2
        
        chosenCountry = arrayOfLocation[country]
        chosenState = arrayOfLocation[state]
        chosenCity = arrayOfLocation[city]
    }
    
    
    private func checkIfCacheNotEmpty () {
        
        storedCache = FetchCache.fetchCache(&storedCache)
        
        if storedCache.count != 0 {
            savedLocations = storedCache[0].cachedLocation ?? [[]]
        }
    }
}

extension Menu: userChosenLocationDataDelegate {
    
    func sendArrayToMenu(dataArray:[String]) {
        chosenCountry = dataArray[0]
        chosenState = dataArray[1]
        chosenCity = dataArray[2]
        performSegue(withIdentifier: "locationIsChosen", sender: nil)
        
    }
}
