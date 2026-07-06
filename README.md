# Auto Catalog — Catalogue de voitures (Flutter)

Application mobile de catalogue de voitures développée pour l'évaluation Dev Mobile.

## Fonctionnalités (cahier des charges)

- **Catalogue via API (JSON)** : liste de voitures récupérée depuis
  [myfakeapi](https://myfakeapi.com/api/cars/) (marque, modèle, année, couleur,
  prix, VIN). Les visuels proviennent de [LoremFlickr](https://loremflickr.com)
  (photo réelle par mot-clé, stable grâce à `lock`).
- **Responsive** :
  - Mobile (largeur < 600) → liste verticale (`ListView`)
  - Tablette (largeur ≥ 600) → grille (`GridView`, 2 à 4 colonnes)
- **Détail & navigation** : clic sur une carte → page de détail (image en grand
  via `Hero`, caractéristiques et description complète).
- **Fonctionnalité native (« Le Plus »)** : onglet **Ma Garage** (favoris)
  protégé par **authentification biométrique** (Face ID / Touch ID / empreinte)
  via le package `local_auth`.

## Architecture

```
lib/
├── main.dart                     # Entrée, thème, navigation à onglets, FavoritesScope
├── models/
│   └── car.dart                  # Modèle Car + parsing JSON + URL image/description
├── services/
│   ├── car_api.dart              # Appel HTTP au catalogue (myfakeapi)
│   ├── favorites_store.dart      # ChangeNotifier + InheritedNotifier (favoris)
│   └── auth_service.dart         # Authentification biométrique (local_auth)
├── screens/
│   ├── catalog_screen.dart       # Catalogue responsive (LayoutBuilder)
│   ├── detail_screen.dart        # Page de détail
│   └── garage_screen.dart        # Garage protégé par biométrie
└── widgets/
    └── car_card.dart             # Cartes liste/grille, image cachée, bouton favori
```

## Lancer le projet

```bash
flutter pub get
flutter run            # choisir un device (iPhone, émulateur…)
```

> La biométrie nécessite un appareil réel ou un simulateur avec Face ID/Touch ID
> configuré. Sans biométrie disponible, le garage se déverrouille automatiquement
> pour ne pas bloquer la démonstration.

## Tests & qualité

```bash
flutter analyze        # 0 issue
flutter test           # tests unitaires du modèle Car
```
