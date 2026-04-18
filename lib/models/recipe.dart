class RecipeMaterial {
  final String name;
  final String image;
  final int quantity;

  const RecipeMaterial({
    required this.name,
    required this.image,
    required this.quantity,
  });

  factory RecipeMaterial.fromJson(Map<String, dynamic> json) => RecipeMaterial(
        name: json['name'] as String,
        image: json['image'] as String,
        quantity: json['quantity'] as int,
      );
}
