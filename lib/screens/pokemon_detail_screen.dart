import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/habitat.dart';
import '../models/pokemon_info.dart';
import 'habitat_detail_screen.dart';

class PokemonDetailScreen extends StatelessWidget {
  final String pokemonName;
  const PokemonDetailScreen({super.key, required this.pokemonName});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DataProvider>();
    final PokemonInfo? info = provider.getPokemonInfo(pokemonName);
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
            _HeaderCard(info: info, name: pokemonName),
            if (info != null) ...[
              const SizedBox(height: 16),
              _InfoCard(info: info),
            ],
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
                  child: Text(
                    '找不到 $pokemonName 的棲息地資料',
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ),
              )
            else
              ...habitats.map((h) => _HabitatInfoCard(habitat: h)),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final PokemonInfo? info;
  final String name;
  const _HeaderCard({required this.info, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFCC0000), Color(0xFFFF4444)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (info?.image != null)
            Image.asset(
              'assets/images/pokemon/${info!.image}',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.catching_pokemon, size: 80, color: Colors.white54),
            )
          else
            const Icon(Icons.catching_pokemon, size: 80, color: Colors.white54),
          const SizedBox(height: 8),
          if (info != null)
            Text(
              '#${info!.number}',
              style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (info != null && info!.types.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: info!.types.map((t) => _TypeChip(type: t)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final PokemonInfo info;
  const _InfoCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCCCC)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (info.specialties.isNotEmpty)
            _InfoRow(
              icon: Icons.auto_awesome,
              label: '能力',
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: info.specialties.map((s) => _Chip(label: s, color: const Color(0xFFFFF3E0), borderColor: const Color(0xFFFFB74D), textColor: const Color(0xFFE65100))).toList(),
              ),
            ),
          if (info.times.isNotEmpty) ...[
            if (info.specialties.isNotEmpty) const _Divider(),
            _InfoRow(
              icon: Icons.access_time,
              label: '出現時間',
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: info.times.map((t) => _Chip(label: t, color: const Color(0xFFE3F2FD), borderColor: const Color(0xFF90CAF9), textColor: const Color(0xFF1565C0))).toList(),
              ),
            ),
          ],
          if (info.weather.isNotEmpty) ...[
            const _Divider(),
            _InfoRow(
              icon: Icons.cloud,
              label: '天氣',
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: info.weather.map((w) => _Chip(label: w, color: const Color(0xFFE8F5E9), borderColor: const Color(0xFFA5D6A7), textColor: const Color(0xFF2E7D32))).toList(),
              ),
            ),
          ],
          if (info.environment.isNotEmpty) ...[
            const _Divider(),
            _InfoRow(
              icon: Icons.nature,
              label: '喜歡的環境',
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: info.environment.map((e) => _Chip(label: e, color: const Color(0xFFF3E5F5), borderColor: const Color(0xFFCE93D8), textColor: const Color(0xFF6A1B9A))).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  const _InfoRow({required this.icon, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFCC0000)),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: Color(0xFFFFEEEE));
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color borderColor;
  final Color textColor;
  const _Chip({required this.label, required this.color, required this.borderColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── Habitat card ──────────────────────────────────────────────────────────────

class _HabitatInfoCard extends StatelessWidget {
  final Habitat habitat;
  const _HabitatInfoCard({required this.habitat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HabitatDetailScreen(habitat: habitat)),
      ),
      child: Container(
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
                  width: 64,
                  height: 64,
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
                  const SizedBox(height: 4),
                  Text(
                    habitat.materials == '無' ? '無需特定素材' : habitat.materials,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
