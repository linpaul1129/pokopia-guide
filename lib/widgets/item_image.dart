import 'package:flutter/material.dart';

class ItemImage extends StatelessWidget {
  final String filename;
  final double size;
  final BoxFit fit;

  const ItemImage({
    super.key,
    required this.filename,
    this.size = 56,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final path = filename.contains('/')
        ? 'assets/images/$filename'
        : 'assets/images/items/$filename';
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (_, __, ___) => SizedBox(
        width: size,
        height: size,
        child: Icon(Icons.broken_image_outlined,
            color: Colors.grey[400], size: size * 0.5),
      ),
    );
  }

}
