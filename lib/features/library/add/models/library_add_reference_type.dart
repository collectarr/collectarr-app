import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';

enum LibraryAddReferenceType { media, edition, bundleRelease }

extension LibraryAddReferenceTypeLabels on LibraryAddReferenceType {
  String labelForType(LibraryKindRegistration type) {
    return switch (this) {
      LibraryAddReferenceType.media =>
        libraryAddChromeForKind(type.kind).mediaReferenceLabel,
      LibraryAddReferenceType.edition => 'Edition',
      LibraryAddReferenceType.bundleRelease => 'Bundle',
    };
  }

  String helperLabelForType(LibraryKindRegistration type) {
    return switch (this) {
      LibraryAddReferenceType.media =>
        libraryAddChromeForKind(type.kind).mediaReferenceHelperLabel,
      LibraryAddReferenceType.edition =>
        libraryAddChromeForKind(type.kind).editionReferenceHelperLabel,
      LibraryAddReferenceType.bundleRelease =>
        'Attach ownership to a bundle that contains this item',
    };
  }
}
