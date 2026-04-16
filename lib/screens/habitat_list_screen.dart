import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/habitat.dart';
import '../widgets/habitat_card.dart';
import 'habitat_detail_screen.dart';

class HabitatListScreen extends StatefulWidget {
  const HabitatListScreen({super.key});

  @override
  State<HabitatListScreen> createState() => _HabitatListScreenState();
}

class _HabitatListScreenState extends State<HabitatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final List<Habitat> list = _query.isEmpty
        ? provider.habitats
        : provider.habitats
            .where((h) => h.name.contains(_query))
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0000),
        title: const Text(
          '🗺️ 棲息地查詢',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: '搜尋棲息地名稱...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFCC0000)),
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFCC0000)))
          : list.isEmpty
              ? const Center(
                  child: Text('找不到符合的棲息地', style: TextStyle(fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final habitat = list[index];
                    return HabitatCard(
                      habitat: habitat,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              HabitatDetailScreen(habitat: habitat),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}