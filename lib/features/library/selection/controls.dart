import 'action.dart';
import 'package:collectarr_app/features/library/actions/ui_action.dart';
import 'package:collectarr_app/features/library/workspace/config/tokens.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibrarySelectionToolbarDivider extends StatelessWidget {
  const LibrarySelectionToolbarDivider({
    super.key,
    required this.dividerLeft,
    required this.dividerRight,
    this.margin = const EdgeInsets.symmetric(horizontal: 3, vertical: 3.5),
  });

  final Color dividerLeft;
  final Color dividerRight;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      margin: margin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 1, color: dividerLeft),
          Container(width: 1, color: dividerRight),
        ],
      ),
    );
  }
}

class LibrarySelectionMoreIcon extends StatelessWidget {
  const LibrarySelectionMoreIcon({
    super.key,
    this.color = Colors.white,
    this.dotSize = 3.5,
    this.spacing = 3.5,
  });

  final Color color;
  final double dotSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: spacing),
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: spacing),
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class LibrarySelectionControls extends StatelessWidget {
  const LibrarySelectionControls(
      {super.key, required this.actions, this.onAccent = false, this.accent});
  final List<ResolvedLibrarySelectionAction> actions;
  final bool onAccent;
  final Color? accent;

  Future<void> _invoke(
      BuildContext context, ResolvedLibrarySelectionAction action) async {
    try {
      await action.invoke();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)
            ?.showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final effectiveAccent = accent ?? palette.accent;
    final dividerLeft = Color.lerp(effectiveAccent, Colors.black, 0.09)!;
    final dividerRight = Color.lerp(effectiveAccent, Colors.white, 0.11)!;

    final baseStyle = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      foregroundColor: onAccent ? Colors.white : palette.textPrimary,
      backgroundColor: onAccent
          ? Colors.transparent
          : librarySelectionToolbarSecondaryAction(context),
      overlayColor: onAccent ? Colors.white.withValues(alpha: 0.15) : null,
      padding: onAccent
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 0)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      minimumSize: onAccent ? Size.zero : null,
      tapTargetSize: onAccent ? MaterialTapTargetSize.shrinkWrap : null,
      textStyle: onAccent
          ? const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(onAccent ? 4 : 6),
        side: onAccent
            ? BorderSide.none
            : BorderSide(
                color: librarySelectionToolbarBorder(context)
                    .withValues(alpha: 0.86),
              ),
      ),
    );

    TextButton actionButton({
      required VoidCallback? onPressed,
      IconData? icon,
      required String label,
      Color? foregroundColor,
      Color? backgroundColor,
      Color? borderColor,
    }) {
      final effectiveFg = onAccent
          ? (foregroundColor ?? Colors.white)
          : (foregroundColor ?? palette.textPrimary);
      final effectiveBg = onAccent
          ? (backgroundColor ?? Colors.transparent)
          : (backgroundColor ??
              librarySelectionToolbarSecondaryAction(context));
      final effectiveBorder = onAccent
          ? (borderColor != null
              ? BorderSide(color: borderColor)
              : BorderSide.none)
          : BorderSide(
              color: borderColor ??
                  librarySelectionToolbarBorder(context)
                      .withValues(alpha: 0.86),
            );

      final iconWidget = icon != null ? Icon(icon, size: 15) : null;

      return TextButton.icon(
        onPressed: onPressed,
        icon: iconWidget,
        label: Text(label),
        style: baseStyle.copyWith(
          foregroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.disabled)
                  ? effectiveFg.withValues(alpha: 0.45)
                  : effectiveFg),
          backgroundColor: WidgetStatePropertyAll(effectiveBg),
          side: WidgetStatePropertyAll(effectiveBorder),
        ),
      );
    }

    final primary = actions
        .where((action) =>
            action.action.placement == UiActionPlacement.toolbar ||
            (!onAccent &&
                action.action.placement == UiActionPlacement.secondary))
        .toList();
    final overflow =
        actions.where((action) => !primary.contains(action)).toList();
    Widget button(ResolvedLibrarySelectionAction action) {
      final control = actionButton(
          onPressed: action.enabled ? () => _invoke(context, action) : null,
          icon: action.action.icon,
          label: action.action.label);
      return !action.enabled && action.action.unavailableMessage != null
          ? Tooltip(message: action.action.unavailableMessage!, child: control)
          : control;
    }

    Widget menuContent(ResolvedLibrarySelectionAction action) {
      final content = onAccent
          ? Row(children: [
              Icon(action.action.icon,
                  size: 15,
                  color: onAccent
                      ? Colors.white.withValues(alpha: action.enabled ? 1 : .38)
                      : null),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(action.action.label,
                      style: onAccent
                          ? TextStyle(
                              fontSize: 13,
                              color: Colors.white
                                  .withValues(alpha: action.enabled ? 1 : .38))
                          : null))
            ])
          : Material(
              type: MaterialType.transparency,
              child: ListTile(
                  leading: Icon(action.action.icon),
                  title: Text(action.action.label),
                  dense: true));
      return !action.enabled && action.action.unavailableMessage != null
          ? Tooltip(message: action.action.unavailableMessage!, child: content)
          : content;
    }

    final more = PopupMenuButton<ResolvedLibrarySelectionAction>(
      key: const ValueKey('library-selection-more-button'),
      tooltip: 'More selection actions',
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 340),
      popUpAnimationStyle: AnimationStyle.noAnimation,
      position: onAccent ? PopupMenuPosition.under : PopupMenuPosition.over,
      color: onAccent
          ? const Color(0xFF333333)
          : librarySelectionToolbarSecondaryAction(context),
      surfaceTintColor: Colors.transparent,
      style: ButtonStyle(
          padding:
              const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 6)),
          minimumSize: const WidgetStatePropertyAll(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      icon: onAccent
          ? const LibrarySelectionMoreIcon()
          : const Icon(Icons.more_horiz, size: 18),
      onSelected: (action) => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) _invoke(context, action);
      }),
      itemBuilder: (_) => [
        for (var index = 0; index < overflow.length; index++) ...[
          if (index > 0 &&
              overflow[index].action.category !=
                  overflow[index - 1].action.category)
            PopupMenuDivider(height: onAccent ? 7 : 16),
          PopupMenuItem(
            value: overflow[index],
            enabled: overflow[index].enabled,
            height: onAccent ? 28 : 48,
            child: menuContent(overflow[index]),
          ),
        ],
      ],
    );
    if (onAccent) {
      return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < primary.length; index++) ...[
              if (index > 1)
                LibrarySelectionToolbarDivider(
                    dividerLeft: dividerLeft, dividerRight: dividerRight),
              button(primary[index]),
            ],
            if (overflow.isNotEmpty) ...[
              LibrarySelectionToolbarDivider(
                  dividerLeft: dividerLeft, dividerRight: dividerRight),
              more
            ],
          ]);
    }
    return Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final action in primary) button(action),
          if (overflow.isNotEmpty) more
        ]);
  }
}
