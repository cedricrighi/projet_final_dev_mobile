import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/car.dart';

/// Gère les voitures ajoutées à "Mon Garage".
///
/// L'état est la liste des voitures favorites. Elle est persistée localement
/// avec `shared_preferences` : les favoris survivent au redémarrage.
class FavoritesNotifier extends Notifier<List<Car>> {
  static const String _storageKey = 'favorites_cars';

  SharedPreferences? _prefs;
  Future<void> _pendingWrite = Future<void>.value();
  Future<void> _loaded = Future<void>.value();

  /// Future de la dernière écriture disque en cours (utile pour les tests).
  Future<void> get pendingWrite => _pendingWrite;

  /// Future du chargement initial des favoris persistés (utile pour les tests).
  Future<void> get loaded => _loaded;

  @override
  List<Car> build() {
    _loaded = _load();
    return const [];
  }

  bool contains(int id) => state.any((c) => c.id == id);

  Future<void> _load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_storageKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        state = decoded
            .whereType<Map<String, dynamic>>()
            .map(Car.fromJson)
            .toList();
      }
    } catch (_) {
      // Donnée corrompue : on repart d'un garage vide plutôt que de crasher.
    }
  }

  void toggle(Car car) {
    if (contains(car.id)) {
      state = state.where((c) => c.id != car.id).toList();
    } else {
      state = [...state, car];
    }
    _pendingWrite = _persist();
  }

  Future<void> _persist() async {
    _prefs ??= await SharedPreferences.getInstance();
    final data = jsonEncode(state.map((c) => c.toJson()).toList());
    await _prefs!.setString(_storageKey, data);
  }
}

/// Expose la liste des favoris et le notifier associé.
final favoritesProvider = NotifierProvider<FavoritesNotifier, List<Car>>(
  FavoritesNotifier.new,
);
