import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_ownership_capability.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_policy_registry.dart';

LibraryOwnershipCapability libraryOwnershipForKind(CatalogMediaKind kind) =>
    collectarrKindOwnershipCapabilities[kind]!;
