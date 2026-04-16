import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../widgets/habitat_card.dart';
import 'habitat_detail_screen.dart';

class PokemonResultScreen extends StatelessWidget {
  final String pokemonName;
  const PokemonResultScreen({super.key, required this.pokemonName});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DataProvider>();
    final results = provider.searchByPokemon(pokemonName);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0000),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '$pokemonName 的棲息地',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: results.isEmpty
          ? Center(child: Text('找不到 $pokemonName 的棲息地資料', style: const TextStyle(fontSize: 16)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    '$pokemonName 出現在 ${results.length} 個棲息地',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final habitat = results[index];
                      return HabitatCard(
                        habitat: habitat,
                        highlightPokemon: pokemonName,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => HabitatDetailScreen(habitat: habitat)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}