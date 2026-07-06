// Tests unitaires du modèle Car : parsing JSON, titre, image et description.
// (On teste le modèle plutôt que l'UI pour éviter tout appel réseau réel.)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_final/models/car.dart';
import 'package:projet_final/services/favorites_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Car.fromJson', () {
    final json = <String, dynamic>{
      'id': 42,
      'car': 'Toyota',
      'car_model': 'Supra',
      'car_color': 'Rouge',
      'car_model_year': 1998,
      'car_vin': 'JT2DE00000000',
      'price': r'$25000.00',
      'availability': true,
    };

    test('mappe correctement les champs', () {
      final car = Car.fromJson(json);
      expect(car.id, 42);
      expect(car.make, 'Toyota');
      expect(car.model, 'Supra');
      expect(car.year, 1998);
      expect(car.available, isTrue);
    });

    test('title combine marque et modèle', () {
      expect(Car.fromJson(json).title, 'Toyota Supra');
    });

    test('imageUrl cible imagin.studio avec marque/modèle en minuscules', () {
      final url = Car.fromJson(json).imageUrl();
      expect(url, contains('cdn.imagin.studio'));
      expect(url, contains('make=toyota'));
      expect(url, contains('modelFamily=supra'));
    });

    test('description mentionne les caractéristiques clés', () {
      final desc = Car.fromJson(json).description;
      expect(desc, contains('Toyota Supra'));
      expect(desc, contains('1998'));
      expect(desc, contains('en stock'));
    });

    test('tolère les valeurs manquantes ou mal typées', () {
      final car = Car.fromJson({'id': '7', 'car': 'Fiat'});
      expect(car.id, 7); // id fourni en String
      expect(car.model, ''); // modèle absent
      expect(car.year, 0); // année absente
      expect(car.available, isFalse);
    });

    test('toJson -> fromJson conserve les données (round-trip)', () {
      final original = Car.fromJson(json);
      final copy = Car.fromJson(original.toJson());
      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.year, original.year);
      expect(copy.available, original.available);
    });
  });

  group('FavoritesNotifier (persistance)', () {
    final car = Car.fromJson({
      'id': 1,
      'car': 'Honda',
      'car_model': 'Civic',
      'car_model_year': 2020,
    });

    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('toggle ajoute puis retire un favori', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(favoritesProvider.notifier);

      notifier.toggle(car);
      expect(notifier.contains(1), isTrue);
      expect(container.read(favoritesProvider).length, 1);

      notifier.toggle(car);
      expect(notifier.contains(1), isFalse);
      expect(container.read(favoritesProvider), isEmpty);
    });

    test('les favoris survivent dans un nouveau container (persistance)', () async {
      final container1 = ProviderContainer();
      final notifier = container1.read(favoritesProvider.notifier);
      notifier.toggle(car);
      await notifier.pendingWrite; // attend la fin de l'écriture disque
      container1.dispose();

      // Nouveau container = nouvel état ; build() recharge depuis les prefs.
      final container2 = ProviderContainer();
      addTearDown(container2.dispose);
      await container2.read(favoritesProvider.notifier).loaded;
      final cars = container2.read(favoritesProvider);
      expect(cars.length, 1);
      expect(cars.single.title, 'Honda Civic');
    });
  });
}
