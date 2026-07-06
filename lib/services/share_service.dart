import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/car.dart';

/// Partage natif d'une voiture via la feuille de partage système.
///
/// Tente de partager l'image (téléchargée en PNG) accompagnée d'une légende.
/// Si le téléchargement échoue, se rabat sur un partage de texte seul.
class ShareService {
  ShareService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String _caption(Car car) =>
      '🚗 ${car.title} (${car.year})\n'
      'Couleur : ${car.color} · Prix : ${car.price}\n\n'
      'Partagé depuis Auto Catalog';

  /// Partage la voiture. Retourne `false` si le partage n'a pas pu aboutir
  /// (ex: plugin non enregistré) — sans jamais lever d'exception non gérée.
  Future<bool> shareCar(Car car) async {
    final caption = _caption(car);
    try {
      // fileType=png force un PNG (aperçu fiable sur iOS/Android).
      final url = '${car.imageUrl()}&fileType=png';
      final res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/car_${car.id}.png');
        await file.writeAsBytes(res.bodyBytes);
        await Share.shareXFiles([XFile(file.path)], text: caption);
        return true;
      }
      // Image indisponible : on partage le texte seul.
      await Share.share(caption);
      return true;
    } catch (_) {
      // Dernier recours : tenter le texte seul, sinon abandonner proprement.
      try {
        await Share.share(caption);
        return true;
      } catch (_) {
        return false;
      }
    }
  }
}
