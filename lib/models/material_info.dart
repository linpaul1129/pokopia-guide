class MaterialInfo {
  final String image;
  final String description;
  final List<String> sources;

  const MaterialInfo({
    required this.image,
    required this.description,
    required this.sources,
  });

  factory MaterialInfo.fromJson(Map<String, dynamic> json) {
    final raw = json['sources'];
    final sources =
        raw is List ? List<String>.from(raw) : const <String>[];
    return MaterialInfo(
      image: (json['image'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      sources: sources,
    );
  }
}
