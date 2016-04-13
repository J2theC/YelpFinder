
import Foundation
import CoreLocation
import UIKit

class Restaurant : CustomStringConvertible {
  
  let identifier : String
  let name : String
  let reviewsDescription : String?
  let rating : Double
  let category : String?
  let address : String
  let priceDescription : String?
  let imagePath: String?
  let coordinate : CLLocationCoordinate2D?
  weak var image : UIImage?
  
  init? (dictionary: [String : AnyObject]) {
    guard let name = dictionary["name"] as? String, let vicinity = dictionary["vicinity"] as? String, let placeID = dictionary["place_id"] as? String else {
      self.name = ""
      address = ""
      identifier = ""
      reviewsDescription = nil
      category = nil
      priceDescription = nil
      imagePath = nil
      coordinate = nil
      return nil
    }
    self.name = name
    address = vicinity
    identifier = placeID
    if  let types = dictionary["types"]  as? [String] where !types.isEmpty {
      category = types.joinWithSeparator(", ").capitalizedString.stringByReplacingOccurrencesOfString("_", withString: " ")
    } else {
      category = nil
    }
    if let ratings = dictionary["rating"]  as? Float  where ratings > 0 {
      reviewsDescription = String (format: "%.1f out of 5 stars", ratings)
      rating = Double(ratings)
    } else {
      reviewsDescription = nil
      rating = 0
    }
    if let geometry = dictionary["geometry"] as? [String : AnyObject], let location = geometry["location"] as? [String : AnyObject], let latitude = location["lat"] as? Double,  let longitude = location["lng"] as? Double {
      let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      if  locationCoordinate.isValid {
        coordinate = locationCoordinate
      } else {
        coordinate = nil
      }
    } else {
      coordinate = nil
    }
    if let iconPath = dictionary["icon"] as? String where !iconPath.isEmpty {
      imagePath = iconPath
    } else {
      imagePath = nil
    }
    let priceLevel : Int
    if let price = dictionary["price_level"] as? Int {
      priceLevel = price
    } else {
      priceLevel = 1
    }
    priceDescription = String(count: priceLevel, repeatedValue: Character("$"))
  }
  
  var description: String {
    return "name: \(self.name), address: \(self.address)"
  }
  
}