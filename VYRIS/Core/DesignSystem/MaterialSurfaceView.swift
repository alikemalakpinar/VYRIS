import SwiftUI

// MARK: - Card Tier
// Defines the material behavior level for a card surface.

enum CardTier: String, Codable, CaseIterable, Identifiable {
    case standard    // Matte surface, no specular
    case executive   // Matte + specular highlight layer
    case signature   // Matte + specular + edge illumination + serial number

    var id: String { rawValue }

    var localizationKey: LocalizedStringKey {
        LocalizedStringKey("tier.\(rawValue)")
    }

    var hasSpecular: Bool {
        self != .standard
    }

    var hasEdgeIllumination: Bool {
        self == .signature
    }
}

// MARK: - Material Variant
// The three core material palettes.

enum MaterialVariant: String, Codable, CaseIterable, Identifiable {
    case obsidian   // Deep blue-black
    case titanium   // Cool mid-gray
    case ivory      // Warm off-white

    var id: String { rawValue }

    var localizationKey: LocalizedStringKey {
        LocalizedStringKey("material.\(rawValue)")
    }

    var baseColor: Color {
        switch self {
        case .obsidian: return Color(hex: 0x0E1117)
        case .titanium: return Color(hex: 0x3A3D42)
        case .ivory: return Color(hex: 0xF4F1EB)
        }
    }

    var textColor: Color {
        switch self {
        case .obsidian: return Color(hex: 0xE8E6E2)
        case .titanium: return Color(hex: 0xF0EDE8)
        case .ivory: return Color(hex: 0x1C1C1E)
        }
    }

    var secondaryTextColor: Color {
        switch self {
        case .obsidian: return Color(hex: 0x6B7280)
        case .titanium: return Color(hex: 0x9CA3AF)
        case .ivory: return Color(hex: 0x6E6E73)
        }
    }

    var accentColor: Color {
        switch self {
        case .obsidian: return Color(hex: 0xC6A96B)
        case .titanium: return Color(hex: 0xA8B4C0)
        case .ivory: return Color(hex: 0xC6A96B)
        }
    }

    var specularGradientColors: [Color] {
        switch self {
        case .obsidian:
            return [
                Color.white.opacity(0.0),
                Color.white.opacity(0.04),
                Color.white.opacity(0.0)
            ]
        case .titanium:
            return [
                Color.white.opacity(0.0),
                Color.white.opacity(0.06),
                Color.white.opacity(0.0)
            ]
        case .ivory:
            return [
                Color.white.opacity(0.0),
                Color.white.opacity(0.08),
                Color.white.opacity(0.0)
            ]
        }
    }

    var edgeColor: Color {
        switch self {
        case .obsidian: return Color(hex: 0xC6A96B).opacity(0.3)
        case .titanium: return Color.white.opacity(0.15)
        case .ivory: return Color(hex: 0xC6A96B).opacity(0.2)
        }
    }
}

// MARK: - Material Surface View
// Reusable component: MaterialSurfaceView(material, tier, tiltX, tiltY)
// Renders layered material surface with grain, specular highlight, and edge illumination.

struct MaterialSurfaceView: View {
    let material: MaterialVariant
    let tier: CardTier
    let tiltX: Double
    let tiltY: Double
    let cornerRadius: CGFloat

    init(
        material: MaterialVariant = .obsidian,
        tier: CardTier = .standard,
        tiltX: Double = 0,
        tiltY: Double = 0,
        cornerRadius: CGFloat = 4
    ) {
        self.material = material
        self.tier = tier
        self.tiltX = tiltX
        self.tiltY = tiltY
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        ZStack {
            // Layer 1: Base material color
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(material.baseColor)

            // Layer 2: Subtle grain/noise texture at very low opacity
            MaterialGrainLayer()
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .opacity(grainOpacity)

            // Layer 3: Specular highlight (Executive+ tiers)
            if tier.hasSpecular {
                SpecularHighlightLayer(
                    material: material,
                    tiltX: tiltX,
                    tiltY: tiltY
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }

            // Layer 4: Edge illumination (Signature tier)
            if tier.hasEdgeIllumination {
                EdgeIlluminationLayer(
                    color: material.edgeColor,
                    tiltX: tiltX,
                    tiltY: tiltY,
                    cornerRadius: cornerRadius
                )
            }
        }
    }

    private var grainOpacity: Double {
        switch material {
        case .obsidian: return 0.025
        case .titanium: return 0.03
        case .ivory: return 0.035
        }
    }
}

// MARK: - Material Grain Layer
// Fine noise texture that simulates physical material surface.

struct MaterialGrainLayer: View {
    var body: some View {
        Canvas { context, size in
            let density = 0.012
            let count = Int(size.width * size.height * density)
            for _ in 0..<count {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let opacity = Double.random(in: 0.03...0.10)
                context.fill(
                    Path(CGRect(x: x, y: y, width: 1, height: 1)),
                    with: .color(.gray.opacity(opacity))
                )
            }
        }
    }
}

// MARK: - Specular Highlight Layer
// LinearGradient driven by device tilt. Simulates light reflection on a polished surface.

struct SpecularHighlightLayer: View {
    let material: MaterialVariant
    let tiltX: Double
    let tiltY: Double

    // Specular position shifts 1.5x relative to tilt
    private var highlightOffset: CGPoint {
        CGPoint(
            x: tiltY * 1.5 * 15.0,
            y: -tiltX * 1.5 * 15.0
        )
    }

    // Gradient angle derived from tilt direction
    private var gradientAngle: Angle {
        let angle = atan2(tiltY, tiltX) * (180.0 / .pi)
        return .degrees(angle + 90)
    }

    var body: some View {
        LinearGradient(
            colors: material.specularGradientColors,
            startPoint: specularStart,
            endPoint: specularEnd
        )
        .offset(x: highlightOffset.x, y: highlightOffset.y)
    }

    private var specularStart: UnitPoint {
        let normalized = normalizedTilt
        return UnitPoint(
            x: 0.3 + normalized.x * 0.2,
            y: 0.2 + normalized.y * 0.2
        )
    }

    private var specularEnd: UnitPoint {
        let normalized = normalizedTilt
        return UnitPoint(
            x: 0.7 + normalized.x * 0.2,
            y: 0.8 + normalized.y * 0.2
        )
    }

    private var normalizedTilt: CGPoint {
        CGPoint(
            x: tiltY / 5.0,  // Normalize to -1...1 range (max 5 degrees)
            y: -tiltX / 5.0
        )
    }
}

// MARK: - Edge Illumination Layer
// Subtle glow along card edges, shifting with tilt. Signature tier only.

struct EdgeIlluminationLayer: View {
    let color: Color
    let tiltX: Double
    let tiltY: Double
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(
                AngularGradient(
                    colors: [
                        color.opacity(edgeOpacity(at: 0)),
                        color.opacity(edgeOpacity(at: 0.25)),
                        color.opacity(edgeOpacity(at: 0.5)),
                        color.opacity(edgeOpacity(at: 0.75)),
                        color.opacity(edgeOpacity(at: 1.0))
                    ],
                    center: .center,
                    startAngle: .degrees(tiltAngle),
                    endAngle: .degrees(tiltAngle + 360)
                ),
                lineWidth: 1.0
            )
    }

    private var tiltAngle: Double {
        atan2(tiltY, tiltX) * (180.0 / .pi)
    }

    /// Compute varying edge opacity based on angular position relative to tilt.
    private func edgeOpacity(at fraction: Double) -> Double {
        let tiltMagnitude = sqrt(tiltX * tiltX + tiltY * tiltY) / 5.0
        let angleDiff = abs(fraction - 0.5) * 2.0
        return max(0.1, 1.0 - angleDiff) * min(1.0, tiltMagnitude + 0.3)
    }
}

// MARK: - Preview

#Preview("Obsidian Standard") {
    MaterialSurfaceView(material: .obsidian, tier: .standard)
        .aspectRatio(VYRISCardDimensions.aspectRatio, contentMode: .fit)
        .padding()
}

#Preview("Titanium Executive") {
    MaterialSurfaceView(material: .titanium, tier: .executive, tiltX: 2, tiltY: -1)
        .aspectRatio(VYRISCardDimensions.aspectRatio, contentMode: .fit)
        .padding()
}

#Preview("Ivory Signature") {
    MaterialSurfaceView(material: .ivory, tier: .signature, tiltX: 3, tiltY: 2)
        .aspectRatio(VYRISCardDimensions.aspectRatio, contentMode: .fit)
        .padding()
}
