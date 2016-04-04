
import Foundation
import UIKit

protocol YelpResultsViewControllerDelegate : class {
    
}

class YelpResultsViewController : UITableViewController {
    
    var delegate : YelpResultsViewControllerDelegate?
    
    override func viewDidLoad() {
        self.tableView.registerClass(YelpResultCell.self, forCellReuseIdentifier: YelpResultCell.reuseIdentifier)
    }
    
}

