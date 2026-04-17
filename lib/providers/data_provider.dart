import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habitat.dart';
import '../models/recipe.dart';
import '../models/material_info.dart';

class DataProvider extends ChangeNotifier {
  List<Habitat> _habitats = [];
  Set<int> _favorites = {};
  Map<String, String> _pokemonNameMap = {};

  List<Recipe> _recipes = [];
  Set<String> _recipeFavorites = {};
  Map<String, MaterialInfo> _materialsInfo = {};

  bool _isLoading = true;

  List<Habitat> get habitats => _habitats;
  Set<int> get favorites => _favorites;
  Map<String, String> get pokemonNameMap => _pokemonNameMap;
  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;

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

    final String nameMapStr =
        await rootBundle.loadString('assets/data/pokemon_name_map.json');
    _pokemonNameMap = Map<String, String>.from(json.decode(nameMapStr) as Map);

    final String recipeStr =
        await rootBundle.loadString('assets/data/makeRecipe.json');
    final Map<String, dynamic> recipeMap =
        json.decode(recipeStr) as Map<String, dynamic>;
    _recipes = recipeMap.entries.map((entry) {
      final data = entry.value as Map<String, dynamic>;
      final materials = (data['materials'] as List)
          .map((m) => RecipeMaterial.fromJson(m as Map<String, dynamic>))
          .toList();
      return Recipe(
        name: entry.key,
        image: data['image'] as String,
        materials: materials,
      );
    }).toList();

    final prefs = await SharedPreferences.getInstance();

    final favList = prefs.getStringList('favorites') ?? [];
    _favorites = favList.map(int.parse).toSet();

    final recFavList = prefs.getStringList('recipeFavorites') ?? [];
    _recipeFavorites = recFavList.toSet();

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

  // ── Recipe favorites ───────────────────────────────────────────────────────

  bool isRecipeFavorite(String name) => _recipeFavorites.contains(name);

  Future<void> toggleRecipeFavorite(String name) async {
    if (_recipeFavorites.contains(name)) {
      _recipeFavorites.remove(name);
    } else {
      _recipeFavorites.add(name);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recipeFavorites', _recipeFavorites.toList());
    notifyListeners();
  }

  List<Recipe> get favoriteRecipes =>
      _recipes.where((r) => _recipeFavorites.contains(r.name)).toList();

  List<Recipe> searchRecipes(String query) {
    if (query.isEmpty) return _recipes;
    final q = query.toLowerCase();
    return _recipes
        .where((r) =>
            r.name.contains(query) ||
            r.materials.any((m) => m.name.toLowerCase().contains(q)))
        .toList();
  }
}