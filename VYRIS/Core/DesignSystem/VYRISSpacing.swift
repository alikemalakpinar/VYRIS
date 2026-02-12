import SwiftUI

// MARK: - VYRIS Spacing System
// Consistent spatial rhythm for the luxury aesthetic.

enum VYRISSpacing {

    /// 4pt — micro adjustments
    static let xxs: CGFloat = 4

    /// 8pt — tight internal padding
    static let xs: CGFloat = 8

    /// 12pt — compact spacing
    static let sm: CGFloat = 12

    /// 16pt — standard padding
    static let md: CGFloat = 16

    /// 24pt — section spacing
    static let lg: CGFloat = 24

    /// 32pt — generous breathing room
    static let xl: CGFloat = 32

    /// 48pt — major section divisions
    static let xxl: CGFloat = 48

    /// 64pt — hero-level spacing
    static let hero: CGFloat = 64
}

// MARK: - Card Dimensions

enum VYRISCardDimensions {

    /// Standard business card aspect ratio (3.5 × 2 inches → 1.75:1)
    static let aspectRatio: CGFloat = 1.586

    /// Card corner radius — sharp, precise, premium (2–4pt range)
    static let cornerRadius: CGFloat = 4

    /// Horizontal card padding from screen edge
    static let horizontalInset: CGFloat = 24

    /// Thumbnail card width for selector
    static let thumbnailWidth: CGFloat = 64

    /// Thumbnail card height for selector
    static let thumbnailHeight: CGFloat = 40

    static func cardWidth(in geometry: GeometryProxy) -> CGFloat {
        geometry.size.width - (horizontalInset * 2)
    }

    static func cardHeight(in geometry: GeometryProxy) -> CGFloat {
        cardWidth(in: geometry) / aspectRatio
    }
}
