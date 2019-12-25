import UIKit

class Forcast: UICollectionViewController {
    
    @IBOutlet var titleView: UICollectionView!
    
    private let cellIdentifiers = ["forcastMainCellOne", "forcastMainCellTwo", "forcastMainCellThree", "forcastMainCellFour", "forcastMainCellFive", "forcastMainCellSix"]
    var degreeType = true
    var chosenCountry = ""
    var chosenState = ""
    var chosenCity = ""
    var pickedLocation: Bool = false
    var gradient = Gradient()
    var arrangeDataForCells = ForcastDataModel.init()
    private var rowsReady: [Int] = []
    override open var shouldAutorotate: Bool { return false }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradient.setBackgroundGradient(view: view)
        arrangeDataForCells.giveOnlyFiveDays()
        arrangeDataForCells.getDayOccurrence()
        splitDataBetweenCells()
        fixRange()
        setMenu()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrangeDataForCells.filteredDays.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifiers[indexPath.row], for: indexPath) as! ForcastMainCell
        
        cell.dayLabel.text = arrangeDataForCells.filteredDays[indexPath.row]
        
        switch indexPath.row {
        case 0:
            
            cell.arrangeDataForCells = arrangeDataForCells
            cell.tableNumOfRows = rowsReady[indexPath.row]
            let indexRange = giveTableRange(rowNumber: indexPath.row)
            
            let tempArray = arrangeDataForCells.tempeture
            let slicedTempArray: [Int] = Array(tempArray[indexRange])
            cell.arrangeDataForCells.tempeture = slicedTempArray
            
            let textArray = arrangeDataForCells.timeText
            let slicedTextArray: [String] = Array(textArray[indexRange])
            cell.arrangeDataForCells.timeText = slicedTextArray
            
            let icon = arrangeDataForCells.weatherIconId
            let slicedIconArray: [String] = Array(icon[indexRange])
            cell.arrangeDataForCells.weatherIconId = slicedIconArray
            
        case 1:
            
            cell.arrangeDataForCells = arrangeDataForCells
            cell.tableNumOfRows = rowsReady[indexPath.row]
            let indexRange = giveTableRange(rowNumber: indexPath.row)
            
            
            let tempArray = arrangeDataForCells.tempeture
            let slicedTempArray: [Int] = Array(tempArray[indexRange])
            cell.arrangeDataForCells.tempeture = slicedTempArray
            
            
            let textArray = arrangeDataForCells.timeText
            let slicedTextArray: [String] = Array(textArray[indexRange])
            cell.arrangeDataForCells.timeText = slicedTextArray
            
            
            let icon = arrangeDataForCells.weatherIconId
            let slicedIconArray: [String] = Array(icon[indexRange])
            cell.arrangeDataForCells.weatherIconId = slicedIconArray
            
        case 2:
            
            cell.arrangeDataForCells = arrangeDataForCells
            cell.tableNumOfRows = rowsReady[indexPath.row]
            let indexRange = giveTableRange(rowNumber: indexPath.row)
            
            let fullArray = arrangeDataForCells.tempeture
            let slicedTempArray: [Int] = Array(fullArray[indexRange])
            cell.arrangeDataForCells.tempeture = slicedTempArray
            
            
            let textArray = arrangeDataForCells.timeText
            let slicedTextArray: [String] = Array(textArray[indexRange])
            cell.arrangeDataForCells.timeText = slicedTextArray
            
            
            let icon = arrangeDataForCells.weatherIconId
            let slicedIconArray: [String] = Array(icon[indexRange])
            cell.arrangeDataForCells.weatherIconId = slicedIconArray
            
        case 3:
            
            cell.arrangeDataForCells = arrangeDataForCells
            cell.tableNumOfRows = rowsReady[indexPath.row]
            let indexRange = giveTableRange(rowNumber: indexPath.row)
            
            let fullArray = arrangeDataForCells.tempeture
            let slicedTempArray: [Int] =  Array(fullArray[indexRange])
            cell.arrangeDataForCells.tempeture = slicedTempArray
            
            let textArray = arrangeDataForCells.timeText
            let slicedTextArray: [String] = Array(textArray[indexRange])
            cell.arrangeDataForCells.timeText = slicedTextArray
            
            
            let icon = arrangeDataForCells.weatherIconId
            let slicedIconArray: [String] = Array(icon[indexRange])
            cell.arrangeDataForCells.weatherIconId = slicedIconArray
            
        case 4:
            
            cell.arrangeDataForCells = arrangeDataForCells
            cell.tableNumOfRows = rowsReady[indexPath.row]
            let indexRange = giveTableRange(rowNumber: indexPath.row)
            
            let fullArray = arrangeDataForCells.tempeture
            let slicedTempArray: [Int] = Array(fullArray[indexRange])
            cell.arrangeDataForCells.tempeture = slicedTempArray
            
            let textArray = arrangeDataForCells.timeText
            let slicedTextArray: [String] = Array(textArray[indexRange])
            cell.arrangeDataForCells.timeText = slicedTextArray
            
            let icon = arrangeDataForCells.weatherIconId
            let slicedIconArray: [String] = Array(icon[indexRange])
            cell.arrangeDataForCells.weatherIconId = slicedIconArray
            
        case 5:
            
            cell.arrangeDataForCells = arrangeDataForCells
            cell.tableNumOfRows = rowsReady[indexPath.row]
            let indexRange = giveTableRange(rowNumber: indexPath.row)
            
            let fullArray = arrangeDataForCells.tempeture
            let slicedTempArray: [Int] = Array(fullArray[indexRange])
            cell.arrangeDataForCells.tempeture = slicedTempArray
            
            
            let textArray = arrangeDataForCells.timeText
            let slicedTextArray: [String] = Array(textArray[indexRange])
            cell.arrangeDataForCells.timeText = slicedTextArray
            
            
            let icon = arrangeDataForCells.weatherIconId
            let slicedIconArray: [String] = Array(icon[indexRange])
            cell.arrangeDataForCells.weatherIconId = slicedIconArray
            
        default:
            return cell
        }
        return cell
    }
    
    
    private func splitDataBetweenCells () {
        
        var cellOneNumRows = 0
        var cellTwoNumRows = 0
        var cellThreeNumRows = 0
        var cellFourNumRows = 0
        var cellFiveNumRows = 0
        var cellSixNumRows = 0
        var loopCount = 0
        
        
        for i in self.arrangeDataForCells.filteredDays {
            
            switch loopCount {
                
            case 0:
                cellOneNumRows = arrangeDataForCells.occurrenceDays[i] ?? 0
                rowsReady.append(cellOneNumRows)
                loopCount += 1
            case 1:
                cellTwoNumRows = arrangeDataForCells.occurrenceDays[i] ?? 0
                rowsReady.append(cellTwoNumRows)
                loopCount += 1
                
            case 2:
                cellThreeNumRows = arrangeDataForCells.occurrenceDays[i] ?? 0
                rowsReady.append(cellThreeNumRows)
                loopCount += 1
                
            case 3:
                cellFourNumRows = arrangeDataForCells.occurrenceDays[i] ?? 0
                rowsReady.append(cellFourNumRows)
                loopCount += 1
                
            case 4:
                cellFiveNumRows = arrangeDataForCells.occurrenceDays[i] ?? 0
                rowsReady.append(cellFiveNumRows)
                loopCount += 1
                
            case 5:
                cellSixNumRows = arrangeDataForCells.occurrenceDays[i] ?? 0
                rowsReady.append(cellSixNumRows)
                loopCount += 1
                
            default:
                return
            }  
        }
    }
    
    
    private func fixRange () {
        let lastIndex = rowsReady.count
        rowsReady[0] = rowsReady[0] + 1
        rowsReady[lastIndex - 1] = rowsReady[lastIndex - 1] - 1
    }
    
    
    @objc private func previousScreen(_ sender: Any) {
        performSegue(withIdentifier: "previousScreen", sender: self)
    }
    
    
    private func setMenu () {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: "Back"), style: .plain, target: self, action: #selector(previousScreen(_:)))
        
        self.navigationItem.title = self.chosenCity
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if  segue.identifier == "previousScreen" {
            if let controller = segue.destination as? CurrentWeather {
                controller.chosenCountry = chosenCountry
                controller.chosenState = chosenState
                controller.chosenCity = chosenCity
                controller.pickedLocation = pickedLocation
                controller.gradient = gradient
            }
        }
    }
    
    
    private func giveTableRange (rowNumber: Int) ->  ClosedRange<Int> {
        
        switch rowNumber {
            
        case 0:
            let tableRange = 0...rowsReady[rowNumber]-1
            return tableRange
            
        case 1:
            let minRange = rowsReady[rowNumber-1]
            let maxRange = rowsReady[rowNumber-1] + rowsReady[rowNumber]
            let tableRange = minRange...maxRange
            return tableRange
            
        case 2:
            let minRange = rowsReady[rowNumber-2] + rowsReady[rowNumber-1]
            let maxRange = rowsReady[rowNumber-2] + rowsReady[rowNumber-1] + rowsReady[rowNumber]
            let tableRange = minRange...maxRange
            return tableRange
            
        case 3:
            let minRange = rowsReady[rowNumber-3] + rowsReady[rowNumber-2] + rowsReady[rowNumber-1]
            let maxRange = rowsReady[rowNumber-3] + rowsReady[rowNumber-2] + rowsReady[rowNumber-1] + rowsReady[rowNumber]
            let tableRange = minRange...maxRange
            return tableRange
            
        case 4:
            let minRange = rowsReady[rowNumber-4] + rowsReady[rowNumber-3] + rowsReady[rowNumber-2] + rowsReady[rowNumber-1]
            var maxRange = rowsReady[rowNumber-4] + rowsReady[rowNumber-3] + rowsReady[rowNumber-2] + rowsReady[rowNumber-1] + rowsReady[rowNumber]
            maxRange = checkIfRangeIsAtMax(range: maxRange)
            let tableRange = minRange...maxRange
            return tableRange
            
        case 5:
            let minRange = rowsReady[rowNumber-5] + rowsReady[rowNumber-4] + rowsReady[rowNumber-3] + rowsReady[rowNumber-2] + rowsReady[rowNumber-1]
            let maxRange = rowsReady[rowNumber-5] + rowsReady[rowNumber-4] + rowsReady[rowNumber-3] + rowsReady[rowNumber-2] + rowsReady[rowNumber-1] + rowsReady[rowNumber]
            
            if maxRange > minRange {
                let tableRange = minRange...maxRange-1
                return tableRange
            } else {
                return 0...0
            }
            
        default:
            return 0...0
        }
    }
    
    
    private func checkIfRangeIsAtMax (range: Int) -> Int {
        if range >= 40 {
            return range - 1
        } else {
            return range
        }
    }
}


