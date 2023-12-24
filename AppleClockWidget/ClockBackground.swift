import SwiftUI

struct ClockBackground: View {
    struct Style: OptionSet {
        var rawValue: UInt8
        
        static let numbered = Style(rawValue: 1 << 0)
        static let ticked = Style(rawValue: 1 << 1)
        static let timezoneAttributed = Style(rawValue: 1 << 2)
        static let all = Style([.numbered, .ticked, .timezoneAttributed])
    }
    
    private let style: Style
    
    init(style: Style = .all) {
        self.style = style
    }
    
    var body: some View {
        let isNumbered = style.contains(.numbered)
        let isTicked = style.contains(.ticked)
        let isTimezoneAttributed = style.contains(.timezoneAttributed)
        
        GeometryReader { geometry in
            let minDimension = min(geometry.size.width, geometry.size.height)
            let size = switch minDimension {
            case ...256: "Small"
            case ...512: "Medium"
            default: "Large"
            }
            
            ZStack {
                if isNumbered && isTicked {
                    Image("ClockStaticBackground" + size).resizable().scaledToFit()
                } else if isNumbered {
                    Image("ClockNumbersStaticBackground" + size).resizable().scaledToFit()
                } else if isTicked {
                    Image("ClockTicksStaticBackground" + size).resizable().scaledToFit()
                }
                
                if isTimezoneAttributed, let str = TimeZone.current.abbreviation() {
                    Text(str)
                        .font(.system(size: minDimension / 9))
                        .padding(.bottom, minDimension / 3)
                        .foregroundStyle(.secondary)
                }
            }
            .position(CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
        }
    }
}
