import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';

abstract interface class LibraryKindMetadataRuntime {
  CatalogMediaKind get mediaKind;
  Map<String, dynamic> toSyncPayload();
}

typedef KindMetadataDecoder = LibraryKindMetadataRuntime Function(
  CatalogMediaKind mediaKind,
  Map<String, dynamic> json,
);

abstract final class LibraryKindMetadataDecoders {
  static KindMetadataDecoder? _globalDecoder;

  static void registerGlobalDecoder(KindMetadataDecoder decoder) {
    _globalDecoder = decoder;
  }

  static LibraryKindMetadataRuntime decode(
    CatalogMediaKind mediaKind,
    Map<String, dynamic> json,
  ) {
    var decoder = _globalDecoder;
    if (decoder == null) {
      ensureLibraryKindDecodersInitialized();
      decoder = _globalDecoder;
    }
    if (decoder != null) {
      return decoder(mediaKind, json);
    }
    return DefaultMapKindMetadata(mediaKind, json);
  }
}

class DefaultMapKindMetadata implements LibraryKindMetadataRuntime {
  const DefaultMapKindMetadata(this.mediaKind, this._payload);

  @override
  final CatalogMediaKind mediaKind;

  final Map<String, dynamic> _payload;

  @override
  Map<String, dynamic> toSyncPayload() => _payload;
}

class EmptyKindMetadata implements LibraryKindMetadataRuntime {
  const EmptyKindMetadata(this.mediaKind);

  @override
  final CatalogMediaKind mediaKind;

  @override
  Map<String, dynamic> toSyncPayload() => const {};
}
