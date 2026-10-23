import '../domain/game_hardware_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_platform_icon.dart';
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
import '../workspace/game_hardware_workspace_dto.dart';
import '../domain/game_hardware_personal_data.dart';

String? gameHardwareValueSummary(GameHardwarePersonalData personal) {
  final values = [
    if (personal.details.completeness?.label case final label?) label,
    if (personal.marketValueCents != null)
      AppFormats.current.formatMoney(personal.marketValueCents,
          personal.currency ?? AppFormats.current.currency)
  ];
  return values.isEmpty ? null : values.join(' | ');
}

Widget buildGameHardwareInspectorHero(
    BuildContext context, LibraryInspectorRequest request) {
  final dto = request.item.dto as GameHardwareWorkspaceDto;
  final metadata = dto.metadata;
  final entry = dto.entry;
  final palette = appPalette(context);
  final personal = entry?.personal;
  final value = personal == null ? null : gameHardwareValueSummary(personal);
  final includes = personal == null
      ? null
      : personal.details.hasBox == true && personal.details.hasManual == true
          ? 'Includes box & manual'
          : personal.details.hasBox == true
              ? 'Includes box'
              : personal.details.hasManual == true
                  ? 'Includes manual'
                  : null;
  final status = libraryCollectionStatusFromValue(
      personal?.collectionStatus ?? 'In Collection');
  return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (metadata.seriesTitle?.isNotEmpty == true)
          Text(metadata.seriesTitle!,
              style: TextStyle(color: palette.textPrimary)),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Text(metadata.title,
                  style: TextStyle(
                      fontSize: 24,
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
                        kind: CatalogMediaKind.gameHardware, id: entry.id),
                fallbackAspectRatio: 0.7,
                borderRadius: 0)),
        const SizedBox(height: 12),
        Wrap(
            spacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (metadata.platform?.isNotEmpty == true) ...[
                Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(resolveGamePlatformIcon(metadata.platform!),
                        size: 24, color: palette.textPrimary)),
                Text(metadata.platform!,
                    style: TextStyle(
                        fontWeight: kAppBoldFontWeight,
                        color: palette.textPrimary)),
              ],
              if (metadata.releaseDateParts?.year case final year?)
                Text(
                    metadata.platform?.isNotEmpty == true ? '($year)' : '$year',
                    style: TextStyle(
                        fontWeight: kAppBoldFontWeight,
                        color: palette.textPrimary)),
            ]),
        if (metadata.hardwareType?.isNotEmpty == true)
          Text(metadata.hardwareType!),
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

List<Widget> buildGameHardwareInspectorSections(
    BuildContext context, LibraryInspectorRequest request) {
  final dto = request.item.dto as GameHardwareWorkspaceDto;
  final metadata = dto.metadata;
  final entry = dto.entry;
  Widget links(Iterable<GameHardwareCatalogLink> values) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final link in values)
          TextButton(
              onPressed: () => launchUrl(Uri.parse(link.url)),
              style: TextButton.styleFrom(
                  foregroundColor: appPalette(context).link),
              child: Text(link.title ?? link.url))
      ]);
  Widget section(String title, Widget child) =>
      LibraryDetailSection(title: title, collapsible: false, children: [child]);
  return [
    if (metadata.description?.isNotEmpty == true)
      section('Description', Text(metadata.description!)),
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
                if (entry.personal.details.serialNumber case final serial?)
                  LibraryDetailField(label: 'Serial No.', value: serial),
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
