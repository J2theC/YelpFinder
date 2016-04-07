import Foundation

extension Dictionary where Key: StringLiteralConvertible, Value: AnyObject {
  
  var asEncodedString : String {
    var string = String()
    let stringArray = Array(self.keys.map {String($0)}).sort(<)
    for key in stringArray {
      string.appendContentsOf("\(key)=\(self[key as! Key]!)&")
    }
    string.removeAtIndex(string.endIndex.predecessor())
    return string.pathEncodedString
  }
  
  var asHeaderString : String {
    var string = String()
    let stringArray = Array(self.keys.map {String($0)}).sort(<)
    for currentKey in stringArray {
      string.appendContentsOf("\(currentKey)=\"\(self [currentKey as! Key]!)\", ")
    }
    string.removeAtIndex(string.endIndex.predecessor())
    string.removeAtIndex(string.endIndex.predecessor())
    return string
  }
  
}

func +=<K, V> (inout left: [K : V], right: [K : V]) { for (k, v) in right { left[k] = v } }