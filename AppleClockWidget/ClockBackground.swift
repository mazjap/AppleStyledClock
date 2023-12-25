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
    private let backgroundColor: Color
    
    init(style: Style = .all, backgroundColor: Color = .clear) {
        self.style = style
        self.backgroundColor = backgroundColor
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
                Circle()
                    .foregroundStyle(backgroundColor)
                
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

#Preview {
    VStack {
        HStack {
            VStack {
                Text("Numbered")
                ClockBackground(style: .numbered, backgroundColor: .green)
            }
            
            VStack {
                Text("Ticked")
                ClockBackground(style: .ticked, backgroundColor: .red)
            }
            
            VStack {
                Text("Timezone")
                ClockBackground(style: .timezoneAttributed, backgroundColor: .blue)
            }
        }
        
        HStack {
            VStack {
                Text("Ticked & Numbered")
                ClockBackground(style: ClockBackground.Style([.ticked, .numbered]), backgroundColor: .yellow)
            }
            
            VStack {
                Text("All")
                ClockBackground(style: .all)
            }
        }
    }
}
