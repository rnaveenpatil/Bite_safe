import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image that works for both platforms
  static Future<ImageData?> pickImage() async {
    try {
      if (kIsWeb) {
        return await _pickImageWeb();
      } else {
        return await _pickImageMobile();
      }
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Pick image for web
  static Future<ImageData?> _pickImageWeb() async {
    // Web implementation will be handled separately
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        return ImageData(
          file: bytes,
          name: pickedFile.name,
          isWeb: true,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image on web: $e');
    }
  }

  /// Pick image for mobile
  static Future<ImageData?> _pickImageMobile() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        return ImageData(
          file: bytes,
          name: pickedFile.name,
          isWeb: false,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image on mobile: $e');
    }
  }

  /// Get image URL for display
  static Future<String> getImageUrl(ImageData imageData) async {
    final bytes = imageData.file;
    final base64String = base64.encode(bytes);

    // Detect image type
    String mimeType = 'image/jpeg';
    final name = imageData.name.toLowerCase();
    if (name.endsWith('.png')) {
      mimeType = 'image/png';
    } else if (name.endsWith('.gif')) {
      mimeType = 'image/gif';
    } else if (name.endsWith('.bmp')) {
      mimeType = 'image/bmp';
    } else if (name.endsWith('.webp')) {
      mimeType = 'image/webp';
    }

    return 'data:$mimeType;base64,$base64String';
  }

  /// Convert ImageData to Uint8List
  static Uint8List getImageBytes(ImageData imageData) {
    return imageData.file;
  }

  /// Get image size in KB
  static double getImageSizeInKB(ImageData imageData) {
    return imageData.file.length / 1024;
  }

  /// Validate image size (max 10MB)
  static bool isValidImageSize(ImageData imageData, {double maxSizeMB = 10}) {
    final sizeInKB = getImageSizeInKB(imageData);
    return sizeInKB <= (maxSizeMB * 1024);
  }

  /// Check if image format is supported
  static bool isSupportedFormat(ImageData imageData) {
    return imageData.isSupportedFormat;
  }
}

class ImageData {
  final Uint8List file;
  final String name;
  final bool isWeb;

  ImageData({
    required this.file,
    required this.name,
    required this.isWeb,
  });

  /// Get file extension
  String get extension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Check if image is supported format
  bool get isSupportedFormat {
    final ext = extension;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }
}