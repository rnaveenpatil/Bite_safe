class InsectInfo {
  final String name;
  final String image;
  final String description;
  final String habitat;
  final String diet;
  final String lifespan;
  final List<String> facts;
  final String moreInfoLink; // New field for external links

  InsectInfo({
    required this.name,
    required this.image,
    required this.description,
    required this.habitat,
    required this.diet,
    required this.lifespan,
    required this.facts,
    this.moreInfoLink = '', // Default empty string
  });

  // Convert InsectInfo to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'description': description,
      'habitat': habitat,
      'diet': diet,
      'lifespan': lifespan,
      'facts': facts,
      'moreInfoLink': moreInfoLink,
    };
  }

  // Create InsectInfo from JSON
  factory InsectInfo.fromJson(Map<String, dynamic> json) {
    return InsectInfo(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      habitat: json['habitat'] ?? '',
      diet: json['diet'] ?? '',
      lifespan: json['lifespan'] ?? '',
      facts: List<String>.from(json['facts'] ?? []),
      moreInfoLink: json['moreInfoLink'] ?? '',
    );
  }

  // Create a copy of InsectInfo with updated values
  InsectInfo copyWith({
    String? name,
    String? image,
    String? description,
    String? habitat,
    String? diet,
    String? lifespan,
    List<String>? facts,
    String? moreInfoLink,
  }) {
    return InsectInfo(
      name: name ?? this.name,
      image: image ?? this.image,
      description: description ?? this.description,
      habitat: habitat ?? this.habitat,
      diet: diet ?? this.diet,
      lifespan: lifespan ?? this.lifespan,
      facts: facts ?? this.facts,
      moreInfoLink: moreInfoLink ?? this.moreInfoLink,
    );
  }

  // String representation
  @override
  String toString() {
    return 'InsectInfo{name: $name, category: $category, facts: ${facts.length} items}';
  }

  // Equality operator
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsectInfo &&
          runtimeType == other.runtimeType &&
          name == other.name;

  // Hash code
  @override
  int get hashCode => name.hashCode;

  // Check if image URL is valid
  bool get hasValidImage => image.isNotEmpty && Uri.tryParse(image) != null;

  // Get short description
  String get shortDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 97)}...';
  }

  // Check if insect is beneficial
  bool get isBeneficial {
    final beneficialKeywords = ['pollination', 'beneficial', 'predator', 'pest control'];
    final text = '${description.toLowerCase()} ${diet.toLowerCase()}';
    return beneficialKeywords.any((keyword) => text.contains(keyword));
  }

  // Get insect category based on diet
  String get category {
    final dietLower = diet.toLowerCase();
    if (dietLower.contains('nectar') || dietLower.contains('pollen')) {
      return 'Pollinator';
    } else if (dietLower.contains('insects') || dietLower.contains('pest') || 
               dietLower.contains('spiders') || dietLower.contains('hunt')) {
      return 'Predator';
    } else if (dietLower.contains('plants') || dietLower.contains('leaves') || 
               dietLower.contains('herbivorous')) {
      return 'Herbivore';
    } else if (dietLower.contains('omnivorous') || dietLower.contains('organic matter')) {
      return 'Omnivore';
    } else {
      return 'Other';
    }
  }

  // Get insect size category
  String get sizeCategory {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('butterfly') || nameLower.contains('dragonfly')) {
      return 'Medium';
    } else if (nameLower.contains('bee') || nameLower.contains('ladybug')) {
      return 'Small';
    } else if (nameLower.contains('mantis') || nameLower.contains('cricket')) {
      return 'Small to Medium';
    } else {
      return 'Varies';
    }
  }

  // Get conservation status
  String get conservationStatus {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('monarch')) {
      return 'Near Threatened';
    } else if (nameLower.contains('honeybee')) {
      return 'Vulnerable';
    } else {
      return 'Stable';
    }
  }

  // Get fun emoji based on insect type
  String get emoji {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('butterfly')) return '🦋';
    if (nameLower.contains('bee')) return '🐝';
    if (nameLower.contains('ladybug')) return '🐞';
    if (nameLower.contains('dragonfly')) return '🐉';
    if (nameLower.contains('mantis')) return '🙏';
    if (nameLower.contains('cricket')) return '🦗';
    return '🐛';
  }

  // Validate if all required fields are filled
  bool get isValid {
    return name.isNotEmpty && description.isNotEmpty;
  }
}