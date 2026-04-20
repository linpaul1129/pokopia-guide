import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habitat.dart';
import '../models/material_info.dart';
import '../models/pokemon_info.dart';

class DataProvider extends ChangeNotifier {
  List<Habitat> _habitats = [];
  Set<int> _favorites = {};
  List<PokemonInfo> _pokemonList = [];

  Set<String> _itemFavorites = {};
  Map<String, MaterialInfo> _materialsInfo = {};

  bool _isLoading = true;

  List<Habitat> get habitats => _habitats;
  Set<int> get favorites => _favorites;
  List<PokemonInfo> get pokemonList => _pokemonList;
  bool get isLoading => _isLoading;

  String? getPokemonImage(String name) {
    try {
      return _pokemonList.firstWhere((p) => p.name == name).image;
    } catch (_) {
      return null;
    }
  }

  PokemonInfo? getPokemonInfo(String name) {
    try {
      return _pokemonList.firstWhere((p) => p.name == name);
    } catch (_) {
      return null;
    }
  }

  MaterialInfo? getMaterialInfo(String name) => _materialsInfo[name];

  DataProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final String jsonStr =
        await rootBundle.loadString('assets/data/habitats.json');
    final Map<String, dynamic> jsonData = json.decode(jsonStr);
    _habitats = (jsonData['habitats'] as List)
        .map((e) => Habitat.fromJson(e as Map<String, dynamic>))
        .toList();

    final String pokemonStr =
        await rootBundle.loadString('assets/data/pokemon.json');
    _pokemonList = (json.decode(pokemonStr) as List)
        .map((e) => PokemonInfo.fromJson(e as Map<String, dynamic>))
        .toList();

    final prefs = await SharedPreferences.getInstance();

    final favList = prefs.getStringList('favorites') ?? [];
    _favorites = favList.map(int.parse).toSet();

    final itemFavList = prefs.getStringList('itemFavorites') ?? [];
    // migrate old key
    if (itemFavList.isEmpty) {
      final old = prefs.getStringList('recipeFavorites') ?? [];
      _itemFavorites = old.toSet();
    } else {
      _itemFavorites = itemFavList.toSet();
    }

    final String matStr =
        await rootBundle.loadString('assets/data/items.json');
    final Map<String, dynamic> matMap =
        json.decode(matStr) as Map<String, dynamic>;
    _materialsInfo = matMap.map(
      (k, v) => MapEntry(k, MaterialInfo.fromJson(v as Map<String, dynamic>)),
    );

    _isLoading = false;
    notifyListeners();
  }

  // ── Habitat favorites ──────────────────────────────────────────────────────

  Future<void> toggleFavorite(int habitatId) async {
    if (_favorites.contains(habitatId)) {
      _favorites.remove(habitatId);
    } else {
      _favorites.add(habitatId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'favorites', _favorites.map((e) => e.toString()).toList());
    notifyListeners();
  }

  bool isFavorite(int habitatId) => _favorites.contains(habitatId);

  List<Habitat> searchByPokemon(String query) {
    if (query.isEmpty) return [];
    return _habitats
        .where((h) => h.pokemon.any((p) => p.contains(query)))
        .toList();
  }

  List<Habitat> searchByHabitat(String query) {
    if (query.isEmpty) return [];
    return _habitats.where((h) => h.name.contains(query)).toList();
  }

  List<Habitat> get favoriteHabitats =>
      _habitats.where((h) => _favorites.contains(h.id)).toList();

  // ── Item favorites ─────────────────────────────────────────────────────────

  bool isRecipeFavorite(String name) => _itemFavorites.contains(name);

  Future<void> toggleRecipeFavorite(String name) async {
    if (_itemFavorites.contains(name)) {
      _itemFavorites.remove(name);
    } else {
      _itemFavorites.add(name);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('itemFavorites', _itemFavorites.toList());
    notifyListeners();
  }

  List<MapEntry<String, MaterialInfo>> get favoriteItemEntries =>
      _materialsInfo.entries
          .where((e) => _itemFavorites.contains(e.key))
          .toList();

  // ── Search ─────────────────────────────────────────────────────────────────

  List<String> get allCategories {
    final seen = <String>{};
    final result = <String>[];
    for (final info in _materialsInfo.values) {
      if (info.category.isNotEmpty && seen.add(info.category)) {
        result.add(info.category);
      }
    }
    return result;
  }

  List<MapEntry<String, MaterialInfo>> searchAllItems(
    String query, {
    String category = '',
  }) {
    var entries = _materialsInfo.entries.toList();
    if (category.isNotEmpty) {
      entries = entries.where((e) => e.value.category == category).toList();
    }
    if (query.isEmpty) return entries;
    final q = query.toLowerCase();
    return entries
        .where((e) =>
            e.key.toLowerCase().contains(q) ||
            e.value.craftMaterials.any(
                (m) => (m['name'] as String? ?? '').toLowerCase().contains(q)))
        .toList();
  }
}
