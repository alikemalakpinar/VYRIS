import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Watch QR View
// Full-screen high-contrast QR code for maximum scanability.
// Static render; brightness-friendly white-on-black.

struct WatchQRView: View {
    let card: WatchCardData
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 4) {
                if let image = generateQR(from: card.vCardString) {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                } else {
                    Text("QR")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                Text(card.fullName)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.black)
                    .lineLimit(1)
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
