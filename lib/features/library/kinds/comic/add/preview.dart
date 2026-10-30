import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_character.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_creator.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_issue_label.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The issue in the Add dialog's confirm sheet, as the reference shows it:
/// the cover beside series, issue box, variant, barcode, dates, price and
/// key, then creators by role beside the characters.
Widget buildComicAddPreviewPane(
  BuildContext context,
  LibraryAddPreviewPaneRequest request,
) {
  final item = request.item;
  if (item == null) return const SizedBox.shrink();
  final fields = item.comicCatalogFields;
  final comic = fields.metadata;
  final palette = appPalette(context);
  const bold = TextStyle(fontWeight: FontWeight.w700);
  final issue = comicIssueText(comic?.issueNumber, comic?.variant);
  final series = comic?.seriesTitle?.trim() ?? '';
  final variant = comic?.variantDescription?.trim() ?? '';
  final barcode = comic?.barcode?.trim() ?? '';
  final release = _date(comic?.releaseDateParts, comic?.releaseDate);
  final cover = _date(comic?.coverDateParts, comic?.coverDate);
  final price = comic?.coverPriceCents == null
      ? ''
      : AppFormats.current.formatMoney(comic!.coverPriceCents, comic.currency);
  final key = comic?.keyReason?.trim() ?? '';
  final roles = _creatorsByRole(comic);
  final characters = [
    for (final character in comic?.characters ?? const <ComicCharacter>[])
      if (character.name?.trim() case final name? when name.isNotEmpty)
        character.realName?.trim().isNotEmpty == true
            ? '$name (${character.realName!.trim()})'
            : name,
  ];
  Widget dated(String label, String value) => Row(children: [
        SizedBox(width: 59, child: Text('$label:')),
        Expanded(child: Text(value)),
      ]);
  return DefaultTextStyle.merge(
    style: TextStyle(fontSize: 14, height: 20 / 14, color: palette.textPrimary),
    child: SingleChildScrollView(
      key: const ValueKey('comic-add-preview'),
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 210,
                child: Center(
                  child: SizedBox(
                    width: 137,
                    height: 210,
                    child: LibraryInteractiveCover(
                      title: item.summary.primaryLabel,
                      imageUrl: fields.coverImageUrl,
                      accentColor: request.accent,
                      fallbackAspectRatio: 137 / 210,
                      borderRadius: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            series.isEmpty ? fields.title : series,
                            style: const TextStyle(
                                fontSize: 24,
                                height: 26 / 24,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (issue != null) _IssueBox('#$issue'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (comic?.publisher?.trim() case final publisher?
                        when publisher.isNotEmpty)
                      Text(publisher, style: bold),
                    if (variant.isNotEmpty) Text(variant, style: bold),
                    if (barcode.isNotEmpty) Text(barcode),
                    if (release.isNotEmpty) dated('Release', release),
                    if (cover.isNotEmpty) dated('Cover', cover),
                    if (price.isNotEmpty) Text(price),
                    if (key.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2, right: 6),
                            child: Icon(AppIcons.key,
                                size: 14, color: palette.utilityAction),
                          ),
                          Expanded(child: Text(key, style: bold)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (roles.isNotEmpty || characters.isNotEmpty) ...[
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final MapEntry(key: role, value: names)
                          in roles.entries) ...[
                        Text(role, style: bold),
                        for (final name in names) Text(name),
                        const SizedBox(height: 5),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (characters.isNotEmpty)
                        const Text('Characters', style: bold),
                      for (final name in characters)
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text('•  $name'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (request.isFetchingPreview)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text('Fetching full metadata...',
                  style: TextStyle(color: palette.textMuted)),
            ),
        ],
      ),
    ),
  );
}

/// The reference's outlined "#1A" box beside the series title.
class _IssueBox extends StatelessWidget {
  const _IssueBox(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = appPalette(context).textPrimary;
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    );
  }
}

Map<String, List<String>> _creatorsByRole(ComicCatalogItem? comic) {
  final roles = <String, List<String>>{};
  for (final creator in comic?.creators ?? const <ComicCreator>[]) {
    final name = creator.name?.trim() ?? '';
    if (name.isEmpty) continue;
    final role = creator.role?.trim() ?? '';
    (roles[role.isEmpty ? 'Creator' : role] ??= []).add(name);
  }
  return roles;
}

String _date(PartialDate? parts, DateTime? date) {
  final value = parts ?? (date == null ? null : PartialDate.fromDateTime(date));
  return value == null ? '' : AppFormats.current.formatPartialDate(value);
}
