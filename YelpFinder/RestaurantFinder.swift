import Foundation
import CoreLocation
import UIKit

typealias RestaurantFinderCompletionBlock = [Restaurant] -> ()
typealias RestaurantImageCompletionBlock = UIImage  -> ()

class RestaurantFinder {
  
  private let imageCache = NSCache()
  private var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
  
  func findRestaurantsWithRequest(request: GoogleRestaurantRequest, completion: RestaurantFinderCompletionBlock) {
    if let url = request.URLRepresentation {
      let completionHandler =  { (data : NSData?, response: NSURLResponse?, error: NSError?) in
        switch (data, response as? NSHTTPURLResponse, error) {
        case (let .Some(data), let .Some(response), _) where data.length > 0 && response.statusCode == 200:
          let parsed = self.restaurantsFromData(data)
          dispatch_async(dispatch_get_main_queue()) {
            completion(parsed)
          }
        case (_, _, let .Some(error)):
          print(error)
        default:
          break
        }
      }
      let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler:  completionHandler)
      task.resume()
    }
  }
  
  func findImageForRestaurant(restaurant: Restaurant, completion: RestaurantImageCompletionBlock) {
    guard let imagePath = restaurant.imagePath else { return }
    if let image =  self.imageCache.objectForKey(imagePath) as? UIImage {
      completion(image)
    } else {
      if let url = NSURL(string: imagePath) {
        let task = self.session.dataTaskWithURL(url, completionHandler: { (data, response, error) in
          switch (data, response, error) {
          case (let .Some(data), _, _):
            if let image = UIImage(data: data) {
              self.imageCache.setObject(image, forKey: imagePath)
              dispatch_async(dispatch_get_main_queue()) {
                completion(image)
              }
            }
          case (_,_, let .Some(error)):
            print(error)
          default:
            break
          }
        })
        task.resume()
      }
    }
  }
  
  func restaurantsFromData(data: NSData) -> [Restaurant] {
    var jsonObject : AnyObject
    do {
      jsonObject =  try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
    } catch let error {
      print(error)
      return []
    }
    var restaurants = [Restaurant]()
    if let dictionary = jsonObject as? [String : AnyObject],
      let status = dictionary["status"]  as? String where status == "OK",
      let results = dictionary["results"]  as? [[String: AnyObject]] where !results.isEmpty {
      for dictionary in results {
        if let restaurant = Restaurant(dictionary: dictionary) {
          dispatch_async(dispatch_get_main_queue()) {
          restaurants.append(restaurant)
          }
        }
      }
    }
    return restaurants
  }
  
  func cancelExistingRequests() {
    self.imageCache.removeAllObjects()
    self.session.invalidateAndCancel()
    self.session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
  }
}
