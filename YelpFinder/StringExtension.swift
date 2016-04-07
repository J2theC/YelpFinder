import Foundation

extension String {
  
  var pathEncodedString : String {
    let characterSet = NSCharacterSet(charactersInString: "!*'();:@&=+$,/?%#[]").invertedSet
    return (self as NSString).stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!
  }
  
}