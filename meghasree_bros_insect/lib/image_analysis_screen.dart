import 'package:flutter/material.dart';
import 'insect_image_piker.dart';
import 'insect_api_call.dart';

class ImageAnalysisScreen extends StatefulWidget {
  @override
  _ImageAnalysisScreenState createState() => _ImageAnalysisScreenState();
}

class _ImageAnalysisScreenState extends State<ImageAnalysisScreen> {
  ImageData? _selectedImage;
  String _analysisResult = '';
  bool _isAnalyzing = false;
  String _currentStatus = 'Select an insect image to analyze';
  String _imageUrl = '';

  Future<void> _pickImage() async {
    try {
      setState(() {
        _currentStatus = 'Selecting image...';
      });

      final imageData = await ImageUtils.pickImage();
      
      if (imageData != null) {
        final imageUrl = await ImageUtils.getImageUrl(imageData);
        setState(() {
          _selectedImage = imageData;
          _imageUrl = imageUrl;
          _analysisResult = '';
          _currentStatus = 'Image selected. Ready to analyze.';
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = '';
      _currentStatus = 'Analyzing insect image...';
    });

    try {
      final result = await GeminiService.analyzeImage(_selectedImage!.file);
      
      setState(() {
        _isAnalyzing = false;
        if (result.success) {
          _analysisResult = result.analysis!;
          _currentStatus = 'Analysis complete!';
        } else {
          _analysisResult = result.error!;
          _currentStatus = 'Analysis failed';
        }
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _analysisResult = 'Error: $e';
        _currentStatus = 'Analysis error';
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedImage = null;
      _imageUrl = '';
      _analysisResult = '';
      _currentStatus = 'Select an insect image to analyze';
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imageUrl.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.photo,
          size: 64,
          color: Colors.grey[400],
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(Icons.error, color: Colors.red),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('meghashrees insect identifiar'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: _clearSelection,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Status
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isAnalyzing ? Icons.autorenew : 
                      _selectedImage != null ? Icons.check_circle : Icons.info,
                      color: _isAnalyzing ? Colors.orange : Colors.green,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentStatus,
                        style: TextStyle(
                          color: _isAnalyzing ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Select Image Button
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.photo_library),
                label: Text('Select Image from Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Image Preview
              if (_selectedImage != null) _buildImagePreview(),
              
              SizedBox(height: 20),
              
              // Analyze Button
              if (_selectedImage != null && !_isAnalyzing)
                ElevatedButton(
                  onPressed: _analyzeImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('upload to meghashree bros Ai model ',style: TextStyle(fontSize: 30),),
                ),
              
              if (_isAnalyzing) ...[
                SizedBox(height: 20),
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Analyzing...'),
              ],
              
              SizedBox(height: 20),
              
              // Results
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Results:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    _analysisResult.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bug_report, size: 64, color: Colors.grey[400]),
                                SizedBox(height: 16),
                                Text(
                                  'Select an insect image\nand click analyze',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            child: Text(
                              _analysisResult,
                              style: TextStyle(fontSize: 26),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}