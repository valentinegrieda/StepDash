import SwiftUI
import UIKit

// MARK: - Hex color

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

// MARK: - Home-screen palette (from the design spec)

extension Pixel {
    static let dYellow     = Color(hex: 0xFEC217)   // claim button when ready
    static let dYellowEdge = Color(hex: 0xD79E0F)
    static let dBlue       = Color(hex: 0xC5DCEB)   // category boxes
    static let dBlueEdge   = Color(hex: 0x9CBDD4)
    static let dOrange     = Color(hex: 0xD94833)   // delivery title, progress bar + text
    static let dWhite      = Color(hex: 0xF9F8F6)   // panels / page background
    static let dWhiteEdge  = Color(hex: 0xE2DED6)
    static let dNavy       = Color(hex: 0x14263F)   // player box + toolbar
    static let dNavyEdge   = Color(hex: 0x0A1626)
    static let dGreen      = Color(hex: 0x36A852)   // accept button
    static let dGreenEdge  = Color(hex: 0x2A8642)
    static let dTrack      = Color(hex: 0xE7E4DE)   // progress track
    static let dMuted      = Color(hex: 0x7A7A7A)
}

// MARK: - Rounded box (radius 8 + 2px darker "under" stroke)

struct PixelBox: ViewModifier {
    var fill: Color
    var stroke: Color
    var radius: CGFloat = 8

    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: radius).fill(fill))
            .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(stroke, lineWidth: 2))
    }
}

extension View {
    func pixelBox(fill: Color, stroke: Color, radius: CGFloat = 8) -> some View {
        modifier(PixelBox(fill: fill, stroke: stroke, radius: radius))
    }
}

// MARK: - Icon loader (asset catalog OR loose Sprites/ PNG, by base name)

struct PixelIcon: View {
    let name: String

    var body: some View {
        resolved
            .resizable()
            .interpolation(.none)
            .scaledToFit()
    }

    private var resolved: Image {
        if let ui = UIImage(named: name) {
            return Image(uiImage: ui)
        }
        if let url = Bundle.main.url(forResource: name, withExtension: "png"),
           let ui = UIImage(contentsOfFile: url.path) {
            return Image(uiImage: ui)
        }
        return Image(systemName: "square.fill")
    }
}

// MARK: - Number formatting ("6.500" style, like the design)

func stepFormatted(_ value: Int) -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.groupingSeparator = "."
    f.groupingSize = 3
    return f.string(from: NSNumber(value: value)) ?? "\(value)"
}
