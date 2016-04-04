import Foundation

extension Dictionary {
  
  var asEncodedString : String {
    var string = String()
    for (key, value) in self {
      string.appendContentsOf("\(key)=\(value)&")
    }
    string.removeAtIndex(string.endIndex.predecessor())
    return string.pathEncodedString
  }
  
  var asHeaderString : String {
    var string = String()
    for (key, value) in self {
      string.appendContentsOf("\(key)=\"\(value)\", ")
    }
    string.removeAtIndex(string.endIndex.predecessor())
    string.removeAtIndex(string.endIndex.predecessor())
    return string
  }
  
}

func +=<K, V> (inout left: [K : V], right: [K : V]) { for (k, v) in right { left[k] = v } }