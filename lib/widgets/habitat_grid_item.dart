import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habitat.dart';
import '../providers/data_provider.dart';
import '../screens/pokemon_result_screen.dart';

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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFav ? const Color(0xFFFFD700) : const Color(0xFFFFCCCC),
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
              // 第一行：左邊編號+名稱 column，右邊最愛星號
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 棲息地編號
                        Text(
                          'No.${habitat.id.toString().padLeft(3, '0')}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFCC0000),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // 編號與名稱間隔 4px
                        const SizedBox(height: 4),
                        // 棲息地名稱
                        Text(
                          habitat.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // 最愛按鈕（與編號名稱同行，靠右）
                  GestureDetector(
                    onTap: () => provider.toggleFavorite(habitat.id),
                    child: Icon(
                      isFav ? Icons.star : Icons.star_border,
                      color: isFav ? const Color(0xFFFFD700) : Colors.grey[400],
                      size: 18,
                    ),
                  ),
                ],
              ),
              // 名稱與照片間隔 12px
              const SizedBox(height: 12),
              // 棲息地照片（原尺寸 * 1.5）
              if (habitat.image != null)
                Image.asset(
                  'assets/images/habitats/${habitat.image}',
                  height: 84,
                  fit: BoxFit.contain,
                )
              else
                const SizedBox(height: 84),
              // 照片與寶可夢名稱間隔 16px
              const SizedBox(height: 16),
              // 寶可夢名稱列表（按鈕樣式）
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 3,
                    runSpacing: 3,
                    alignment: WrapAlignment.center,
                    children: habitat.pokemon.map((p) {
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PokemonResultScreen(pokemonName: p),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEEEE),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFCC0000),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            p,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFFCC0000),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
