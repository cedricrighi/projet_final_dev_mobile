import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/car.dart';
import '../providers.dart';
import '../services/favorites_store.dart';
import '../widgets/car_card.dart';
import 'detail_screen.dart';

/// Écran "Découvrir" : on swipe les voitures façon Tinder.
///  - swipe à droite (❤️) -> ajout à "Mon Garage"
///  - swipe à gauche -> passer
class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final CardSwiperController _controller = CardSwiperController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carsAsync = ref.watch(carsProvider);
    return carsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text(error.toString().replaceFirst('Exception: ', ''))),
      data: (cars) {
        // Un paquet mélangé et limité pour une session de découverte agréable.
        final deck = [...cars]..shuffle();
        final cards = deck.take(30).toList();
        if (cards.isEmpty) {
          return const Center(child: Text('Aucune voiture à découvrir.'));
        }
        return _SwipeDeck(controller: _controller, cars: cards);
      },
    );
  }
}

class _SwipeDeck extends ConsumerStatefulWidget {
  const _SwipeDeck({required this.controller, required this.cars});

  final CardSwiperController controller;
  final List<Car> cars;

  @override
  ConsumerState<_SwipeDeck> createState() => _SwipeDeckState();
}

class _SwipeDeckState extends ConsumerState<_SwipeDeck> {
  bool _finished = false;

  bool _onSwipe(int previous, int? current, CardSwiperDirection direction) {
    final car = widget.cars[previous];
    if (direction == CardSwiperDirection.right) {
      final favorites = ref.read(favoritesProvider.notifier);
      if (!favorites.contains(car.id)) favorites.toggle(car);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 900),
            content: Text('${car.title} ajoutée à votre garage ❤️'),
          ),
        );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return _DeckFinished(onRestart: () => setState(() => _finished = false));
    }
    return Column(
      children: [
        Expanded(
          child: CardSwiper(
            controller: widget.controller,
            cardsCount: widget.cars.length,
            numberOfCardsDisplayed: widget.cars.length >= 3
                ? 3
                : widget.cars.length,
            padding: const EdgeInsets.all(24),
            onSwipe: _onSwipe,
            onEnd: () => setState(() => _finished = true),
            allowedSwipeDirection: const AllowedSwipeDirection.symmetric(
              horizontal: true,
              vertical: false,
            ),
            cardBuilder: (context, index, percentX, percentY) {
              return _SwipeCard(car: widget.cars[index], percentX: percentX);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RoundButton(
                icon: Icons.close,
                color: Colors.redAccent,
                tooltip: 'Passer',
                onTap: () => widget.controller.swipe(CardSwiperDirection.left),
              ),
              _RoundButton(
                icon: Icons.favorite,
                color: Colors.green,
                tooltip: 'Ajouter à mon garage',
                onTap: () => widget.controller.swipe(CardSwiperDirection.right),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Carte de découverte : grande image + infos, avec tampons LIKE / NOPE.
class _SwipeCard extends StatelessWidget {
  const _SwipeCard({required this.car, required this.percentX});

  final Car car;
  final int percentX;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => DetailScreen(car: car))),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CarImage(car: car),
            // Dégradé bas pour lisibilité du texte.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${car.year} • ${car.color}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            if (percentX > 10)
              const _Stamp(label: 'GARAGE', color: Colors.green),
            if (percentX < -10)
              const _Stamp(label: 'PASSER', color: Colors.redAccent),
          ],
        ),
      ),
    );
  }
}

class _Stamp extends StatelessWidget {
  const _Stamp({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: label == 'GARAGE' ? Alignment.topLeft : Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Transform.rotate(
          angle: label == 'GARAGE' ? -0.3 : 0.3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        shape: const CircleBorder(),
        elevation: 2,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Icon(icon, color: color, size: 32),
          ),
        ),
      ),
    );
  }
}

class _DeckFinished extends StatelessWidget {
  const _DeckFinished({required this.onRestart});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.done_all, size: 56),
          const SizedBox(height: 12),
          const Text('Vous avez tout parcouru !'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh),
            label: const Text('Recommencer'),
          ),
        ],
      ),
    );
  }
}
