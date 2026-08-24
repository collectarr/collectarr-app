import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';

abstract interface class CatalogKindCodec<T extends CatalogItemDto> {
  T decode(Map<String, dynamic> payload);
  Map<String, dynamic> encode(T value);
}

final class DefaultCatalogKindCodec<T extends CatalogItemDto>
    implements CatalogKindCodec<T> {
  const DefaultCatalogKindCodec(this._decoder, this._encoder);

  final T Function(Map<String, dynamic> payload) _decoder;
  final Map<String, dynamic> Function(T value) _encoder;

  @override
  T decode(Map<String, dynamic> payload) => _decoder(payload);

  @override
  Map<String, dynamic> encode(T value) => _encoder(value);
}

final Map<CatalogMediaKind, CatalogKindCodec<CatalogItemDto>>
    _catalogKindCodecs = <CatalogMediaKind, CatalogKindCodec<CatalogItemDto>>{};

void registerCatalogKindCodec<T extends CatalogItemDto>(
  CatalogMediaKind kind,
  CatalogKindCodec<T> codec,
) {
  _catalogKindCodecs[kind] = _CatalogKindCodecAdapter<T>(codec);
}

CatalogKindCodec<CatalogItemDto> catalogKindCodecFor(CatalogMediaKind kind) {
  final codec = _catalogKindCodecs[kind];
  if (codec != null) {
    return codec;
  }
  return _FallbackCatalogKindCodec(kind);
}

class _CatalogKindCodecAdapter<T extends CatalogItemDto>
    implements CatalogKindCodec<CatalogItemDto> {
  const _CatalogKindCodecAdapter(this._inner);
  final CatalogKindCodec<T> _inner;

  @override
  CatalogItemDto decode(Map<String, dynamic> payload) => _inner.decode(payload);

  @override
  Map<String, dynamic> encode(CatalogItemDto value) =>
      _inner.encode(value as T);
}

class _FallbackCatalogKindCodec implements CatalogKindCodec<CatalogItemDto> {
  const _FallbackCatalogKindCodec(this.kind);
  final CatalogMediaKind kind;

  @override
  CatalogItemDto decode(Map<String, dynamic> payload) =>
      CatalogItemDto.decodeFromPayload(kind, payload);

  @override
  Map<String, dynamic> encode(CatalogItemDto value) => value.toSyncPayload();
}
