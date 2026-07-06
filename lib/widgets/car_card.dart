import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/car.dart';
import '../providers.dart';
import '../services/favorites_store.dart';

/// Image distante d'une voiture, avec placeholder pendant le chargement et
/// une icône de repli si l'image est indisponible.
class CarImage extends StatelessWidget {
  const CarImage({super.key, required this.car, this.width, this.height});

  final Car car;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: car.imageUrl(),
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.directions_car, size: 48),
      ),
    );
  }
}

/// Bouton cœur pour ajouter/retirer une voiture de "Ma Garage".
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.car});

  final Car car;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.any((c) => c.id == car.id);
    return IconButton(
      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
      color: isFavorite ? Colors.redAccent : null,
      tooltip: isFavorite ? 'Retirer de ma garage' : 'Ajouter à ma garage',
      onPressed: () {
        // Petit retour haptique natif à chaque ajout/retrait.
        HapticFeedback.lightImpact();
        ref.read(favoritesProvider.notifier).toggle(car);
      },
    );
  }
}

/// Bouton de partage natif d'une voiture (feuille de partage système).
class ShareButton extends ConsumerWidget {
  const ShareButton({super.key, required this.car});

  final Car car;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.ios_share),
      tooltip: 'Partager',
      onPressed: () => ref.read(shareServiceProvider).shareCar(car),
    );
  }
}

/// Carte verticale (image en haut, infos en bas) utilisée dans la grille
/// (tablette).
class CarCard extends StatelessWidget {
  const CarCard({super.key, required this.car, required this.onTap});

  final Car car;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(tag: 'car-image-${car.id}', child: CarImage(car: car)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${car.year} • ${car.color}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  FavoriteButton(car: car),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte horizontale (vignette à gauche, infos à droite) utilisée dans la
/// liste verticale (mobile).
class CarListItem extends StatelessWidget {
  const CarListItem({super.key, required this.car, required this.onTap});

  final Car car;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Hero(
              tag: 'car-image-${car.id}',
              child: CarImage(car: car, width: 120, height: 96),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      car.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${car.year} • ${car.color}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      car.price,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            FavoriteButton(car: car),
          ],
        ),
      ),
    );
  }
}
