import SwiftUI

extension Color {

    /// Initialize a Color from a hex integer value.
    /// Usage: `Color(hex: 0xF4F1EB)`
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }

    /// Initialize a Color from a hex string.
    /// Supports formats: "#RRGGBB", "RRGGBB", "#RGB"
    init(hexString: String) {
        var cleaned = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        cleaned = cleaned.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)

        if cleaned.count == 6 {
            self.init(hex: UInt(rgb))
        } else if cleaned.count == 3 {
            let r = (rgb >> 8) & 0xF
            let g = (rgb >> 4) & 0xF
            let b = rgb & 0xF
            self.init(hex: UInt((r << 20) | (r << 16) | (g << 12) | (g << 8) | (b << 4) | b))
        } else {
            self.init(hex: 0x000000)
        }
    }
}
