import 'package:collectarr_app/core/models/catalog_media_kind.dart';

abstract interface class CatalogKindCodec<T> {
  T decode(Map<String, dynamic> payload);
  Map<String, dynamic> encode(Object? value);
}

final class DefaultCatalogKindCodec<T>
    implements CatalogKindCodec<T> {
  const DefaultCatalogKindCodec(this._decoder, this._encoder);

  final T Function(Map<String, dynamic> payload) _decoder;
  final Map<String, dynamic> Function(T value) _encoder;

  @override
  T decode(Map<String, dynamic> payload) => _decoder(payload);

  @override
  Map<String, dynamic> encode(Object? value) {
    if (value is T) {
      return _encoder(value);
    }
    return const <String, dynamic>{};
  }
}

final Map<CatalogMediaKind, CatalogKindCodec<Object?>>
    _catalogKindCodecs =
    <CatalogMediaKind, CatalogKindCodec<Object?>>{};

void registerCatalogKindCodec<T>(
  CatalogMediaKind kind,
  CatalogKindCodec<T> codec,
) {
  _catalogKindCodecs[kind] = _CatalogKindCodecAdapter<T>(codec);
}

CatalogKindCodec<Object?>? catalogKindCodecFor(
    CatalogMediaKind kind) {
  return _catalogKindCodecs[kind];
}

class _CatalogKindCodecAdapter<T> implements CatalogKindCodec<Object?> {
  const _CatalogKindCodecAdapter(this._inner);
  final CatalogKindCodec<T> _inner;

  @override
  Object? decode(Map<String, dynamic> payload) => _inner.decode(payload);

  @override
  Map<String, dynamic> encode(Object? value) {
    if (value is T) return _inner.encode(value);
    return const <String, dynamic>{};
  }
}
