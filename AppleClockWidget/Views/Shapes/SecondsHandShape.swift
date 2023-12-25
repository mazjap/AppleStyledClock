import SwiftUI

struct SecondsHandShape: Shape {
    var rotation: Angle
    
    var animatableData: Double {
        get { rotation.radians }
        set { rotation = .radians(newValue) }
    }
    
    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.width, rect.height)
        let radius = diameter / 2
        let bounds = CGRect(center: rect.center, size: CGSize(width: diameter, height: diameter))
        let handWidth = radius / 45
        let holeSize = radius / 16
        let holeBounds = CGRect(center: bounds.center, size: CGSize(width: holeSize, height: holeSize))
        
        return Capsule()
            .offset(y: -radius / 10)
            .rotation(rotation, anchor: .top)
            .path(in: CGRect(x: bounds.midX - handWidth / 2, y: bounds.midY, width: handWidth, height: radius))
            .union(Circle()
                .stroke(lineWidth: handWidth * 1.1)
                .path(in: holeBounds)
            )
            .subtracting(Circle()
                .path(in: holeBounds)
            )
    }
}
