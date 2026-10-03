import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';

typedef LibraryCopyCreationPolicy = bool Function(LibraryEntityRef node);

/// Kind-entry policy for creating a local library record from a Catalog Item.
final class LibraryEntryPolicyCapability {
  const LibraryEntryPolicyCapability({required this.copyCreationPolicy});

  const LibraryEntryPolicyCapability.allowEverywhere()
      : copyCreationPolicy = _allowEverywhere;

  final LibraryCopyCreationPolicy copyCreationPolicy;

  bool canCreateCopyAt(LibraryEntityRef node) => copyCreationPolicy(node);
}

bool _allowEverywhere(LibraryEntityRef node) => true;
