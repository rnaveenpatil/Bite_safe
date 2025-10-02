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
      // You can show a snackbar or dialog here to inform the user
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageSection(),
              title: Text(
                insect.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
                onPressed: () {
                  _shareInsect(context);
                },
              ),
            ],
          ),

          // Content Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Status
                  _buildCategoryRow(),
                  const SizedBox(height: 20),

                  // Description
                  _buildSectionTitle('Description'),
                  const SizedBox(height: 8),
                  _buildDescription(),
                  const SizedBox(height: 30),

                  // Quick Info Grid
                  _buildQuickInfoGrid(),
                  const SizedBox(height: 30),

                  // Habitat
                  _buildInfoSection('🏠 Habitat', insect.habitat, Icons.home),
                  
                  // Diet
                  _buildInfoSection('🍽️ Diet', insect.diet, Icons.restaurant),
                  
                  // Lifespan
                  _buildInfoSection('⏳ Lifespan', insect.lifespan, Icons.access_time),

                  // Interesting Facts
                  _buildFactsSection(),

                  // Learn More Section (only show if link exists)
                  if (insect.moreInfoLink.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    _buildLearnMoreSection(context),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Floating Action Button for external link (only show if link exists)
      floatingActionButton: insect.moreInfoLink.isNotEmpty 
          ? FloatingActionButton.extended(
              onPressed: () async {
                try {
                  await _launchURL(insect.moreInfoLink);
                } catch (e) {
                  _showLinkErrorDialog(context);
                }
              },
              backgroundColor: Colors.green[600],
              icon: const Icon(Icons.public, color: Colors.white),
              label: const Text('Learn More', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  void _shareInsect(BuildContext context) {
    // Simple share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${insect.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            insect.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderImage();
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

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.green[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bug_report, size: 80, color: Colors.green[300]),
            const SizedBox(height: 10),
            Text(insect.emoji, style: const TextStyle(fontSize: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getCategoryColor(),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            insect.category,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            insect.sizeCategory,
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        Text(
          insect.emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      insect.description,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black54,
        height: 1.6,
      ),
    );
  }

  Widget _buildQuickInfoGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 3,
      children: [
        _buildQuickInfoItem('Conservation', insect.conservationStatus, Icons.health_and_safety),
        _buildQuickInfoItem('Size', insect.sizeCategory, Icons.straighten),
        _buildQuickInfoItem('Facts', '${insect.facts.length}', Icons.lightbulb),
        _buildQuickInfoItem('Beneficial', insect.isBeneficial ? 'Yes' : 'No', Icons.thumb_up),
      ],
    );
  }

  Widget _buildQuickInfoItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green[600]),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
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

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.green[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
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

  Widget _buildFactsSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange[700]),
              const SizedBox(width: 8),
              const Text(
                'Interesting Facts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...insect.facts.asMap().entries.map((entry) {
            int index = entry.key;
            String fact = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
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
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fact,
                      style: const TextStyle(
                        fontSize: 15,
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

  Widget _buildLearnMoreSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Want to Learn More?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore additional resources and detailed information about this insect:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await _launchURL(insect.moreInfoLink);
              } catch (e) {
                _showLinkErrorDialog(context);
              }
            },
            icon: const Icon(Icons.public),
            label: const Text('Visit Resource Page'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
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