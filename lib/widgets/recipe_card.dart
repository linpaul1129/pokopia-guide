import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/material_info.dart';
import '../providers/data_provider.dart';
import '../screens/recipe_detail_screen.dart';
import '../screens/item_detail_screen.dart';
import 'item_image.dart';

List<RecipeMaterial> _toMaterials(List<Map<String, dynamic>> raw) =>
    raw.map(RecipeMaterial.fromJson).toList();

class RecipeCard extends StatelessWidget {
  final String itemName;
  final MaterialInfo info;

  const RecipeCard({
    super.key,
    required this.itemName,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final hasMaterials = info.craftMaterials.isNotEmpty;
    final isFav = provider.isRecipeFavorite(itemName);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => hasMaterials
              ? RecipeDetailScreen(itemName: itemName, info: info)
              : ItemDetailScreen(itemName: itemName, info: info),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFav
                ? const Color(0xFFFFD700)
                : hasMaterials
                    ? const Color(0xFFCCE5FF)
                    : const Color(0xFFE5E7EB),
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
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ItemImage(filename: info.image, size: 64),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            itemName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF222222),
                            ),
                          ),
                        ),
                        _CategoryBadge(category: info.category),
                      ],
                    ),
                    if (info.description.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        info.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (hasMaterials) ...[
                      const SizedBox(height: 5),
                      _MaterialChips(
                          materials: _toMaterials(info.craftMaterials)),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => provider.toggleRecipeFavorite(itemName),
                child: Padding(
                  padding: const EdgeInsets.only(left: 6, top: 2),
                  child: Icon(
                    isFav ? Icons.star : Icons.star_border,
                    color: isFav ? const Color(0xFFFFD700) : Colors.grey[400],
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Material chips ────────────────────────────────────────────────────────────

class _MaterialChips extends StatelessWidget {
  final List<RecipeMaterial> materials;
  const _MaterialChips({required this.materials});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: materials.map((m) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ItemImage(filename: m.image, size: 18),
              const SizedBox(width: 3),
              Text(
                '${m.name} ×${m.quantity}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF1D4ED8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Category badge ────────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  static const _colors = <String, (Color, Color)>{
    '食物': (Color(0xFFFEE2E2), Color(0xFFDC2626)),
    '材料': (Color(0xFFFEF3C7), Color(0xFFD97706)),
    '自然': (Color(0xFFDCFCE7), Color(0xFF16A34A)),
    '工具套裝': (Color(0xFFDBEAFE), Color(0xFF2563EB)),
    '家具': (Color(0xFFF3E8FF), Color(0xFF9333EA)),
    '其他': (Color(0xFFF3F4F6), Color(0xFF6B7280)),
    '雜貨': (Color(0xFFCFFAFE), Color(0xFF0891B2)),
    '便利道具': (Color(0xFFD1FAE5), Color(0xFF059669)),
    '戶外': (Color(0xFFECFCCB), Color(0xFF65A30D)),
    '建築': (Color(0xFFFEF3C7), Color(0xFFB45309)),
    '方塊': (Color(0xFFF1F5F9), Color(0xFF475569)),
    '重要物品': (Color(0xFFFCE7F3), Color(0xFFDB2777)),
    '非收藏品': (Color(0xFFF9FAFB), Color(0xFF9CA3AF)),
  };

  @override
  Widget build(BuildContext context) {
    if (category.isEmpty) return const SizedBox.shrink();
    final (bg, fg) =
        _colors[category] ?? (const Color(0xFFE0F2FE), const Color(0xFF0369A1));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
