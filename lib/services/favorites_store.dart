import 'package:flutter/widgets.dart';

import '../models/car.dart';

/// Stocke les voitures ajoutées à "Ma Garage".
///
/// Simple [ChangeNotifier] partagé via un [InheritedNotifier] (voir
/// `FavoritesScope`). Les favoris sont conservés en mémoire pour la durée de
/// la session — suffisant pour la démonstration, sans dépendance de stockage.
class FavoritesStore extends ChangeNotifier {
  final Map<int, Car> _cars = {};

  List<Car> get cars => List.unmodifiable(_cars.values);
  int get count => _cars.length;

  bool contains(int id) => _cars.containsKey(id);

  void toggle(Car car) {
    if (_cars.containsKey(car.id)) {
      _cars.remove(car.id);
    } else {
      _cars[car.id] = car;
    }
    notifyListeners();
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
