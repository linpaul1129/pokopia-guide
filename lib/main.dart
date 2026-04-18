import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/data_provider.dart';
import 'screens/habitat_list_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/recipe_list_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => DataProvider(),
      child: const PokopiaApp(),
    ),
  );
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class PokopiaApp extends StatelessWidget {
  const PokopiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokopia 攻略',
      debugShowCheckedModeBanner: false,
      scrollBehavior: _AppScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFCC0000)),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HabitatListScreen(),
    SearchScreen(),
    RecipeListScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFFCC0000),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.landscape),
            label: '棲息地',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '搜尋',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.construction),
            label: '物品',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: '收藏',
          ),
        ],
      ),
    );
  }
}