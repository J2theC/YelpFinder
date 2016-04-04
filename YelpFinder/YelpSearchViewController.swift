import UIKit

class YelpSearchViewController : UIViewController  {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filter: UIBarButtonItem!
    @IBOutlet weak var search: UIBarButtonItem!
    private var zipcodeFinder : ZipcodeFinder?
    private let resultsSegueIdentifier = "resultsSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadFirstZipcode()
    }
    
    func loadFirstZipcode() {
        let firstZipcode : ZipcodeFinderCompletion = { zipcode in
            if let zipcode = zipcode where !zipcode.isEmpty {
                self.searchBar.text = zipcode
                self.showLoadingIndicatorForSearchParamater(zipcode)
            }
        }
        self.zipcodeFinder = ZipcodeFinder(delegate: self, completionBlock: firstZipcode)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier, segue.destinationViewController as? YelpResultsViewController) {
        case (let .Some(identifier), let .Some(destination))where identifier == self.resultsSegueIdentifier:
            destination.delegate = self
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