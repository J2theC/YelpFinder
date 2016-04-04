
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
  
  private class YelpURLRequest : NSMutableURLRequest {
    
    static let consumerKey = "ClyDZIHf3cItVbNc4OWwjA"
    static let consumerSecret = "td2gtBpYXIrXx3spYf4A7zZqC0U"
    static let token = "Tz_GwW9GqtR8pxgpftPth50Gpb7vSKs4"
    static let tokenSecret = "xacH7FHCfqqJl8u3UEKssPqN44g"
    static let baseSearchPath = "https://api.yelp.com/v2/search/"
    static let signatureMethod = "HMAC-SHA1"
    static let defaultMethod: String = "GET"
    static let defaultTimeoutInterval : NSTimeInterval = 30
    
    static var baseParameter : Dictionary <String, AnyObject> {
      var dictionary = Dictionary <String, AnyObject>()
      dictionary["oauth_token"] = "\(self.token)"
      dictionary["oauth_consumer_key"] = "\(self.consumerKey)"
      dictionary["oauth_signature_method"] = "\(self.signatureMethod)"
      dictionary["oauth_version"] = "1.0"
      dictionary["oauth_timestamp"] = "\(Int(NSDate().timeIntervalSince1970))"
      dictionary["oauth_nonce"] = "\(NSUUID().UUIDString)"
      return dictionary
    }
    
    static var baseHeader : Dictionary <String, String> {
      var dictionary = Dictionary <String, String>()
      dictionary["Accept-Encoding"] = "gzip"
      return dictionary
    }
    
    required init (searchRequest: YelpSearchRequest) {
      let basePath = YelpURLRequest.baseSearchPath
      let searchPath = YelpURLRequest.baseSearchPath.substringToIndex(basePath.endIndex.predecessor()) + "?" + searchRequest.description
      let baseURL = NSURL(string: searchPath)!
      super.init(URL:baseURL, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: YelpURLRequest.defaultTimeoutInterval)
      self.HTTPMethod = YelpURLRequest.defaultMethod
      var parameters = YelpURLRequest.baseParameter
      var searchParameter = searchRequest.parameterRepresentation
      searchParameter += parameters
      parameters["oauth_signature"] = self.signatureFromParameters(searchParameter)
      var headers = YelpURLRequest.baseHeader
      headers["Authorization"] = "OAuth \(parameters.asHeaderString)"
      self.allHTTPHeaderFields = headers
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    private func signatureFromParameters (parameters: Dictionary<String, AnyObject>) -> String {
      let signature = [YelpURLRequest.defaultMethod,
        YelpURLRequest.baseSearchPath.pathEncodedString,
        parameters.asEncodedString].joinWithSeparator("&".pathEncodedString)
      let secrets = [YelpURLRequest.consumerSecret, YelpURLRequest.tokenSecret].joinWithSeparator("&")
      func encoded (string: String) -> NSData? { return string.dataUsingEncoding(NSUTF8StringEncoding) }
      let signatureData = encoded(signature)
      let secretsData = encoded(secrets)
      switch (signatureData, secretsData) {
      case (.Some, .Some):
        break
      case (.Some, .None):
        fatalError("Could not generate secret. Check your API configuration")
      case (.None, .Some):
        fatalError("Could not generate signature. Check your API configuration")
      default:
        fatalError("Could not create a request. Check all your API configuration values")
      }
      let length = Int(CC_SHA1_DIGEST_LENGTH)
      let bytes = UnsafeMutablePointer<Void>.alloc(length)
      CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1),
             secretsData!.bytes,
             secretsData!.length,
             signatureData!.bytes,
             signatureData!.length,
             bytes)
      return NSData(bytes: bytes, length: length).base64EncodedStringWithOptions(.Encoding76CharacterLineLength)
    }
    
  }
  private class YelpSession : NSURLSession {
    
    private var taskTable = NSMapTable.strongToWeakObjectsMapTable()
    
    override init() {
      super.init()
    }
    
    func downloadRequest(request: YelpSearchRequest) -> Int {
      let urlRequest = YelpURLRequest(searchRequest: request)
      let task = self.dataTaskWithRequest(urlRequest) { (data, response, error) in
      }
      task.resume()
      return task.taskIdentifier
    }
    
    func cancelTasks(taskIdentifiers: [Int]) {
      guard !taskIdentifiers.isEmpty else { return }
      for identifier in taskIdentifiers {
        if let task = self[identifier] {
          task.cancel()
        }
      }
    }
    
    subscript (identifier: Int) -> NSURLSessionTask? {
      get {
        switch self.taskTable.objectForKey(identifier) as? NSURLSessionTask {
        case let .Some(task) where task.state != .Completed && task.state != .Canceling:
          return task
        default:
          return nil
        }
      }
      set {
        self.taskTable.setObject(newValue, forKey: identifier)
      }
    }
    
  }
  
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
