class MaterialInfo {
  final String category;   // 材料 / 方塊 / ...
  final String image;
  final String description;
  final List<String> sources;
  final List<Map<String, dynamic>> craftMaterials; // 方塊類：所需材料
  final List<String> unlockConditions;             // 方塊類：配方解鎖條件

  const MaterialInfo({
    required this.category,
    required this.image,
    required this.description,
    required this.sources,
    required this.craftMaterials,
    required this.unlockConditions,
  });

  factory MaterialInfo.fromJson(Map<String, dynamic> json) {
    List<String> asList(dynamic raw) =>
        raw is List ? List<String>.from(raw) : const <String>[];

    List<Map<String, dynamic>> asMaps(dynamic raw) => raw is List
        ? List<Map<String, dynamic>>.from(
            raw.map((e) => Map<String, dynamic>.from(e as Map)))
        : const [];

    return MaterialInfo(
      category: (json['category'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      sources: asList(json['sources']),
      craftMaterials: asMaps(json['materials']),
      unlockConditions: asList(json['unlockConditions']),
    );
  }
}
