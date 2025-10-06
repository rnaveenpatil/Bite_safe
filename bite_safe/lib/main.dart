import 'package:flutter/material.dart';
import 'insect_image_api_call.dart';
import 'image_analysis_screen.dart';
import 'insect_card.dart';
import 'insect_data.dart';
import 'insect_detail.dart';
import 'insect_image_piker.dart';
import 'insectinfo.dart';
import 'insect_search_screen.dart';

void main() {
  runApp(const BiteSafe());
}

class BiteSafe extends StatelessWidget {
  const BiteSafe({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bite Safe",
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Poppins',
      ),
      home: const InsectHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InsectHomePage extends StatefulWidget {
  const InsectHomePage({super.key});

  @override
  State<InsectHomePage> createState() => _InsectHomePageState();
}

class _InsectHomePageState extends State<InsectHomePage> {
  final InsectDataService _dataService = InsectDataService();
  List<InsectInfo> _insects = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadInsects();
  }

  Future<void> _loadInsects() async {
    setState(() {
      _isLoading = true;
    });

    final insects = await _dataService.getAllInsects();
    setState(() {
      _insects = insects;
      _isLoading = false;
    });
  }

  void _navigateToDetailPage(InsectInfo insect) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsectDetailPage(insect: insect),
      ),
    );
  }

  List<InsectInfo> get _filteredInsects {
    if (_searchQuery.isEmpty && _selectedCategory == 'All') {
      return _insects;
    }

    return _insects.where((insect) {
      final matchesSearch = _searchQuery.isEmpty ||
          insect.name.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' ||
          insect.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> get _availableCategories {
    final categories = _insects.map((e) => e.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 800;
    final bool isVeryLargeScreen = screenWidth > 1200;

    return Scaffold(
      backgroundColor: Color(0xFFF8FDF8),
      body: _isLoading
          ? _buildLoadingState()
          : _buildMainContent(isLargeScreen, isVeryLargeScreen, screenWidth),
    );
  }

  Widget _buildMainContent(bool isLargeScreen, bool isVeryLargeScreen, double screenWidth) {
    return CustomScrollView(
      slivers: [
        // Header Section
        SliverAppBar(
          expandedHeight: isLargeScreen ? 250.0 : 200.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                          Icons.eco,
                          size: isLargeScreen ? 90.0 : 70.0,
                          color: Colors.white
                      ),
                      SizedBox(width: isLargeScreen ? 15.0 : 10.0),
                      Text(
                        "",
                        style: TextStyle(
                          fontSize: isLargeScreen ? 28.0 : 24.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLargeScreen ? 15.0 : 10.0),
                  Text(
                    "",
                    style: TextStyle(
                      fontSize: isLargeScreen ? 38.0 : 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 12.0 : 8.0),
                  Text(
                    "",
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18.0 : 16.0,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              "Bite Safe",
              style: TextStyle(
                color: Colors.white,
                fontSize: isLargeScreen ? 24.0 : 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          backgroundColor: Colors.green,
        ),

        // Search and Filter Section
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.all(isLargeScreen ? 25.0 : 20.0),
            padding: EdgeInsets.all(isLargeScreen ? 25.0 : 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(50),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xFFF0F8F0),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '🔍 Search insects by name...',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isLargeScreen ? 18.0 : 16.0,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.green),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: isLargeScreen ? 20.0 : 15.0
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: isLargeScreen ? 20.0 : 16.0),

                // Category Filter
                Text(
                  'Filter by Category:',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 18.0 : 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: isLargeScreen ? 15.0 : 10.0),
                Wrap(
                  spacing: isLargeScreen ? 12.0 : 8.0,
                  runSpacing: isLargeScreen ? 12.0 : 8.0,
                  children: _availableCategories.map((category) {
                    bool isSelected = _selectedCategory == category;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = isSelected ? 'All' : category;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 20.0 : 16.0,
                            vertical: isLargeScreen ? 12.0 : 8.0
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Color(0xFFF0F8F0),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.green[300]!,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.green[800],
                            fontWeight: FontWeight.w600,
                            fontSize: isLargeScreen ? 16.0 : 14.0,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),

        // Detect Insect Buttons Section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 25.0 : 20.0,
                vertical: isLargeScreen ? 15.0 : 10.0
            ),
            child: isLargeScreen
                ? _buildDesktopButtons(isLargeScreen, screenWidth)
                : _buildMobileButtons(isLargeScreen),
          ),
        ),

        // Grid Title
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 25.0 : 20.0,
                vertical: isLargeScreen ? 15.0 : 10.0
            ),
            child: Row(
              children: [
                Text(
                  'Insect Collection',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 24.0 : 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                Spacer(),
                Text(
                  '${_filteredInsects.length} items',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isLargeScreen ? 16.0 : 14.0,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Insects Grid
        _filteredInsects.isEmpty
            ? SliverToBoxAdapter(child: _buildEmptyState(isLargeScreen))
            : SliverPadding(
          padding: EdgeInsets.all(isLargeScreen ? 20.0 : 16.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(context),
              crossAxisSpacing: isLargeScreen ? 20.0 : 16.0,
              mainAxisSpacing: isLargeScreen ? 20.0 : 16.0,
              childAspectRatio: _getChildAspectRatio(context),
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final insect = _filteredInsects[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(30),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InsectCard(
                    insect: insect,
                    isExpanded: false,
                    onTap: () => _navigateToDetailPage(insect),
                  ),
                );
              },
              childCount: _filteredInsects.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopButtons(bool isLargeScreen, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // First Button
        Container(
          width: screenWidth * 0.3,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageAnalysisScreen()),
              );
            },
            icon: Icon(
              Icons.image,
              size: isLargeScreen ? 24.0 : 20.0,
              color: Colors.white,
            ),
            label: Text(
              "upload image of insect ",
              style: TextStyle(
                fontSize: isLargeScreen ? 16.0 : 14.0,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 20.0 : 15.0,
                vertical: isLargeScreen ? 15.0 : 12.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Second Button
        Container(
          width: screenWidth * 0.3,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InsectSearchScreen()),
              );
            },
            icon: Icon(
              Icons.search,
              size: isLargeScreen ? 24.0 : 20.0,
              color: Colors.white,
            ),
            label: Text(
              "search any insect ",
              style: TextStyle(
                fontSize: isLargeScreen ? 16.0 : 14.0,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 20.0 : 15.0,
                vertical: isLargeScreen ? 15.0 : 12.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileButtons(bool isLargeScreen) {
    return Column(
      children: [
        // First Button
        Container(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InsectSearchScreen()),
              );
            },
            icon: Icon(
              Icons.search,
              size: 20.0,
              color: Colors.white,
            ),
            label: Text(
              "search any insect  ",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        SizedBox(height: 12),

        // Second Button
        Container(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageAnalysisScreen()),
              );
            },
            icon: Icon(
              Icons.photo_library,
              size: 20.0,
              color: Colors.white,
            ),
            label: Text(
              "upload image of the insect",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, bool isLargeScreen) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isLargeScreen ? 20.0 : 15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(30),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
                icon,
                size: isLargeScreen ? 30.0 : 24.0,
                color: Colors.green
            ),
            SizedBox(height: isLargeScreen ? 12.0 : 8.0),
            Text(
              value,
              style: TextStyle(
                fontSize: isLargeScreen ? 22.0 : 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: isLargeScreen ? 14.0 : 12.0,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(50),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Loading Amazing Insects...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Discovering nature\'s tiny wonders',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isLargeScreen) {
    return Container(
      height: isLargeScreen ? 350.0 : 300.0,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(isLargeScreen ? 30.0 : 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isLargeScreen ? 40.0 : 30.0),
                decoration: BoxDecoration(
                  color: Color(0xFFF0F8F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off,
                  size: isLargeScreen ? 80.0 : 60.0,
                  color: Colors.green[300],
                ),
              ),
              SizedBox(height: isLargeScreen ? 25.0 : 20.0),
              Text(
                _searchQuery.isEmpty
                    ? 'No insects found in this category'
                    : 'No results for "$_searchQuery"',
                style: TextStyle(
                  fontSize: isLargeScreen ? 22.0 : 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isLargeScreen ? 15.0 : 10.0),
              Text(
                'Try changing your search or filter settings',
                style: TextStyle(
                  fontSize: isLargeScreen ? 16.0 : 14.0,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isLargeScreen ? 25.0 : 20.0),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedCategory = 'All';
                  });
                },
                icon: Icon(Icons.refresh, color: Colors.white),
                label: Text(
                    'Show All Insects',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isLargeScreen ? 16.0 : 14.0,
                    )
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 25.0 : 20.0,
                      vertical: isLargeScreen ? 15.0 : 12.0
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 5;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 0.75;
    if (width > 800) return 0.8;
    return 0.85;
  }
}