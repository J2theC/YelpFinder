import UIKit

class YelpSearchViewController : UIViewController  {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filter: UIBarButtonItem!
    @IBOutlet weak var search: UIBarButtonItem!
    private let resultsSegueIdentifier = "resultsSegue"
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier, segue.destinationViewController as? YelpResultsViewController) {
        case (let .Some(identifier), let .Some(destination))where identifier == self.resultsSegueIdentifier:
            destination.delegate = self
            break
        default:
            break
        }
    }
    
}

// MARK: UISearchBarDelegate
extension YelpSearchViewController : UISearchBarDelegate {
    
}

// MARK: YelpResultsViewControllerDelegate
extension YelpSearchViewController : YelpResultsViewControllerDelegate {
    
}