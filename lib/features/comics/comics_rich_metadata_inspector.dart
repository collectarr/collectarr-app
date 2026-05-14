import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/comic_detail.dart';
import 'package:collectarr_app/features/comics/comics_inspector_formatters.dart';
import 'package:collectarr_app/features/library/library_item_state.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComicsRichMetadataInspector extends StatelessWidget {
  const ComicsRichMetadataInspector({
    super.key,
    required this.item,
    required this.detail,
    required this.libraryState,
  });

  final CatalogItem item;
  final AsyncValue<ComicDetail>? detail;
  final LibraryItemState libraryState;

  @override
  Widget build(BuildContext context) {
    final owned = libraryState.ownedItem;
    final detailValue = detail?.value;
    final edition = detailValue?.primaryEdition;
    final variant = detailValue?.primaryVariant;
    final source = edition?.sourceMetadata;
    final creators = _creditFacts(
      detailValue?.creators ?? const [],
      fallbackValues: _metadataNames(source, 'person_credits'),
    );
    final characters = _creditNames(
      detailValue?.characters ?? const [],
      fallbackValues: _metadataNames(source, 'character_credits'),
    );
    final arcs = _creditNames(
      detailValue?.storyArcs ?? const [],
      fallbackValues: _metadataNames(source, 'story_arc_credits'),
    );
    final providerFacts = _providerFacts(detailValue, edition);
    final releaseFacts = _releaseFacts(edition);
    final variantFacts = _variantFacts(variant);
    final tracking = owned?.mediaTracking;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LibraryInspectorSection(
          title: 'Product Details',
          children: [
            LibraryInspectorFact(
              'Series',
              detailValue?.seriesTitle ?? detailValue?.volumeName ?? item.title,
            ),
            LibraryInspectorFact(
              'Publisher',
              edition?.publisher ?? item.publisher ?? '-',
            ),
            LibraryInspectorFact(
              'Release',
              formatNullableComicInspectorDate(
                    edition?.releaseDate ??
                        detailValue?.storeDate ??
                        item.releaseDate,
                  ) ??
                  '-',
            ),
            LibraryInspectorFact(
              'Cover date',
              formatNullableComicInspectorDate(detailValue?.coverDate) ?? '-',
            ),
            LibraryInspectorFact(
              'Format',
              edition?.physicalFormatLabel ?? edition?.format ?? item.kind,
            ),
            LibraryInspectorFact(
              'UPC / ISBN',
              edition?.upc ?? edition?.isbn ?? '-',
            ),
            LibraryInspectorFact(
              'Pages / Price',
              [
                if (detailValue?.pageCount != null)
                  '${detailValue!.pageCount} pages',
                formatComicInspectorMoney(
                  detailValue?.coverPriceCents ?? variant?.coverPriceCents,
                  detailValue?.currency ?? variant?.currency,
                ),
              ].where((value) => value.isNotEmpty).join(' | ').ifEmpty('-'),
            ),
          ],
        ),
        if (variantFacts.isNotEmpty || releaseFacts.isNotEmpty)
          LibraryInspectorSection(
            title: 'Edition',
            children: [
              for (final fact in variantFacts)
                LibraryInspectorFact(fact.label, fact.value),
              if (releaseFacts.isNotEmpty) ...[
                const SizedBox(height: 4),
                LibraryInspectorChipWrap(values: releaseFacts),
              ],
            ],
          ),
        LibraryInspectorSection(
          title: 'Personal',
          children: [
            LibraryInspectorFactGrid(
              facts: [
                LibraryInspectorFactData(
                  'Quantity',
                  owned?.quantity.toString() ?? '-',
                ),
                LibraryInspectorFactData(
                  'Storage box',
                  owned?.storageBox ?? '-',
                ),
                LibraryInspectorFactData(
                  'Index',
                  owned?.indexNumber?.toString() ?? '-',
                ),
                LibraryInspectorFactData(
                  'Tracking',
                  tracking?.statusLabel ?? '-',
                ),
                LibraryInspectorFactData(
                  'Rating',
                  tracking?.rating?.toString() ?? '-',
                ),
                LibraryInspectorFactData(
                  'Read status',
                  owned?.readStatus ?? '-',
                ),
                LibraryInspectorFactData('Tags', owned?.tags ?? '-'),
              ],
            ),
            if (owned?.signedBy != null && owned!.signedBy!.isNotEmpty)
              LibraryInspectorFact('Signed by', owned.signedBy!),
          ],
        ),
        LibraryInspectorSection(
          title: 'Value',
          children: [
            LibraryInspectorFactGrid(
              facts: [
                LibraryInspectorFactData(
                  'Purchase',
                  formatComicInspectorMoney(
                    owned?.pricePaidCents,
                    owned?.currency,
                  ).ifEmpty('-'),
                ),
                LibraryInspectorFactData(
                  'Cover price',
                  formatComicInspectorMoney(
                    owned?.coverPriceCents,
                    owned?.currency,
                  ).ifEmpty('-'),
                ),
                LibraryInspectorFactData(
                  'Grade status',
                  owned?.rawOrSlabbed ?? '-',
                ),
                LibraryInspectorFactData(
                  'Grading company',
                  owned?.gradingCompany ?? '-',
                ),
                LibraryInspectorFactData(
                  'Key issue',
                  owned?.keyComic == true ? 'Yes' : 'No',
                ),
              ],
            ),
            if (owned?.keyReason != null && owned!.keyReason!.isNotEmpty)
              LibraryInspectorFact('Key reason', owned.keyReason!),
          ],
        ),
        if (creators.isNotEmpty)
          LibraryInspectorSection(
            title: 'Creators',
            children: [
              for (final fact in creators.take(8))
                LibraryInspectorFact(fact.label, fact.value),
            ],
          ),
        if (characters.isNotEmpty)
          LibraryInspectorChipSection(title: 'Characters', values: characters),
        if (arcs.isNotEmpty)
          LibraryInspectorChipSection(title: 'Story arcs', values: arcs),
        if (providerFacts.isNotEmpty)
          LibraryInspectorSection(
            title: 'Provider Links',
            children: [
              for (final fact in providerFacts)
                LibraryInspectorFact(fact.label, fact.value),
            ],
          ),
        if (detail?.isLoading ?? false)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  List<String> _metadataNames(Map<String, dynamic>? source, String key) {
    final values = source?[key];
    if (values is! List) {
      return const [];
    }
    return [
      for (final value in values)
        if (value is Map && value['name'] != null) value['name'].toString(),
    ];
  }

  List<LibraryInspectorFactData> _creditFacts(
    List<ComicCredit> credits, {
    required List<String> fallbackValues,
  }) {
    if (credits.isEmpty) {
      return [
        for (final value in fallbackValues)
          LibraryInspectorFactData('Creator', value),
      ];
    }
    final byRole = <String, List<String>>{};
    for (final credit in credits) {
      final role = (credit.role == null || credit.role!.isEmpty)
          ? 'Creator'
          : credit.role!;
      byRole.putIfAbsent(role, () => []).add(credit.name);
    }
    return [
      for (final entry in byRole.entries)
        LibraryInspectorFactData(entry.key, entry.value.take(4).join(', ')),
    ];
  }

  List<String> _creditNames(
    List<ComicCredit> credits, {
    required List<String> fallbackValues,
  }) {
    if (credits.isEmpty) {
      return fallbackValues;
    }
    return [
      for (final credit in credits) credit.name,
    ];
  }

  List<LibraryInspectorFactData> _variantFacts(ComicVariant? variant) {
    if (variant == null) {
      return const [];
    }
    return [
      LibraryInspectorFactData('Variant cover', variant.name),
      if (variant.physicalFormatLabel != null)
        LibraryInspectorFactData('Physical format', variant.physicalFormatLabel!),
      if (variant.variantType != null)
        LibraryInspectorFactData('Variant type', variant.variantType!),
      if (variant.region != null)
        LibraryInspectorFactData('Region', variant.region!),
      if (variant.barcode != null)
        LibraryInspectorFactData('Barcode', variant.barcode!),
      if (variant.description != null && variant.description!.isNotEmpty)
        LibraryInspectorFactData('Description', variant.description!),
    ];
  }

  List<String> _releaseFacts(ComicEdition? edition) {
    final releases = edition?.releases ?? const [];
    return [
      for (final release in releases.take(6))
        [
          release.region,
          if (release.publisher != null && release.publisher!.isNotEmpty)
            release.publisher,
          if (release.releaseDate != null)
            formatComicInspectorDate(release.releaseDate!),
        ].whereType<String>().join(' | '),
    ];
  }

  List<LibraryInspectorFactData> _providerFacts(
    ComicDetail? detail,
    ComicEdition? edition,
  ) {
    final metadata = edition?.metadataJson;
    final source = edition?.sourceMetadata;
    final releaseIds = edition?.releases
            .map((release) => release.externalIds)
            .whereType<Map<String, dynamic>>()
            .expand((ids) => ids.entries)
            .map((entry) => '${entry.key}: ${entry.value}')
            .toSet()
            .join(', ') ??
        '';
    return [
      for (final link in detail?.providerLinks ?? const <ComicProviderLink>[])
        LibraryInspectorFactData(
          link.provider,
          [
            '${link.entityType}: ${link.providerItemId}',
            if (link.siteUrl != null) link.siteUrl,
          ].whereType<String>().join(' | '),
        ),
      if (metadata?['provider'] != null)
        LibraryInspectorFactData('Provider', metadata!['provider'].toString()),
      if (metadata?['provider_item_id'] != null)
        LibraryInspectorFactData(
          'Provider ID',
          metadata!['provider_item_id'].toString(),
        ),
      if (source?['site_detail_url'] != null)
        LibraryInspectorFactData(
          'Source URL',
          source!['site_detail_url'].toString(),
        ),
      if (source?['api_detail_url'] != null)
        LibraryInspectorFactData(
          'API URL',
          source!['api_detail_url'].toString(),
        ),
      if (releaseIds.isNotEmpty)
        LibraryInspectorFactData('Release IDs', releaseIds),
    ];
  }
}
