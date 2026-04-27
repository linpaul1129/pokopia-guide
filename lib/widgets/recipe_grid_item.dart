import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/material_info.dart';
import '../providers/data_provider.dart';
import '../screens/recipe_detail_screen.dart';
import '../screens/item_detail_screen.dart';
import 'item_image.dart';

class RecipeGridItem extends StatelessWidget {
  final String itemName;
  final MaterialInfo info;

  const RecipeGridItem({
    super.key,
    required this.itemName,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final hasMaterials = info.craftMaterials.isNotEmpty;
    final isFav = provider.isRecipeFavorite(itemName);
    final imagePath = info.image.contains('/')
        ? 'assets/images/${info.image}'
        : 'assets/images/items/${info.image}';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => hasMaterials
              ? RecipeDetailScreen(itemName: itemName, info: info)
              : ItemDetailScreen(itemName: itemName, info: info),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final nameSize = (w * 0.088).clamp(10.0, 14.0);
          final descSize = (w * 0.073).clamp(8.5, 11.0);
          final starSize = (w * 0.15).clamp(14.0, 22.0);

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 名稱 + 分類標籤 + 星星 ─────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemName,
                              style: TextStyle(
                                fontSize: nameSize,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF222222),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (info.category.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              _CategoryBadge(category: info.category),
                            ],
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => provider.toggleRecipeFavorite(itemName),
                        child: Icon(
                          isFav ? Icons.star : Icons.star_border,
                          color: isFav
                              ? const Color(0xFFFFD700)
                              : Colors.grey[400],
                          size: starSize,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // ── 圖片（填滿剩餘高度，隨格子寬度縮放）──────────────
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        if (hasMaterials)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCC0000),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.build,
                                color: Colors.white,
                                size: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // ── 描述（圖片下方 16px）─────────────────────────────
                  if (info.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      info.description,
                      style: TextStyle(
                        fontSize: descSize,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  // ── 素材圖示 ─────────────────────────────────────────
                  if (hasMaterials) ...[
                    const SizedBox(height: 4),
                    _MaterialIcons(
                      materials: info.craftMaterials
                          .map(RecipeMaterial.fromJson)
                          .toList(),
                      cellWidth: w,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Material icons ────────────────────────────────────────────────────────────

class _MaterialIcons extends StatelessWidget {
  final List<RecipeMaterial> materials;
  final double cellWidth;
  const _MaterialIcons({required this.materials, required this.cellWidth});

  @override
  Widget build(BuildContext context) {
    const maxShow = 4;
    final show = materials.take(maxShow).toList();
    final rest = materials.length - show.length;
    final iconSize = (cellWidth * 0.22).clamp(22.0, 32.0);
    final badgeFontSize = (iconSize * 0.22).clamp(6.0, 9.0);

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
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: ItemImage(filename: m.image, size: iconSize - 6),
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
                          style: TextStyle(
                            fontSize: badgeFontSize,
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
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '+$rest',
                style: TextStyle(
                    fontSize: badgeFontSize, color: Colors.grey[600]),
              ),
            ),
          ),
      ],
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
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
