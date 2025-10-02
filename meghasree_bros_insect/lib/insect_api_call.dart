import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GeminiService {
  static const String _apiKey = "AIzaSyBqrJ7GWVhkB9wl90vD5sSrlxKHmH_KSe8";
  static const String _baseUrl = "https://generativelanguage.googleapis.com/v1beta";

  // Test with different model combinations
  static final List<String> _models = [
    'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-pro',
    'gemini-pro-vision',
    'gemini-2.5-flash-image-preview',
        'gemini-2.5-flash-preview-09-2025',
        'gemini-2.5-flash',
        'gemini-2.5-pro-preview-03-25',
        'gemini-2.0-flash-exp' ,
  ];

  /// Convert image to base64
  static String _imageToBase64(dynamic imageFile) {
    try {
      if (kIsWeb) {
        if (imageFile is Uint8List) {
          return base64.encode(imageFile);
        }
      } else {
        if (imageFile is File) {
          Uint8List bytes = imageFile.readAsBytesSync();
          return base64.encode(bytes);
        }
      }
      throw Exception('Unsupported image type');
    } catch (e) {
      throw Exception('Image conversion failed: $e');
    }
  }

  /// Test API connection first
  static Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/models?key=$_apiKey');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        print('✅ API Connection Successful');
        return true;
      } else {
        print('❌ API Connection Failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ API Connection Error: $e');
      return false;
    }
  }

  /// Analyze image with proper error handling
  static Future<AnalysisResult> analyzeImage(dynamic imageFile) async {
    try {
      // First test connection
      final connectionOk = await testConnection();
      if (!connectionOk) {
        return AnalysisResult(
          success: false,
          error: 'API connection failed. Check your internet connection and API key.',
        );
      }

      String base64Image = _imageToBase64(imageFile);
      print('✅ Image converted to base64, length: ${base64Image.length}');

      // Try each model
      for (String model in _models) {
        try {
          print('🔄 Trying model: $model');
          final result = await _sendRequest(model, base64Image);
          if (result != null) {
            print('✅ Success with model: $model');
            return AnalysisResult(
              success: true,
              analysis: result,
              modelUsed: model,
            );
          }
        } catch (e) {
          print('❌ Model $model failed: $e');
          continue;
        }
      }

      return AnalysisResult(
        success: false,
        error: 'All models failed. Please check:\n1. API key validity\n2. Billing setup\n3. Internet connection',
      );

    } catch (e) {
      return AnalysisResult(
        success: false,
        error: 'Analysis failed: $e',
      );
    }
  }

  static Future<String?> _sendRequest(String model, String base64Image) async {
    final url = Uri.parse('$_baseUrl/models/$model:generateContent?key=$_apiKey');
    
    final requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text": """
              Analyze this insect image comprehensively:

              IDENTIFICATION:
              - Common and scientific names
              - Key identifying features

              CHARACTERISTICS:
              - Size, color, patterns
              - Body structure

              BEHAVIOR & HABITAT:
              - Behavior patterns
              - Preferred habitat

              PRACTICAL INFO:
              - Beneficial or harmful?
              - Health risks?
              - Control methods if pest

              Provide detailed, structured information.
              """
            },
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Image
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.4,
        "maxOutputTokens": 2048,
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(requestBody),
    );

    print('🔧 API Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('✅ API Response: ${jsonResponse.toString().substring(0, 100)}...');
      
      if (jsonResponse['candidates'] != null && 
          jsonResponse['candidates'].isNotEmpty &&
          jsonResponse['candidates'][0]['content'] != null &&
          jsonResponse['candidates'][0]['content']['parts'] != null &&
          jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
        
        return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Invalid response format: ${jsonResponse}');
      }
    } else if (response.statusCode == 400) {
      throw Exception('Bad request - check API key and parameters');
    } else if (response.statusCode == 403) {
      throw Exception('API key invalid or quota exceeded');
    } else if (response.statusCode == 404) {
      throw Exception('Model not found');
    } else if (response.statusCode == 429) {
      throw Exception('Rate limit exceeded');
    } else if (response.statusCode == 500) {
      throw Exception('Server error');
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}

class AnalysisResult {
  final bool success;
  final String? analysis;
  final String? modelUsed;
  final String? error;

  AnalysisResult({
    required this.success,
    this.analysis,
    this.modelUsed,
    this.error,
  });
}