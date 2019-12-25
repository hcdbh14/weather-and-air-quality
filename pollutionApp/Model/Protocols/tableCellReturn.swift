import UIKit

protocol tableCellReturn {
    
    var tableView: UITableView { get }
    var indexPath: IndexPath { get }
    
    func returnCell() -> UITableViewCell
}
