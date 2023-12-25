import SwiftUI

struct ClockView: View {
    let secondHandColor: Color
    let minuteHourHandColor: Color
    let indicatorHourNumberColor: Color
    let timeZoneTextColor: Color
    let backgroundColor: Color
    
    @State private var secondHandRotation = Angle.zero
    @State private var minuteHandRotation = Angle.zero
    @State private var hourHandRotation = Angle.zero
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
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
            
            MinutesHoursHandShape(isMinutesHand: false, rotation: hourHandRotation)
                .fill(minuteHourHandColor)
            
            MinutesHoursHandShape(isMinutesHand: true, rotation: minuteHandRotation)
                .fill(minuteHourHandColor)
            
            SecondsHandShape(rotation: secondHandRotation)
                .fill(secondHandColor)
        }
        .onAppear {
            let rotations = angles(for: .now)
            secondHandRotation = rotations.second
            minuteHandRotation = rotations.minute
            hourHandRotation = rotations.hour
            
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                secondHandRotation = .degrees(secondHandRotation.degrees + 360)
            }
        }
        .onReceive(timer) { _ in
            let rotations = angles(for: .now)
            
            minuteHandRotation = rotations.minute
            hourHandRotation = rotations.hour
        }
        .aspectRatio(1, contentMode: .fit)
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
