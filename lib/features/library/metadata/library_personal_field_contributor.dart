import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter/foundation.dart';

import 'library_field_ownership.dart';

/// Personal-field vocabulary contributed by one library kind.
///
/// The shared settings UI consumes the structural contract only. The meaning
/// and availability of kind-specific fields stay with the owning module.
@immutable
class LibraryPersonalFieldContributor {
  const LibraryPersonalFieldContributor({
    required this.kind,
    required this.fields,
  });

  final CatalogMediaKind kind;
  final List<PersonalLibraryFieldSpec> fields;
}
