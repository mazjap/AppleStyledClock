import SwiftUI

struct ClockView: View {
    let secondHandColor: Color
    let minuteHourHandColor: Color
    let indicatorHourNumberColor: Color
    let timeZoneTextColor: Color
    let backgroundColor: Color
    
    @Environment(\.displayScale) private var displayScale
    
    init(colorScheme: ColorScheme) {
        switch colorScheme {
        case .light:
            self.init(secondHandColor: .red, minuteHourHandColor: .black, indicatorHourNumberColor: .black, timeZoneTextColor: .secondary, backgroundColor: .white)
        case .dark:
            self.init()
        @unknown default:
            self.init()
        }
    }
    
    init(secondHandColor: Color = .red, minuteHourHandColor: Color = .white, indicatorHourNumberColor: Color = .white, timeZoneTextColor: Color = .white.opacity(0.6), backgroundColor: Color = Color(NativeColor.darkGray)) {
        self.secondHandColor = secondHandColor
        self.minuteHourHandColor = minuteHourHandColor
        self.indicatorHourNumberColor = indicatorHourNumberColor
        self.timeZoneTextColor = timeZoneTextColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        ZStack {
            ClockBackground(style: .all, backgroundColor: backgroundColor)
                .foregroundStyle(indicatorHourNumberColor)
            
            TimelineView(.animation(minimumInterval: 1 / 20)) { tl in
                rotatingHandles(for: tl.date)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func rotatingHandles(for date: Date) -> some View {
        Canvas { context, size in
            let diameter = min(size.width, size.height)
            let radius = diameter / 2
            let bounds = CGRect(origin: .zero, size: size)
            let handWidth = radius / 45
            let halfHandWidth = handWidth / 2
            let blownUpWidth = radius / 16
            let halfBlownUpWidth = blownUpWidth / 2
            let angles = angles(for: date)
            let centerHolePath = Circle().path(in: CGRect(x: bounds.midX - halfBlownUpWidth, y: bounds.midY - halfBlownUpWidth, width: blownUpWidth, height: blownUpWidth))
            
            context.stroke(Circle().path(in: CGRect(x: bounds.midX - halfBlownUpWidth - halfHandWidth, y: bounds.midY - halfBlownUpWidth - halfHandWidth, width: blownUpWidth + handWidth, height: blownUpWidth + handWidth)), with: .color(minuteHourHandColor), lineWidth: handWidth)
            
            context.fill(
                Capsule()
                    .rotation(angles.hour, anchor: .top)
                    .path(in: CGRect(x: bounds.midX - halfHandWidth, y: bounds.midY, width: handWidth, height: radius * 0.6)),
                with: .color(minuteHourHandColor)
            )
            context.fill(
                Capsule()
                    .offset(y: radius / 8)
                    .rotation(angles.hour, anchor: .top)
                    .path(in: CGRect(x: bounds.midX - halfBlownUpWidth, y: bounds.midY, width: blownUpWidth, height: radius * 0.6 - radius / 8)),
                with: .color(minuteHourHandColor)
            )
            context.fill(
                Capsule()
                    .rotation(angles.minute, anchor: .top)
                    .path(in: CGRect(x: bounds.midX - halfHandWidth, y: bounds.midY, width: handWidth, height: radius * 0.9)),
                with: .color(minuteHourHandColor)
            )
            context.fill(
                Capsule()
                    .offset(y: radius / 8)
                    .rotation(angles.minute, anchor: .top)
                    .path(in: CGRect(x: bounds.midX - halfBlownUpWidth, y: bounds.midY, width: blownUpWidth, height: radius * 0.9 - radius / 8)),
                with: .color(minuteHourHandColor)
            )
            context.fill(
                Capsule()
                    .offset(y: -radius / 10)
                    .rotation(angles.second, anchor: .top)
                    .path(in: CGRect(x: bounds.midX - halfHandWidth, y: bounds.midY, width: handWidth, height: radius)),
                with: .color(secondHandColor)
            )
            
            context.stroke(centerHolePath, with: .color(secondHandColor), lineWidth: handWidth * 1.1)
            
            context.blendMode = .clear
            context.fill(
                centerHolePath,
                with: .color(.black)
            )
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
    func Stack<Content: View>(@ViewBuilder _ content: @escaping () -> Content) -> some View {
        #if os(macOS)
        HStack(content: content)
        #else
        VStack(content: content)
        #endif
    }
    
    return ZStack {
        Color.black.opacity(0.95)
        
        Stack {
            Spacer()
            
            ClockView(colorScheme: .light)
            
            Spacer()
            
            ClockView(colorScheme: .dark)
            
            Spacer()
        }
        .padding()
    }
    .ignoresSafeArea()
}

extension CGPoint {
    func scaled(by scale: Double) -> CGPoint {
        applying(.init(scaleX: scale, y: scale))
    }
    
    func translated(x: Double, y: Double) -> CGPoint {
        applying(.init(translationX: x, y: y))
    }
}
