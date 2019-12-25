import UIKit

struct Gradient {
    
    var gradientLayer: CAGradientLayer!
    var hour: Int
    
    init() {
        let date = Date()
        let calendar = Calendar.current
        self.hour = calendar.component(.hour, from: date)
    }
    
    
    mutating func setBackgroundGradient (view: UIView, onTableView: UITableViewController? = nil) {
        
        if hour > 6 && hour < 19 {
            let colorTop = UIColor(red: 163 / 255.0, green: 189 / 255.0, blue: 230 / 255.0, alpha: 1.0).cgColor
            let colorBottom = UIColor(red: 105 / 255.0, green: 145 / 255.0, blue: 199 / 255.0, alpha: 1.0).cgColor
            
            self.gradientLayer = CAGradientLayer()
            self.gradientLayer.colors = [colorTop, colorBottom]
            self.gradientLayer.locations = [0.0, 0.3]
            
        } else {
            let colorTop = UIColor(red: 40 / 255.0, green: 49 / 255.0, blue: 59 / 255.0, alpha: 1.0).cgColor
            let colorBottom = UIColor(red: 72 / 255.0, green: 84 / 255.0, blue: 97 / 255.0, alpha: 1.0).cgColor
            
            self.gradientLayer = CAGradientLayer()
            self.gradientLayer.colors = [colorTop, colorBottom]
            self.gradientLayer.locations = [0.0, 1.0]
        }
        
        view.backgroundColor = UIColor.clear
        let backgroundLayer = self.gradientLayer
        backgroundLayer!.frame = view.frame
        
        if onTableView != nil, let bounds = onTableView?.tableView.bounds {
            backgroundLayer?.frame = bounds
            let backgroundView = UIView(frame: bounds)
            backgroundView.layer.insertSublayer(gradientLayer, at: 0)
            onTableView?.tableView.backgroundView = backgroundView
        } else {
            view.layer.insertSublayer(backgroundLayer!, at: 0)
        }
    }
}
