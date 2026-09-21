import 'package:collectarr_app/features/library/kinds/music/provider/music_release_correction_patch.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/providers/transport/provider_patch.dart';

/// Encodes a kind-owned typed correction at the provider HTTP boundary.
///
/// No kind-owned patch exposes a string-keyed map. This codec is the only
/// place where typed correction values become the admin API request shape.
Map<String, Object?> encodeProviderCorrectionsForWire(
  ProviderCorrectionPatch patch,
) {
  return switch (patch) {
    EmptyProviderCorrectionPatch() => const <String, Object?>{},
    CommonProviderCorrectionPatch common => _encodeProviderCorrectionFields([
        _wireField('title', common.title),
        _wireField('synopsis', common.synopsis),
        _wireField('cover_image_url', common.coverImageUrl),
        _wireField('publisher', common.publisher),
        _wireField('barcode', common.barcode),
        _wireField('physical_format', common.physicalFormat),
        _wireField('physical_format_label', common.physicalFormatLabel),
        _wireField('edition_title', common.editionTitle),
        _wireField('item_number', common.itemNumber),
        _wireField('variant', common.variant),
        _wireField(
          'release_date',
          common.releaseDate,
          encode: (value) => value.toUtc().toIso8601String(),
        ),
      ]),
    MusicReleaseCorrectionPatch music => _encodeProviderCorrectionFields([
        _wireField('title', music.title),
        _wireField('synopsis', music.synopsis),
        _wireField('publisher', music.publisher),
        _wireField('catalog_number', music.catalogNumber),
        _wireField('barcode', music.barcode),
        _wireField('cover_image_url', music.coverImageUrl),
        _wireField(
          'release_date',
          music.releaseDate,
          encode: (value) => value.toUtc().toIso8601String(),
        ),
        _wireField('physical_format', music.physicalFormat),
      ]),
    _ => throw StateError(
        'No HTTP correction encoder registered for ${patch.runtimeType}.',
      ),
  };
}

final class _ProviderCorrectionWireField {
  const _ProviderCorrectionWireField._({
    required this.field,
    required this.isChanged,
    required Object? Function() wireValueBuilder,
  }) : _wireValueBuilder = wireValueBuilder;

  final String field;
  final bool isChanged;
  final Object? Function() _wireValueBuilder;

  Object? get wireValue => _wireValueBuilder();
}

_ProviderCorrectionWireField _wireField<T>(
  String field,
  ProviderPatch<T> patch, {
  Object? Function(T value)? encode,
}) {
  final encodeValue = encode ?? (value) => value;
  return switch (patch) {
    ProviderUnchanged<T>() => _ProviderCorrectionWireField._(
        field: field,
        isChanged: false,
        wireValueBuilder: () => null,
      ),
    ProviderSetValue<T>(value: final value) => _ProviderCorrectionWireField._(
        field: field,
        isChanged: true,
        wireValueBuilder: () => encodeValue(value),
      ),
    ProviderClearValue<T>() => _ProviderCorrectionWireField._(
        field: field,
        isChanged: true,
        wireValueBuilder: () => null,
      ),
  };
}

Map<String, Object?> _encodeProviderCorrectionFields(
  Iterable<_ProviderCorrectionWireField> fields,
) {
  return {
    for (final field in fields)
      if (field.isChanged) field.field: field.wireValue,
  };
}
