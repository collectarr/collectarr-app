import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Downloaded covers on disk. The package's default keeps 200 files, far fewer
/// than a collection has covers, so most would download again on every visit.
final libraryCoverCacheManager = CacheManager(Config(
  'libCachedImageData',
  stalePeriod: const Duration(days: 365),
  maxNrOfCacheObjects: 10000,
));

const _decodeWidths = [128, 192, 256, 384, 512, 768, 1024, 1536, 2048];

final _decodedWidths = <Object, int>{};

/// The width to decode a cover at when it needs [needed] pixels.
///
/// Widths come in steps, and a cover already decoded larger is reused while it
/// is at most four times what is needed, so zooming out shows every cover at
/// once instead of decoding each one again.
int libraryCoverDecodeWidth(Object cover, int needed) {
  final decoded = _decodedWidths[cover];
  if (decoded != null && decoded >= needed && decoded <= needed * 4) {
    return decoded;
  }
  final width = _decodeWidths.firstWhere(
    (step) => step >= needed,
    orElse: () => needed,
  );
  _decodedWidths[cover] = width;
  return width;
}
