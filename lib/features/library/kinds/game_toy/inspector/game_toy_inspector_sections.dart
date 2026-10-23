import '../domain/game_toy_metadata.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../workspace/game_toy_workspace_dto.dart';
import '../domain/game_toy_personal_data.dart';

String? gameToyValueSummary(GameToyPersonalData personal) {
  final values = [
    if (personal.details.completeness.label case final label) label,
    if (personal.marketValueCents != null)
      AppFormats.current.formatMoney(personal.marketValueCents,
          personal.currency ?? AppFormats.current.currency)
  ];
  return values.isEmpty ? null : values.join(' | ');
}

Widget buildGameToyInspectorHero(
    BuildContext context, LibraryInspectorRequest request) {
  final dto = request.item.dto as GameToyWorkspaceDto;
  final metadata = dto.metadata;
  final entry = dto.entry;
  final palette = appPalette(context);
  final personal = entry?.personal;
  final value = personal == null ? null : gameToyValueSummary(personal);
  final includes = personal == null
      ? null
      : personal.details.hasBox == true
          ? 'Includes box'
          : null;
  final status = libraryCollectionStatusFromValue(
      personal?.collectionStatus ?? 'In Collection');
  return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (metadata.seriesTitle?.isNotEmpty == true)
          Text(metadata.seriesTitle!,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: kAppBoldFontWeight,
                  color: palette.textPrimary)),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Text(metadata.title,
                  style: TextStyle(
                      fontSize: 24,
                      height: 27 / 24,
                      fontWeight: kAppBoldFontWeight,
                      color: palette.itemTitle))),
          if (entry != null)
            Tooltip(
                message: status.label,
                child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        color: status.color,
                        borderRadius: BorderRadius.circular(3)),
                    child: Icon(status.icon, color: Colors.white, size: 18)))
        ]),
        const SizedBox(height: 8),
        ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 210, maxHeight: 300),
            child: LibraryCoverImage(
                title: metadata.title,
                imageUrl: metadata.coverImageUrl,
                libraryEntryRef: entry == null
                    ? null
                    : LibraryEntryRef(
                        kind: CatalogMediaKind.gameToy, id: entry.id),
                fallbackAspectRatio: 0.7,
                borderRadius: 0)),
        const SizedBox(height: 12),
        Text(metadata.releaseDateParts?.year?.toString() ?? '',
            style: TextStyle(
                fontSize: 15,
                fontWeight: kAppBoldFontWeight,
                color: palette.textPrimary)),
        if (metadata.toyType?.isNotEmpty == true) Text(metadata.toyType!),
        if (metadata.toySubtype?.isNotEmpty == true) Text(metadata.toySubtype!),
        if (value != null)
          Container(
              width: 220,
              margin: const EdgeInsets.only(top: 18),
              decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF0082A6), width: 2),
                  borderRadius: BorderRadius.circular(6)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        color: const Color(0xFF0082A6),
                        padding: const EdgeInsets.all(6),
                        alignment: Alignment.center,
                        child: Text(value,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: kAppBoldFontWeight))),
                    if (includes != null)
                      Container(
                          color: const Color(0xFFB1D8EA),
                          padding: const EdgeInsets.all(3),
                          alignment: Alignment.center,
                          child: Text(includes,
                              style: const TextStyle(
                                  color: Color(0xFF333333), fontSize: 14)))
                  ])),
      ]));
}

List<Widget> buildGameToyInspectorSections(
    BuildContext context, LibraryInspectorRequest request) {
  final dto = request.item.dto as GameToyWorkspaceDto;
  final metadata = dto.metadata;
  final entry = dto.entry;
  Widget links(Iterable<GameToyCatalogLink> values) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final link in values)
          InkWell(
              onTap: () => launchUrl(Uri.parse(link.url)),
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(link.title ?? link.url,
                      style: TextStyle(
                          fontSize: 14, color: appPalette(context).link))))
      ]);
  Widget section(String title, Widget child) =>
      LibraryDetailSection(title: title, collapsible: false, children: [child]);
  return [
    if (metadata.description?.isNotEmpty == true)
      section(
          'Description',
          Text(metadata.description!,
              style: TextStyle(
                  fontSize: 14, color: appPalette(context).textPrimary))),
    if (metadata.links.any((link) => link.isTrailerLink))
      section(
          'Trailer', links(metadata.links.where((link) => link.isTrailerLink))),
    if (metadata.links.any((link) => link.isExternalLink))
      section(
          'Links', links(metadata.links.where((link) => link.isExternalLink))),
    if (entry != null)
      section(
          'Personal',
          LibraryDetailFieldTable(
              minCellWidth: 320,
              labelWidth: 132,
              showHeader: false,
              fields: [
                LibraryDetailField(
                    label: 'Value',
                    value: entry.personal.marketValueCents == null
                        ? '-'
                        : AppFormats.current.formatMoney(
                            entry.personal.marketValueCents,
                            entry.personal.currency ??
                                AppFormats.current.currency)),
                LibraryDetailField(
                    label: 'Index',
                    value: entry.personal.indexNumber?.toString() ?? '-'),
                if (entry.personal.ownerLabel case final owner?)
                  LibraryDetailField(label: 'Owner', value: owner),
                if (entry.personal.rating case final rating?)
                  LibraryDetailField(label: 'My Rating', value: '$rating/10'),
                if (entry.createdAt case final added?)
                  LibraryDetailField(
                      label: 'Added Date',
                      value: AppFormats.current.formatDateTime(added)),
                LibraryDetailField(
                    label: 'Modified Date',
                    value: AppFormats.current.formatDateTime(entry.updatedAt)),
                if (entry.personal.personalNotes case final notes?)
                  LibraryDetailField(label: 'Notes', value: notes),
              ])),
  ];
}
