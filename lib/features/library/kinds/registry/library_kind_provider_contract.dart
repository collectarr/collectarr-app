import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';
import 'package:collectarr_app/features/providers/transport/provider_patch.dart';

/// Kind-owned correction values waiting to cross the admin HTTP boundary.
///
/// The keys are interpreted only by the owning kind while constructing the
/// patch. Generic orchestration treats the patch as opaque transport data.
final class ProviderCorrectionPatch {
  ProviderCorrectionPatch.fromChanges(
      Iterable<ProviderCorrectionChange> changes)
      : changes = List<ProviderCorrectionChange>.unmodifiable(changes);

  const ProviderCorrectionPatch.empty() : changes = const [];

  final List<ProviderCorrectionChange> changes;

  /// Converts the typed kind-owned changes to the admin wire shape.
  ///
  /// This is intentionally the only map conversion in the correction flow.
  /// Provider mappers compare typed values and create [ProviderPatch] values;
  /// generic orchestration only forwards this result to the HTTP boundary.
  Map<String, Object?> toWireFields() => {
        for (final change in changes)
          if (change.isChanged) change.field: change.wireValue,
      };

  bool get isEmpty => changes.every((change) => !change.isChanged);
}

/// A typed correction entry owned by one kind's provider mapper.
///
/// The generic object deliberately does not expose a mutable map. Its
/// generic factory accepts a typed value and [ProviderPatch] so null remains a
/// meaningful clear operation instead of an accidental missing key.
final class ProviderCorrectionChange {
  const ProviderCorrectionChange._({
    required this.field,
    required this.isChanged,
    required Object? Function() wireValueBuilder,
  }) : _wireValueBuilder = wireValueBuilder;

  static ProviderCorrectionChange fromPatch<T>({
    required String field,
    required ProviderPatch<T> patch,
    required Object? Function(T value) encode,
  }) {
    return switch (patch) {
      ProviderUnchanged<T>() => ProviderCorrectionChange._(
          field: field,
          isChanged: false,
          wireValueBuilder: () => null,
        ),
      ProviderSetValue<T>(value: final value) => ProviderCorrectionChange._(
          field: field,
          isChanged: true,
          wireValueBuilder: () => encode(value),
        ),
      ProviderClearValue<T>() => ProviderCorrectionChange._(
          field: field,
          isChanged: true,
          wireValueBuilder: () => null,
        ),
    };
  }

  final String field;
  final bool isChanged;
  final Object? Function() _wireValueBuilder;

  Object? get wireValue => _wireValueBuilder();
}

ProviderCorrectionChange providerCorrectionChange<T>({
  required String field,
  required T? current,
  required T? updated,
  Object? Function(T value)? encode,
}) {
  final patch = current == updated
      ? const ProviderPatch<T>.unchanged()
      : updated == null
          ? const ProviderPatch<T>.clear()
          : ProviderPatch<T>.set(updated);
  return ProviderCorrectionChange.fromPatch(
    field: field,
    patch: patch,
    encode: encode ?? (value) => value,
  );
}

/// Typed kind-owned provider mapping contract.
///
/// The provider layer owns transport and native DTOs. A kind owns the
/// semantic mapping from the normalized provider boundary into its concrete
/// catalog representation. The API/transport projections used by Add and
/// admin are registered as tear-off functions at the composition root; they
/// are not part of this typed domain contract.
abstract interface class TypedLibraryKindProviderMapper<TCatalog> {
  TCatalog catalogFromEnvelope(ProviderRawEnvelope envelope);
}

typedef ProviderMetadataCandidateMapper = CatalogSearchCandidate Function(
  ProviderRawEnvelope envelope,
);

/// Re-enters the generic search transport only after a kind has completed its
/// typed provider mapping. The candidate is built from explicit semantic
/// projection values; a whole catalog is never serialized back to JSON just
/// to cross this boundary.
CatalogSearchCandidate providerCandidateFromTypedProjection({
  required CatalogMediaKind kind,
  required String id,
  required String title,
  String? synopsis,
  String? coverImageUrl,
  DateTime? releaseDate,
  int? releaseYear,
  String? originalTitle,
  String? publisher,
  String? barcode,
  String? physicalFormat,
  String? physicalFormatLabel,
  String? editionTitle,
  String? itemNumber,
  String? variant,
  List<String>? searchAliases,
  Map<String, dynamic> transportPayload = const <String, dynamic>{},
  Object? kindMetadata,
}) {
  return CatalogSearchCandidate.fromKindProjection(
    id: id,
    kind: kind,
    title: title,
    synopsis: synopsis,
    coverImageUrl: coverImageUrl,
    releaseDate: releaseDate,
    releaseYear: releaseYear,
    originalTitle: originalTitle,
    publisher: publisher,
    barcode: barcode,
    physicalFormat: physicalFormat,
    physicalFormatLabel: physicalFormatLabel,
    editionTitle: editionTitle,
    itemNumber: itemNumber,
    variant: variant,
    searchAliases: searchAliases,
    transportPayload: transportPayload,
    kindMetadata: kindMetadata,
  );
}

typedef ProviderCorrectionBuilder = ProviderCorrectionPatch Function({
  required CatalogSearchCandidate preview,
  required CatalogSearchCandidate edited,
});

ProviderCorrectionPatch buildProviderCommonCorrections({
  required CatalogSearchCandidate preview,
  required CatalogSearchCandidate edited,
}) {
  return ProviderCorrectionPatch.fromChanges([
    providerCorrectionChange(
      field: 'title',
      current: preview.title,
      updated: edited.title,
    ),
    providerCorrectionChange(
      field: 'synopsis',
      current: preview.synopsis,
      updated: edited.synopsis,
    ),
    providerCorrectionChange(
      field: 'cover_image_url',
      current: preview.coverImageUrl,
      updated: edited.coverImageUrl,
    ),
    providerCorrectionChange(
      field: 'publisher',
      current: preview.publisher,
      updated: edited.publisher,
    ),
    providerCorrectionChange(
      field: 'barcode',
      current: preview.barcode,
      updated: edited.barcode,
    ),
    providerCorrectionChange(
      field: 'physical_format',
      current: preview.physicalFormat,
      updated: edited.physicalFormat,
    ),
    providerCorrectionChange(
      field: 'physical_format_label',
      current: preview.physicalFormatLabel,
      updated: edited.physicalFormatLabel,
    ),
    providerCorrectionChange(
      field: 'edition_title',
      current: preview.editionTitle,
      updated: edited.editionTitle,
    ),
    providerCorrectionChange(
      field: 'item_number',
      current: preview.mapTransport((item) => item.itemNumber),
      updated: edited.mapTransport((item) => item.itemNumber),
    ),
    providerCorrectionChange(
      field: 'variant',
      current: preview.mapTransport((item) => item.variant),
      updated: edited.mapTransport((item) => item.variant),
    ),
    providerCorrectionChange<String>(
      field: 'release_date',
      current: preview.releaseDate?.toUtc().toIso8601String(),
      updated: edited.releaseDate?.toUtc().toIso8601String(),
    ),
  ]);
}

/// Validates the erased provider boundary before a kind-owned mapper runs.
///
/// Provider adapters may use different native DTOs, but every mapping must
/// hand the kind the same minimum identity and title contract.
void validateLibraryKindProviderEnvelope({
  required ProviderRawEnvelope envelope,
  required CatalogMediaKind expectedKind,
}) {
  final actualKind = envelope.kind;
  if (actualKind != expectedKind) {
    throw StateError(
      '${expectedKind.apiValue} provider integration received ${envelope.kind.apiValue} data',
    );
  }
  if (envelope.provider.trim().isEmpty) {
    throw StateError(
      '${expectedKind.apiValue} provider integration received an envelope without a provider',
    );
  }
  if (envelope.providerItemId.trim().isEmpty) {
    throw StateError(
      '${expectedKind.apiValue} provider integration received an envelope without a provider item ID',
    );
  }
  final title = envelope.payload['title']?.toString().trim();
  if (title == null || title.isEmpty) {
    throw StateError(
      '${expectedKind.apiValue} provider integration received an envelope without a title',
    );
  }
}
