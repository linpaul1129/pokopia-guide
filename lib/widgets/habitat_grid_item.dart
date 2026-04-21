import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habitat.dart';
import '../providers/data_provider.dart';

class HabitatGridItem extends StatelessWidget {
  final Habitat habitat;
  final VoidCallback onTap;

  const HabitatGridItem({
    super.key,
    required this.habitat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final isFav = provider.isFavorite(habitat.id);

    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final numSize = (w * 0.080).clamp(9.0, 13.0);
          final nameSize = (w * 0.088).clamp(10.0, 14.0);
          final pokemonSize = (w * 0.072).clamp(8.0, 11.0);

          // 估算每格寬度可放幾個 chip，限制最多 2 行
          final availWidth = w - 24.0;
          final approxChipW = pokemonSize * 3.5 + 12.0;
          final perRow =
              ((availWidth + 3) / (approxChipW + 3)).floor().clamp(2, 8);
          final maxShow = perRow * 2;
          final showPokemon = habitat.pokemon.take(maxShow).toList();
          final hasEllipsis = habitat.pokemon.length > maxShow;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isFav ? const Color(0xFFFFD700) : const Color(0xFFFFCCCC),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── 編號 + 名稱 + 星星 ──────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No.${habitat.id.toString().padLeft(3, '0')}',
                              style: TextStyle(
                                fontSize: numSize,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFCC0000),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              habitat.name,
                              style: TextStyle(
                                fontSize: nameSize,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF222222),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => provider.toggleFavorite(habitat.id),
                        child: Icon(
                          isFav ? Icons.star : Icons.star_border,
                          color: isFav
                              ? const Color(0xFFFFD700)
                              : Colors.grey[400],
                          size: (w * 0.15).clamp(14.0, 22.0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ── 棲息地圖片（寬度自適應）──────────────────────────
                  if (habitat.image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/habitats/${habitat.image}',
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    )
                  else
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  // ── 寶可夢標籤（最多 2 行，超過顯示 …）──────────────
                  const Spacer(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 3,
                    runSpacing: 3,
                    alignment: WrapAlignment.center,
                    children: [
                      ...showPokemon.map(
                        (p) => _PokemonChip(name: p, fontSize: pokemonSize),
                      ),
                      if (hasEllipsis)
                        _PokemonChip(name: '…', fontSize: pokemonSize, muted: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PokemonChip extends StatelessWidget {
  final String name;
  final double fontSize;
  final bool muted;

  const _PokemonChip({
    required this.name,
    required this.fontSize,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: muted ? Colors.grey[100] : const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: muted ? Colors.grey[300]! : const Color(0xFFCC0000),
          width: 0.8,
        ),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: fontSize,
          color: muted ? Colors.grey[500] : const Color(0xFFCC0000),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
