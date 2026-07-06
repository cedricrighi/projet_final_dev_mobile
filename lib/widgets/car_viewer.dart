import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/car.dart';

/// Visualiseur interactif d'une voiture :
///  - glisser horizontalement fait tourner la voiture (angles imagin.studio) ;
///  - toucher une pastille recolore la carrosserie.
class CarViewer extends StatefulWidget {
  const CarViewer({super.key, required this.car});

  final Car car;

  @override
  State<CarViewer> createState() => _CarViewerState();
}

class _CarViewerState extends State<CarViewer> {
  int _angleIndex = 0;
  String? _color;
  double _dragAccum = 0;

  /// Pixels de glissement nécessaires pour passer à l'angle suivant.
  static const double _dragStep = 22;

  static const List<(String, String, Color)> _palette = [
    ('Rouge', 'red', Color(0xFFD32F2F)),
    ('Bleu', 'blue', Color(0xFF1976D2)),
    ('Noir', 'black', Color(0xFF212121)),
    ('Blanc', 'white', Color(0xFFECEFF1)),
    ('Gris', 'gray', Color(0xFF9E9E9E)),
    ('Vert', 'green', Color(0xFF388E3C)),
    ('Orange', 'orange', Color(0xFFF57C00)),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Préchauffe les angles (couleur courante) pour une rotation fluide.
    for (final angle in Car.viewerAngles) {
      precacheImage(
        CachedNetworkImageProvider(
          widget.car.imageUrl(angle: angle, color: _color),
        ),
        context,
      );
    }
  }

  void _onDrag(DragUpdateDetails details) {
    _dragAccum += details.delta.dx;
    if (_dragAccum.abs() < _dragStep) return;
    final dir = _dragAccum > 0 ? -1 : 1; // glisser vers la droite tourne à gauche
    setState(() {
      _angleIndex =
          (_angleIndex + dir) % Car.viewerAngles.length;
      if (_angleIndex < 0) _angleIndex += Car.viewerAngles.length;
    });
    _dragAccum = 0;
  }

  void _selectColor(String? value) {
    setState(() => _color = value);
    // Préchauffe les angles pour la nouvelle couleur.
    for (final angle in Car.viewerAngles) {
      precacheImage(
        CachedNetworkImageProvider(
          widget.car.imageUrl(angle: angle, color: value),
        ),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.car;
    final angle = Car.viewerAngles[_angleIndex];
    return Column(
      children: [
        GestureDetector(
          onHorizontalDragUpdate: _onDrag,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: car.imageUrl(angle: angle, color: _color),
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.directions_car, size: 64),
                ),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '↔  Glissez pour faire tourner',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _ColorDot(
                color: Colors.transparent,
                selected: _color == null,
                isDefault: true,
                onTap: () => _selectColor(null),
              ),
              for (final (label, value, swatch) in _palette)
                _ColorDot(
                  color: swatch,
                  tooltip: label,
                  selected: _color == value,
                  onTap: () => _selectColor(value),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pastille de couleur sélectionnable.
class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
    this.tooltip,
    this.isDefault = false,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: tooltip ?? 'Couleur d’origine',
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? scheme.primary : scheme.outlineVariant,
                width: selected ? 3 : 1,
              ),
            ),
            child: isDefault
                ? Icon(Icons.format_color_reset,
                    size: 18, color: scheme.onSurfaceVariant)
                : null,
          ),
        ),
      ),
    );
  }
}
