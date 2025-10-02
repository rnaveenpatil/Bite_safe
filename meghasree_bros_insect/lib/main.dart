import 'package:flutter/material.dart';
import 'package:meghasree_bros_insect/insect_card.dart';
import 'package:meghasree_bros_insect/insect_api_call.dart';
import 'package:meghasree_bros_insect/insectinfo.dart';
import 'package:meghasree_bros_insect/insect_data.dart';
import 'package:meghasree_bros_insect/insect_detail.dart';
import 'package:meghasree_bros_insect/image_analysis_screen.dart';

void main() {
  runApp(const Meghashree_Bros_Insects());
}

class Meghashree_Bros_Insects extends StatelessWidget {
  const Meghashree_Bros_Insects({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meghashree Bros Insects',
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
    return Scaffold(
      backgroundColor: Color(0xFFF8FDF8),
      body: _isLoading 
          ? _buildLoadingState()
          : _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return CustomScrollView(
      slivers: [
        // Header Section
        SliverAppBar(
          expandedHeight: 200,
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
                      Icon(Icons.eco, size: 40, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              "meghashrees insect",
              style: TextStyle(
                color: Colors.white,
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
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(20),
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
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.green),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),
                
                // Category Filter
                Text(
                  'Filter by Category:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableCategories.map((category) {
                    bool isSelected = _selectedCategory == category;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = isSelected ? 'All' : category;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

        // Statistics Section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildStatCard('Total Insects', _insects.length.toString(), Icons.bug_report),
                SizedBox(width: 20),
                IconButton(
          icon: const Icon(Icons.arrow_forward, size: 40, color: Colors.blue),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  ImageAnalysisScreen()),
            );},),
              
                SizedBox(width: 10),
                _buildStatCard('Categories', _availableCategories.length.toString(), Icons.category),
              ],
            ),
          ),
        ),

        // Grid Title
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Text(
                  'Insect Collection',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                Spacer(),
                Text(
                  '${_filteredInsects.length} items',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Insects Grid
        _filteredInsects.isEmpty
            ? SliverToBoxAdapter(child: _buildEmptyState())
            : SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(context),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
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

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
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
            Icon(icon, size: 24, color: Colors.green),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
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

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Color(0xFFF0F8F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off,
                  size: 60,
                  color: Colors.green[300],
                ),
              ),
              SizedBox(height: 20),
              Text(
                _searchQuery.isEmpty 
                    ? 'No insects found in this category'
                    : 'No results for "$_searchQuery"',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Try changing your search or filter settings',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedCategory = 'All';
                  });
                },
                icon: Icon(Icons.refresh, color: Colors.white),
                label: Text('Show All Insects', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
    if (width > 1000) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
}