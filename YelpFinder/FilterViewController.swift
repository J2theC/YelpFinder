import UIKit
import MapKit
import CoreLocation

protocol FilterViewControllerDelegate : class {
  
}
class FilterViewController: UIViewController {
  
  var delegate : FilterViewControllerDelegate?
  private let distanceFormatter = MKDistanceFormatter()
  @IBOutlet var slider : UISlider!
  @IBOutlet var label : UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.preferredContentSize = CGSize(width: 280, height: 100)
    self.sliderValueChanged()
  }
  
  @IBAction func sliderValueChanged() {
    let distance = self.distanceFormatter.stringFromDistance(Double(self.slider.value))
    self.label.text = "Search Radius: \(distance)"
  }
  
}