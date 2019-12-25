import UIKit 

class ForcastMainCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var hourTableView: UITableView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherDescLabel: UILabel!
    var arrangeDataForCells = ForcastDataModel.init()
    var tableNumOfRows: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.hourTableView.dataSource = self
            self.hourTableView.tableFooterView = UIView()
            self.updateImageIcons()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableNumOfRows
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "hourCell", for: indexPath) as! hourCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.hourLabel.text = arrangeDataForCells.timeText[indexPath.row]
        cell.tempetureLabel.text = String(arrangeDataForCells.tempeture[indexPath.row]) + "°"
        cell.weatherIcon.image = UIImage(named: arrangeDataForCells.weatherIconId[indexPath.row])
        
        return cell
    }
    
    private func updateImageIcons () {
        var updatedArrayIcons: [String] = []
        
        for i in arrangeDataForCells.weatherIconId {
            
            let updatedIcon = openWeatherIcons(iconId: i)
            updatedArrayIcons.append(updatedIcon)
        }
        arrangeDataForCells.weatherIconId = updatedArrayIcons
    }
}

