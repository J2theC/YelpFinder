import UIKit
import MapKit
import CoreLocation

protocol FilterViewControllerDelegate : class {
  func filterViewController(filterViewController: FilterViewController, didChangeFilterToValue value: Float)
}
class FilterViewController: UIViewController {
  
  var delegate : FilterViewControllerDelegate?
  private let distanceFormatter = MKDistanceFormatter()
  var originalValue = Float(GoogleRestaurantRequest.defaultRadius)
  @IBOutlet var slider : UISlider!
  @IBOutlet var label : UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.preferredContentSize = CGSize(width: 280, height: 100)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.slider.value = self.originalValue
    self.sliderValueChanged()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    if self.originalValue != self.slider.value {
      self.delegate?.filterViewController(self, didChangeFilterToValue: self.slider.value)
    }
  }
  
  @IBAction func sliderValueChanged() {
    let distance = self.distanceFormatter.stringFromDistance(Double(self.slider.value))
    self.label.text = "Search Radius: \(distance)"
  }
  
}