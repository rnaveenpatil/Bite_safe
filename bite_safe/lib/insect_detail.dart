import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'insectinfo.dart';

class InsectDetailPage extends StatelessWidget {
  final InsectInfo insect;

  const InsectDetailPage({super.key, required this.insect});

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  void _showLinkErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cannot Open Link'),
        content: const Text('The link cannot be opened. Please check your internet connection or try again later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 800;
    final bool isVeryLargeScreen = screenWidth > 1200;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: isLargeScreen ? 400.0 : 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageSection(isLargeScreen),
              title: Text(
                insect.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isLargeScreen ? 24.0 : 20.0,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
            ),
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(isLargeScreen ? 10.0 : 8.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: isLargeScreen ? 28.0 : 24.0,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(isLargeScreen ? 10.0 : 8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.share,
                    color: Colors.white,
                    size: isLargeScreen ? 28.0 : 24.0,
                  ),
                ),
                onPressed: () {
                  _shareInsect(context);
                },
              ),
            ],
          ),

          // Content Section
          SliverToBoxAdapter(
            child: Container(
              constraints: isVeryLargeScreen
                  ? BoxConstraints(maxWidth: 1200)
                  : null,
              margin: isVeryLargeScreen
                  ? EdgeInsets.symmetric(horizontal: (screenWidth - 1200) / 2)
                  : null,
              child: Padding(
                padding: EdgeInsets.all(isLargeScreen ? 30.0 : 20.0),
                child: isLargeScreen
                    ? _buildDesktopLayout(context, isLargeScreen, isVeryLargeScreen)
                    : _buildMobileLayout(context, isLargeScreen),
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button for external link (only show if link exists)
      floatingActionButton: insect.moreInfoLink.isNotEmpty
          ? Container(
        margin: isLargeScreen
            ? EdgeInsets.only(right: 50, bottom: 30)
            : EdgeInsets.only(right: 20, bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: () async {
            try {
              await _launchURL(insect.moreInfoLink);
            } catch (e) {
              _showLinkErrorDialog(context);
            }
          },
          backgroundColor: Colors.green[600],
          icon: Icon(
            Icons.public,
            color: Colors.white,
            size: isLargeScreen ? 28.0 : 24.0,
          ),
          label: Text(
            'Learn More',
            style: TextStyle(
              color: Colors.white,
              fontSize: isLargeScreen ? 18.0 : 14.0,
            ),
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isLargeScreen, bool isVeryLargeScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column - Main Content
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category and Status
              _buildCategoryRow(isLargeScreen),
              SizedBox(height: isLargeScreen ? 25.0 : 20.0),

              // Description
              _buildSectionTitle('Description', isLargeScreen),
              SizedBox(height: isLargeScreen ? 12.0 : 8.0),
              _buildDescription(isLargeScreen),
              SizedBox(height: isLargeScreen ? 30.0 : 25.0),

              // Quick Info Grid
              _buildQuickInfoGrid(isLargeScreen),
              SizedBox(height: isLargeScreen ? 30.0 : 25.0),

              // Habitat
              _buildInfoSection('🏠 Habitat', insect.habitat, Icons.home, isLargeScreen),

              // Diet
              _buildInfoSection('🍽️ Diet', insect.diet, Icons.restaurant, isLargeScreen),

              // Lifespan
              _buildInfoSection('⏳ Lifespan', insect.lifespan, Icons.access_time, isLargeScreen),
            ],
          ),
        ),

        SizedBox(width: isLargeScreen ? 30.0 : 20.0),

        // Right Column - Facts and Additional Info
        Expanded(
          flex: 1,
          child: Column(
            children: [
              // Interesting Facts
              _buildFactsSection(isLargeScreen),

              SizedBox(height: isLargeScreen ? 25.0 : 20.0),

              // Learn More Section (only show if link exists)
              if (insect.moreInfoLink.isNotEmpty)
                _buildLearnMoreSection(context, isLargeScreen),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category and Status
        _buildCategoryRow(isLargeScreen),
        SizedBox(height: isLargeScreen ? 25.0 : 20.0),

        // Description
        _buildSectionTitle('Description', isLargeScreen),
        SizedBox(height: isLargeScreen ? 12.0 : 8.0),
        _buildDescription(isLargeScreen),
        SizedBox(height: isLargeScreen ? 30.0 : 25.0),

        // Quick Info Grid
        _buildQuickInfoGrid(isLargeScreen),
        SizedBox(height: isLargeScreen ? 30.0 : 25.0),

        // Habitat
        _buildInfoSection('🏠 Habitat', insect.habitat, Icons.home, isLargeScreen),

        // Diet
        _buildInfoSection('🍽️ Diet', insect.diet, Icons.restaurant, isLargeScreen),

        // Lifespan
        _buildInfoSection('⏳ Lifespan', insect.lifespan, Icons.access_time, isLargeScreen),

        // Interesting Facts
        _buildFactsSection(isLargeScreen),

        // Learn More Section (only show if link exists)
        if (insect.moreInfoLink.isNotEmpty) ...[
          SizedBox(height: isLargeScreen ? 30.0 : 25.0),
          _buildLearnMoreSection(context, isLargeScreen),
        ],

        SizedBox(height: isLargeScreen ? 40.0 : 30.0),
      ],
    );
  }

  void _shareInsect(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${insect.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildImageSection(bool isLargeScreen) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            insect.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderImage(isLargeScreen);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            },
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage(bool isLargeScreen) {
    return Container(
      color: Colors.green[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                Icons.bug_report,
                size: isLargeScreen ? 120.0 : 80.0,
                color: Colors.green[300]
            ),
            SizedBox(height: isLargeScreen ? 15.0 : 10.0),
            Text(
                insect.emoji,
                style: TextStyle(fontSize: isLargeScreen ? 60.0 : 40.0)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(bool isLargeScreen) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 16.0 : 12.0,
              vertical: isLargeScreen ? 10.0 : 6.0
          ),
          decoration: BoxDecoration(
            color: _getCategoryColor(),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            insect.category,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isLargeScreen ? 16.0 : 14.0,
            ),
          ),
        ),
        SizedBox(width: isLargeScreen ? 15.0 : 10.0),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 16.0 : 12.0,
              vertical: isLargeScreen ? 10.0 : 6.0
          ),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            insect.sizeCategory,
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.w600,
              fontSize: isLargeScreen ? 16.0 : 14.0,
            ),
          ),
        ),
        const Spacer(),
        Text(
          insect.emoji,
          style: TextStyle(fontSize: isLargeScreen ? 32.0 : 24.0),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isLargeScreen) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isLargeScreen ? 26.0 : 22.0,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDescription(bool isLargeScreen) {
    return Text(
      insect.description,
      style: TextStyle(
        fontSize: isLargeScreen ? 18.0 : 16.0,
        color: Colors.black54,
        height: 1.6,
      ),
    );
  }

  Widget _buildQuickInfoGrid(bool isLargeScreen) {
    final crossAxisCount = isLargeScreen ? 4 : 2;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: isLargeScreen ? 20.0 : 15.0,
      mainAxisSpacing: isLargeScreen ? 20.0 : 15.0,
      childAspectRatio: isLargeScreen ? 2.5 : 3,
      children: [
        _buildQuickInfoItem('Conservation', insect.conservationStatus, Icons.health_and_safety, isLargeScreen),
        _buildQuickInfoItem('Size', insect.sizeCategory, Icons.straighten, isLargeScreen),
        _buildQuickInfoItem('Facts', '${insect.facts.length}', Icons.lightbulb, isLargeScreen),
        _buildQuickInfoItem('Beneficial', insect.isBeneficial ? 'Yes' : 'No', Icons.thumb_up, isLargeScreen),
      ],
    );
  }

  Widget _buildQuickInfoItem(String title, String value, IconData icon, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 16.0 : 1.0),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Row(
        children: [
          Icon(
              icon,
              size: isLargeScreen ? 24.0 : 20.0,
              color: Colors.green[600]
          ),
          SizedBox(width: isLargeScreen ? 12.0 : 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isLargeScreen ? 14.0 : 12.0,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: isLargeScreen ? 16.0 : 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon, bool isLargeScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isLargeScreen ? 25.0 : 20.0),
      padding: EdgeInsets.all(isLargeScreen ? 20.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
              icon,
              size: isLargeScreen ? 30.0 : 24.0,
              color: Colors.green[600]
          ),
          SizedBox(width: isLargeScreen ? 16.0 : 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 20.0 : 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: isLargeScreen ? 10.0 : 8.0),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 16.0 : 15.0,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactsSection(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 25.0 : 20.0),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.orange[700],
                size: isLargeScreen ? 28.0 : 24.0,
              ),
              SizedBox(width: isLargeScreen ? 12.0 : 8.0),
              Text(
                'Interesting Facts',
                style: TextStyle(
                  fontSize: isLargeScreen ? 22.0 : 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 18.0 : 15.0),
          ...insect.facts.asMap().entries.map((entry) {
            int index = entry.key;
            String fact = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: isLargeScreen ? 15.0 : 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: isLargeScreen ? 32.0 : 28.0,
                    height: isLargeScreen ? 32.0 : 28.0,
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                          fontSize: isLargeScreen ? 14.0 : 12.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isLargeScreen ? 15.0 : 12.0),
                  Expanded(
                    child: Text(
                      fact,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 16.0 : 15.0,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLearnMoreSection(BuildContext context, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 25.0 : 20.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Want to Learn More?',
            style: TextStyle(
              fontSize: isLargeScreen ? 20.0 : 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isLargeScreen ? 10.0 : 8.0),
          Text(
            'Explore additional resources and detailed information about this insect:',
            style: TextStyle(
              fontSize: isLargeScreen ? 16.0 : 14.0,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: isLargeScreen ? 15.0 : 12.0),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await _launchURL(insect.moreInfoLink);
              } catch (e) {
                _showLinkErrorDialog(context);
              }
            },
            icon: Icon(
              Icons.public,
              size: isLargeScreen ? 24.0 : 20.0,
            ),
            label: Text(
              'Visit Resource Page',
              style: TextStyle(
                fontSize: isLargeScreen ? 16.0 : 14.0,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 25.0 : 20.0,
                vertical: isLargeScreen ? 15.0 : 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (insect.category.toLowerCase()) {
      case 'pollinator':
        return Colors.orange[600]!;
      case 'predator':
        return Colors.red[600]!;
      case 'herbivore':
        return Colors.green[600]!;
      case 'omnivore':
        return Colors.blue[600]!;
      default:
        return Colors.purple[600]!;
    }
  }
}