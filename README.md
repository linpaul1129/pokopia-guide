# pokopia

## Project overview

**Pokopia** (`pokopia_guide`) is a Flutter app for querying Pokémon habitat data (棲息地查詢攻略). It is a static, offline-first app — all habitat/Pokémon data is bundled in `assets/data/habitats.json`. There is no backend or network layer.

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

# Run a single test file
flutter test test/widget_test.dart
```


## Architecture

State is managed via a single `ChangeNotifierProvider` wrapping the whole app (`DataProvider`). All screens access data through `context.watch<DataProvider>()` or `context.read<DataProvider>()`.

**Data flow:**
1. `DataProvider` loads `assets/data/habitats.json` at startup and parses it into `List<Habitat>`
2. Favorites are persisted to `SharedPreferences` as a `Set<int>` of habitat IDs
3. Search runs synchronously over the in-memory list — no async needed

**Navigation:** `MainShell` uses `IndexedStack` with a `BottomNavigationBar` for the three top-level tabs. Detail screens use `Navigator.push` (imperative navigation).

**Screen routing:**
- `HabitatListScreen` → `HabitatDetailScreen` (push)
- `HabitatDetailScreen` → `PokemonResultScreen` (push, when tapping a Pokémon chip)
- `SearchScreen` → `HabitatDetailScreen` (push)
- `FavoritesScreen` → `HabitatDetailScreen` (push)

**Key files:**
- `lib/models/habitat.dart` — `Habitat` model with `id`, `name`, `materials`, `pokemon` fields
- `lib/providers/data_provider.dart` — single source of truth; `searchByPokemon`, `searchByHabitat`, `toggleFavorite`
- `assets/data/habitats.json` — all static data; structure: `{ "habitats": [ { "id", "name", "materials", "pokemon": [...] } ] }`

## Data format

The JSON asset uses this shape:
```json
{
  "habitats": [
    {
      "id": 1,
      "name": "棲息地名稱",
      "materials": "所需素材描述",
      "pokemon": ["寶可夢A", "寶可夢B"]
    }
  ]
}
```

`materials` is a plain string; use `"無"` when no materials are required (the UI renders it as `無需特定素材`).

## Style conventions

- Brand color: `Color(0xFFCC0000)` (red) throughout AppBars, accents, and chip borders
- Background: `Color(0xFFFFF8F8)` on all `Scaffold` bodies
- Habitat IDs are displayed zero-padded to 3 digits: `No.${id.toString().padLeft(3, '0')}`
- `HabitatCard` accepts an optional `highlightPokemon` string to visually highlight matching chips in search results
