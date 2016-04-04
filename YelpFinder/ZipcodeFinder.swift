import CoreLocation
import UIKit

typealias ZipcodeFinderCompletion = String? -> ()

class ZipcodeFinder: NSObject {
    
    let locationManager = CLLocationManager()
    private let completionBlock : ZipcodeFinderCompletion
    
    init (completionBlock block: ZipcodeFinderCompletion) {
        completionBlock = block
        super.init()
        self.checkAuthorizationStatus()
    }
    
    func findZipcodeForLocation(location: CLLocation) {
        let geocoder = CLGeocoder()
        let completion : CLGeocodeCompletionHandler = { placemarks, error in
            
        }
        geocoder.reverseGeocodeLocation(location, completionHandler: completion)
    }
    
    func checkAuthorizationStatus () {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        case .AuthorizedAlways:
            fallthrough
        case .AuthorizedWhenInUse:
            self.locationManager.requestLocation()
        default:
            self.completionBlock(nil)
        }
    }
}

//MARK: CLLocationManagerDelegate
extension ZipcodeFinder : CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.findZipcodeForLocation(location)
        } else {
            self.completionBlock(nil)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.completionBlock(nil)
    }
}

