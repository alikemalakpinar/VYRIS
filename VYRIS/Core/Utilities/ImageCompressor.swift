import UIKit

// MARK: - Image Compressor
// Compress and resize images before persisting to SwiftData.
// Max dimension: 1024px, JPEG quality: 0.7.

enum ImageCompressor {

    static let maxDimension: CGFloat = 1024
    static let jpegQuality: CGFloat = 0.7

    /// Compress image data: resize to max 1024px on longest edge, JPEG at 0.7 quality.
    /// Returns nil if the input data is not a valid image.
    static func compress(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let resized = resize(image, maxDimension: maxDimension)
        return resized.jpegData(compressionQuality: jpegQuality)
    }

    /// Resize a UIImage so its longest edge is at most `maxDimension`.
    /// If already smaller, returns the original image.
    private static func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        guard size.width > maxDimension || size.height > maxDimension else {
            return image
        }

        let scale: CGFloat
        if size.width > size.height {
            scale = maxDimension / size.width
        } else {
            scale = maxDimension / size.height
        }

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
