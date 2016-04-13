
import UIKit

class YelpResultCell: UITableViewCell {
  
  static let reuseIdentifier = "YelpResultCellIdentifier"
  static let approximateHeight : CGFloat = 80.0
  static let titleFont = UIFont.boldSystemFontOfSize(13)
  static let infoFont = UIFont.systemFontOfSize(10)
  static let imageWidth : CGFloat = 64.0
  static let distanceLabelWidth : CGFloat = 50.0
  static let defaultPadding : CGFloat = 8.0
  static let defaultNameLabelHeight : CGFloat = 16.0
  static let defaultInfoLabelHeight : CGFloat = 12.0
  
  static func dynamicHeightForRestaurant(restaurant: Restaurant, constraintedToWidth width: CGFloat) -> CGFloat {
    var height = self.approximateHeight
    let titleLabelWidth = width -  self.defaultPadding - self.imageWidth - self.defaultPadding - self.defaultPadding - distanceLabelWidth - self.defaultPadding
    height += heightForLabelWithString(restaurant.name, constraintedToWidth: titleLabelWidth, font: self.titleFont, defaultHeight: self.defaultNameLabelHeight)
    let addressLabelWith = width -  self.defaultPadding - self.imageWidth - self.defaultPadding - self.defaultPadding
    height += heightForLabelWithString(restaurant.address, constraintedToWidth: addressLabelWith, font: self.infoFont, defaultHeight: self.defaultInfoLabelHeight)
    if let category = restaurant.category {
      height += heightForLabelWithString(category, constraintedToWidth: addressLabelWith, font: self.infoFont, defaultHeight: self.defaultInfoLabelHeight)
    }
    return height
  }
  
  static func heightForLabelWithString(string: String, constraintedToWidth maxWidth: CGFloat, font: UIFont, defaultHeight: CGFloat) -> CGFloat {
    let options : NSStringDrawingOptions = [NSStringDrawingOptions.UsesLineFragmentOrigin, NSStringDrawingOptions.UsesFontLeading]
    let boundingSize = CGSize(width: maxWidth, height: CGFloat.max)
    let attributes : [String : AnyObject] = [NSFontAttributeName : font]
    let size = (string as NSString).boundingRectWithSize(boundingSize, options: options , attributes: attributes, context: nil)
    return max(ceil(size.height) - defaultHeight, 0)
  }
  
  @IBOutlet weak var restaurantImage: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var distance: UILabel!
  @IBOutlet weak var starContainer: UIView!
  @IBOutlet weak var reviews: UILabel!
  @IBOutlet weak var price: UILabel!
  @IBOutlet weak var address: UILabel!
  @IBOutlet weak var restaurantType: UILabel!
  @IBOutlet weak var ratingsView: RatingsView!
  var dataIdentifier = String()
}
