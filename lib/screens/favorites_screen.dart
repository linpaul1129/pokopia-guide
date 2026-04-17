import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../widgets/habitat_view_switcher.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final favs = provider.favoriteHabitats;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0000),
        title: const Text(
          '⭐ 收藏清單',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          if (favs.isNotEmpty)
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
      body: favs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text(
                    '還沒有收藏的棲息地\n進入棲息地詳細頁面點選星星即可收藏',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey[500], height: 1.6),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    '已收藏 ${favs.length} 個棲息地',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: HabitatViewSwitcher(
                    habitats: favs,
                    isGridView: _isGridView,
                  ),
                ),
              ],
            ),
    );
  }
}