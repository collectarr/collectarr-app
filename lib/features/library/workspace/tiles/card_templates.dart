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
