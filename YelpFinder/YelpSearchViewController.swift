import UIKit

class YelpSearchViewController : UIViewController  {
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var filter: UIBarButtonItem!
  @IBOutlet weak var search: UIBarButtonItem!
  private var zipcodeFinder : ZipcodeFinder?
  private let resultsSegueIdentifier = "resultsSegue"
  private var request : GoogleRestaurantRequest?
  let restaurantFinder = RestaurantFinder()
  weak var resultsViewController : YelpResultsViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.loadFirstZipcode()
  }
  
  func loadFirstZipcode() {
    let firstZipcode : ZipcodeFinderCompletion = { zipcode, location in
      if let zipcode = zipcode, let location = location where !zipcode.isEmpty  {
        self.searchBar.text = zipcode
        self.showLoadingIndicatorForSearchParamater(zipcode)
        if let request =  GoogleRestaurantRequest(location: location) {
          self.restaurantFinder.findRestaurantsWithRequest(request) { values in
            self.resultsViewController?.showRestaurants(values, fromBaseLocation: location)
          }
        }
      }
    }
    self.zipcodeFinder = ZipcodeFinder(delegate: self, completionBlock: firstZipcode)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    switch (segue.identifier, segue.destinationViewController as? YelpResultsViewController) {
    case (let .Some(identifier), let .Some(destination))where identifier == self.resultsSegueIdentifier:
      destination.delegate = self
      destination.restaurantFinder = self.restaurantFinder
      self.resultsViewController = destination
      break
    default:
      break
    }
  }
  
  func showLoadingIndicatorForSearchParamater(searchParamater: String) {
    
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
        if let location = location, let request = GoogleRestaurantRequest(location: location) {
          self.restaurantFinder.findRestaurantsWithRequest(request , completion: { (restaurantData) in
            self.resultsViewController?.showRestaurants(restaurantData)
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