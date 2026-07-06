import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryDetailSection extends StatefulWidget {
  const LibraryDetailSection({
    super.key,
    required this.title,
    this.subtitle,
    this.fields = const [],
    this.chips = const [],
    this.children = const [],
    this.collapsible = true,
    this.initiallyExpanded = true,
    this.accentColor,
  });

  factory LibraryDetailSection.fromSpec(
    LibraryDetailSectionSpec spec, {
    Color? accentColor,
  }) {
    return LibraryDetailSection(
      title: spec.title,
      subtitle: spec.subtitle,
      fields: spec.fields,
      chips: spec.chips,
      collapsible: true,
      initiallyExpanded: spec.initiallyExpanded,
      accentColor: accentColor,
      children: spec.children,
    );
  }

  final String title;
  final String? subtitle;
  final List<LibraryDetailField> fields;
  final List<LibraryDetailChipGroup> chips;
  final List<Widget> children;
  final bool collapsible;
  final bool initiallyExpanded;
  final Color? accentColor;

  @override
  State<LibraryDetailSection> createState() => _LibraryDetailSectionState();
}

class _LibraryDetailSectionState extends State<LibraryDetailSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = widget.accentColor ?? LibraryAccentScope.accentOf(context);
    final body = <Widget>[];
    if (widget.fields.isNotEmpty) {
      body.add(LibraryDetailFieldTable(fields: widget.fields));
    }
    for (final chipGroup in widget.chips) {
      if (body.isNotEmpty) {
        body.add(const SizedBox(height: 8));
      }
      body.add(
        LibraryDetailChipGroupWidget(
          label: chipGroup.label,
          values: chipGroup.values,
          onValueTap: chipGroup.onValueTap,
        ),
      );
    }
    for (final child in widget.children) {
      if (body.isNotEmpty) {
        body.add(const SizedBox(height: 8));
      }
      body.add(child);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: palette.divider.withValues(alpha: 0.78)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: widget.collapsible ? () => setState(() => _expanded = !_expanded) : null,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: accent.withValues(alpha: 0.18)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: palette.textMuted,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      letterSpacing: 0.35,
                                    ),
                              ),
                              if (widget.subtitle != null &&
                                  widget.subtitle!.trim().isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.subtitle!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: palette.textMuted,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (widget.collapsible)
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_right,
                            size: 16,
                            color: palette.textMuted,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: body,
                  ),
                ),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
