import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:visitor_practise/core/constants/server_link.dart';
import 'package:visitor_practise/core/models/logos_background.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

class LogosBackgroundService {

  static String get defaultTopLogUrl => ServerLink.defaultTopLogo;
  static String get defaultBottomLogoUrl => ServerLink.defaultBottomLogo;
  static String get defaultBackground => ServerLink.defaultBackgroup;
  // Default URLs
  /// Factory method to create LogoBackground instance
  /// Downloads images and handles fallback automatically
  Future<LogosBackground> create({
    String? customTopLogUrl,
    String? customBackground,
  }) async {
    // Process Top Logo
    String finalTopLogUrl;
    Uint8List? topLogBytes;

    if (customTopLogUrl != null && customTopLogUrl.isNotEmpty) {
      finalTopLogUrl = customTopLogUrl;

      // Try to download custom logo
      topLogBytes = await _loadImage(customTopLogUrl);

      if (topLogBytes == null || topLogBytes.isEmpty) {
        // Download failed, fallback to default
        finalTopLogUrl = defaultTopLogUrl;
        topLogBytes = await _loadImage(defaultTopLogUrl); 
      }
    
    } else {
      // No custom logo, use default
      finalTopLogUrl = defaultTopLogUrl;
      topLogBytes = await _loadImage(defaultTopLogUrl);
    }
    // Process Bottom Logo 
    String finalBottomLogUrl;
    Uint8List? bottomLogBytes;

    finalBottomLogUrl = defaultBottomLogoUrl;
    bottomLogBytes = await _loadImage(finalBottomLogUrl);


    // Process Background
    String finalBackground;
    Uint8List? bgBytes;

    if (customBackground != null && customBackground.isNotEmpty) {
      // Has custom background URL
      finalBackground = customBackground;

      // Try to download custom background
      bgBytes = await _loadImage(customBackground);

      if (bgBytes == null || bgBytes.isEmpty) {
        // Download failed, fallback to default
        debugPrint('Custom background download failed, using default');
        finalBackground = defaultBackground;
        bgBytes = await _loadImage(defaultBackground);
      } 

    } else {
      // No custom background, use default
      finalBackground = defaultBackground;
      bgBytes = await _loadImage(defaultBackground);
    }

    saveTolocal(topLogBytes!,bottomLogBytes!,bgBytes!);
    // ============================================
    // Create instance
    // ============================================
    return LogosBackground(
      currentTopLogUrl: finalTopLogUrl,
      bytesTopLog: topLogBytes,
      currentBottomLogUrl: finalBottomLogUrl,
      bytesBottomLog: bottomLogBytes,
      currentBackground: finalBackground,
      bytesBackground: bgBytes,
    );
  }

  Future<void> saveTolocal(Uint8List bytesTopLog, Uint8List bytesBottomLog, Uint8List bytesBackground) async {
    try {
      // Save logo
      await SecureStorageService.saveClientTopLogoBytes(bytesTopLog!);
      await SecureStorageService.saveClientBottomLogoBytes(bytesBottomLog!);
      await SecureStorageService.saveClientBackgroundBytes(bytesBackground!);
    } catch (e) {
      debugPrint('Failed to save LogoBackground: $e');
    }
  }

  static Future<Uint8List?> _loadImage(String path) async {
    try {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        debugPrint('Downloading from network: $path');
        final response = await http.get(Uri.parse(path)).timeout(
          const Duration(seconds: 30),
        );

        if (response.statusCode == 200) {
          debugPrint('Downloaded: ${response.bodyBytes.length} bytes');
          return response.bodyBytes;
        } else {
          debugPrint('Download failed: HTTP ${response.statusCode}');
          return null;
        }
      } else {
        debugPrint('Loading local asset: $path');
        final ByteData data = await rootBundle.load(path);
        final bytes = data.buffer.asUint8List();
        debugPrint('Loaded: ${bytes.length} bytes');
        return bytes;
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
      return null;
    }
  }
}