import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Watch QR View
// Full-screen high-contrast QR code. Static, no animation.
// Maximum scanability: black QR on white pad, dark surround.
// Tap to dismiss.

struct WatchQRView: View {
    let card: WatchCardData
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 6) {
                // QR on white pad for scanability
                if let image = generateQR(from: card.vCardString) {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                        )
                        .padding(.horizontal, 8)
                } else {
                    Image(systemName: "qrcode")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                }

                // Name
                Text(card.fullName)
                    .font(.system(size: 9, weight: .medium, design: .serif))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)

                // Access Key label
                Text("ACCESS KEY")
                    .font(.system(size: 7, weight: .regular))
                    .foregroundColor(.white.opacity(0.3))
                    .tracking(2)
            }
        }
        .onTapGesture { dismiss() }
    }

    private func generateQR(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        guard let data = string.data(using: .utf8) else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")

        guard let output = filter.outputImage else { return nil }
        let scale: CGFloat = 200 / output.extent.width
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
