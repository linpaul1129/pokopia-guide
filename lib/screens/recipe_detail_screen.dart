import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/material_info.dart';
import '../providers/data_provider.dart';
import '../widgets/item_image.dart';
import 'item_detail_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String itemName;
  final MaterialInfo info;

  const RecipeDetailScreen(
      {super.key, required this.itemName, required this.info});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final isFav = provider.isRecipeFavorite(itemName);
    final materials =
        info.craftMaterials.map(RecipeMaterial.fromJson).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0000),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          itemName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.star : Icons.star_border,
              color: isFav ? const Color(0xFFFFD700) : Colors.white,
            ),
            onPressed: () => provider.toggleRecipeFavorite(itemName),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ItemHero(itemName: itemName, info: info),
            const SizedBox(height: 24),
            _SectionHeader(label: '所需材料 (${materials.length})'),
            const SizedBox(height: 12),
            for (final mat in materials)
              _MaterialCard(
                material: mat,
                info: provider.getMaterialInfo(mat.name),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Item hero ─────────────────────────────────────────────────────────────────

class _ItemHero extends StatelessWidget {
  final String itemName;
  final MaterialInfo info;
  const _ItemHero({required this.itemName, required this.info});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: ItemImage(filename: info.image, size: 96),
          ),
          const SizedBox(height: 12),
          Text(
            itemName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          if (info.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              info.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFCC0000),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

// ── Material card ─────────────────────────────────────────────────────────────

class _MaterialCard extends StatelessWidget {
  final RecipeMaterial material;
  final MaterialInfo? info;

  const _MaterialCard({required this.material, this.info});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final target = info;
        if (target == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => target.craftMaterials.isNotEmpty
                ? RecipeDetailScreen(itemName: material.name, info: target)
                : ItemDetailScreen(itemName: material.name, info: target),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E7FF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                padding: const EdgeInsets.all(6),
                child: ItemImage(filename: material.image, size: 40),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  material.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC0000).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '× ${material.quantity}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCC0000),
                  ),
                ),
              ),
              if (info != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right,
                    size: 18, color: Color(0xFFADB5BD)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
