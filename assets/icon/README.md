# Icône de l'application

Déposez ici l'image source de l'icône :

- **`icon.png`** — 1024×1024 px, format PNG, carré, sans coins arrondis.

Puis générez toutes les tailles (Android, iOS, web) avec :

```bash
dart run flutter_launcher_icons
```

La configuration se trouve dans `pubspec.yaml`, section `flutter_launcher_icons`.
Les fichiers générés (mipmap Android, AppIcon iOS…) ne doivent pas être édités
à la main : relancez simplement la commande après avoir changé `icon.png`.
