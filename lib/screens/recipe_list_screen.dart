import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/material_info.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_grid_item.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = '';
  bool _isGridView = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final List<MapEntry<String, MaterialInfo>> list =
        provider.searchAllItems(_query, category: _selectedCategory);
    final categories = provider.allCategories;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0000),
        title: const Text(
          '🔨 道具圖鑑',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: Colors.white,
            ),
            tooltip: _isGridView ? '切換為清單' : '切換為格狀',
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: '搜尋道具名稱或材料名稱...',
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFFCC0000)),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
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
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFCC0000)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
              _CategoryChips(
                  categories: categories,
                  selected: _selectedCategory,
                  onSelect: (cat) =>
                      setState(() => _selectedCategory = cat),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                  child: Text(
                    list.isEmpty
                        ? '找不到符合的道具'
                        : '共 ${list.length} 筆道具',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (list.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        '找不到符合的道具',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: _isGridView
                        ? GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final entry = list[index];
                              return RecipeGridItem(
                                itemName: entry.key,
                                info: entry.value,
                              );
                            },
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(12, 6, 12, 12),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final entry = list[index];
                              return RecipeCard(
                                itemName: entry.key,
                                info: entry.value,
                              );
                            },
                          ),
                  ),
              ],
            ),
    );
  }
}

// ── Category chips ────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  static const _categoryColors = <String, Color>{
    '食物': Color(0xFFDC2626),
    '材料': Color(0xFFD97706),
    '自然': Color(0xFF16A34A),
    '工具套裝': Color(0xFF2563EB),
    '家具': Color(0xFF9333EA),
    '其他': Color(0xFF6B7280),
    '雜貨': Color(0xFF0891B2),
    '便利道具': Color(0xFF059669),
    '戶外': Color(0xFF65A30D),
    '建築': Color(0xFFB45309),
    '方塊': Color(0xFF475569),
    '重要物品': Color(0xFFDB2777),
    '非收藏品': Color(0xFF9CA3AF),
  };

  @override
  Widget build(BuildContext context) {
    final all = ['全部', ...categories];
    return SizedBox(
      height: 40,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: all.length,
        itemBuilder: (context, index) {
          final cat = all[index];
          final isAll = cat == '全部';
          final isSelected = isAll ? selected.isEmpty : selected == cat;
          final color = isAll
              ? const Color(0xFFCC0000)
              : _categoryColors[cat] ?? const Color(0xFF6B7280);

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Center(
              child: GestureDetector(
                onTap: () => onSelect(isAll ? '' : cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color : color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        ),
      ),
    );
  }
}
