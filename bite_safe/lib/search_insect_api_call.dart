import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiApiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static final List<String> _availableModels = [
    'gemini-pro',
    'gemini-1.5-flash',
    'gemini-1.5-pro', 'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-pro',
    'gemini-pro-vision',
    'gemini-2.5-flash-image-preview',
    'gemini-2.5-flash-preview-09-2025',
    'gemini-2.5-flash',
    'gemini-2.5-pro-preview-03-25',
    'gemini-2.0-flash-exp' ,
  ];

  String apiKey;
  String _currentModel = 'gemini-pro';

  GeminiApiService({required this.apiKey});

  void updateApiKey(String newApiKey) {
    apiKey = "AIzaSyBqrJ7GWVhkB9wl90vD5sSrlxKHmH_KSe8";
  }

  Future<GeminiResponse> analyzeInsectQuery(String userQuery) async {
    GeminiResponse response = await _makeApiCall(userQuery, _currentModel);

    if (!response.success) {
      for (String model in _availableModels) {
        if (model != _currentModel) {
          response = await _makeApiCall(userQuery, model);
          if (response.success) {
            _currentModel = model;
            break;
          }
        }
      }
    }

    return response;
  }

  Future<GeminiResponse> _makeApiCall(String userQuery, String modelName) async {
    try {
      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text": """
                Analyze this insect query: "$userQuery"
                
                STEP 1: VERIFICATION - Is this an insect?
                - If NOT AN INSECT → Respond with: "This is not an insect"
                - If VERIFIED AS INSECT → Provide detailed insect information
                
                STEP 2: IF INSECT - PROVIDE STRUCTURED INFORMATION:

                🖼️ VISUAL APPEARANCE:
                Primary Colors: 
                Body Shape: 
                Size Description: 
                Distinctive Markings: 
                Wing Features: 
                Antennae Type: 

                🎯 IDENTIFICATION:
                Common Name: 
                Scientific Name: 
                Family/Order: 

                📊 PHYSICAL CHARACTERISTICS:
                Size Range: 
                Color Patterns: 
                Key Identifying Features: 

                🌍 HABITAT & DISTRIBUTION:
                Natural Habitat: 
                Geographical Range: 
                Preferred Environments: 

                ⚠️ SAFETY ASSESSMENT:
                Harmful to Humans: 
                Risk Level: 
                Potential Dangers: 

                🏥 FIRST AID MEASURES:
                1. 
                2. 
                3. 

                💡 INTERESTING FACTS:
                1. 
                2. 
                3. 

                🔍 IDENTIFICATION TIPS:
                1. 
                2. 
                3. 

                Provide accurate information in this exact format.
                """
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.1,
          "maxOutputTokens": 2048,
          "topP": 0.8,
          "topK": 40
        }
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/models/$modelName:generateContent?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return _parseResponse(responseData);
      } else {
        return GeminiResponse(
          success: false,
          error: 'API Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return GeminiResponse(
        success: false,
        error: 'Network Error: $e',
      );
    }
  }

  GeminiResponse _parseResponse(Map<String, dynamic> responseData) {
    try {
      if (responseData['candidates'] != null &&
          responseData['candidates'].isNotEmpty &&
          responseData['candidates'][0]['content'] != null &&
          responseData['candidates'][0]['content']['parts'] != null &&
          responseData['candidates'][0]['content']['parts'].isNotEmpty) {

        final String text = responseData['candidates'][0]['content']['parts'][0]['text'];
        return GeminiResponse(
          success: true,
          analysis: text,
          rawResponse: responseData,
        );
      } else {
        return GeminiResponse(
          success: false,
          error: 'No valid response from API',
        );
      }
    } catch (e) {
      return GeminiResponse(
        success: false,
        error: 'Error parsing response: $e',
      );
    }
  }
}

class GeminiResponse {
  final bool success;
  final String? analysis;
  final String? error;
  final Map<String, dynamic>? rawResponse;

  GeminiResponse({
    required this.success,
    this.analysis,
    this.error,
    this.rawResponse,
  });
}