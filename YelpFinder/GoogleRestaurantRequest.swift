
import Foundation
import CoreLocation

class GoogleRestaurantRequest : CustomStringConvertible {
  
  static let defaultRadius  = 1000
  
  let location : CLLocation
  var radius : Int
  let openRestriction : Bool
  private (set) var pageToken : Int = 0
  
  init? (location: CLLocation, radius: Int = GoogleRestaurantRequest.defaultRadius, openNow: Bool = false) {
    self.location = location
    self.radius = radius
    self.openRestriction = openNow
    if !CLLocationCoordinate2DIsValid(location.coordinate) {
      return nil
    }
  }
  
  var description: String {
    return "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(self.location.coordinate.latitude),\(self.location.coordinate.longitude)&radius=\(self.radius)&type=restaurant&opennow=\(Int(self.openRestriction))&key=AIzaSyAQOkMuc-MnPudJheH6ZI0i81qUx_lcSo4"
  }
  
  var URLRepresentation : NSURL? {
    return NSURL(string: self.description)
  }
  
}