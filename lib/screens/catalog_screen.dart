import 'package:flutter/material.dart';

import '../models/car.dart';
import '../services/car_api.dart';
import '../widgets/car_card.dart';
import 'detail_screen.dart';

/// Écran principal : le catalogue de voitures.
///
/// Responsive via [LayoutBuilder] :
///  - largeur < 600 (mobile)  -> liste verticale (ListView)
///  - largeur >= 600 (tablette) -> grille (GridView)
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final CarApi _api = CarApi();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Car>> _future;
  String _query = '';

  /// Seuil de bascule mobile / tablette (en pixels logiques).
  static const double _tabletBreakpoint = 600;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchCars();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _api.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() => _future = _api.fetchCars());
  }

  void _openDetail(Car car) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetailScreen(car: car)),
    );
  }

  /// Filtre la liste sur la marque, le modèle ou l'année (insensible à la casse).
  List<Car> _filter(List<Car> cars) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return cars;
    return cars
        .where((c) =>
            c.title.toLowerCase().contains(q) || c.year.toString().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: SearchBar(
            controller: _searchController,
            hintText: 'Rechercher une marque, un modèle, une année…',
            leading: const Icon(Icons.search),
            trailing: [
              if (_query.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Effacer',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
            ],
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(child: _buildResults()),
      ],
    );
  }

  Widget _buildResults() {
    return FutureBuilder<List<Car>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorState(
            message: snapshot.error.toString().replaceFirst('Exception: ', ''),
            onRetry: _reload,
          );
        }
        final cars = snapshot.data ?? const [];
        if (cars.isEmpty) {
          return const Center(child: Text('Aucune voiture disponible.'));
        }
        final filtered = _filter(cars);
        if (filtered.isEmpty) {
          return Center(
            child: Text('Aucun résultat pour « $_query ».'),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= _tabletBreakpoint;
              return isTablet
                  ? _CarGrid(
                      cars: filtered,
                      maxWidth: constraints.maxWidth,
                      onTap: _openDetail,
                    )
                  : _CarList(cars: filtered, onTap: _openDetail);
            },
          ),
        );
      },
    );
  }
}

/// Liste verticale — mobile.
class _CarList extends StatelessWidget {
  const _CarList({required this.cars, required this.onTap});

  final List<Car> cars;
  final ValueChanged<Car> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: cars.length,
      itemBuilder: (context, index) {
        final car = cars[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CarListItem(car: car, onTap: () => onTap(car)),
        );
      },
    );
  }
}

/// Grille — tablette. Le nombre de colonnes s'adapte à la largeur.
class _CarGrid extends StatelessWidget {
  const _CarGrid({
    required this.cars,
    required this.maxWidth,
    required this.onTap,
  });

  final List<Car> cars;
  final double maxWidth;
  final ValueChanged<Car> onTap;

  @override
  Widget build(BuildContext context) {
    // ~320px par carte : 2 colonnes sur petite tablette, 3+ sur grande.
    final crossAxisCount = (maxWidth / 320).floor().clamp(2, 4);
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: cars.length,
      itemBuilder: (context, index) {
        final car = cars[index];
        return CarCard(car: car, onTap: () => onTap(car));
      },
    );
  }
}

/// État d'erreur avec bouton "Réessayer".
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
