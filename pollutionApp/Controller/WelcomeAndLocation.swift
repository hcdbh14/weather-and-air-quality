import UIKit
import CoreLocation

class WelcomeAndLocation: UIViewController {
    
    @IBOutlet weak var thankYouText: UILabel!
    @IBOutlet weak var introText: UILabel!
    @IBOutlet weak var EnableLocationButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var globeImage: UIImageView!
    
    private var latitude = ""
    private var longitude = ""
    private var fetchDataArray: [StoredCache] = []
    private let locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    private var isUpdatingLocation = false
    private var lastLocationError: Error?
    private var locationReadyFlag = false
    private var reportedNoLocation = false
    private var gradient = Gradient()
    override open var shouldAutorotate: Bool { return false }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navBarTransparent()
        gradient.setBackgroundGradient(view: view)
        hideUI()
        setUpLoadingScreen(view: view)
        checkIfUserFirstTime()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        navigationItem.setHidesBackButton(true, animated:true);
        setButtonColors()
        callLoadScreenWhenLocationIsEnabled()
    }
    
    
    @IBAction private func enableLocation(_ sender: Any) {
        getLocation()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "enabledLocation" {
            if let controller = segue.destination as? CurrentWeather {
                controller.longitude = longitude
                controller.latitude = latitude
            }
        }
    }
    
    
    private func hideUI () {
        thankYouText.isHidden = true
        introText.isHidden = true
        globeImage.isHidden = true
        EnableLocationButton.isHidden = true
        skipButton.isHidden = true
    }
    
    
    private func unhideUI () {
        thankYouText.isHidden = false
        introText.isHidden = false
        globeImage.isHidden = false
        EnableLocationButton.isHidden = false
        skipButton.isHidden = false
    }
    
    
    private func setButtonColors () {
        EnableLocationButton.backgroundColor = UIColor(red: 40/255, green: 44/255, blue: 53/255, alpha: 0.5)
        EnableLocationButton.layer.cornerRadius = 20
        EnableLocationButton.layer.borderWidth = 0.5
        EnableLocationButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        EnableLocationButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        EnableLocationButton.layer.shadowOpacity = 1.0
        EnableLocationButton.layer.shadowRadius = 0.0
        EnableLocationButton.layer.masksToBounds = false
        
        skipButton.backgroundColor = UIColor(red: 40/255, green: 44/255, blue: 53/255, alpha: 0.5)
        skipButton.layer.cornerRadius = 20
        skipButton.layer.borderWidth = 0.5
        skipButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        skipButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        skipButton.layer.shadowOpacity = 1.0
        skipButton.layer.shadowRadius = 0.0
        skipButton.layer.masksToBounds = false
    }
    
    
    private func navBarTransparent() {
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage = nil
    }
    
    
    private func callLoadScreenWhenLocationIsEnabled () {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .notDetermined {
            closeLoadingScreen()
        } else {
            getLocation()
        }
    }
    
    
    private func checkIfUserFirstTime () {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .notDetermined {
            unhideUI()
        } else {
            
            return
        }
    }
}


extension WelcomeAndLocation : CLLocationManagerDelegate {
    
    private func getLocation() {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            performSegue(withIdentifier: "enabledLocation", sender: self)
            if self.reportedNoLocation == false {
                reportLocationServicesDeniedError()
                self.reportedNoLocation = true
                return
            } else {
                return
            }
        }
        if isUpdatingLocation {
            stopLocationManager()
        } else {
            userLocation = nil
            lastLocationError = nil
            startLocationManager()
        }
    }
    
    
    private func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.startUpdatingLocation()
            isUpdatingLocation = true
        }
    }
    
    
    private func stopLocationManager() {
        if isUpdatingLocation {
            locationManager.startUpdatingLocation()
            locationManager.delegate = nil
            isUpdatingLocation = false
        }
    }
    
    
    private func passLocationDetails() {
        if userLocation != nil {
            
            let dataLatitude = String(format: "%.8f", userLocation!.coordinate.latitude)
            let dataLongitude = String(format: "%.8f", userLocation!.coordinate.longitude)
            self.latitude = dataLatitude
            self.longitude = dataLongitude
            print("latitude" + latitude + " " + "longitude" + longitude)
            
        } else {
            print("no latitude/longitude data")
        }
        performSegue(withIdentifier: "enabledLocation", sender: self)
    }
    
    
    private func reportLocationServicesDeniedError () {
        
        let alert = UIAlertController(title: "Location services is disabled", message: "You can allow location services for this app within the device settings", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error!! locationManager-didFailWithError: \(error)")
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        stopLocationManager()
    }
    
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        userLocation = locations.last!
        print("Location detected locationManager-didUpdateLocations \(String(describing: userLocation))")
        passLocationDetails()
        stopLocationManager()
    }
}
