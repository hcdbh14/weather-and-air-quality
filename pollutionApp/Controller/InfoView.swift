import UIKit

private struct infoCellStruct: tableCellReturn {
    
    let indexPath: IndexPath
    let tableView: UITableView
    
    func returnCell() -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell") as? InfoCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        
        switch indexPath.row {
            
        case 0:
            cell.minNum.text = "0"
            cell.maxNum.text = "50"
            cell.infoTitle.text = "GOOD"
            cell.infoText.text = "No health impacts."
            cell.backgroundColor = UIColor.init(named: "green")
            return cell
            
        case 1:
            cell.minNum.text = "51"
            cell.maxNum.text = "100"
            cell.infoTitle.text = "MODERATE"
            cell.infoText.text = "Potential mild impacts for extremely sensitive groups."
            cell.backgroundColor = UIColor.init(named: "yellow")
            return cell
            
        case 2:
            cell.minNum.text = "101"
            cell.maxNum.text = "150"
            cell.infoTitle.text = "UNHEALTHY FOR SENSITIVE GROUPS"
            cell.infoText.text = "Sensitive groups (asthma sufferers, young children, the elderly) should limit heavy outdoor activity."
            cell.backgroundColor = UIColor.init(named: "orange")
            return cell
            
        case 3:
            cell.minNum.text = "150"
            cell.maxNum.text = "200"
            cell.infoTitle.text = "UNHEALTHY"
            cell.infoText.text = "Heavy outdoor activity should be limited for all."
            cell.backgroundColor = UIColor.init(named: "red")
            return cell
            
        case 4:
            cell.minNum.text = "201"
            cell.maxNum.text = "300"
            cell.infoTitle.text = "VERY UNHEALTHY"
            cell.infoText.text = "Outdoor activity should be restricted for all and exposure be limited for sensitive groups."
            cell.backgroundColor = UIColor.init(named: "purple")
            return cell
            
        case 5:
            cell.minNum.text = "300"
            cell.maxNum.text = "500"
            cell.infoTitle.text = "HAZARDOUS"
            cell.infoText.text = "Hazardous to high risk people and general public health."
            cell.backgroundColor = UIColor.init(named: "bordo")
            return cell
            
        default:
            return cell
        }
    }
}
    

class InfoView: UITableViewController {
    
    @IBOutlet weak var infoTableView: UITableView!
    @IBOutlet var mainView: UIView!
    private let numOfInfoRows = 6
    override open var shouldAutorotate: Bool { return false }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numOfInfoRows
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = infoCellStruct.init(indexPath: indexPath, tableView: tableView)
        
        return cell.returnCell()
    }
}
