import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';

typedef LibraryCopyCreationPolicy = bool Function(LibraryEntityRef node);

/// Kind-owned policy for creating a physical/local copy from a library node.
final class LibraryOwnershipCapability {
  const LibraryOwnershipCapability({required this.copyCreationPolicy});

  const LibraryOwnershipCapability.allowEverywhere()
      : copyCreationPolicy = _allowEverywhere;

  const LibraryOwnershipCapability.releaseOnly()
      : copyCreationPolicy = _allowReleaseOnly;

  final LibraryCopyCreationPolicy copyCreationPolicy;

  bool canCreateCopyAt(LibraryEntityRef node) => copyCreationPolicy(node);
}

bool _allowEverywhere(LibraryEntityRef node) => true;

bool _allowReleaseOnly(LibraryEntityRef node) =>
    node.scope == LibraryEntityScope.release;
