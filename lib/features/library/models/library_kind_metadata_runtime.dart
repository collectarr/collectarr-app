import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

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
    final decoder = _globalDecoder;
    if (decoder != null) {
      return decoder(mediaKind, json);
    }
    return EmptyKindMetadata(mediaKind);
  }
}

class EmptyKindMetadata implements LibraryKindMetadataRuntime {
  const EmptyKindMetadata(this.mediaKind);

  @override
  final CatalogMediaKind mediaKind;

  @override
  Map<String, dynamic> toSyncPayload() => const {};
}

