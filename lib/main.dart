import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/catalog_screen.dart';
import 'screens/garage_screen.dart';
import 'screens/swipe_screen.dart';
import 'services/favorites_store.dart';

void main() {
  runApp(const ProviderScope(child: AutoCatalogApp()));
}

class AutoCatalogApp extends StatelessWidget {
  const AutoCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}

/// Coquille principale avec navigation à deux onglets : Catalogue et Garage.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _index = 0;

  static const _titles = ['Catalogue', 'Découvrir', 'Mon Garage'];

  @override
  Widget build(BuildContext context) {
    final favoritesCount = ref.watch(favoritesProvider).length;

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(
        index: _index,
        children: [
          const CatalogScreen(),
          const SwipeScreen(),
          GarageScreen(isActive: _index == 2),
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
          const NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: 'Découvrir',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: favoritesCount > 0,
              label: Text('$favoritesCount'),
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
