import 'dart:async'; // Added this import for Completer
import 'dart:io';
//import 'dart:html' as html;
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
        //return await _pickImageWeb();
      } else {
        return await _pickImageMobile();
      }
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Pick image for web

 //static Future<ImageData?> _pickImageWeb() async {
    //final html.FileUploadInputElement input = html.FileUploadInputElement();
   // input.accept = 'image/*';
   // input.click();

   // final completer = Completer<ImageData?>(); // Fixed: Now Completer is available

   // input.onChange.listen((event) {
   //   final files = input.files;
     // if (files == null || files.isEmpty) {
  // completer.complete(null);
     //   return;
      //}

      //final file = files[0];
     // final reader = html.FileReader();

    //  reader.onLoadEnd.listen((e) {
      //  final bytes = reader.result as Uint8List?;
     //   if (bytes != null) {
      //    completer.complete(ImageData(
      //      file: bytes,
          //  name: file.name,
          //  isWeb: true,
       //   ));
      //  } else {
       //   completer.complete(null);
    //    }
  //    });

   //   reader.readAsArrayBuffer(file);
 //   });

 //   return await completer.future;
// }

  /// Pick image for mobile
  static Future<ImageData?> _pickImageMobile() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      return ImageData(
        file: File(pickedFile.path),
        name: pickedFile.name,
        isWeb: false,
      );
    }
    return null;
  }

  /// Get image URL for display
  static Future<String> getImageUrl(ImageData imageData) async {
    if (kIsWeb) {
      // For web, convert Uint8List to data URL
      final bytes = imageData.file as Uint8List;
      final base64String = base64.encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } else {
      // For mobile, return file path
      final file = imageData.file as File;
      return file.path;
    }
  }
}

class ImageData {
  final dynamic file; // Uint8List for web, File for mobile
  final String name;
  final bool isWeb;

  ImageData({
    required this.file,
    required this.name,
    required this.isWeb,
  });
}