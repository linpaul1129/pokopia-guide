import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../widgets/habitat_card.dart';
import 'habitat_detail_screen.dart';

enum SearchMode { byPokemon, byHabitat }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  SearchMode _mode = SearchMode.byPokemon;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final results = _query.isEmpty
        ? []
        : _mode == SearchMode.byPokemon
            ? provider.searchByPokemon(_query)
            : provider.searchByHabitat(_query);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0000),
        title: const Text('🔍 搜尋',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFCC0000),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ModeButton(
                          label: '依寶可夢搜尋',
                          icon: Icons.catching_pokemon,
                          selected: _mode == SearchMode.byPokemon,
                          onTap: () => setState(() {
                            _mode = SearchMode.byPokemon;
                            _query = '';
                            _controller.clear();
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ModeButton(
                          label: '依棲息地搜尋',
                          icon: Icons.landscape,
                          selected: _mode == SearchMode.byHabitat,
                          onTap: () => setState(() {
                            _mode = SearchMode.byHabitat;
                            _query = '';
                            _controller.clear();
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller,
                    onChanged: (v) => setState(() => _query = v),
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: _mode == SearchMode.byPokemon
                          ? '輸入寶可夢名稱（例：皮卡丘）'
                          : '輸入棲息地名稱（例：草叢）',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFCC0000)),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 16),
                        Text(
                          _mode == SearchMode.byPokemon
                              ? '輸入寶可夢名稱\n查看牠出現的所有棲息地'
                              : '輸入棲息地名稱\n查看該地出現的寶可夢',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey[500], height: 1.6),
                        ),
                      ],
                    ),
                  )
                : results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('😢', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text('找不到「$_query」的相關結果', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: Text(
                              _mode == SearchMode.byPokemon
                                  ? '「$_query」出現在 ${results.length} 個棲息地'
                                  : '找到 ${results.length} 個棲息地',
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
                                  highlightPokemon: _mode == SearchMode.byPokemon ? _query : null,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HabitatDetailScreen(habitat: habitat),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? const Color(0xFFCC0000) : Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: selected ? const Color(0xFFCC0000) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}