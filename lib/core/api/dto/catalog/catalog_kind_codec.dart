import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';

abstract interface class CatalogKindCodec<T extends LibraryKindMetadataRuntime> {
  T decode(Map<String, dynamic> payload);
  Map<String, dynamic> encode(LibraryKindMetadataRuntime value);
}

final class DefaultCatalogKindCodec<T extends LibraryKindMetadataRuntime>
    implements CatalogKindCodec<T> {
  const DefaultCatalogKindCodec(this._decoder, this._encoder);

  final T Function(Map<String, dynamic> payload) _decoder;
  final Map<String, dynamic> Function(T value) _encoder;

  @override
  T decode(Map<String, dynamic> payload) => _decoder(payload);

  @override
  Map<String, dynamic> encode(LibraryKindMetadataRuntime value) {
    if (value is T) {
      return _encoder(value);
    }
    return const <String, dynamic>{};
  }
}

final Map<CatalogMediaKind, CatalogKindCodec<LibraryKindMetadataRuntime>>
    _catalogKindCodecs =
    <CatalogMediaKind, CatalogKindCodec<LibraryKindMetadataRuntime>>{};

void registerCatalogKindCodec<T extends LibraryKindMetadataRuntime>(
  CatalogMediaKind kind,
  CatalogKindCodec<T> codec,
) {
  _catalogKindCodecs[kind] = _CatalogKindCodecAdapter<T>(codec);
}

CatalogKindCodec<LibraryKindMetadataRuntime>? catalogKindCodecFor(
    CatalogMediaKind kind) {
  return _catalogKindCodecs[kind];
}

class _CatalogKindCodecAdapter<T extends LibraryKindMetadataRuntime>
    implements CatalogKindCodec<LibraryKindMetadataRuntime> {
  const _CatalogKindCodecAdapter(this._inner);
  final CatalogKindCodec<T> _inner;

  @override
  LibraryKindMetadataRuntime decode(Map<String, dynamic> payload) =>
      _inner.decode(payload);

  @override
  Map<String, dynamic> encode(LibraryKindMetadataRuntime value) =>
      _inner.encode(value as T);
}

