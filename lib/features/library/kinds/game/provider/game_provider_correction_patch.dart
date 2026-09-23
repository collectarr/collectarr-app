import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/kinds/registry/provider_typed_correction_values.dart';
import 'package:collectarr_app/features/providers/transport/provider_patch.dart';

final class GameProviderCorrectionPatch implements ProviderCorrectionPatch {
  const GameProviderCorrectionPatch({
    required this.title,
    required this.synopsis,
    required this.coverImageUrl,
    required this.publisher,
    required this.barcode,
    required this.physicalFormat,
    required this.physicalFormatLabel,
    required this.editionTitle,
    required this.itemNumber,
    required this.variant,
    required this.releaseDate,
  });

  factory GameProviderCorrectionPatch.fromCandidates({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    final before = requireProviderKindMetadata<GameCatalogMetadata>(preview);
    final after = requireProviderKindMetadata<GameCatalogMetadata>(edited);
    return GameProviderCorrectionPatch(
      title: providerStringPatch(preview.primaryLabel, edited.primaryLabel),
      synopsis: providerStringPatch(preview.gameCatalogFields.synopsis,
          edited.gameCatalogFields.synopsis),
      coverImageUrl: providerStringPatch(
          preview.gameCatalogFields.coverImageUrl,
          edited.gameCatalogFields.coverImageUrl),
      publisher: providerStringPatch(
        before.publishers.firstOrNull,
        after.publishers.firstOrNull,
      ),
      barcode: providerStringPatch(before.barcode, after.barcode),
      physicalFormat: providerStringPatch(
        before.physicalFormat,
        after.physicalFormat,
      ),
      physicalFormatLabel: providerStringPatch(
        before.physicalFormatLabel,
        after.physicalFormatLabel,
      ),
      editionTitle: providerStringPatch(before.edition, after.edition),
      itemNumber: const ProviderPatch.unchanged(),
      variant: const ProviderPatch.unchanged(),
      releaseDate: providerDatePatch(before.releaseDate, after.releaseDate),
    );
  }

  final ProviderPatch<String> title;
  final ProviderPatch<String> synopsis;
  final ProviderPatch<String> coverImageUrl;
  final ProviderPatch<String> publisher;
  final ProviderPatch<String> barcode;
  final ProviderPatch<String> physicalFormat;
  final ProviderPatch<String> physicalFormatLabel;
  final ProviderPatch<String> editionTitle;
  final ProviderPatch<String> itemNumber;
  final ProviderPatch<String> variant;
  final ProviderPatch<DateTime> releaseDate;

  @override
  bool get isEmpty => [
        title,
        synopsis,
        coverImageUrl,
        publisher,
        barcode,
        physicalFormat,
        physicalFormatLabel,
        editionTitle,
        itemNumber,
        variant,
        releaseDate,
      ].every(providerPatchIsUnchanged);
}

Map<String, Object?> encodeGameProviderCorrectionsForWire(
  ProviderCorrectionPatch patch,
) {
  if (patch is EmptyProviderCorrectionPatch) {
    return const <String, Object?>{};
  }
  if (patch is! GameProviderCorrectionPatch) {
    throw StateError('Game correction encoder received ${patch.runtimeType}.');
  }
  return encodeChangedProviderPatchFields([
    providerPatchWireField('title', patch.title),
    providerPatchWireField('synopsis', patch.synopsis),
    providerPatchWireField('cover_image_url', patch.coverImageUrl),
    providerPatchWireField('publisher', patch.publisher),
    providerPatchWireField('barcode', patch.barcode),
    providerPatchWireField('physical_format', patch.physicalFormat),
    providerPatchWireField('physical_format_label', patch.physicalFormatLabel),
    providerPatchWireField('edition_title', patch.editionTitle),
    providerPatchWireField('item_number', patch.itemNumber),
    providerPatchWireField('variant', patch.variant),
    providerPatchWireField(
      'release_date',
      patch.releaseDate,
      encode: (value) => value.toUtc().toIso8601String(),
    ),
  ]);
}
