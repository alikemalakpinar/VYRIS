import SwiftUI

// MARK: - Card Theme Protocol

protocol CardThemeDefinition {
    var id: String { get }
    var name: String { get }
    var backgroundColor: Color { get }
    var textColor: Color { get }
    var secondaryTextColor: Color { get }
    var accentColor: Color { get }
    var strokeColor: Color { get }
    var strokeWidth: CGFloat { get }
    var layoutStyle: CardLayoutStyle { get }
}

// MARK: - Card Layout Styles

enum CardLayoutStyle: String, Codable {
    case classic         // Name top-left, details bottom
    case centered        // Everything centered
    case minimal         // Name only, large serif
    case modern          // Left-aligned, tight spacing
    case editorial       // Right-aligned name, left details
    case split           // Name left, details right
    case bold            // Large name, small details
    case stacked         // Vertical stack, generous spacing
    case executive       // Centered name, rule separator
    case refined         // Small caps, tracked text
    case asymmetric      // Off-grid artistic placement
    case monogram        // Large initial + compact info
}

// MARK: - Concrete Theme

struct CardTheme: CardThemeDefinition, Identifiable, Hashable {
    let id: String
    let name: String
    let backgroundColor: Color
    let textColor: Color
    let secondaryTextColor: Color
    let accentColor: Color
    let strokeColor: Color
    let strokeWidth: CGFloat
    let layoutStyle: CardLayoutStyle

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CardTheme, rhs: CardTheme) -> Bool {
        lhs.id == rhs.id
    }
}
