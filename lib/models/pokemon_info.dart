class PokemonInfo {
  final String number;
  final String name;
  final List<String> types;
  final List<String> specialties;
  final List<String> times;
  final List<String> weather;
  final List<String> environment;
  final List<String> habitats;
  final String? image;

  const PokemonInfo({
    required this.number,
    required this.name,
    required this.types,
    required this.specialties,
    required this.times,
    required this.weather,
    required this.environment,
    required this.habitats,
    this.image,
  });

  factory PokemonInfo.fromJson(Map<String, dynamic> json) => PokemonInfo(
        number: json['number'] as String,
        name: json['name'] as String,
        types: List<String>.from(json['types'] as List),
        specialties: List<String>.from(json['specialties'] as List),
        times: List<String>.from(json['times'] as List),
        weather: List<String>.from(json['weather'] as List),
        environment: List<String>.from(json['environment'] as List),
        habitats: List<String>.from(json['habitats'] as List),
        image: json['image'] as String?,
      );
}
