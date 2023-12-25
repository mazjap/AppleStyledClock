import SwiftUI

@main
struct AppleClockWidgetApp: App {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some Scene {
        WindowGroup {
            ClockView(colorScheme: colorScheme)
                .background {
                    switch colorScheme {
                    case .light:
                        Color(NativeColor.darkGray)
                    case .dark:
                        Color.white
                    @unknown default:
                        Color.gray
                    }
                }
        }
    }
}
