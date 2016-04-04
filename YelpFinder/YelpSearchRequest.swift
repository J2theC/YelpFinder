
import Foundation

enum SortOrder : Int, CustomStringConvertible {
  case BestMatch = 0
  case Distance, Rating
  
  var description: String {
    return "\(self.rawValue)"
  }
  
}

protocol YelpSearchRequestDelegate {
  func searchRequestDidUpdateData(request: YelpSearchRequest)
  func searchRequest(request: YelpSearchRequest, DidFailToFetchDataWithError: NSError)
}

class YelpSearchRequest {
  
  static let maxRadius = 40000;
  static let defaultResultCount = 20
  static let defaultSearchTerm = "restaurants"
  let zipcode : String
  let sortOrder : SortOrder
  let radius : Int
  
  static private let sharedSession = YelpSession()
  private (set) var loading : Bool = false
  private var taskIdentifiers = Set<Int>()
  private var currentOffsetPosition = 0
  private var resultData = [AnyObject]()
  
  init? (zipcode: String, sortOrder: SortOrder = .BestMatch, radius: Int = YelpSearchRequest.maxRadius) {
    self.zipcode = zipcode
    self.sortOrder = sortOrder
    self.radius = radius
    if zipcode.isEmpty {
      return nil
    } else {
      self.requestData()
    }
  }
  
  func cancelRequest () {
    YelpSearchRequest.sharedSession.cancelTasks(Array(self.taskIdentifiers))
    self.taskIdentifiers.removeAll()
  }
  
  func loadMore() {
    YelpSearchRequest.sharedSession.downloadRequest(self)
  }
  
  private func appendData(data: [AnyObject]) {
    self.resultData.appendContentsOf(data)
  }
  
  private func requestData() {
    YelpSearchRequest.sharedSession.downloadRequest(self)
  }
  
  private var parameterRepresentation : Dictionary <String, AnyObject> {
    return ["term" : YelpSearchRequest.defaultSearchTerm, "location": self.zipcode, "radius_filter" : self.radius, "sort" : self.sortOrder.rawValue, "offset" : self.currentOffsetPosition]
  }
  
}

extension YelpSearchRequest : CustomStringConvertible {
  
  var description : String {
    return "term=\(YelpSearchRequest.defaultSearchTerm)&location=\(self.zipcode.pathEncodedString)&radius_filter=\(self.radius)&sort=\(self.sortOrder)&offset=\(self.currentOffsetPosition)"
  }
}

