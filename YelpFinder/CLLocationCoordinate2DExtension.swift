import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
  
  var isValid : Bool {
    return CLLocationCoordinate2DIsValid(self)
  }
  
}
