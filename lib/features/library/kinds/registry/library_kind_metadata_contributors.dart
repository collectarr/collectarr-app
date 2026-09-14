import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_metadata_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';

List<PhysicalMediaFormat> libraryPhysicalMediaFormatsForKind(
  CatalogMediaKind kind,
) =>
    collectarrKindPhysicalMediaFormats[kind]!;

LibraryMediaPresentation libraryPresentationForKind(CatalogMediaKind kind) =>
    collectarrKindPresentations[kind]!;

LibraryMetadataCapability libraryMetadataForKind(CatalogMediaKind kind) =>
    collectarrKindMetadata[kind]!;
