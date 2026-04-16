import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habitat.dart';
import '../providers/data_provider.dart';

class HabitatCard extends StatelessWidget {
  final Habitat habitat;
  final VoidCallback onTap;
  final String? highlightPokemon;

  const HabitatCard({
    super.key,
    required this.habitat,
    required this.onTap,
    this.highlightPokemon,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final isFav = provider.isFavorite(habitat.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFav ? const Color(0xFFFFD700) : const Color(0xFFFFCCCC),
            width: isFav ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC0000),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No.${habitat.id.toString().padLeft(3, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habitat.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 5),
                    _buildPokemonPreview(habitat.pokemon, highlightPokemon),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => provider.toggleFavorite(habitat.id),
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
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

  Widget _buildPokemonPreview(List<String> pokemon, String? highlight) {
    const maxShow = 5;
    final show = pokemon.take(maxShow).toList();
    final rest = pokemon.length - show.length;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...show.map((p) {
          final isHighlight = highlight != null && p.contains(highlight);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isHighlight
                  ? const Color(0xFFFFEEEE)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isHighlight
                    ? const Color(0xFFCC0000)
                    : Colors.transparent,
              ),
            ),
            child: Text(
              p,
              style: TextStyle(
                fontSize: 12,
                color: isHighlight
                    ? const Color(0xFFCC0000)
                    : Colors.grey[700],
                fontWeight:
                    isHighlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }),
        if (rest > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+$rest',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }
}