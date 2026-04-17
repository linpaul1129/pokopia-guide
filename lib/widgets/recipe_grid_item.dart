import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/data_provider.dart';
import '../screens/recipe_detail_screen.dart';

class RecipeGridItem extends StatelessWidget {
  final Recipe recipe;

  const RecipeGridItem({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final isFav = provider.isRecipeFavorite(recipe.name);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipe: recipe),
        ),
      ),
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFav ? const Color(0xFFFFD700) : const Color(0xFFCCE5FF),
          width: isFav ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Name row + star
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => provider.toggleRecipeFavorite(recipe.name),
                  child: Icon(
                    isFav ? Icons.star : Icons.star_border,
                    color: isFav ? const Color(0xFFFFD700) : Colors.grey[400],
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Item image
            Expanded(
              child: Image.asset(
                'assets/images/makeRecipe/${recipe.image}',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Materials (icon only, up to 4, then +N)
            _MaterialIcons(materials: recipe.materials),
          ],
        ),
      ),
    ), // Container
    ); // GestureDetector
  }
}

class _MaterialIcons extends StatelessWidget {
  final List<RecipeMaterial> materials;
  const _MaterialIcons({required this.materials});

  @override
  Widget build(BuildContext context) {
    const maxShow = 4;
    final show = materials.take(maxShow).toList();
    final rest = materials.length - show.length;

    return Wrap(
      spacing: 2,
      runSpacing: 2,
      alignment: WrapAlignment.center,
      children: [
        ...show.map((m) => Tooltip(
              message: '${m.name} ×${m.quantity}',
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Image.asset(
                        'assets/images/materials/${m.image}',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.help_outline,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  if (m.quantity > 1)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D4ED8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '×${m.quantity}',
                          style: const TextStyle(
                            fontSize: 7,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )),
        if (rest > 0)
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '+$rest',
                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              ),
            ),
          ),
      ],
    );
  }
}
