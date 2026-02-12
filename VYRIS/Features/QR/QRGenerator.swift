import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - QR Code Generator
// Generates high-quality QR codes from vCard data.

enum QRGenerator {

    private static let context = CIContext()
    private static let filter = CIFilter.qrCodeGenerator()

    /// Generate a QR code UIImage from a string.
    static func generate(
        from string: String,
        size: CGFloat = 250,
        correctionLevel: CorrectionLevel = .medium
    ) -> UIImage? {
        guard let data = string.data(using: .utf8) else { return nil }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(correctionLevel.rawValue, forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else { return nil }

        let scale = size / outputImage.extent.width
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    /// Generate a QR code from a BusinessCard's vCard data.
    static func generate(for card: BusinessCard, size: CGFloat = 250) -> UIImage? {
        generate(from: card.vCardString, size: size)
    }

    enum CorrectionLevel: String {
        case low = "L"
        case medium = "M"
        case quartile = "Q"
        case high = "H"
    }
}

// MARK: - SwiftUI QR Code View

struct QRCodeView: View {
    let card: BusinessCard
    let size: CGFloat
    let tintColor: Color

    init(card: BusinessCard, size: CGFloat = 200, tintColor: Color = .black) {
        self.card = card
        self.size = size
        self.tintColor = tintColor
    }

    var body: some View {
        Group {
            if let image = QRGenerator.generate(for: card, size: size) {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .colorMultiply(tintColor)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: size, height: size)
                    .overlay(
                        Text("QR")
                            .font(VYRISTypography.meta())
                            .foregroundColor(.gray)
                    )
            }
        }
    }
}
