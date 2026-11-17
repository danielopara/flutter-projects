import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wardrobe/models/garment.dart';
import 'package:wardrobe/state/wardrobe_providers.dart';

/// A garment's photo, or its category icon when there is no photo.
class GarmentPhoto extends ConsumerWidget {
  const GarmentPhoto({
    super.key,
    required this.imagePath,
    required this.category,
    this.size = 56,
    this.radius = 12,
  });

  final String? imagePath;
  final Category category;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        color: scheme.secondaryContainer,
        child: Icon(
          category.icon,
          size: size * 0.45,
          color: scheme.onSecondaryContainer,
        ),
      ),
    );

    final path = imagePath;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: path == null
          ? placeholder
          : Image.file(
              ref.watch(garmentStoreProvider).imageFile(path),
              width: size,
              height: size,
              fit: BoxFit.cover,
              cacheWidth: (size * dpr).round(),
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}

/// A row of small swatches for a garment's colors.
class ColorDots extends StatelessWidget {
  const ColorDots({super.key, required this.colors});

  final List<String> colors;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return Semantics(
      label: colors.isEmpty ? null : 'Colors: ${colors.join(', ')}',
      child: ExcludeSemantics(
        child: Wrap(
          spacing: 4,
          children: [
            for (final name in colors)
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: garmentPalette[name] ?? Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: outline),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
