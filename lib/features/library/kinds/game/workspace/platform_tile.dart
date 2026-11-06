import 'package:collectarr_app/features/library/ui/primitives/platform_icon.dart';
import 'package:flutter/material.dart';

/// A platform's logo on the reference's white rounded tile, which keeps dark
/// logos legible on every card and selection color.
class GamePlatformTile extends StatelessWidget {
  const GamePlatformTile(this.platform, {super.key, this.size = 22});

  final String platform;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * 0.18),
        ),
        child: PlatformIcon(platform,
            size: size * 0.86, color: const Color(0xff222222)),
      );
}
