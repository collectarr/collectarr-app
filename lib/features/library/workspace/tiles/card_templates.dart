import 'package:collectarr_app/features/library/workspace/config/tokens.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'card_presentation.dart';
import 'card_footer.dart';

/// A reusable layout explicitly selected by the owning kind.
Widget buildStandardHorizontalCardBody(
    BuildContext context, LibraryCardBodyData data) {
  final palette = appPalette(context);
  final item = data.item;
  final presentation = data.presentation;
  final selected = data.selected;
  final coverWidth = data.coverWidth;
  final customFieldBadges = data.customFieldBadges;
  return Row(children: [
    ConstrainedBox(
        constraints: BoxConstraints(maxWidth: coverWidth),
        child: data.buildCover(alignment: Alignment.center)),
    const SizedBox(width: 5),
    Expanded(
        child: Stack(children: [
      // Title, series and badges may exceed a short
      // card; they clip rather than overflow.
      Positioned.fill(
          bottom: 26,
          child: ClipRect(
              child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxHeight: double.infinity,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Text(item.dto.primaryLabel,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          height: 1.15,
                                          color: selected
                                              ? Colors.white
                                              : palette.itemTitle))),
                              if (presentation.compactBadges.isNotEmpty)
                                Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          for (final badge
                                              in presentation.compactBadges)
                                            Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (badge.icon != null) ...[
                                                    Icon(badge.icon,
                                                        size: 12,
                                                        color: selected
                                                            ? Colors.white
                                                            : palette
                                                                .textPrimary),
                                                    const SizedBox(width: 2),
                                                  ],
                                                  Text(badge.label,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: badge
                                                                      .icon ==
                                                                  null
                                                              ? FontWeight.w400
                                                              : FontWeight.w700,
                                                          color: selected
                                                              ? Colors.white
                                                              : palette
                                                                  .textPrimary)),
                                                ]),
                                        ])),
                            ]),
                        if (presentation.detailLine?.isNotEmpty == true)
                          Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: Text(presentation.detailLine!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: selected
                                          ? Colors.white
                                          : palette.textMuted))),
                        if (presentation.seriesTitle?.isNotEmpty == true)
                          Text(presentation.seriesTitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? Colors.white
                                      : palette.textPrimary)),
                        if (customFieldBadges.isNotEmpty)
                          Text(customFieldBadges.join(' | '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: selected
                                      ? Colors.white
                                      : palette.textMuted)),
                      ])))),
      Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: LibraryCardFooter(
              label: [
                presentation.format,
                presentation.releaseDate?.year.toString()
              ].whereType<String>().join(' \u2013 '),
              value: presentation.valueLabel,
              status: data.pillStatus,
              selected: selected)),
    ])),
  ]);
}

Widget buildStandardVerticalCardBody(
        BuildContext context, LibraryCardBodyData data) =>
    _StandardVerticalCardBody(
      item: data.item,
      status: data.coverStatus,
      presentation: data.presentation,
      selected: data.selected,
      titleColor: data.titleColor,
      detailColor: data.detailColor,
      mutedColor: data.mutedColor,
      customFieldBadges: data.customFieldBadges,
      buildCover: data.buildCover,
    );

class _StandardVerticalCardBody extends StatelessWidget {
  const _StandardVerticalCardBody({
    required this.item,
    required this.status,
    required this.presentation,
    required this.selected,
    required this.titleColor,
    required this.detailColor,
    required this.mutedColor,
    required this.customFieldBadges,
    required this.buildCover,
  });

  final Widget status;
  final LibraryProjectionView item;
  final LibraryCardPresentation presentation;
  final bool selected;
  final Color titleColor;
  final Color detailColor;
  final Color mutedColor;
  final List<String> customFieldBadges;
  final Widget Function({required Alignment alignment}) buildCover;

  @override
  Widget build(BuildContext context) {
    final subtitle = presentation.verticalSubtitle;
    final trailingText = presentation.verticalTrailing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                buildCover(alignment: Alignment.topCenter),
                Positioned(
                  left: 5,
                  bottom: 5,
                  child: status,
                ),
                if (customFieldBadges.isNotEmpty)
                  Text(
                    customFieldBadges.join(' | '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white : mutedColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
          child: SizedBox(
            height: 57,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.dto.primaryLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (subtitle != null && subtitle.isNotEmpty)
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: presentation.verticalSubtitleEmphasized
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: detailColor,
                          ),
                        ),
                      ),
                    if (trailingText != null && trailingText.isNotEmpty)
                      Text(
                        trailingText,
                        style: TextStyle(
                          fontSize: 12,
                          color: detailColor,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget buildStandardCoverContent(
        BuildContext context, LibraryCardBodyData data) =>
    data.buildCover(alignment: Alignment.center);
Widget buildStandardShelfContent(
        BuildContext context, LibraryCardBodyData data) =>
    data.buildCover(alignment: Alignment.center);

Widget buildStandardFlowContent(
    BuildContext context, LibraryCardBodyData data) {
  final title = data.item.dto.primaryLabel;
  final subtitle = data.presentation.flowSubtitle ?? '';
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      data.buildCover(alignment: Alignment.center),
      const SizedBox(height: 14),
      Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: kLibraryCardTitleColor,
              height: 1.2,
            ),
      ),
      if (subtitle.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: appPalette(context).textMuted,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    ],
  );
}

Widget buildStandardFlowFooter(BuildContext context, LibraryFlowFooterData data,
    {required String title, required String meta, String? numberLabel}) {
  final palette = appPalette(context);
  return DecoratedBox(
    decoration: BoxDecoration(
      color: palette.panel,
      borderRadius: kAppRadiusLarge,
      border: Border.all(color: palette.cardBorder),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.index + 1} / ${data.total}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: data.accent,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      key: const ValueKey('flow-carousel-footer-title'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: kLibraryCardTitleColor,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        meta,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: appPalette(context).textMuted,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (numberLabel != null && numberLabel.trim().isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: data.accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border:
                        Border.all(color: data.accent.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    numberLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

String? libraryFlowDate(DateTime? date) => date == null
    ? null
    : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
