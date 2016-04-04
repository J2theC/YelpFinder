import Foundation

class YelpSession {
  
  private var taskTable = NSMapTable.strongToWeakObjectsMapTable()
  private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
  
  func downloadRequest(request: YelpSearchRequest) -> Int {
    let urlRequest = YelpURLRequest(searchRequest: request)
    let task = self.session.dataTaskWithRequest(urlRequest) { (data, response, error) in
      switch (data, response as? NSHTTPURLResponse, error) {
      case (_, _, let .Some(error)):
        print(error)
        break
      case (let .Some(data), let .Some(response), _) where response.statusCode == 200:
        let jsonObject : AnyObject
        do {
          try jsonObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
          print(jsonObject)
        } catch let error {
          print(error)
        }
        break
      default:
        break
      }
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
