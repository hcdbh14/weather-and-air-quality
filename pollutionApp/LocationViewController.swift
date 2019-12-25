//
//  LocationViewController.swift
//  pollutionApp
//
//  Created by Kenny Kurochkin on 06/09/2019.
//  Copyright © 2019 kenny. All rights reserved.
//

import UIKit




class LocationViewController: UIViewController {
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var pollutionLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDirection: UILabel!
    @IBOutlet weak var tempetureLabel: UILabel!
    @IBOutlet weak var pollutionProgress: UIProgressView!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet var loadingScreen: UIView!
    @IBOutlet weak var loadingIcon: UIImageView!
    @IBOutlet weak var airQualityLabel: UILabel!
    
    var chosenCountry: String = ""
    var chosenState: String = ""
    var chosenCity: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationRequest()
        callLoadScreen()
    }
    
    private func locationRequest() {
        
        let encodedCity = chosenCity.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let encodedState = chosenState.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let encodedCountry = chosenCountry.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        getRequest(requestUrl: "https://api.airvisual.com/v2/city?city=\(encodedCity)&state=\(encodedState)&country=\(encodedCountry)&", personalKey: "d5124c42-f5de-4a46-b117-3f08a4514d57") { (result) in
            
            switch result {
                
            case .failure(let error):
                print("error: \(error)")
                
            case .success(let response):
                let decoder = JSONDecoder()
                do {
                    let decodedResponse = try decoder.decode(NearMe.self, from: response)
                    self.cityLabel.text = decodedResponse.data?.city
                    self.countryLabel.text = decodedResponse.data?.country
                    if let savedInt = decodedResponse.data?.current?.weather?.tp {
                        self.tempetureLabel.text =   String(savedInt) + "*c"
                    }
                    if let savedInt = decodedResponse.data?.current?.pollution?.aqius {
                        self.pollutionLabel.text = "air pollution: " + String(savedInt)
                        self.switchBarColor(pollution: savedInt)
                    }
                    if let savedInt = decodedResponse.data?.current?.weather?.hu {
                        self.humidityLabel.text = "humidity: " + String(savedInt)
                    }
                    if let savedInt = decodedResponse.data?.current?.weather?.ws {
                        self.windSpeedLabel.text = " wind speed: " + String(savedInt)
                    }
                    if let savedInt = decodedResponse.data?.current?.weather?.wd {
                        self.windDirection.text = "wind direction: " + String(savedInt)
                    }
                    if let weatherIconIndecation = decodedResponse.data?.current?.weather?.ic {
                        self.setImage(iconName: weatherIconIndecation)
                        //print stuff
                        print(weatherIconIndecation)
                        print(decodedResponse)
                    }
                    self.loadingScreen.isHidden = true
                    
                    
                } catch let error {
                    print("error: \(error)")
                }
                
            }
        }
    }
    
    
    private func setImage(iconName: String) {
        
        switch iconName {
            
        case Icons.sunny.rawValue :
            self.weatherIcon.image = UIImage(named: Icons.sunny.rawValue)
            
        case Icons.night.rawValue :
            self.weatherIcon.image = UIImage(named: Icons.sunny.rawValue)
            
        case Icons.sunAndCloud.rawValue :
            self.weatherIcon.image = UIImage(named: Icons.sunAndCloud.rawValue)
            
        case Icons.nightAndCloud.rawValue :
            self.weatherIcon.image = UIImage(named: Icons.nightAndCloud.rawValue)
            
        case Icons.cloud.rawValue :
            self.weatherIcon.image = UIImage(named: Icons.cloud.rawValue)
            
        case Icons.cloudy.rawValue :
            self.weatherIcon.image = UIImage(named: Icons.cloudy.rawValue)
            
        case Icons.rain.rawValue :
            self.weatherIcon.image = UIImage(named: Icons.rain.rawValue)
            
        case Icons.rainAndSun.rawValue :
            self.weatherIcon.image = UIImage(named: Icons.rainAndSun.rawValue)
            
        case Icons.rainAndNight.rawValue :
            self.weatherIcon.image = UIImage(named: Icons.rainAndNight.rawValue)
            
        case Icons.storm.rawValue :
            self.weatherIcon.image = UIImage(named: Icons.storm.rawValue)
            
        case Icons.snow.rawValue :
            self.weatherIcon.image = UIImage(named: Icons.snow.rawValue)
            
        case Icons.fog.rawValue :
            self.weatherIcon.image = UIImage(named: Icons.fog.rawValue)
            
        case "04n":
            self.weatherIcon.image = UIImage(named: Icons.nightAndCloud.rawValue)
            
        default:
            self.weatherIcon.image = UIImage(named: Icons.nightAndCloud.rawValue)
        }
    }
    
    func switchBarColor(pollution: Int) {
        let  xMax = 1.0;
        let  xMin = 0.0;
        
        var  yMax: Double
        var  yMin = 0.0
        
        var   percent: Double
        var   outputX = 0.0
        
        
        // green
        if pollution <= 50 {
            yMax = 50.0;
            percent = (Double(pollution) - yMin) / (yMax - yMin);
            outputX = percent * (xMax - xMin) + xMin;
            
            self.pollutionProgress.progressTintColor = UIColor.green
            self.pollutionProgress.setProgress(Float(outputX), animated: true)
        }
            //yellow
        else if  51 ... 100 ~= pollution {
            yMax = 100.0
            yMin = 51.0
            percent = (Double(pollution) - yMin) / (yMax - yMin)
            outputX = percent * (xMax - xMin) + xMin
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                self.pollutionProgress.progressTintColor = UIColor.yellow
                self.pollutionProgress.setProgress(Float(outputX), animated: true)
                
            }
        } //orange
        else if 101...150 ~= pollution {
            yMax = 150.0
            yMin = 101.0
            percent = (Double(pollution) - yMin) / (yMax - yMin)
            outputX = percent * (xMax - xMin) + xMin
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                self.pollutionProgress.progressTintColor = UIColor.orange
                self.pollutionProgress.setProgress(Float(outputX), animated: true)
                
            }
        }
            //red
        else if 151...200 ~= pollution {
            yMax = 200.0
            yMin = 151.0
            percent = (Double(pollution) - yMin) / (yMax - yMin)
            outputX = percent * (xMax - xMin) + xMin
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                self.pollutionProgress.progressTintColor = UIColor.red
                self.pollutionProgress.setProgress(Float(outputX), animated: true)
                
            }
        }
            //purple
        else if 201...300 ~= pollution {
            yMax = 300.0
            yMin = 201.0
            percent = (Double(pollution) - yMin) / (yMax - yMin)
            outputX = percent * (xMax - xMin) + xMin
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                self.pollutionProgress.progressTintColor = UIColor.purple
                self.pollutionProgress.setProgress(Float(outputX), animated: true)
                
            }
        }
            //bordo
        else if 301...500 ~= pollution {
            yMax = 500.0
            yMin = 301.0
            percent = (Double(pollution) - yMin) / (yMax - yMin)
            outputX = percent * (xMax - xMin) + xMin
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                self.pollutionProgress.progressTintColor = UIColor.purple
                self.pollutionProgress.setProgress(Float(outputX), animated: true)
                
            }
        }
    }
    
    private func callLoadScreen () {
        view.addSubview(loadingScreen)
        do {
            let gif = try UIImage(gifName: "spinner.gif")
            self.loadingIcon.setGifImage(gif)
        } catch {
            print(error)
        }
    }
    
}
