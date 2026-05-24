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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 220;
        final isVeryCompact = constraints.maxWidth < 150;
        final starSize = isVeryCompact ? 20.0 : isCompact ? 22.0 : 28.0;
        final starPadding = isVeryCompact ? 0.0 : isCompact ? 1.0 : 2.0;
        final ratingText = Text(
          '$value/$maxRating',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
        );

        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isCompact ? 10 : 12,
              vertical: isCompact ? 6 : 8,
            ),
          ),
          child: isVeryCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 0,
                      runSpacing: 0,
                      children: [
                        for (var i = 1; i <= starCount; i++)
                          _StarButton(
                            filled: value >= (i * pointsPerStar).round(),
                            half:
                                value >= ((i - 0.5) * pointsPerStar).round() &&
                                value < (i * pointsPerStar).round(),
                            size: starSize,
                            horizontalPadding: starPadding,
                            onTap: () {
                              final newValue = (i * pointsPerStar).round();
                              final current =
                                  int.tryParse(controller.text) ?? 0;
                              controller.text =
                                  (current == newValue ? 0 : newValue)
                                      .toString();
                              (context as Element).markNeedsBuild();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ratingText,
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 1; i <= starCount; i++)
                              _StarButton(
                                filled: value >= (i * pointsPerStar).round(),
                                half: value >=
                                        ((i - 0.5) * pointsPerStar).round() &&
                                    value < (i * pointsPerStar).round(),
                                size: starSize,
                                horizontalPadding: starPadding,
                                onTap: () {
                                  final newValue =
                                      (i * pointsPerStar).round();
                                  final current =
                                      int.tryParse(controller.text) ?? 0;
                                  controller.text =
                                      (current == newValue ? 0 : newValue)
                                          .toString();
                                  (context as Element).markNeedsBuild();
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(child: ratingText),
                  ],
                ),
        );
      },
    );
  }
}

class _StarButton extends StatelessWidget {
  const _StarButton({
    required this.filled,
    required this.half,
    required this.onTap,
    this.size = 28,
    this.horizontalPadding = 2,
  });

  final bool filled;
  final bool half;
  final VoidCallback onTap;
  final double size;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Icon(
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          size: size,
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
