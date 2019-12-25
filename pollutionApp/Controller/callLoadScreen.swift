import UIKit

let loadingIcon: UIActivityIndicatorView = {
    let icon = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
    icon.style = .large
    icon.color = .white

    return icon
}()


let loadingScreen: UIView = {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 414, height: 842))
    view.addSubview(loadingIcon)
    return view
}()


let errorMessage: UILabel = {
    let message = UILabel()
    message.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 400, height: 20))
    message.font = UIFont(name: "Noto Sans Oriya", size: 17)
    message.textAlignment = .center
    message.text = "Oops! Something went wrong"
    
    return message
}()


func setUpLoadingScreen (view: UIView, isChooseLocation: Bool? = false) {
    
    view.addSubview(loadingScreen)
    loadingScreen.addSubview(errorMessage)
    setUpLoadingScreenConstraints(mainView: view, subView: loadingScreen, loadingIcon: (loadingIcon))
     setUpErrorMessageConstraints(mainView: view, errorMessage: errorMessage)
    loadingIcon.startAnimating()
    loadingIcon.isHidden = false
    errorMessage.isHidden = true
    
    if isChooseLocation == true {
        loadingIcon.color = .label
        errorMessage.textColor = .label
    } else {
        loadingIcon.color = .white
        errorMessage.textColor = .white
    }
}


func setUpLoadingScreenConstraints (mainView: UIView, subView: UIView, loadingIcon: UIActivityIndicatorView) {
    
    subView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
    subView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
    subView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
    subView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
    subView.backgroundColor = .clear
    
    loadingIcon.center = mainView.center
}


func closeLoadingScreen () {
    
    loadingIcon.isHidden = true
    loadingScreen.removeFromSuperview()
}


func switchFromLoadingToErrorMessage () {
    
    loadingIcon.isHidden = true
    errorMessage.isHidden = false
}


func setUpErrorMessageConstraints (mainView: UIView, errorMessage: UILabel) {
    
        errorMessage.center = mainView.center
}
