import 'package:collectarr_app/features/library/generic/quick_view.dart';

class LibraryToolbarStatsCalculator {
  const LibraryToolbarStatsCalculator();

  LibraryToolbarCounts calculate({
    required int totalAllItems,
    required int shownCount,
  }) {
    return LibraryToolbarCounts(
      total: totalAllItems,
      shown: shownCount,
    );
  }
}
