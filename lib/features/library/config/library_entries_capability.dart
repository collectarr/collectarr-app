import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:flutter/widgets.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';

typedef LibraryCopyCreationPolicy = bool Function(LibraryTargetRef target);

/// Kind-entry policy for creating a local library record from a Catalog Item.
final class LibraryEntryPolicyCapability {
  const LibraryEntryPolicyCapability(
      {required this.copyCreationPolicy, this.mergeEntries});

  const LibraryEntryPolicyCapability.allowEverywhere({this.mergeEntries})
      : copyCreationPolicy = _allowEverywhere;

  final LibraryCopyCreationPolicy copyCreationPolicy;
  final Future<LibraryEntryRef?> Function(BuildContext context,
      LocalDatabase database, List<LibraryEntryRef> entries)? mergeEntries;

  bool canCreateCopyAt(LibraryTargetRef target) => copyCreationPolicy(target);
}

bool _allowEverywhere(LibraryTargetRef target) => true;
