import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/material_info.dart';
import '../providers/data_provider.dart';
import '../widgets/item_image.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemName;
  final MaterialInfo info;

  const ItemDetailScreen(
      {super.key, required this.itemName, required this.info});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final isFav = provider.isRecipeFavorite(itemName);

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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 圖片
            Center(
              child: Container(
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
            ),
            const SizedBox(height: 16),
            // 名稱
            Center(
              child: Text(
                itemName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            // 描述
            if (info.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Center(
                child: Text(
                  info.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            // 獲得方式
            if (info.sources.isNotEmpty) ...[
              const SizedBox(height: 28),
              const _SectionHeader(
                icon: Icons.location_on_outlined,
                label: '獲得方式',
              ),
              const SizedBox(height: 10),
              ...info.sources.map((src) => _InfoRow(text: src)),
            ],
            // 解鎖條件
            if (info.unlockConditions.isNotEmpty) ...[
              const SizedBox(height: 24),
              const _SectionHeader(
                icon: Icons.lock_open_outlined,
                label: '配方解鎖條件',
              ),
              const SizedBox(height: 10),
              ...info.unlockConditions.map((cond) => _InfoRow(text: cond)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

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
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String text;
  const _InfoRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFCC0000).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
