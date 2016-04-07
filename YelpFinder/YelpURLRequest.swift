import Foundation

class YelpURLRequest : NSMutableURLRequest {
  
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
//    dictionary["oauth_timestamp"] = "\(Int(NSDate().timeIntervalSince1970))"
    dictionary["oauth_nonce"] = "\(NSUUID().UUIDString)"
    return dictionary
  }
  
  static var baseHeader : Dictionary <String, String> {
    var dictionary = Dictionary <String, String>()
    dictionary["Accept-Encoding"] = "gzip"
    return dictionary
  }
  
  required init (searchRequest: YelpSearchRequest) {
    let searchPath = YelpURLRequest.baseSearchPath + "?" + searchRequest.description
    let time = Int(NSDate().timeIntervalSince1970)
    let baseURL = NSURL(string: searchPath)!
    super.init(URL:baseURL, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: YelpURLRequest.defaultTimeoutInterval)
    self.HTTPMethod = YelpURLRequest.defaultMethod
    var parameters = YelpURLRequest.baseParameter
    parameters["oauth_timestamp"] = time
    var searchParameter = searchRequest.parameterRepresentation
    searchParameter += parameters
    let signature = self.signatureFromParameters(searchParameter)
    parameters["oauth_signature"] = signature
    var headers = YelpURLRequest.baseHeader
//    headers["Authorization"] = "OAuth \(parameters.asHeaderString)"
    headers["Authorization"] = "OAuth oauth_token=\"\(YelpURLRequest.token)\", oauth_nonce=\"\(NSUUID().UUIDString)\", oauth_signature_method=\"\(YelpURLRequest.signatureMethod)\", oauth_consumer_key=\"\(YelpURLRequest.consumerKey)\", oauth_timestamp=\"\(time)\", oauth_version=\"1.0\", oauth_signature=\"\(signature)\""
    self.allHTTPHeaderFields = headers
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func signatureFromParameters (parameters: Dictionary<String, AnyObject>) -> String {
    let signature = [YelpURLRequest.defaultMethod + "&".pathEncodedString + YelpURLRequest.baseSearchPath.pathEncodedString,
      parameters.asEncodedString].joinWithSeparator("&".pathEncodedString)
    print("coming with signature \(signature)")
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
    return NSData(bytes: bytes, length: length).base64EncodedStringWithOptions(.Encoding76CharacterLineLength).pathEncodedString
  }
  
}