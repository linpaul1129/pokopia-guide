import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habitat.dart';

class DataProvider extends ChangeNotifier {
  List<Habitat> _habitats = [];
  Set<int> _favorites = {};
  bool _isLoading = true;

  List<Habitat> get habitats => _habitats;
  Set<int> get favorites => _favorites;
  bool get isLoading => _isLoading;

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

    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList('favorites') ?? [];
    _favorites = favList.map(int.parse).toSet();

    _isLoading = false;
    notifyListeners();
  }

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
}