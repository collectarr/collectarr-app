import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class LibraryAddKindDraft {
  const LibraryAddKindDraft();

  CatalogMediaKind get kind;
  JsonEncodable toOwnedDetailsDraft();
}
