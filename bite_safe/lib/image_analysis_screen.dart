import 'package:flutter/material.dart';
import 'insect_image_piker.dart';
import 'insect_image_api_call.dart';

class ImageAnalysisScreen extends StatefulWidget {
  @override
  _ImageAnalysisScreenState createState() => _ImageAnalysisScreenState();
}

class _ImageAnalysisScreenState extends State<ImageAnalysisScreen> {
  ImageData? _selectedImage;
  String _analysisResult = '';
  bool _isAnalyzing = false;
  String _currentStatus = 'Select an insect image to analyze';

  // Parsed data from analysis
  bool _hasInsects = false;
  bool _isHarmful = false;
  String _insectName = '';
  String _scientificName = '';
  List<String> _firstAidPoints = [];
  List<String> _interestingFacts = [];
  String _riskLevel = '';
  String _ecologicalRole = '';

  Future<void> _pickImage() async {
    try {
      setState(() {
        _currentStatus = 'Selecting image...';
        _resetParsedData();
      });

      final imageData = await ImageUtils.pickImage();

      if (imageData != null) {
        setState(() {
          _selectedImage = imageData;
          _analysisResult = '';
          _currentStatus = 'Image selected. Ready to analyze.';
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  void _resetParsedData() {
    _hasInsects = false;
    _isHarmful = false;
    _insectName = '';
    _scientificName = '';
    _firstAidPoints = [];
    _interestingFacts = [];
    _riskLevel = '';
    _ecologicalRole = '';
  }

  void _parseAnalysisResult(String result) {
    _resetParsedData();

    // Check if no insects found
    if (result.contains('The image does not contain any visible insects')) {
      _hasInsects = false;
      return;
    }

    _hasInsects = true;

    // Check if harmful insect
    if (result.contains('🚨 HARMFUL INSECT') || result.contains('HARMFUL INSECT DETECTED')) {
      _isHarmful = true;

      // Extract insect name
      final nameMatch = RegExp(r'Identification:\s*([^\n]+)').firstMatch(result);
      if (nameMatch != null) _insectName = nameMatch.group(1)!.trim();

      // Extract scientific name
      final sciMatch = RegExp(r'Scientific Name:\s*([^\n]+)').firstMatch(result);
      if (sciMatch != null) _scientificName = sciMatch.group(1)!.trim();

      // Extract risk level
      final riskMatch = RegExp(r'Risk Level:\s*([^\n]+)').firstMatch(result);
      if (riskMatch != null) _riskLevel = riskMatch.group(1)!.trim();

      // Extract first aid points
      final firstAidMatches = RegExp(r'\d+\.\s*([^\n]+)').allMatches(result);
      _firstAidPoints = firstAidMatches
          .map((match) => match.group(1)!.trim())
          .where((point) => point.length > 10) // Filter out short points
          .toList();

    } else {
      _isHarmful = false;

      // Extract insect name for harmless insects
      final nameMatch = RegExp(r'Identification:\s*([^\n]+)').firstMatch(result);
      if (nameMatch != null) _insectName = nameMatch.group(1)!.trim();

      // Extract scientific name
      final sciMatch = RegExp(r'Scientific Name:\s*([^\n]+)').firstMatch(result);
      if (sciMatch != null) _scientificName = sciMatch.group(1)!.trim();

      // Extract interesting facts
      final factMatches = RegExp(r'\d+\.\s*([^\n]+)').allMatches(result);
      _interestingFacts = factMatches
          .map((match) => match.group(1)!.trim())
          .where((fact) => fact.length > 10)
          .toList();

      // Extract ecological role
      final ecoMatch = RegExp(r'Ecological (?:Role|Importance):\s*([^\n]+)').firstMatch(result);
      if (ecoMatch != null) _ecologicalRole = ecoMatch.group(1)!.trim();
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = '';
      _currentStatus = 'Analyzing insect image...';
      _resetParsedData();
    });

    try {
      // Pass the Uint8List bytes directly to the API
      final result = await GeminiService.analyzeImage(_selectedImage!.file);

      setState(() {
        _isAnalyzing = false;
        if (result.success) {
          _analysisResult = result.analysis!;
          _parseAnalysisResult(result.analysis!);
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
      _analysisResult = '';
      _currentStatus = 'Select an insect image to analyze';
      _resetParsedData();
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
    if (_selectedImage == null) {
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
        child: Image.memory(
          _selectedImage!.file,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Format: ${_selectedImage!.extension}',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoInsectsCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'No Insects Detected',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'The image does not contain any visible insects or insect bites.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentificationCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, size: 28, color: Colors.green),
                SizedBox(width: 12),
                Text(
                  'Insect Identification',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_insectName.isNotEmpty)
              _buildInfoRow('Common Name', _insectName),
            if (_scientificName.isNotEmpty)
              _buildInfoRow('Scientific Name', _scientificName),
            if (_riskLevel.isNotEmpty)
              _buildInfoRow('Risk Level', _riskLevel, isRisk: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstAidCard() {
    return Card(
      color: Colors.red[50],
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, size: 28, color: Colors.red),
                SizedBox(width: 12),
                Text(
                  'First Aid Measures',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ..._firstAidPoints.map((point) => _buildBulletPoint(point, Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildFactsCard() {
    return Card(
      color: Colors.green[50],
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, size: 28, color: Colors.green),
                SizedBox(width: 12),
                Text(
                  'Interesting Facts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ..._interestingFacts.map((fact) => _buildBulletPoint(fact, Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildEcologicalRoleCard() {
    return Card(
      color: Colors.blue[50],
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco, size: 28, color: Colors.blue),
                SizedBox(width: 12),
                Text(
                  'Ecological Role',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              _ecologicalRole,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskAssessmentCard() {
    return Card(
      color: _isHarmful ? Colors.orange[50] : Colors.teal[50],
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isHarmful ? Icons.warning : Icons.verified_user,
                  size: 28,
                  color: _isHarmful ? Colors.orange : Colors.teal,
                ),
                SizedBox(width: 12),
                Text(
                  _isHarmful ? 'Safety Warning' : 'Safety Status',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _isHarmful ? Colors.orange[800] : Colors.teal[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              _isHarmful
                  ? 'This insect is considered harmful. Exercise caution and follow first aid measures if needed.'
                  : 'This insect is harmless and poses no threat to humans.',
              style: TextStyle(
                fontSize: 16,
                color: _isHarmful ? Colors.orange[700] : Colors.teal[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isRisk = false}) {
    Color riskColor = Colors.green;
    if (isRisk) {
      if (value.toLowerCase().contains('high')) riskColor = Colors.red;
      else if (value.toLowerCase().contains('medium')) riskColor = Colors.orange;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: isRisk ? riskColor : Colors.black,
                fontWeight: isRisk ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullAnalysisCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, size: 28, color: Colors.purple),
                SizedBox(width: 12),
                Text(
                  'Complete Analysis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              _analysisResult,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_analysisResult.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.bug_report, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Select an insect image and click analyze',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasInsects) {
      return _buildNoInsectsCard();
    }

    return Column(
      children: [
        _buildIdentificationCard(),
        SizedBox(height: 16),

        _buildRiskAssessmentCard(),
        SizedBox(height: 16),

        if (_isHarmful && _firstAidPoints.isNotEmpty) ...[
          _buildFirstAidCard(),
          SizedBox(height: 16),
        ],

        if (_interestingFacts.isNotEmpty) ...[
          _buildFactsCard(),
          SizedBox(height: 16),
        ],

        if (_ecologicalRole.isNotEmpty) ...[
          _buildEcologicalRoleCard(),
          SizedBox(height: 16),
        ],

        _buildFullAnalysisCard(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meghashree\'s Insect Identifier',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: Icon(Icons.clear, size: 28),
              onPressed: _clearSelection,
              tooltip: 'Clear Selection',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Status Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _isAnalyzing ? Icons.autorenew :
                        _selectedImage != null ? Icons.check_circle : Icons.info,
                        size: 28,
                        color: _isAnalyzing ? Colors.orange :
                        _selectedImage != null ? Colors.green : Colors.blue,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _currentStatus,
                          style: TextStyle(
                            fontSize: 16,
                            color: _isAnalyzing ? Colors.orange :
                            _selectedImage != null ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.photo_library, size: 24),
                      label: Text(
                        'Select Image',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: Size(0, 55),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  if (_selectedImage != null && !_isAnalyzing)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _analyzeImage,
                        icon: Icon(Icons.upload, size: 24),
                        label: Text(
                          'Analyze',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: Size(0, 55),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 24),

              // Image Preview
              _buildImagePreview(),

              if (_isAnalyzing) ...[
                SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text(
                          'Analyzing Image...',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'This may take a few seconds',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: 24),

              // Results Section
              _buildResultsSection(),
            ],
          ),
        ),
      ),
    );
  }
}