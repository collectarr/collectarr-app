import 'package:flutter/material.dart';

class LibraryWorkspaceIconButton extends StatelessWidget {
  const LibraryWorkspaceIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.dimension = 30,
    this.iconSize = 17,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double dimension;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
      child: IconButton.filledTonal(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, size: iconSize),
      ),
    );
  }
}

class LibraryWorkspaceSeparator extends StatelessWidget {
  const LibraryWorkspaceSeparator({
    super.key,
    required this.color,
    this.horizontalPadding = 7,
    this.height = 24,
  });

  final Color color;
  final double horizontalPadding;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SizedBox(
        height: height,
        child: VerticalDivider(width: 1, thickness: 1, color: color),
      ),
    );
  }
}
