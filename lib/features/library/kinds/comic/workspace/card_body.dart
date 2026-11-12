import 'package:collectarr_app/features/library/workspace/tiles/card_templates.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/card_geometry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/card_presentation.dart';
import 'package:collectarr_app/features/library/workspace/tiles/outlined_pill.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';

class ComicCardFields {
  const ComicCardFields(
      {this.headline, this.numberLabel, this.date, this.pill});
  final String? headline;
  final String? numberLabel;
  final String? date;
  final LibraryCardPill? pill;
}

Widget buildComicHorizontalCardBody(BuildContext context,
        LibraryCardBodyData data, ComicCardFields fields) =>
    LibraryHorizontalCardLayout(
      data: data,
      details: _SplitMetadataHorizontalBody(
          item: data.item,
          status: data.pillStatus,
          presentation: data.presentation,
          selected: data.selected,
          fields: fields),
    );

Widget buildComicVerticalCardBody(BuildContext context,
        LibraryCardBodyData data, ComicCardFields fields) =>
    _HeadlinedVerticalCardBody(
        item: data.item,
        status: data.coverStatus,
        showHeadline: data.showHeadline,
        selected: data.selected,
        titleColor: data.titleColor,
        detailColor: data.detailColor,
        mutedColor: data.mutedColor,
        customFieldBadges: data.customFieldBadges,
        buildCover: data.buildCover,
        fields: fields);

class _SplitMetadataHorizontalBody extends StatelessWidget {
  const _SplitMetadataHorizontalBody({
    required this.item,
    required this.status,
    required this.presentation,
    required this.selected,
    required this.fields,
  });

  final Widget status;
  final LibraryProjectionView item;
  final LibraryCardPresentation presentation;
  final bool selected;
  final ComicCardFields fields;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final foreground = selected ? Colors.white : palette.textPrimary;
    return Stack(children: [
      Positioned(
        top: 0,
        left: 0,
        right: 58,
        child: Text(fields.headline ?? item.dto.primaryLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: selected ? Colors.white : palette.itemTitle,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      ),
      if (fields.numberLabel case final number?)
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: palette.utilityAction,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      if (fields.date case final date?)
        Positioned(
          right: 0,
          top: 28,
          child: Text(date, style: TextStyle(color: foreground, fontSize: 12)),
        ),
      if (fields.pill != null || presentation.compactBadges.isNotEmpty)
        Positioned(
          bottom: 0,
          left: 0,
          right: 32,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (fields.pill case final pill?)
              Flexible(
                  child: LibraryOutlinedPill(
                      pill: pill,
                      color: selected ? Colors.white : palette.utilityAction)),
            for (final badge in presentation.compactBadges)
              if (badge.icon case final icon?)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Tooltip(
                      message: badge.label,
                      child: Icon(icon, size: 16, color: foreground)),
                ),
          ]),
        ),
      Positioned(
        right: 0,
        bottom: 0,
        child: status,
      ),
    ]);
  }
}

class _HeadlinedVerticalCardBody extends StatelessWidget {
  const _HeadlinedVerticalCardBody({
    required this.item,
    required this.status,
    required this.showHeadline,
    required this.selected,
    required this.titleColor,
    required this.detailColor,
    required this.mutedColor,
    required this.customFieldBadges,
    required this.buildCover,
    required this.fields,
  });

  final Widget status;
  final LibraryProjectionView item;
  final bool showHeadline;
  final bool selected;
  final Color titleColor;
  final Color detailColor;
  final Color mutedColor;
  final List<String> customFieldBadges;
  final Widget Function({required Alignment alignment}) buildCover;
  final ComicCardFields fields;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeadline)
          _HeadlinedCardTitle(
            text: fields.headline ?? item.dto.primaryLabel,
            color: titleColor,
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(5),
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
        _HeadlinedCardFooter(
          fields: fields,
          numberColor: titleColor,
          dateColor: detailColor,
          pillColor: selected ? Colors.white : palette.utilityAction,
        ),
      ],
    );
  }
}

class _HeadlinedCardTitle extends StatelessWidget {
  const _HeadlinedCardTitle({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
      constraints:
          const BoxConstraints(minHeight: 22, maxHeight: comicCardTitleHeight),
      child: SizedBox(
          width: double.infinity,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 3, 5, 0),
              child: Text(text,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 18.5714 / 13)))));
}

/// A large number with the date at the right, then an outlined pill row.
class _HeadlinedCardFooter extends StatelessWidget {
  const _HeadlinedCardFooter(
      {required this.fields,
      required this.numberColor,
      required this.dateColor,
      required this.pillColor});
  final ComicCardFields fields;
  final Color numberColor;
  final Color dateColor;
  final Color pillColor;

  @override
  Widget build(BuildContext context) {
    final pill = fields.pill;
    return SizedBox(
        height: comicCardFooterHeight,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                  height: 24,
                  child: Row(children: [
                    Expanded(
                        child: Text(fields.numberLabel ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: numberColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                height: 24 / 18))),
                    if (fields.date case final date?)
                      Text(date,
                          style: TextStyle(
                              color: dateColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                  ])),
              if (pill != null)
                Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: LibraryOutlinedPill(pill: pill, color: pillColor)),
            ])));
  }
}
