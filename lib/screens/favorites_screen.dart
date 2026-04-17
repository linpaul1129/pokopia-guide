import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../widgets/habitat_view_switcher.dart';
import '../widgets/recipe_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final habFavs = provider.favoriteHabitats;
    final recFavs = provider.favoriteRecipes;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0000),
        title: const Text(
          '⭐ 收藏清單',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          if (_tabController.index == 0 && habFavs.isNotEmpty)
            IconButton(
              icon: Icon(
                _isGridView ? Icons.view_list : Icons.grid_view,
                color: Colors.white,
              ),
              tooltip: _isGridView ? '切換為清單' : '切換為格狀',
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: '棲息地 (${habFavs.length})'),
            Tab(text: '配方 (${recFavs.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Habitat favorites ──────────────────────────────────────────────
          habFavs.isEmpty
              ? _emptyState('⭐', '還沒有收藏的棲息地\n進入棲息地詳細頁面點選星星即可收藏')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        '已收藏 ${habFavs.length} 個棲息地',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: HabitatViewSwitcher(
                        habitats: habFavs,
                        isGridView: _isGridView,
                      ),
                    ),
                  ],
                ),

          // ── Recipe favorites ───────────────────────────────────────────────
          recFavs.isEmpty
              ? _emptyState('🔨', '還沒有收藏的配方\n在配方頁點選星星即可收藏')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        '已收藏 ${recFavs.length} 筆配方',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                        itemCount: recFavs.length,
                        itemBuilder: (context, index) =>
                            RecipeCard(recipe: recFavs[index]),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _emptyState(String emoji, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15, color: Colors.grey[500], height: 1.6),
          ),
        ],
      ),
    );
  }
}
