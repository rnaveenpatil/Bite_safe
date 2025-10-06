import 'package:flutter/material.dart';
import 'search_insect_api_call.dart';

class InsectSearchScreen extends StatefulWidget {
  @override
  _InsectSearchScreenState createState() => _InsectSearchScreenState();
}

class _InsectSearchScreenState extends State<InsectSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GeminiApiService _apiService = GeminiApiService(
    apiKey: "AIzaSyBqrJ7GWVhkB9wl90vD5sSrlxKHmH_KSe8",
  );

  String _searchResult = '';
  bool _isLoading = false;

  // Parsed data from API response
  Map<String, String> _parsedData = {};
  List<String> _interestingFacts = [];
  List<String> _firstAidSteps = [];
  List<String> _identificationTips = [];

  void _parseResponse(String response) {
    _parsedData.clear();
    _interestingFacts.clear();
    _firstAidSteps.clear();
    _identificationTips.clear();

    final lines = response.split('\n');
    String currentSection = '';

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Detect sections
      if (line.contains('🖼️') || line.toLowerCase().contains('visual')) {
        currentSection = 'visual';
      } else if (line.contains('🎯') || line.toLowerCase().contains('identification')) {
        currentSection = 'identification';
      } else if (line.contains('📊') || line.toLowerCase().contains('physical')) {
        currentSection = 'physical';
      } else if (line.contains('🌍') || line.toLowerCase().contains('habitat')) {
        currentSection = 'habitat';
      } else if (line.contains('⚠️') || line.toLowerCase().contains('safety')) {
        currentSection = 'safety';
      } else if (line.contains('🏥') || line.toLowerCase().contains('first aid')) {
        currentSection = 'first_aid';
      } else if (line.contains('💡') || line.toLowerCase().contains('interesting facts')) {
        currentSection = 'facts';
      } else if (line.contains('🔍') || line.toLowerCase().contains('identification tips')) {
        currentSection = 'tips';
      }

      // Parse key-value pairs
      if (line.contains(':') && !line.startsWith('🖼️') && !line.startsWith('🎯') &&
          !line.startsWith('📊') && !line.startsWith('🌍') && !line.startsWith('⚠️') &&
          !line.startsWith('🏥') && !line.startsWith('💡') && !line.startsWith('🔍')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts[1].trim();
          if (value.isNotEmpty) {
            _parsedData[key] = value;
          }
        }
      }

      // Parse numbered lists
      if (RegExp(r'^\d+\.').hasMatch(line)) {
        final content = line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
        if (content.isNotEmpty) {
          if (currentSection == 'facts') {
            _interestingFacts.add(content);
          } else if (currentSection == 'first_aid') {
            _firstAidSteps.add(content);
          } else if (currentSection == 'tips') {
            _identificationTips.add(content);
          }
        }
      }
    }
  }

  Future<void> _searchInsect() async {
    if (_searchController.text.isEmpty) {
      _showSnackBar('Please enter an insect name', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
      _searchResult = '';
      _parsedData.clear();
      _interestingFacts.clear();
      _firstAidSteps.clear();
      _identificationTips.clear();
    });

    try {
      final response = await _apiService.analyzeInsectQuery(_searchController.text);

      setState(() {
        _isLoading = false;
        if (response.success) {
          _searchResult = response.analysis!;
          if (_searchResult.toLowerCase().contains('not an insect')) {
            _showSnackBar('This is not an insect', Colors.red);
          } else {
            _parseResponse(response.analysis!);
            _showSnackBar('Insect information loaded!', Colors.green);
          }
        } else {
          _searchResult = response.error!;
          _showSnackBar('Error: ${response.error}', Colors.red);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResult = 'Failed to search: $e';
      });
      _showSnackBar('Search failed', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bug_report, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text(
                  'search any insect ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'search any insect ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: ' Search for insects ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onSubmitted: (_) => _searchInsect(),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _searchInsect,
              icon: Icon(Icons.search, size: 20),
              label: Text(
                'Identify Insect',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualReferenceCard() {
    // Get visual data
    final primaryColors = _parsedData['Primary Colors'] ?? 'Not specified';
    final bodyShape = _parsedData['Body Shape'] ?? 'Not specified';
    final size = _parsedData['Size Description'] ?? _parsedData['Size Range'] ?? 'Not specified';
    final markings = _parsedData['Distinctive Markings'] ?? 'Not specified';
    final wings = _parsedData['Wing Features'] ?? 'Not specified';
    final antennae = _parsedData['Antennae Type'] ?? 'Not specified';

    // Determine insect type for appropriate icon
    String insectType = _getInsectType(primaryColors, bodyShape, wings);

    return Card(
      margin: EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_library, color: Colors.purple, size: 24),
                SizedBox(width: 12),
                Text(
                  'Visual Reference',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800]
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Visual Representation Container
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple[50]!, Colors.purple[100]!],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dynamic icon based on insect type
                  _buildInsectIcon(insectType),
                  SizedBox(height: 12),
                  Text(
                    _parsedData['Common Name'] ?? 'Insect',
                    style: TextStyle(
                      color: Colors.purple[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (primaryColors != 'Not specified')
                    Text(
                      'Colors: $primaryColors',
                      style: TextStyle(
                        color: Colors.purple[600],
                        fontSize: 14,
                      ),
                    ),
                  if (size != 'Not specified')
                    Text(
                      'Size: $size',
                      style: TextStyle(
                        color: Colors.purple[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Visual Details
            _buildVisualDetailItem('Body Shape', bodyShape, Icons.shape_line),
            _buildVisualDetailItem('Distinctive Markings', markings, Icons.brush),
            _buildVisualDetailItem('Wing Features', wings, Icons.flight),
            _buildVisualDetailItem('Antennae Type', antennae, Icons.ads_click),

            if (_identificationTips.isNotEmpty) ...[
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),
              Text(
                '🔍 Identification Tips',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[700],
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              ..._identificationTips.map((tip) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_right, size: 16, color: Colors.purple),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsectIcon(String insectType) {
    switch (insectType) {
      case 'butterfly':
        return Icon(Icons.wind_power, size: 60, color: Colors.purple[400]);
      case 'bee':
        return Icon(Icons.hive_outlined, size: 60, color: Colors.orange[400]);
      case 'ant':
        return Icon(Icons.cable, size: 60, color: Colors.black);
      case 'spider':
        return Icon(Icons.grain, size: 60, color: Colors.brown[400]);
      case 'ladybug':
        return Icon(Icons.circle, size: 60, color: Colors.red[400]);
      case 'mosquito':
        return Icon(Icons.flight_takeoff, size: 60, color: Colors.grey[600]);
      default:
        return Icon(Icons.bug_report, size: 60, color: Colors.purple[400]);
    }
  }

  String _getInsectType(String colors, String shape, String wings) {
    final query = _searchController.text.toLowerCase();
    if (query.contains('butterfly') || query.contains('moth')) return 'butterfly';
    if (query.contains('bee') || query.contains('wasp')) return 'bee';
    if (query.contains('ant')) return 'ant';
    if (query.contains('spider')) return 'spider';
    if (query.contains('ladybug') || query.contains('ladybird')) return 'ladybug';
    if (query.contains('mosquito')) return 'mosquito';
    return 'general';
  }

  Widget _buildVisualDetailItem(String label, String value, IconData icon) {
    if (value == 'Not specified') return SizedBox();

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.purple),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 14
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Keep all your existing card methods (_buildIdentificationCard, _buildHabitatCard, etc.)
  // They remain exactly the same as in your previous code
  Widget _buildIdentificationCard() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fingerprint, color: Colors.blue, size: 24),
                SizedBox(width: 12),
                Text(
                  'Insect Identification',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800]
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildInfoRow('Common Name', _parsedData['Common Name'] ?? 'Loading...'),
            _buildInfoRow('Scientific Name', _parsedData['Scientific Name'] ?? 'Loading...'),
            _buildInfoRow('Family/Order', _parsedData['Family/Order'] ?? 'Loading...'),
            if (_parsedData['Size Range'] != null)
              _buildInfoRow('Size', _parsedData['Size Range']!),
            if (_parsedData['Key Identifying Features'] != null)
              _buildInfoRow('Identifying Features', _parsedData['Key Identifying Features']!),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitatCard() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.nature, color: Colors.green, size: 24),
                SizedBox(width: 12),
                Text(
                  'Habitat & Distribution',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800]
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildInfoRow('Natural Habitat', _parsedData['Natural Habitat'] ?? 'Loading...'),
            _buildInfoRow('Geographical Range', _parsedData['Geographical Range'] ?? 'Loading...'),
            if (_parsedData['Preferred Environments'] != null)
              _buildInfoRow('Preferred Environments', _parsedData['Preferred Environments']!),
            if (_parsedData['Behavior'] != null)
              _buildInfoRow('Behavior', _parsedData['Behavior']!),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyCard() {
    final isHarmful = (_parsedData['Harmful to Humans'] ?? '').toLowerCase().contains('yes');
    final riskLevel = _parsedData['Risk Level'] ?? 'Unknown';

    return Card(
      margin: EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isHarmful ? Colors.red[50] : Colors.green[50],
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                    isHarmful ? Icons.warning : Icons.verified_user,
                    color: isHarmful ? Colors.red : Colors.green,
                    size: 24
                ),
                SizedBox(width: 12),
                Text(
                  'Safety Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isHarmful ? Colors.red[800] : Colors.green[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildInfoRow('Harmful to Humans', _parsedData['Harmful to Humans'] ?? 'Unknown'),
            _buildInfoRow('Risk Level', riskLevel),
            if (_parsedData['Potential Dangers'] != null)
              _buildInfoRow('Potential Dangers', _parsedData['Potential Dangers']!),
            if (_firstAidSteps.isNotEmpty && isHarmful) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.medical_services, color: Colors.red[800]),
                        SizedBox(width: 8),
                        Text(
                          'First Aid Measures',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    ..._firstAidSteps.asMap().entries.map((entry) {
                      int index = entry.key;
                      String step = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.red[200],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[800],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(fontSize: 14, color: Colors.red[900], height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFactsCard() {
    if (_interestingFacts.isEmpty) return SizedBox();

    return Card(
      margin: EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.orange, size: 24),
                SizedBox(width: 12),
                Text(
                  'Interesting Facts',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800]
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Column(
              children: _interestingFacts.asMap().entries.map((entry) {
                int index = entry.key;
                String fact = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[100]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          fact,
                          style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  fontSize: 14
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Card(
      margin: EdgeInsets.all(16),
      color: Colors.orange[50],
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              _searchResult,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.orange[800],
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.orange[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
            children: []
                  .map((insect) => Chip(
                label: Text(insect),
                backgroundColor: Colors.orange[100],
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insect Identifier'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF8FDF8),
      body: Column(
        children: [
          _buildSearchSection(),
          if (_isLoading) ...[
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Analyzing insect...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
          if (_searchResult.isNotEmpty && !_isLoading) ...[
            if (_searchResult.toLowerCase().contains('not an insect'))
              _buildErrorState()
            else
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildVisualReferenceCard(),
                      _buildIdentificationCard(),
                      _buildHabitatCard(),
                      _buildSafetyCard(),
                      _buildFactsCard(),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
          ] else if (!_isLoading) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bug_report, size: 100, color: Colors.grey[300]),
                    SizedBox(height: 20),
                    Text(
                      'Discover Insects',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Search for any insect to learn about its characteristics',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}