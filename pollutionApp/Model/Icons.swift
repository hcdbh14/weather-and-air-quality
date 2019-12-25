import UIKit

enum Icons: String {
    case sunny = "01d"
    case night = "01n"
    case sunAndCloud = "02d"
    case nightAndCloud = "02n"
    case cloud = "03d"
    case cloudy = "04d"
    case rain = "09d"
    case rainAndSun = "10d"
    case rainAndNight = "10n"
    case storm = "11d"
    case snow = "13d"
    case fog = "50d"
}

func openWeatherIcons (iconId: String) ->  String {
    switch iconId {
        
    case "01d":
        return Icons.sunny.rawValue
    case "01n":
        return Icons.night.rawValue
        
    case "02d":
        return Icons.sunAndCloud.rawValue
    case "02n":
        return Icons.nightAndCloud.rawValue
        
    case "03d":
        return Icons.cloud.rawValue
    case "03n":
        return Icons.cloud.rawValue
        
    case "04d":
        return Icons.cloudy.rawValue
    case "04n":
        return Icons.cloudy.rawValue
        
    case "09d":
        return Icons.rain.rawValue
        
    case "11d":
        return Icons.storm.rawValue
    case "11n":
        return Icons.storm.rawValue
        
    case "10d":
        return Icons.rain.rawValue
        
        
    case "13d":
        return Icons.snow.rawValue
        
    case "50d":
        return Icons.fog.rawValue
        
        
    default:
        return Icons.cloud.rawValue
    }
}

func setWeatherIcon(iconName: String) -> String {
    
    switch iconName {
    case Icons.sunny.rawValue :
        return Icons.sunny.rawValue
        
    case Icons.night.rawValue :
        return Icons.night.rawValue
        
    case Icons.sunAndCloud.rawValue :
        return Icons.sunAndCloud.rawValue
        
    case Icons.nightAndCloud.rawValue :
        return Icons.nightAndCloud.rawValue
        
    case Icons.cloud.rawValue :
        return Icons.cloud.rawValue
        
    case Icons.cloudy.rawValue :
        return Icons.cloudy.rawValue
        
    case Icons.rain.rawValue :
        return Icons.rain.rawValue
        
    case Icons.rainAndSun.rawValue :
        return Icons.rainAndSun.rawValue
        
    case Icons.rainAndNight.rawValue :
        return Icons.rainAndNight.rawValue
        
    case Icons.storm.rawValue :
        return Icons.storm.rawValue
        
    case Icons.snow.rawValue :
        return Icons.snow.rawValue
        
    case Icons.fog.rawValue :
        return Icons.fog.rawValue
        
    case "04n":
        return Icons.nightAndCloud.rawValue
        
    default:
        return Icons.cloud.rawValue
    }
}
