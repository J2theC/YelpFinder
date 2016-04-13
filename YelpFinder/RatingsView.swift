import UIKit

class RatingsView : UIView {
  
  static let defaultHorizontalPadding : CGFloat = 4.0
  static let defaultVerticalPadding : CGFloat = 0
  var maximunScore = 5;
  var currentScore : Double = 0 {
    didSet {
      self.updateScore()
    }
  }
  private var scoreViews = [ScoreView]()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let maximunScore = CGFloat(self.maximunScore)
    let widthLimit = (self.frame.size.width - (maximunScore * RatingsView.defaultHorizontalPadding)) / maximunScore
    let heightLimit = self.frame.size.height - (RatingsView.defaultVerticalPadding)
    let radius = min(widthLimit, heightLimit)
    guard radius > 0 else { return }
    var horizontalOffset : CGFloat = 0
    for i in 0..<self.maximunScore {
      horizontalOffset += RatingsView.defaultHorizontalPadding
      let origin = CGPoint(x: horizontalOffset, y: RatingsView.defaultVerticalPadding)
      let size = CGSize(width: radius, height: radius)
      let rect = CGRect(origin: origin, size: size)
      self.scoreViews[i].frame = rect
      horizontalOffset += radius
    }
  }
  
  func prepareSubviews() {
    guard self.scoreViews.count != self.maximunScore else { return }
    for view in self.scoreViews {view.removeFromSuperview()}
    for _ in 0..<self.maximunScore {
      let scoreView = ScoreView()
      self.addSubview(scoreView)
      self.scoreViews.append(scoreView)
    }
    self.setNeedsLayout()
  }
  
  func updateScore() {
    self.prepareSubviews()
    var current = self.currentScore
    var index = 0
    while index < self.scoreViews.count {
      let scoreView = self.scoreViews[index]
      scoreView.currentScore = CGFloat(max (min(Double(1), current), 0))
      index += 1
      current -= 1
    }
  }
  
}

class ScoreView : UIView {
  
  var currentScore : CGFloat = 0 {
    didSet {
      print(currentScore)
      self.updateScore()
    }
  }
  var shapeLayer  = CAShapeLayer()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.layer.insertSublayer(self.shapeLayer, atIndex: 0)
    self.clipsToBounds = true
    let color = UIColor.orangeColor()
    self.layer.borderColor = color.CGColor
    self.layer.borderWidth = 1.0
    self.shapeLayer.strokeStart = 0
    self.shapeLayer.strokeEnd = 1
    self.shapeLayer.strokeColor  = color.colorWithAlphaComponent(0.7).CGColor
    self.shapeLayer.setNeedsDisplay()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if self.shapeLayer.frame != self.layer.bounds {
      self.shapeLayer.frame = self.layer.bounds
      let bezierPath = UIBezierPath()
      bezierPath.moveToPoint(CGPoint(x: 0, y: self.frame.height / 2))
      bezierPath.addLineToPoint(CGPoint(x: self.frame.width, y: self.frame.height / 2))
      self.shapeLayer.path = bezierPath.CGPath
      self.shapeLayer.lineWidth = self.frame.size.height
      self.layer.cornerRadius = self.frame.size.width/2
    }
  }
  
  func updateScore() {
    self.shapeLayer.strokeEnd = self.currentScore
  }
  
}
