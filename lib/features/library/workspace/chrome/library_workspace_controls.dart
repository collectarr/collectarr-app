import 'package:flutter/material.dart';

import '../config/library_workspace_tokens.dart';

BoxDecoration libraryToolbarDropdownDecoration(
  BuildContext context, {
  Color? backgroundColor,
  Color? borderColor,
}) {
  return BoxDecoration(
    color: backgroundColor ?? libraryToolbarControlSurface(context),
    border: Border.all(
      color: borderColor ?? libraryToolbarControlBorder(context),
    ),
  );
}

class LibraryToolbarCompactDropdownTrigger extends StatefulWidget {
  const LibraryToolbarCompactDropdownTrigger({
    super.key,
    required this.icon,
    this.iconColor,
    this.arrowColor,
  });

  final IconData icon;
  final Color? iconColor;
  final Color? arrowColor;

  @override
  State<LibraryToolbarCompactDropdownTrigger> createState() =>
      _LibraryToolbarCompactDropdownTriggerState();
}

class _LibraryToolbarCompactDropdownTriggerState
    extends State<LibraryToolbarCompactDropdownTrigger> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: DecoratedBox(
        decoration: libraryToolbarDropdownDecoration(
          context,
          backgroundColor: _hovered
              ? libraryToolbarControlHover(context)
              : null,
        ),
        child: SizedBox(
          width: kLibraryToolbarCompactDropdownWidth,
          height: kLibraryToolbarCompactDropdownSize,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 17,
                color: widget.iconColor ?? libraryToolbarControlText(context),
              ),
              const SizedBox(width: 1),
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: widget.arrowColor ??
                    libraryToolbarControlMutedText(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LibraryToolbarFrame extends StatelessWidget {
  const LibraryToolbarFrame({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.dividerColor,
  });

  final Widget child;
  final Color backgroundColor;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: child,
    );
  }
}

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
    return DecoratedBox(
      decoration: libraryToolbarDropdownDecoration(context),
      child: SizedBox.square(
        dimension: dimension,
        child: IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            hoverColor: libraryToolbarControlHover(context),
            highlightColor: Colors.transparent,
          ),
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: iconSize,
            color: libraryToolbarControlText(context),
          ),
        ),
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

class LibraryWorkspaceControlStrip extends StatelessWidget {
  const LibraryWorkspaceControlStrip({
    super.key,
    required this.children,
    this.spacing = 6,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _spacedChildren(),
          ),
        ),
      ),
    );
  }

  List<Widget> _spacedChildren() {
    final spaced = <Widget>[];
    for (var index = 0; index < children.length; index += 1) {
      if (index > 0) {
        spaced.add(SizedBox(width: spacing));
      }
      spaced.add(children[index]);
    }
    return spaced;
  }
}
