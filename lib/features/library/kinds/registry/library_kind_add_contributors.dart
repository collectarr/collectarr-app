import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_add_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';

LibraryAddCapability libraryAddForKind(CatalogMediaKind kind) =>
    collectarrKindAdds[kind]!;

LibraryAddChromeConfig libraryAddChromeForKind(CatalogMediaKind kind) =>
    libraryAddForKind(kind).chrome;
