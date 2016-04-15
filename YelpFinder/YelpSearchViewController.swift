import UIKit

class YelpSearchViewController : UIViewController  {
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var filter: UIBarButtonItem!
  @IBOutlet weak var search: UIBarButtonItem!
  let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge )
  let activityLabel = UILabel()
  let activityTitleFont = UIFont.boldSystemFontOfSize(14.0)
  private var zipcodeFinder : ZipcodeFinder?
  private let resultsSegueIdentifier = "resultsSegue"
  private let filterSegueIdentifier = "filterpopover"
  private var request : GoogleRestaurantRequest?
  let restaurantFinder = RestaurantFinder()
  weak var resultsViewController : YelpResultsViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.loadFirstZipcode()
    self.setupBarButtons()
  }
  
  func setupBarButtons() {
    self.activityIndicator.tintColor = UIColor.blueColor()
    let activityItem = UIBarButtonItem(customView: self.activityIndicator)
    let spaceItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    self.activityLabel.numberOfLines = 2;
    self.activityLabel.minimumScaleFactor = 0.5
    self.activityLabel.textAlignment = .Center
    self.activityLabel.font = self.activityTitleFont
    let titleItem = UIBarButtonItem(customView: self.activityLabel)
    self.activityLabel.sizeToFit()
    self.toolbarItems = [spaceItem, titleItem, spaceItem, activityItem]
    self.activityIndicator.hidesWhenStopped = true
  }
  
  func loadFirstZipcode() {
    self.showLoadingIndicatorForSearchParamater("your current zipcode")
    let firstZipcode : ZipcodeFinderCompletion = { zipcode, location in
      if let zipcode = zipcode, let location = location where !zipcode.isEmpty  {
        self.searchBar.text = zipcode
        if let request =  GoogleRestaurantRequest(location: location) {
          self.showLoadingIndicatorForSearchParamater(zipcode)
          self.restaurantFinder.findRestaurantsWithRequest(request) { values in
            self.request = request
            self.resultsViewController?.showRestaurants(values, fromBaseLocation: location)
            self.stopLoadingIndicator()
          }
        }
      }
    }
    self.zipcodeFinder = ZipcodeFinder(delegate: self, completionBlock: firstZipcode)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    switch (segue.identifier, segue.destinationViewController) {
    case (let .Some(identifier), let destination as YelpResultsViewController)where identifier == self.resultsSegueIdentifier:
      destination.delegate = self
      destination.restaurantFinder = self.restaurantFinder
      self.resultsViewController = destination
    case (let .Some(identifier), let destination as FilterViewController) where identifier == self.filterSegueIdentifier:
      if let popover = destination.popoverPresentationController {
        popover.delegate = self
      }
      if let request = self.request {
        destination.originalValue = Float(request.radius)
      }
      destination.delegate = self
      break
    default:
      break
    }
  }
  
  func showLoadingIndicatorForSearchParamater(searchParamater: String) {
    guard !searchParamater.isEmpty else { return }
    self.activityLabel.text = "Finding restaurants in \(searchParamater)..."
    self.activityIndicator.startAnimating()
  }
  
  func stopLoadingIndicator() {
    self.activityLabel.text = nil
    self.activityIndicator.stopAnimating()
  }
  
}

// MARK: UISearchBarDelegate
extension YelpSearchViewController : UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    self.restaurantFinder.cancelExistingRequests()
    self.resultsViewController?.showRestaurants([], clearPrevious: true)
    if let text = searchBar.text where !text.isEmpty {
      ZipcodeFinder.findLocationForZipcode(text, completion: { location in
        self.showLoadingIndicatorForSearchParamater(text)
        if let location = location, let request = GoogleRestaurantRequest(location: location) {
          self.restaurantFinder.findRestaurantsWithRequest(request , completion: { (restaurantData) in
            self.request = request
            self.resultsViewController?.showRestaurants(restaurantData, fromBaseLocation: request.location)
            self.stopLoadingIndicator()
          })
        }
      })
    }
  }
  
}

// MARK: YelpResultsViewControllerDelegate
extension YelpSearchViewController : YelpResultsViewControllerDelegate {
  
}

extension YelpSearchViewController : ZipcodeFinderDelegate {
  
  func zipcodeFinderDidFinish(zipcodeFinder: ZipcodeFinder) {
    if zipcodeFinder ==  self.zipcodeFinder {
      self.zipcodeFinder = nil
    }
  }
  
}

extension YelpSearchViewController : FilterViewControllerDelegate {
  
  func filterViewController(filterViewController: FilterViewController, didChangeFilterToValue value: Float) {
    if let request = self.request {
      request.radius = Int(value)
      self.restaurantFinder.findRestaurantsWithRequest(request, completion: { restaurants in
        self.resultsViewController?.showRestaurants(restaurants, fromBaseLocation: request.location, clearPrevious: true)
      })
    }
  }
}

extension YelpSearchViewController : UIPopoverPresentationControllerDelegate {
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return .None
  }
  
}