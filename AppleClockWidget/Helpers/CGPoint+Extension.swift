import CoreGraphics

extension CGPoint {
    func scaled(by scale: Double) -> CGPoint {
        applying(.init(scaleX: scale, y: scale))
    }
    
    func translated(x: Double, y: Double) -> CGPoint {
        applying(.init(translationX: x, y: y))
    }
}
