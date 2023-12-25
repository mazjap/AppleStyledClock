import SwiftUI

struct MinutesHoursHandShape: Shape {
    let rotation: Angle
    let isMinutesHand: Bool
    
    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.width, rect.height)
        let radius = diameter / 2
        let bounds = CGRect(center: rect.center, size: CGSize(width: diameter, height: diameter))
        let handWidth = radius / 45
        let blownUpWidth = radius / 16
        let holeSize = radius / 16
        let holeBounds = CGRect(center: bounds.center, size: CGSize(width: holeSize, height: holeSize))
        
        return Capsule()
            .rotation(rotation, anchor: .top)
            .path(in: CGRect(x: bounds.midX - handWidth / 2, y: bounds.midY, width: handWidth, height: radius * (isMinutesHand ? 0.9 : 0.6)))
            .union(Capsule()
                .offset(y: radius / 8)
                .rotation(rotation, anchor: .top)
                .path(in: CGRect(x: bounds.midX - blownUpWidth / 2, y: bounds.midY, width: blownUpWidth, height: radius * (isMinutesHand ? 0.9 : 0.6) - radius / 8))
            )
            .union(Circle()
                .stroke(lineWidth: handWidth * 2)
                .path(in: holeBounds)
            )
            .subtracting(Circle()
                .path(in: holeBounds)
            )
    }
}
