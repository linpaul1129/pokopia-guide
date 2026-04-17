# Pokopia Guide

## Project overview

**Pokopia Guide** (`pokopia_guide`) is a Flutter app for browsing Pokémon habitat and crafting recipe data (棲息地查詢攻略). It is a static, offline-first app — all data is bundled in `assets/data/`. There is no backend or network layer.

The app deploys as a Flutter Web app to GitHub Pages at `/pokopia-guide/` via CI on push to `main`.

## Common commands

```bash
# Install dependencies
flutter pub get

# Run on a connected device or browser
flutter run -d chrome

# Build for web (matches CI)
flutter build web --release --base-href "/pokopia-guide/"

# Lint
flutter analyze

# Run tests
flutter test
```

## Architecture

State is managed via a single `ChangeNotifierProvider` wrapping the whole app (`DataProvider`). All screens access data through `context.watch<DataProvider>()` or `context.read<DataProvider>()`.

**Data flow:**
1. `DataProvider` loads all four JSON assets at startup
2. Habitat and recipe favorites are each persisted to `SharedPreferences`
3. Search runs synchronously over in-memory lists — no async needed

**Navigation:** `MainShell` uses `IndexedStack` with a `BottomNavigationBar` for the four top-level tabs. Detail screens use `Navigator.push` (imperative navigation).

**Screen routing:**
- `HabitatListScreen` → `HabitatDetailScreen` (push)
- `HabitatDetailScreen` → `PokemonResultScreen` (push, when tapping a Pokémon chip)
- `SearchScreen` → `HabitatDetailScreen` (push)
- `FavoritesScreen` → `HabitatDetailScreen` or `RecipeDetailScreen` (push)
- `RecipeListScreen` → `RecipeDetailScreen` (push)

**Key files:**
- `lib/models/habitat.dart` — `Habitat` model: `id`, `name`, `materials`, `pokemon`, `image`
- `lib/models/recipe.dart` — `Recipe` model: `name`, `image`, `materials: List<RecipeMaterial>`
- `lib/models/material_info.dart` — `MaterialInfo` model: `category`, `description`, `sources`, `craftMaterials`, `unlockConditions`
- `lib/providers/data_provider.dart` — single source of truth; search, favorites, and material lookups
- `assets/data/` — all static data (see Data format below)

## Data format

**`assets/data/habitats.json`**
```json
{
  "habitats": [
    {
      "id": 1,
      "name": "棲息地名稱",
      "materials": "綠草 ×4",
      "pokemon": ["寶可夢A", "寶可夢B"],
      "image": "habitat_1.png"
    }
  ]
}
```

**`assets/data/makeRecipe.json`**
```json
{
  "配方名稱": {
    "image": "item.png",
    "materials": [
      { "name": "材料名稱", "image": "item-1.png", "quantity": 4 }
    ]
  }
}
```

**`assets/data/items.json`**
```json
{
  "材料名稱": {
    "category": "材料",
    "image": "item-1.png",
    "description": "說明文字",
    "sources": ["獲得方式"],
    "materials": [],
    "unlockConditions": []
  }
}
```
`category` is either `"材料"` (material) or `"方塊"` (block). For blocks, `sources` and `unlockConditions` are displayed in `RecipeDetailScreen`.

**`assets/data/pokemon_name_map.json`** — maps Chinese Pokémon names to image filenames.

## Style conventions

- Brand color: `Color(0xFFCC0000)` (red) throughout AppBars, accents, and chip borders
- Background: `Color(0xFFFFF8F8)` on all `Scaffold` bodies
- Habitat IDs are displayed zero-padded to 3 digits: `No.${id.toString().padLeft(3, '0')}`
- `HabitatCard` accepts an optional `highlightPokemon` string to visually highlight matching chips in search results
- Category badges use fixed color pairs: `材料` → amber, `方塊` → grey, others → blue
