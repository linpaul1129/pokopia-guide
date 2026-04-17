import 'package:flutter/material.dart';
import '../models/habitat.dart';
import 'habitat_card.dart';
import 'habitat_grid_item.dart';
import '../screens/habitat_detail_screen.dart';

/// 共用的棲息地清單／格狀切換元件。
/// 傳入 [habitats] 與 [isGridView]，元件負責渲染對應排版。
/// 導航邏輯（點卡片 → HabitatDetailScreen）內建於元件中。
class HabitatViewSwitcher extends StatelessWidget {
  final List<Habitat> habitats;
  final bool isGridView;
  final String? highlightPokemon;

  const HabitatViewSwitcher({
    super.key,
    required this.habitats,
    required this.isGridView,
    this.highlightPokemon,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.55,
        ),
        itemCount: habitats.length,
        itemBuilder: (context, index) {
          final habitat = habitats[index];
          return HabitatGridItem(
            habitat: habitat,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HabitatDetailScreen(habitat: habitat),
              ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: habitats.length,
      itemBuilder: (context, index) {
        final habitat = habitats[index];
        return HabitatCard(
          habitat: habitat,
          highlightPokemon: highlightPokemon,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HabitatDetailScreen(habitat: habitat),
            ),
          ),
        );
      },
    );
  }
}
