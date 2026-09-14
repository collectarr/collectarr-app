import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_transfer_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';

LibraryTransferCapability libraryTransferForKind(CatalogMediaKind kind) =>
    collectarrKindTransfers[kind]!;
