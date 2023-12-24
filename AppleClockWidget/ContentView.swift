import SwiftUI

struct ContentView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 60)) { tl in
            Canvas { context, size in
                let diameter = min(size.width, size.height)
                let radius = diameter / 2
                let bounds = CGRect(origin: .zero, size: size)
                let clockFrame = CGRect(
                    x: (size.width - diameter) / 2,
                    y: (size.height - diameter) / 2,
                    width: diameter,
                    height: diameter
                )
                let circlePath = Circle().path(in: clockFrame)
                
                context.fill(
                    Path() <- { $0.addRect(bounds) },
                    with: .color(Color(nsColor: .darkGray))
                )
                
                context.blendMode = .clear
                context.fill(circlePath, with: .color(.black))
                context.blendMode = .normal
                
                let nsFont = NSFont.systemFont(ofSize: diameter / 9)
                let font = Font(nsFont)
                
                for (index, hour) in (Array(3...12) + [1, 2]).enumerated() {
                    let hourStr = "\(hour)"
                    let angle = Angle(degrees: 360 * Double(index) / 12)
                    let textSize = hourStr.size(withAttributes: [.font : nsFont])
                    let sin = sin(angle.radians)
                    let cos = cos(angle.radians)
                    
                    let frame = CGRect(
                        origin: CGPoint(
                            x: (bounds.midX + cos * diameter * 0.35) - textSize.width / 2,
                            y: (bounds.midY + sin * diameter * 0.35) - textSize.height / 2
                        ),
                        size: textSize
                    )
                    
                    context.draw(Text(hourStr).font(font).foregroundStyle(.white), in: frame)
                }
                
                for (i, angle) in (1...60).map({ ($0, Angle(degrees: 360 * Double($0) / 60.0)) }) {
                    let cos = cos(angle.radians)
                    let sin = sin(angle.radians)
                    
                    let isNumbered = i % 5 == 0
                    
                    context.stroke(Path() <- { path in
                        let point = CGPoint(x: cos * diameter, y: sin * diameter)
                        
                        path.move(to: point.scaled(by: isNumbered ? 0.43 : 0.44).translated(x: bounds.midX, y: bounds.midY))
                        path.addLine(to: point.scaled(by: isNumbered ? 0.48 : 0.47).translated(x: bounds.midX, y: bounds.midY))
                    }, with: .color(isNumbered ? .white : .gray), style: StrokeStyle(lineWidth: diameter * 0.01, lineCap: .round))
                }
                
                let angles = angles(for: tl.date)
                
                let handWidth = radius / 45
                let halfHandWidth = handWidth / 2
                let blownUpWidth = radius / 16
                let halfBlownUpWidth = blownUpWidth / 2
                let centerHolePath = Circle().path(in: CGRect(x: bounds.midX - halfBlownUpWidth, y: bounds.midY - halfBlownUpWidth, width: blownUpWidth, height: blownUpWidth))
                
                context.stroke(Circle().path(in: CGRect(x: bounds.midX - halfBlownUpWidth - halfHandWidth, y: bounds.midY - halfBlownUpWidth - halfHandWidth, width: blownUpWidth + handWidth, height: blownUpWidth + handWidth)), with: .color(.white), lineWidth: handWidth)
                
                context.fill(
                    Capsule()
                        .offset(y: -radius / 5)
                        .rotation(angles.hour, anchor: .top)
                        .path(in: CGRect(x: bounds.midX - halfHandWidth, y: bounds.midY, width: handWidth, height: radius * 0.8)),
                    with: .color(.white)
                )
                context.fill(
                    Capsule()
                        .offset(y: radius / 10)
                        .rotation(angles.hour, anchor: .top)
                        .path(in: CGRect(x: bounds.midX - halfBlownUpWidth, y: bounds.midY, width: blownUpWidth, height: radius * 0.8 - radius / 5 - radius / 10)),
                    with: .color(.white)
                )
                context.fill(
                    Capsule()
                        .offset(y: -radius / 10)
                        .rotation(angles.minute, anchor: .top)
                        .path(in: CGRect(x: bounds.midX - halfHandWidth, y: bounds.midY, width: handWidth, height: radius)),
                    with: .color(.white)
                )
                context.fill(
                    Capsule()
                        .offset(y: radius / 10)
                        .rotation(angles.minute, anchor: .top)
                        .path(in: CGRect(x: bounds.midX - halfBlownUpWidth, y: bounds.midY, width: blownUpWidth, height: radius - radius / 5)),
                    with: .color(.white)
                )
                context.fill(
                    Capsule()
                        .offset(y: -radius / 10)
                        .rotation(angles.second, anchor: .top)
                        .path(in: CGRect(x: bounds.midX - halfHandWidth, y: bounds.midY, width: handWidth, height: radius)),
                    with: .color(.red)
                )
                
                context.stroke(centerHolePath, with: .color(.red), lineWidth: halfHandWidth * 2)
                
                context.blendMode = .clear
                
                context.fill(
                    centerHolePath,
                    with: .color(.black)
                )
            }
        }
    }
    
    private func angles(for time: Date) -> (hour: Angle, minute: Angle, second: Angle) {
        let components = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: time)
        guard let hourInt = components.hour,
              let minuteInt = components.minute,
              let secondInt = components.second,
              let nanosecondInt = components.nanosecond
        else { return (.zero, .zero, .zero) }
        
        let seconds = Double(secondInt) + (Double(nanosecondInt) / 1_000_000_000)
        let minutes = Double(minuteInt) + seconds / 60
        let hours = Double(hourInt) + minutes / 60
        
        return (.degrees(hours / 12 * 360 - 180), .degrees(minutes / 60 * 360 - 180), .degrees(seconds / 60 * 360 - 180))
    }
}

#Preview {
    ContentView()
}

extension CGPoint {
    func scaled(by scale: Double) -> CGPoint {
        CGPoint(x: x * scale, y: y * scale)
    }
    
    func translated(x: Double, y: Double) -> CGPoint {
        CGPoint(x: self.x + x, y: self.y + y)
    }
}
