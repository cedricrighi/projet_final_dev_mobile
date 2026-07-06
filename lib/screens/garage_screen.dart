import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/car.dart';
import '../providers.dart';
import '../services/favorites_store.dart';
import '../widgets/car_card.dart';
import 'detail_screen.dart';

/// "Mon Garage" : la liste des voitures favorites, protégée par une
/// authentification biométrique (Face ID / Touch ID / empreinte).
///
/// Tant que l'utilisateur ne s'est pas authentifié, le contenu reste masqué.
/// L'écran est maintenu vivant par l'IndexedStack parent ; [isActive] indique
/// si l'onglet Garage est actuellement sélectionné. Face ID se déclenche quand
/// l'onglet devient actif, et le garage se re-verrouille quand on le quitte.
class GarageScreen extends ConsumerStatefulWidget {
  const GarageScreen({super.key, required this.isActive});

  final bool isActive;

  @override
  ConsumerState<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends ConsumerState<GarageScreen> {
  bool _unlocked = false;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    }
  }

  @override
  void didUpdateWidget(GarageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _unlock();
    } else if (!widget.isActive && oldWidget.isActive) {
      setState(() {
        _unlocked = false;
        _authenticating = false;
      });
    }
  }

  Future<void> _unlock() async {
    if (_authenticating || _unlocked) return;
    setState(() => _authenticating = true);

    final auth = ref.read(authServiceProvider);
    final canAuth = await auth.canAuthenticate();
    // Si aucune biométrie n'est configurée (ex: émulateur), on n'enferme pas
    // l'utilisateur : on déverrouille pour ne pas bloquer la démo.
    final ok = canAuth ? await auth.authenticate() : true;

    if (!mounted) return;
    setState(() {
      _unlocked = ok;
      _authenticating = false;
    });

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentification refusée.')),
      );
    }
  }

  void _openDetail(Car car) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DetailScreen(car: car)));
  }

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) {
      return _LockedView(authenticating: _authenticating, onUnlock: _unlock);
    }

    final cars = ref.watch(favoritesProvider);

    if (cars.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Votre garage est vide.\nAjoutez des voitures avec le ❤️ du catalogue.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: cars.length,
      itemBuilder: (context, index) {
        final car = cars[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CarListItem(car: car, onTap: () => _openDetail(car)),
        );
      },
    );
  }
}

/// Écran de verrouillage affiché tant que l'utilisateur n'est pas authentifié.
class _LockedView extends StatelessWidget {
  const _LockedView({required this.authenticating, required this.onUnlock});

  final bool authenticating;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 64),
          const SizedBox(height: 16),
          const Text('Garage verrouillé'),
          const SizedBox(height: 16),
          if (authenticating)
            const CircularProgressIndicator()
          else
            FilledButton.icon(
              onPressed: onUnlock,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Déverrouiller'),
            ),
        ],
      ),
    );
  }
}
