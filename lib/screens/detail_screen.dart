import 'package:flutter/material.dart';

import '../models/car.dart';
import '../widgets/car_card.dart';

/// Page de détail : image en grand, titre, caractéristiques et description
/// complète. Ouverte au clic sur une carte du catalogue.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            actions: [FavoriteButton(car: car)],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'car-image-${car.id}',
                child: CarImage(car: car),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(car.title, style: textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(icon: Icons.event, label: '${car.year}'),
                      _InfoChip(icon: Icons.palette, label: car.color),
                      _InfoChip(icon: Icons.sell, label: car.price),
                      _InfoChip(
                        icon: car.available
                            ? Icons.check_circle
                            : Icons.schedule,
                        label: car.available ? 'En stock' : 'Sur commande',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Description', style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(car.description, style: textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Text('VIN : ${car.vin}', style: textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
