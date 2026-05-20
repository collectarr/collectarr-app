import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';

class LibraryAddCopy {
  const LibraryAddCopy._();

  static String addToTargetLabel({
    required int count,
    required LibraryTypeConfig type,
    required LibraryAddTarget target,
  }) {
    final safeCount = count <= 1 ? 1 : count;
    return 'Add $safeCount ${type.countLabel(safeCount)} to ${target.destinationLabel}';
  }
}
