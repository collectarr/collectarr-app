import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

enum LibraryAddReferenceType { media, edition, bundleRelease }

extension LibraryAddReferenceTypeLabels on LibraryAddReferenceType {
  String labelForType(LibraryKindModule type) {
    return switch (this) {
      LibraryAddReferenceType.media => type.addChrome.mediaReferenceLabel,
      LibraryAddReferenceType.edition => 'Edition',
      LibraryAddReferenceType.bundleRelease => 'Bundle',
    };
  }

  String helperLabelForType(LibraryKindModule type) {
    return switch (this) {
      LibraryAddReferenceType.media => type.addChrome.mediaReferenceHelperLabel,
      LibraryAddReferenceType.edition =>
        type.addChrome.editionReferenceHelperLabel,
      LibraryAddReferenceType.bundleRelease =>
        'Attach ownership to a bundle that contains this item',
    };
  }
}
