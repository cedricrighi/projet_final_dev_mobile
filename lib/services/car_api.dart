import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/car.dart';

/// Service d'accès au catalogue de voitures.
///
/// Source : https://myfakeapi.com/api/cars/ — renvoie ~1000 voitures en JSON.
/// On expose une méthode simple qui récupère et mappe la liste en [Car].
class CarApi {
  CarApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _endpoint = Uri.parse('https://myfakeapi.com/api/cars/');

  /// Récupère le catalogue. [limit] borne le nombre d'éléments pour garder
  /// l'UI fluide (l'API en renvoie ~1000).
  ///
  /// Lève une [Exception] en cas d'échec réseau ou de réponse invalide, afin
  /// que l'UI puisse afficher un état d'erreur avec possibilité de réessayer.
  Future<List<Car>> fetchCars({int limit = 200}) async {
    final http.Response response;
    try {
      response = await _client
          .get(_endpoint, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception('Impossible de contacter le serveur. Vérifiez votre connexion.');
    }

    if (response.statusCode != 200) {
      throw Exception('Erreur serveur (${response.statusCode}).');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final rawList = (decoded is Map<String, dynamic>) ? decoded['cars'] : null;
    if (rawList is! List) {
      throw Exception('Réponse inattendue du serveur.');
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(Car.fromJson)
        .where((car) => car.make.isNotEmpty && car.model.isNotEmpty)
        .take(limit)
        .toList();
  }

  void dispose() => _client.close();
}
