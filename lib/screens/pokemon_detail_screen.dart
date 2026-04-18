import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/habitat.dart';

class PokemonDetailScreen extends StatelessWidget {
  final String pokemonName;
  const PokemonDetailScreen({super.key, required this.pokemonName});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DataProvider>();
    final imageFile = provider.pokemonNameMap[pokemonName];
    final List<Habitat> habitats = provider.searchByPokemon(pokemonName);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0000),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          pokemonName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pokemon image + name header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCC0000), Color(0xFFFF4444)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  if (imageFile != null)
                    Image.asset(
                      'assets/images/pokemon/$imageFile',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    )
                  else
                    const Icon(Icons.catching_pokemon, size: 80, color: Colors.white54),
                  const SizedBox(height: 12),
                  Text(
                    pokemonName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '🏕️ 出現的棲息地（${habitats.length} 個）',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 8),
            if (habitats.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('找不到 $pokemonName 的棲息地資料', style: const TextStyle(fontSize: 15, color: Colors.grey)),
                ),
              )
            else
              ...habitats.map((habitat) => _HabitatInfoCard(habitat: habitat)),
          ],
        ),
      ),
    );
  }
}

class _HabitatInfoCard extends StatelessWidget {
  final Habitat habitat;
  const _HabitatInfoCard({required this.habitat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCCCC)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (habitat.image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/habitats/${habitat.image}',
                width: 72,
                height: 72,
                fit: BoxFit.contain,
              ),
            ),
          if (habitat.image != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No.${habitat.id.toString().padLeft(3, '0')} ${habitat.name}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                ),
                const SizedBox(height: 6),
                Text(
                  habitat.materials == '無' ? '無需特定素材' : habitat.materials,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
