class Habitat {
  final int id;
  final String name;
  final String materials;
  final List<String> pokemon;
  final String? image;

  Habitat({
    required this.id,
    required this.name,
    required this.materials,
    required this.pokemon,
    this.image,
  });

  factory Habitat.fromJson(Map<String, dynamic> json) {
    return Habitat(
      id: json['id'] as int,
      name: json['name'] as String,
      materials: json['materials'] as String,
      pokemon: List<String>.from(json['pokemon'] as List),
      image: json['image'] as String?,
    );
  }
}