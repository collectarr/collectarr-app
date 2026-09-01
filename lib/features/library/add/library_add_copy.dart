import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

class LibraryAddCopy {
  const LibraryAddCopy._();

  static String addToTargetLabel({
    required int count,
    required LibraryKindRuntime type,
    required LibraryAddTarget target,
  }) {
    final safeCount = count <= 1 ? 1 : count;
    return 'Add $safeCount ${type.identity.countLabel(safeCount)} to ${target.destinationLabel}';
  }
}
