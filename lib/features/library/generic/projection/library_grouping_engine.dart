import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_series_sidebar.dart';

class LibraryGroupingEngine {
  const LibraryGroupingEngine();

  String getGroupBucketForItem(
    LibraryProjectionItem item,
    LibraryTypeConfig type,
    String groupMode,
  ) {
    return genericBucketForItemMode(item, type, groupMode);
  }

  List<LibrarySeriesBucket> buildBuckets(
    List<LibraryProjectionItem> items,
    LibraryTypeConfig type,
    String groupMode,
  ) {
    return libraryBucketsForItems(items, type, groupMode);
  }
}
