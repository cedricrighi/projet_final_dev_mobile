import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/car.dart';

/// Stocke les voitures ajoutées à "Ma Garage".
///
/// [ChangeNotifier] partagé via un [InheritedNotifier] (voir `FavoritesScope`).
/// Les favoris sont persistés localement avec `shared_preferences` : ils
/// survivent donc au redémarrage de l'application.
class FavoritesStore extends ChangeNotifier {
  static const String _storageKey = 'favorites_cars';

  SharedPreferences? _prefs;
  final Map<int, Car> _cars = {};
  Future<void> _pendingWrite = Future<void>.value();

  List<Car> get cars => List.unmodifiable(_cars.values);
  int get count => _cars.length;

  bool contains(int id) => _cars.containsKey(id);

  /// Future de la dernière écriture disque en cours. Utile pour attendre la
  /// persistance (tests) ; l'UI n'a pas besoin de l'attendre.
  Future<void> get pendingWrite => _pendingWrite;

  /// Charge les favoris persistés. À appeler une fois au démarrage.
  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_storageKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _cars
          ..clear()
          ..addEntries(
            decoded.whereType<Map<String, dynamic>>().map((json) {
              final car = Car.fromJson(json);
              return MapEntry(car.id, car);
            }),
          );
        notifyListeners();
      }
    } catch (_) {
      // Donnée corrompue : on repart d'un garage vide plutôt que de crasher.
    }
  }

  void toggle(Car car) {
    if (_cars.containsKey(car.id)) {
      _cars.remove(car.id);
    } else {
      _cars[car.id] = car;
    }
    notifyListeners();
    _pendingWrite = _persist();
  }

  Future<void> _persist() async {
    _prefs ??= await SharedPreferences.getInstance();
    final data = jsonEncode(_cars.values.map((c) => c.toJson()).toList());
    await _prefs!.setString(_storageKey, data);
  }
}

/// Rend [FavoritesStore] accessible depuis n'importe quel widget descendant.
class FavoritesScope extends InheritedNotifier<FavoritesStore> {
  const FavoritesScope({
    super.key,
    required FavoritesStore store,
    required super.child,
  }) : super(notifier: store);

  static FavoritesStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FavoritesScope>();
    assert(scope?.notifier != null, 'FavoritesScope introuvable dans l’arbre.');
    return scope!.notifier!;
  }
}
