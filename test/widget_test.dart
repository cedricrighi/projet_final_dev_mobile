// Tests unitaires du modèle Car : parsing JSON, titre, image et description.
// (On teste le modèle plutôt que l'UI pour éviter tout appel réseau réel.)

import 'package:flutter_test/flutter_test.dart';
import 'package:projet_final/models/car.dart';

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

    test('imageUrl est déterministe (lock sur id)', () {
      final url = Car.fromJson(json).imageUrl();
      expect(url, contains('loremflickr.com'));
      expect(url, contains('lock=42'));
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
  });
}
