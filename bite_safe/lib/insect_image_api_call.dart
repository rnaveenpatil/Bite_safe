import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GeminiService {
  static const String _apiKey = "AIzaSyBqrJ7GWVhkB9wl90vD5sSrlxKHmH_KSe8";
  static const String _baseUrl = "https://generativelanguage.googleapis.com/v1beta";

  // Use only working vision models
  static final List<String> _models = [


    'gemini-1.5-flash',
    'gemini-1.5-pro', 'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-pro',
    'gemini-pro-vision',
    'gemini-2.5-flash-image-preview',
    'gemini-2.5-flash-preview-09-2025',
    'gemini-2.5-flash',
    'gemini-2.5-pro-preview-03-25',
    'gemini-2.0-flash-exp'
  ];

  /// Convert image to base64
  static String _imageToBase64(Uint8List imageBytes) {
    try {
      return base64.encode(imageBytes);
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
        final data = json.decode(response.body);
        print('Available models: ${data['models']?.length ?? 0}');
        return true;
      } else {
        print('❌ API Connection Failed: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ API Connection Error: $e');
      return false;
    }
  }

  /// Analyze image with proper error handling
  static Future<AnalysisResult> analyzeImage(Uint8List imageBytes) async {
    try {
      print('🔄 Starting image analysis...');

      // First test connection
      final connectionOk = await testConnection();
      if (!connectionOk) {
        return AnalysisResult(
          success: false,
          error: 'API connection failed. Please check your internet connection.',
        );
      }

      String base64Image = _imageToBase64(imageBytes);
      print('✅ Image converted to base64, length: ${base64Image.length}');

      // Try each model
      for (String model in _models) {
        try {
          print('🔄 Trying model: $model');
          final result = await _sendRequest(model, base64Image);
          if (result != null && result.isNotEmpty) {
            print('✅ Success with model: $model');
            return AnalysisResult(
              success: true,
              analysis: result,
              modelUsed: model,
            );
          }
        } catch (e) {
          print('❌ Model $model failed: $e');
          // Continue to next model
        }
      }

      return AnalysisResult(
        success: false,
        error: 'Unable to analyze the image. Please try again with a clearer image.',
      );

    } catch (e) {
      print('❌ Analysis failed with error: $e');
      return AnalysisResult(
        success: false,
        error: 'Analysis failed: ${e.toString()}',
      );
    }
  }

  static Future<String?> _sendRequest(String model, String base64Image) async {
    final url = Uri.parse('$_baseUrl/models/$model:generateContent?key=$_apiKey');

    // Simple, clear prompt
    final requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text": """Analyze this image carefully and provide a structured response:

STEP 1: Check if the image contains any insects or bugs
- Look carefully for any insects, bugs, arthropods, or small creatures
- If NO insects are visible, respond with: "This is not an insect image."

STEP 2: If insects ARE detected:
- Identify the insect (common name)
- Determine if it is HARMFUL or HARMLESS to humans
- Provide a brief description

STEP 3: If the insect is HARMFUL:
- Provide 2-3 first aid tips
- Include 1-2 interesting facts

STEP 4: If the insect is HARMLESS:
- Provide 2-3 interesting facts
- Explain its ecological role

RESPONSE FORMAT:

If NO insect:
❌ This is not an insect image.

If HARMFUL insect:
🐛 INSECT DETECTED - HARMFUL

Identification: [Insect name]
Description: [Brief description]
Risk Level: [Low/Medium/High]

FIRST AID TIPS:
1. [First aid tip 1]
2. [First aid tip 2]
3. [First aid tip 3]

INTERESTING FACTS:
• [Fact 1]
• [Fact 2]

If HARMLESS insect:
🦋 INSECT DETECTED - HARMLESS

Identification: [Insect name]
Description: [Brief description]

INTERESTING FACTS:
• [Fact 1]
• [Fact 2]
• [Fact 3]

Ecological Role: [Brief ecological importance]

Be accurate and only identify what you clearly see."""
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
        "temperature": 0.1,
        "maxOutputTokens": 1200,
        "topP": 0.8,
        "topK": 40
      }
    };

    print('🔧 Sending request to: $model');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    print('🔧 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['candidates'] != null &&
          jsonResponse['candidates'].isNotEmpty &&
          jsonResponse['candidates'][0]['content'] != null &&
          jsonResponse['candidates'][0]['content']['parts'] != null &&
          jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {

        final text = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        print('📝 Analysis result: $text');
        return text;
      } else {
        print('❌ Invalid response format: ${jsonResponse}');
        return null;
      }
    } else {
      print('❌ HTTP Error ${response.statusCode}: ${response.body}');
      throw Exception('HTTP ${response.statusCode}');
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