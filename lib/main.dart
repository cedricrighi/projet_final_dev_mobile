import 'package:flutter/material.dart';

import 'screens/catalog_screen.dart';
import 'screens/garage_screen.dart';
import 'services/favorites_store.dart';

void main() {
  runApp(const AutoCatalogApp());
}

class AutoCatalogApp extends StatefulWidget {
  const AutoCatalogApp({super.key});

  @override
  State<AutoCatalogApp> createState() => _AutoCatalogAppState();
}

class _AutoCatalogAppState extends State<AutoCatalogApp> {
  // Store de favoris partagé à toute l'application via FavoritesScope.
  final FavoritesStore _favorites = FavoritesStore();

  @override
  void initState() {
    super.initState();
    // Recharge les favoris persistés au démarrage (met à jour l'UI via notify).
    _favorites.load();
  }

  @override
  void dispose() {
    _favorites.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FavoritesScope(
      store: _favorites,
      child: MaterialApp(
        title: 'Auto Catalog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

/// Coquille principale avec navigation à deux onglets : Catalogue et Garage.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  static const _titles = ['Catalogue', 'Ma Garage'];

  @override
  Widget build(BuildContext context) {
    // Rebuild du badge quand les favoris changent.
    final favorites = FavoritesScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(
        index: _index,
        children: [
          const CatalogScreen(),
          GarageScreen(isActive: _index == 1),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Catalogue',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: favorites.count > 0,
              label: Text('${favorites.count}'),
              child: const Icon(Icons.garage_outlined),
            ),
            selectedIcon: const Icon(Icons.garage),
            label: 'Garage',
          ),
        ],
      ),
    );
  }
}
