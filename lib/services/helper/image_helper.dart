import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Image Helper - Utility functions for image processing
class ImageHelper {
  ImageHelper._();

  /// Compress and resize image
  /// Must be top-level function to work with compute() for isolate processing
  ///
  /// Parameters:
  /// - bytes: Original image bytes
  /// - maxWidth: Maximum width (default: 800)
  /// - maxHeight: Maximum height (default: 800)
  /// - quality: JPEG quality 0-100 (default: 85)
  static Uint8List compressImage(
    Uint8List bytes, {
    int maxWidth = 800,
    int maxHeight = 800,
    int quality = 85,
  }) {
    try {
      final image = img.decodeImage(bytes);
      if (image != null) {
        final resized = img.copyResize(
          image,
          width: maxWidth,
          height: maxHeight,
        );
        return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
      }
      return bytes;
    } catch (e) {
      // If compression fails, return original bytes
      return bytes;
    }
  }
}

/// Top-level function for image compression in isolate
/// Must be top-level (not in class) to work with compute()
Uint8List compressImageInIsolate(Uint8List bytes) {
  return ImageHelper.compressImage(bytes);
}
