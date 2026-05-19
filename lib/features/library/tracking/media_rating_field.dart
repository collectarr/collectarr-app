import 'package:flutter/material.dart';

class MediaRatingField extends StatelessWidget {
  const MediaRatingField({
    super.key,
    required this.controller,
    this.label = 'Rating',
    this.maxRating = 10,
  });

  final TextEditingController controller;
  final String label;
  final int maxRating;

  @override
  Widget build(BuildContext context) {
    final value = int.tryParse(controller.text) ?? 0;
    final starCount = maxRating <= 5 ? maxRating : 5;
    final pointsPerStar = maxRating / starCount;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= starCount; i++)
            _StarButton(
              filled: value >= (i * pointsPerStar).round(),
              half: value >= ((i - 0.5) * pointsPerStar).round() &&
                  value < (i * pointsPerStar).round(),
              onTap: () {
                final newValue = (i * pointsPerStar).round();
                final current = int.tryParse(controller.text) ?? 0;
                controller.text =
                    (current == newValue ? 0 : newValue).toString();
                (context as Element).markNeedsBuild();
              },
            ),
          const SizedBox(width: 8),
          Text(
            '$value/$maxRating',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }
}

class _StarButton extends StatelessWidget {
  const _StarButton({
    required this.filled,
    required this.half,
    required this.onTap,
  });

  final bool filled;
  final bool half;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Icon(
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          size: 28,
          color: filled || half ? accent : muted,
        ),
      ),
    );
  }
}

class MediaRatingDisplay extends StatelessWidget {
  const MediaRatingDisplay({
    super.key,
    required this.rating,
    this.maxRating = 10,
  });

  final int rating;
  final int maxRating;

  @override
  Widget build(BuildContext context) {
    final starCount = maxRating <= 5 ? maxRating : 5;
    final pointsPerStar = maxRating / starCount;
    final accent = Theme.of(context).colorScheme.primary;
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= starCount; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Icon(
              rating >= (i * pointsPerStar).round()
                  ? Icons.star_rounded
                  : rating >= ((i - 0.5) * pointsPerStar).round()
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
              size: 18,
              color: rating >= ((i - 0.5) * pointsPerStar).round()
                  ? accent
                  : muted,
            ),
          ),
        const SizedBox(width: 4),
        Text(
          '$rating/$maxRating',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
        ),
      ],
    );
  }
}
