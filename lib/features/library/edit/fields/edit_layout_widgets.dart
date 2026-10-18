import 'package:collectarr_app/features/library/ui/library_form_layout.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_responsive_field_layout.dart';
import 'package:collectarr_app/features/library/ui/library_section_state_message.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_summary_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';

// Tabs, sections and responsive field rows of library edit dialogs.

class EditTabShell extends StatelessWidget {
  const EditTabShell({
    super.key,
    required this.children,
    this.cover,
    this.scrollable = true,
  });

  final List<Widget> children;
  final Widget? cover;

  /// Set false when this shell is embedded inside a parent-owned scroll view.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final palette = appPalette(context);
        final content = Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
        final scrollContent = DecoratedBox(
          decoration: BoxDecoration(
            color: palette.panelRaised,
          ),
          child: scrollable
              ? SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(15, 16, 15, 16),
                  child: content,
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(15, 16, 15, 16),
                  child: content,
                ),
        );
        if (cover == null || constraints.maxWidth < 720) {
          return scrollContent;
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 188,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              decoration: BoxDecoration(
                color: appPalette(context).surface,
                border: Border(
                    right: BorderSide(color: appPalette(context).divider)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(aspectRatio: 2 / 3, child: cover!),
                    ),
                  ),
                  if (constraints.maxHeight >= 430) ...[
                    const SizedBox(height: 8),
                    const EditMiniBadge('Local item'),
                    const SizedBox(height: 6),
                    Text(
                      'Personal fields stay on this device or your sync service.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appPalette(context).textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: scrollContent,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Section card (accent left border)
// ---------------------------------------------------------------------------

class EditSection extends StatelessWidget {
  const EditSection({
    super.key,
    required this.title,
    required this.child,
    this.accent = kEditAccent,
  });

  final String title;
  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: child,
    );
  }
}

class EditSectionStateMessage extends LibrarySectionStateMessage {
  const EditSectionStateMessage({
    super.key,
    required super.message,
    super.icon,
  });
}

class EditSectionLoadingState extends StatelessWidget {
  const EditSectionLoadingState({
    super.key,
    this.message = 'Loading…',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.72),
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            const SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab label with icon
// ---------------------------------------------------------------------------

class EditTab extends StatelessWidget {
  const EditTab({
    super.key,
    this.icon,
    this.svgAsset,
    required this.label,
  }) : assert(icon != null || svgAsset != null,
            'Either icon or svgAsset must be provided.');

  final IconData? icon;
  final String? svgAsset;
  final String label;

  @override
  Widget build(BuildContext context) {
    final iconWidget = svgAsset != null
        ? Builder(
            builder: (context) {
              final iconTheme = IconTheme.of(context);
              return SvgPicture.asset(
                svgAsset!,
                width: iconTheme.size ?? 14,
                height: iconTheme.size ?? 14,
                colorFilter: iconTheme.color != null
                    ? ColorFilter.mode(iconTheme.color!, BlendMode.srcIn)
                    : null,
              );
            },
          )
        : Icon(icon, size: 14);

    // A fixed-width icon box, as in the reference tabs: wide glyphs such as
    // the people icon no longer run into their label.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 18, child: Center(child: iconWidget)),
        const SizedBox(width: 3),
        Text(label),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared single-line text field primitive
// ---------------------------------------------------------------------------

/// A responsive form row that stacks its [children] on narrow layouts and uses
/// equal-width columns above [breakpoint]. Geometry is shared with schema forms.
class LibraryEditResponsiveRow extends StatelessWidget {
  const LibraryEditResponsiveRow({
    super.key,
    required this.children,
    this.breakpoint = 620,
  });

  final List<Widget> children;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LibraryResponsiveFieldLayout(
      maxColumns: children.length,
      columnBreakpoints: {
        if (children.length > 1) children.length: breakpoint,
      },
      spacing: 10,
      runSpacing: 10,
      children: children,
    );
  }
}

/// A responsive dense grid of form fields laid out with a [Wrap] so ragged
/// trailing rows stay left-aligned at a fixed column width. Column counts and
/// their breakpoints are configurable so each kind keeps its own density while
/// sharing this single mechanism.
class LibraryEditDenseFields extends StatelessWidget {
  const LibraryEditDenseFields({
    super.key,
    required this.children,
    this.wideColumns = 2,
    this.ultraWideColumns = 3,
    this.wideBreakpoint = kLibraryFormTwoColumnMinWidth,
    this.ultraWideBreakpoint = kLibraryFormThreeColumnMinWidth,
    this.spacing = 10,
  });

  final List<Widget> children;
  final int wideColumns;
  final int ultraWideColumns;
  final double wideBreakpoint;
  final double ultraWideBreakpoint;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LibraryResponsiveFieldLayout(
      maxColumns: ultraWideColumns,
      columnBreakpoints: {
        if (wideColumns > 1) wideColumns: wideBreakpoint,
        if (ultraWideColumns > wideColumns)
          ultraWideColumns: ultraWideBreakpoint,
      },
      spacing: spacing,
      runSpacing: spacing,
      children: children,
    );
  }
}

// ---------------------------------------------------------------------------
// Small badge pill
// ---------------------------------------------------------------------------
