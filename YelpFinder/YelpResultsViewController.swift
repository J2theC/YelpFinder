
import Foundation
import UIKit
import CoreLocation
import MapKit

protocol YelpResultsViewControllerDelegate : class {
  
}

class YelpResultsViewController : UITableViewController {
  
  var delegate : YelpResultsViewControllerDelegate?
  private var restaurants = [Restaurant]()
  private var baseLocation: CLLocation?
  private let distanceFormatter = MKDistanceFormatter()
  var restaurantFinder : RestaurantFinder?
  
  override func viewDidLoad() {
    self.distanceFormatter.unitStyle = .Full
    super.viewDidLoad()
  }
  
  func showRestaurants(restaurants: [Restaurant], fromBaseLocation location: CLLocation? = nil, clearPrevious: Bool = false) {
    self.baseLocation = location
    if clearPrevious {
      self.restaurants.removeAll()
      self.tableView.reloadData()
    }
    self.restaurants.appendContentsOf(restaurants)
    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
  }
  
}

extension YelpResultsViewController {
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.restaurants.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(YelpResultCell.reuseIdentifier, forIndexPath: indexPath)  as! YelpResultCell
    self.updateCell(cell, withRestaurantAtIndexPath: indexPath)
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return YelpResultCell.dynamicHeightForRestaurant(self.restaurants[indexPath.row], constraintedToWidth: tableView.frame.size.width)
  }
  
  func updateCell(cell: YelpResultCell, withRestaurantAtIndexPath indexPath: NSIndexPath) {
    let restaurant = self.restaurants[indexPath.row]
    cell.dataIdentifier = restaurant.identifier
    cell.name.text = restaurant.name
    cell.reviews.text = restaurant.reviewsDescription
    cell.address.text = restaurant.address
    cell.restaurantType.text = restaurant.category
    cell.price.text = restaurant.priceDescription
    cell.ratingsView.currentScore = restaurant.rating
    if let baseLocation = self.baseLocation, let restaurantCoordinate = restaurant.coordinate {
      cell.distance.text = self.distanceFormatter.stringFromDistance(baseLocation.distanceFromLocation(CLLocation(latitude: restaurantCoordinate.latitude, longitude: restaurantCoordinate.longitude)))
    } else {
      cell.distance.text = "No data"
    }
    if let image = restaurant.image {
      cell.restaurantImage.image = image
    } else {
      self.restaurantFinder?.findImageForRestaurant(restaurant, completion: { image in
        restaurant.image = image
        if cell.dataIdentifier == restaurant.identifier {
            cell.restaurantImage.image = image
        } else {
          self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        }
      })
    }
  }
  
}
