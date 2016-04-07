import CoreLocation
import UIKit
import Contacts

typealias ZipcodeFinderCompletion = (String?, CLLocation?) -> ()
typealias ZipcodeLocationFinderCompletion = CLLocation? -> ()

protocol ZipcodeFinderDelegate {
  func zipcodeFinderDidFinish(zipcodeFinder: ZipcodeFinder)
}

class ZipcodeFinder: NSObject {
  
  let locationManager = CLLocationManager()
  private (set) var zipcode : String?
  private (set) var location : CLLocation?
  private let completionBlock : ZipcodeFinderCompletion?
  private let delegate : ZipcodeFinderDelegate?
  
  class func findLocationForZipcode(zipcode: String, completion block: ZipcodeLocationFinderCompletion) {
    guard !zipcode.isEmpty else { return }
    CLGeocoder().geocodeAddressDictionary([ CNPostalAddressPostalCodeKey : zipcode]) { placemarks, error in
      guard let placemarks = placemarks else { return }
      locationLoop: for placemark in placemarks {
        switch placemark.location {
        case let .Some(location) where CLLocationCoordinate2DIsValid(location.coordinate):
          block(location)
          break locationLoop
        default:
          break
        }
      }
      block(nil)
    }
  }
  
  init (delegate: ZipcodeFinderDelegate?, completionBlock block: ZipcodeFinderCompletion?) {
    self.completionBlock = block
    self.delegate = delegate
    super.init()
    self.checkAuthorizationStatus()
  }
  
  func findZipcodeForLocation(location: CLLocation) {
    let completion : CLGeocodeCompletionHandler = { placemarks, error in
      guard let placemarks = placemarks else {
        self.notify()
        return
      }
      placemarkLoop: for placemark in placemarks {
        switch (placemark.postalCode, placemark.location) {
        case (let .Some(postalCode), let .Some(location)) where !postalCode.isEmpty && CLLocationCoordinate2DIsValid(location.coordinate):
          self.notify(withZipcode: postalCode, location: location)
          break placemarkLoop
        default:
          break
        }
      }
    }
    CLGeocoder().reverseGeocodeLocation(location, completionHandler: completion)
  }
  
  func checkAuthorizationStatus () {
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    switch CLLocationManager.authorizationStatus() {
    case .NotDetermined:
      self.locationManager.requestWhenInUseAuthorization()
    case .AuthorizedAlways, .AuthorizedWhenInUse:
      self.locationManager.requestLocation()
    default:
      self.notify()
    }
  }
  
  func notify(withZipcode zipcode: String? = nil, location: CLLocation? = nil) {
    self.zipcode = zipcode
    self.completionBlock?(zipcode, location)
  }
  
}

//MARK: CLLocationManagerDelegate
extension ZipcodeFinder : CLLocationManagerDelegate {
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      self.findZipcodeForLocation(location)
    } else {
      self.notify()
    }
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    self.notify()
  }
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    switch status {
    case .AuthorizedWhenInUse, .AuthorizedAlways:
      self.locationManager.requestLocation()
    case .Restricted, .Denied:
      self.notify()
    default:
      break
    }
  }
  
}

