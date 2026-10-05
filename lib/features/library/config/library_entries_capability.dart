import 'package:collectarr_app/features/library/domain/library_target_ref.dart';

typedef LibraryCopyCreationPolicy = bool Function(LibraryTargetRef target);

/// Kind-entry policy for creating a local library record from a Catalog Item.
final class LibraryEntryPolicyCapability {
  const LibraryEntryPolicyCapability({required this.copyCreationPolicy});

  const LibraryEntryPolicyCapability.allowEverywhere()
      : copyCreationPolicy = _allowEverywhere;

  final LibraryCopyCreationPolicy copyCreationPolicy;

  bool canCreateCopyAt(LibraryTargetRef target) => copyCreationPolicy(target);
}

bool _allowEverywhere(LibraryTargetRef target) => true;
