/// Modèle d'une voiture du catalogue.
///
/// Les données proviennent de l'API myfakeapi (marque, modèle, année, couleur,
/// prix, VIN). L'image n'existe pas dans cette API : on la dérive via le CDN
/// imagin.studio, qui renvoie un rendu studio de la voiture à partir de la
/// marque et du modèle (voir [imageUrl]).
class Car {
  final int id;
  final String make; // marque, ex: "Toyota"
  final String model; // modèle, ex: "Supra"
  final String color;
  final int year;
  final String vin;
  final String price;
  final bool available;

  const Car({
    required this.id,
    required this.make,
    required this.model,
    required this.color,
    required this.year,
    required this.vin,
    required this.price,
    required this.available,
  });

  /// Titre affiché dans la liste et le détail : "Marque Modèle".
  String get title => '$make $model';

  /// Angles de prise de vue disponibles pour la rotation 360° (imagin.studio).
  static const List<int> viewerAngles = [1, 5, 9, 13, 17, 21, 23, 25, 27, 29];

  /// URL du rendu studio de la voiture (imagin.studio).
  ///
  /// Le CDN génère l'image à partir de la marque et de la "famille" de modèle.
  /// Les valeurs doivent être en minuscules ; on ne garde que le premier mot du
  /// modèle (ex: "Golf GTI" -> "golf"). Pour un modèle non couvert, le CDN
  /// renvoie tout de même un rendu générique de voiture (jamais d'erreur).
  ///
  /// [angle] change la prise de vue (voir [viewerAngles]) ; [color] recolore la
  /// carrosserie (ex: "red", "blue", "black"). Chaque combinaison est une URL
  /// distincte, donc mise en cache séparément par cached_network_image.
  String imageUrl({int? angle, String? color}) {
    final modelFamily = model.toLowerCase().trim().split(' ').first;
    return Uri.https('cdn.imagin.studio', '/getImage', {
      'customer': 'img',
      'make': make.toLowerCase().trim(),
      'modelFamily': modelFamily,
      'angle': ?angle?.toString().padLeft(2, '0'),
      'paintdescription': ?color,
    }).toString();
  }

  /// Description construite à partir des caractéristiques disponibles.
  String get description =>
      'La $make $model de $year se distingue par sa teinte $color. '
      'Prix indicatif : $price. '
      'Numéro de série (VIN) : $vin. '
      "Disponibilité : ${available ? 'en stock' : 'sur commande'}.";

  /// Parse un élément JSON de l'API myfakeapi.
  ///
  /// Robuste aux valeurs manquantes ou mal typées (l'API renvoie l'année et
  /// l'id en nombre, mais on sécurise le parsing).
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: _asInt(json['id']),
      make: (json['car'] ?? '').toString().trim(),
      model: (json['car_model'] ?? '').toString().trim(),
      color: (json['car_color'] ?? 'N/A').toString().trim(),
      year: _asInt(json['car_model_year']),
      vin: (json['car_vin'] ?? '').toString().trim(),
      price: (json['price'] ?? 'N/A').toString().trim(),
      available: json['availability'] == true,
    );
  }

  /// Sérialise la voiture avec les mêmes clés que l'API, afin de pouvoir la
  /// relire avec [Car.fromJson] (utilisé pour la persistance des favoris).
  Map<String, dynamic> toJson() => {
        'id': id,
        'car': make,
        'car_model': model,
        'car_color': color,
        'car_model_year': year,
        'car_vin': vin,
        'price': price,
        'availability': available,
      };

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}
