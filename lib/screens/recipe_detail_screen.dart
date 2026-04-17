import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/material_info.dart';
import '../providers/data_provider.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final isFav = provider.isRecipeFavorite(recipe.name);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0000),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          recipe.name,
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
            onPressed: () => provider.toggleRecipeFavorite(recipe.name),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RecipeHero(recipe: recipe),
            const SizedBox(height: 24),
            _SectionHeader(
                label: '所需材料 (${recipe.materials.length})'),
            const SizedBox(height: 12),
            for (final mat in recipe.materials)
              _MaterialDetailCard(
                material: mat,
                info: provider.getMaterialInfo(mat.name),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Recipe hero ──────────────────────────────────────────────────────────────

class _RecipeHero extends StatelessWidget {
  final Recipe recipe;
  const _RecipeHero({required this.recipe});

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
            child: Image.asset(
              'assets/images/makeRecipe/${recipe.image}',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            recipe.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ───────────────────────────────────────────────────────────

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

// ── Material detail card ─────────────────────────────────────────────────────

class _MaterialDetailCard extends StatelessWidget {
  final RecipeMaterial material;
  final MaterialInfo? info;

  const _MaterialDetailCard({required this.material, this.info});

  @override
  Widget build(BuildContext context) {
    // Build children imperatively to avoid nested-spread issues in dart2js
    final cardChildren = <Widget>[_buildHeader()];

    final description = info?.description ?? '';
    if (description.isNotEmpty) {
      cardChildren.add(const SizedBox(height: 10));
      cardChildren.add(_buildDescription(description));
    }

    final isBlock = info?.category == '方塊';
    final sources = info?.sources ?? const <String>[];
    final unlockConditions = info?.unlockConditions ?? const <String>[];

    if (isBlock) {
      if (sources.isNotEmpty || unlockConditions.isNotEmpty) {
        cardChildren.add(const SizedBox(height: 10));
        cardChildren.add(const Divider(height: 1, color: Color(0xFFE5E7EB)));
        cardChildren.add(const SizedBox(height: 10));
      }
      if (sources.isNotEmpty) {
        cardChildren.add(_buildSourcesLabel());
        cardChildren.add(const SizedBox(height: 6));
        for (final src in sources) {
          cardChildren.add(_buildSourceRow(src));
        }
      }
      if (unlockConditions.isNotEmpty) {
        if (sources.isNotEmpty) cardChildren.add(const SizedBox(height: 10));
        cardChildren.add(_buildUnlockLabel());
        cardChildren.add(const SizedBox(height: 6));
        for (final cond in unlockConditions) {
          cardChildren.add(_buildSourceRow(cond));
        }
      }
    } else if (sources.isNotEmpty) {
      cardChildren.add(const SizedBox(height: 10));
      cardChildren.add(const Divider(height: 1, color: Color(0xFFE5E7EB)));
      cardChildren.add(const SizedBox(height: 10));
      cardChildren.add(_buildSourcesLabel());
      cardChildren.add(const SizedBox(height: 6));
      for (final src in sources) {
        cardChildren.add(_buildSourceRow(src));
      }
    } else if (info == null) {
      cardChildren.add(const SizedBox(height: 8));
      cardChildren.add(_buildNoInfo());
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cardChildren,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
          child: Image.asset(
            'assets/images/items/${material.image}',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.help_outline, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                material.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (info != null && info!.category.isNotEmpty)
                    _CategoryBadge(category: info!.category),
                  _QuantityBadge(quantity: material.quantity),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
        height: 1.5,
      ),
    );
  }

  Widget _buildSourcesLabel() {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined,
            size: 14, color: Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(
          '獲得方式',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockLabel() {
    return Row(
      children: [
        const Icon(Icons.lock_open_outlined,
            size: 14, color: Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(
          '配方解鎖條件',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSourceRow(String src) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFCC0000).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              src,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoInfo() {
    return Text(
      '暫無詳細資訊',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[400],
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

// ── Category badge ───────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  static const _styles = <String, (Color, Color)>{
    '材料': (Color(0xFFFFF3CD), Color(0xFF92600A)),
    '方塊': (Color(0xFFF3F4F6), Color(0xFF4B5563)),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _styles[category] ?? (const Color(0xFFE0F2FE), const Color(0xFF0369A1));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}

// ── Quantity badge ───────────────────────────────────────────────────────────

class _QuantityBadge extends StatelessWidget {
  final int quantity;
  const _QuantityBadge({required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFCC0000).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '需要 × $quantity',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFFCC0000),
        ),
      ),
    );
  }
}
