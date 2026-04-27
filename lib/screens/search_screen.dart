import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/pokemon_info.dart';
import '../widgets/habitat_view_switcher.dart';
import 'pokemon_detail_screen.dart';

enum _DisplayTab { habitat, pokemon }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  _DisplayTab _tab = _DisplayTab.habitat;
  bool _isGridView = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();

    final filteredHabitats = _query.isEmpty
        ? provider.habitats
        : provider.habitats
            .where((h) =>
                h.name.contains(_query) || h.materials.contains(_query))
            .toList();

    final filteredPokemon = _query.isEmpty
        ? provider.pokemonList
        : provider.pokemonList
            .where((p) => p.name.contains(_query))
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0000),
        title: const Text(
          '🔍 搜尋',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          if (_tab == _DisplayTab.habitat)
            IconButton(
              icon: Icon(
                _isGridView ? Icons.view_list : Icons.grid_view,
                color: Colors.white,
              ),
              tooltip: _isGridView ? '切換為清單' : '切換為格狀',
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFCC0000),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        label: '棲息地',
                        icon: Icons.landscape,
                        selected: _tab == _DisplayTab.habitat,
                        onTap: () => setState(() {
                          _tab = _DisplayTab.habitat;
                          _query = '';
                          _controller.clear();
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TabButton(
                        label: '寶可夢',
                        icon: Icons.catching_pokemon,
                        selected: _tab == _DisplayTab.pokemon,
                        onTap: () => setState(() {
                          _tab = _DisplayTab.pokemon;
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
                    hintText: _tab == _DisplayTab.habitat ? '搜尋棲息地名稱或所需素材...' : '搜尋寶可夢名稱...',
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
          if (provider.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFFCC0000))))
          else if (_tab == _DisplayTab.habitat)
            _HabitatBody(
              habitats: filteredHabitats,
              isGridView: _isGridView,
              query: _query,
            )
          else
            _PokemonBody(
              pokemons: filteredPokemon,
              query: _query,
            ),
        ],
      ),
    );
  }
}

// ── Habitat tab ──────────────────────────────────────────────────────────────

class _HabitatBody extends StatelessWidget {
  final List habitats;
  final bool isGridView;
  final String query;

  const _HabitatBody({required this.habitats, required this.isGridView, required this.query});

  @override
  Widget build(BuildContext context) {
    if (habitats.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😢', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                query.isEmpty ? '目前沒有棲息地資料' : '找不到「$query」的棲息地',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
              child: Text(
                '找到 ${habitats.length} 個棲息地',
                style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ),
          Expanded(
            child: HabitatViewSwitcher(
              habitats: List.from(habitats),
              isGridView: isGridView,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pokemon tab ───────────────────────────────────────────────────────────────

class _PokemonBody extends StatelessWidget {
  final List<PokemonInfo> pokemons;
  final String query;

  const _PokemonBody({required this.pokemons, required this.query});

  @override
  Widget build(BuildContext context) {
    if (pokemons.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😢', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                '找不到「$query」的寶可夢',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
              child: Text(
                '找到 ${pokemons.length} 隻寶可夢',
                style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: pokemons.length,
              itemBuilder: (context, index) {
                final p = pokemons[index];
                return _PokemonCard(pokemon: p);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PokemonCard extends StatelessWidget {
  final PokemonInfo pokemon;
  const _PokemonCard({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PokemonDetailScreen(pokemonName: pokemon.name)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFCCCC)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (pokemon.image != null)
              Image.asset(
                'assets/images/pokemon/${pokemon.image}',
                width: 64,
                height: 64,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.catching_pokemon, size: 48, color: Colors.grey),
              )
            else
              const Icon(Icons.catching_pokemon, size: 48, color: Colors.grey),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                pokemon.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '#${pokemon.number}',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
            if (pokemon.types.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 3,
                children: pokemon.types.map((t) => _TypeBadge(type: t)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  static const _colors = {
    '草': Color(0xFF78C850),
    '火': Color(0xFFF08030),
    '水': Color(0xFF6890F0),
    '毒': Color(0xFFA040A0),
    '一般': Color(0xFFA8A878),
    '飛行': Color(0xFF98D8D8),
    '電': Color(0xFFF8D030),
    '冰': Color(0xFF98D8D8),
    '格鬥': Color(0xFFC03028),
    '地面': Color(0xFFE0C068),
    '岩石': Color(0xFFB8A038),
    '蟲': Color(0xFFA8B820),
    '幽靈': Color(0xFF705898),
    '龍': Color(0xFF7038F8),
    '惡': Color(0xFF705848),
    '鋼': Color(0xFFB8B8D0),
    '超能力': Color(0xFFF85888),
    '妖精': Color(0xFFEE99AC),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[type] ?? const Color(0xFFA8A878);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── Shared tab button ─────────────────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.icon, required this.selected, required this.onTap});

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
