import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/car.dart';
import 'services/auth_service.dart';
import 'services/car_api.dart';

/// Service d'accès à l'API du catalogue. Fermé automatiquement à la disposition.
final carApiProvider = Provider<CarApi>((ref) {
  final api = CarApi();
  ref.onDispose(api.dispose);
  return api;
});

/// Catalogue de voitures chargé depuis l'API (état async : loading/error/data).
/// `ref.invalidate(carsProvider)` relance le chargement (pull-to-refresh).
final carsProvider = FutureProvider<List<Car>>((ref) {
  return ref.watch(carApiProvider).fetchCars();
});

/// Texte de recherche saisi dans le catalogue.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Service d'authentification biométrique (Face ID / Touch ID / empreinte).
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
