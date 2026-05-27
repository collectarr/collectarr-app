import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A shimmer skeleton placeholder shown while library content is loading.
/// Displays a grid of pulsing rounded rectangles that hint at the layout shape.
class SkeletonGrid extends StatefulWidget {
  const SkeletonGrid({super.key});

  @override
  State<SkeletonGrid> createState() => _SkeletonGridState();
}

class _SkeletonGridState extends State<SkeletonGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.04, end: 0.10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const tileWidth = 160.0;
        const tileHeight = 240.0;
        const spacing = 10.0;
        final crossAxisCount =
            ((constraints.maxWidth + spacing) / (tileWidth + spacing))
                .floor()
                .clamp(1, 10);
        const rowCount = 3;
        return Padding(
          padding: const EdgeInsets.all(10),
          child: AnimatedBuilder(
            animation: _opacity,
            builder: (context, _) {
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: List.generate(crossAxisCount * rowCount, (_) {
                  return SizedBox(
                    width: (constraints.maxWidth -
                            20 -
                            ((crossAxisCount - 1) * spacing)) /
                        crossAxisCount,
                    height: tileHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: _opacity.value),
                        borderRadius: kAppRadiusSmall,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        );
      },
    );
  }
}
