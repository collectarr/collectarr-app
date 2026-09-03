import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';

class LibraryCollectionValueSummary {
  const LibraryCollectionValueSummary({
    required this.valuedCount,
    required this.totalValueCents,
    required this.currency,
    required this.hasMixedCurrencies,
  });

  final int valuedCount;
  final int? totalValueCents;
  final String? currency;
  final bool hasMixedCurrencies;
}

abstract interface class LibraryValueCapability {
  int? resolveProviderValueCents(LibraryProjectionRuntime item);

  LibraryCollectionValueSummary? resolveCollectionValueSummary(
    Iterable<ShelfEntry> entries,
  );
}

class DefaultLibraryValueCapability implements LibraryValueCapability {
  const DefaultLibraryValueCapability();

  @override
  int? resolveProviderValueCents(LibraryProjectionRuntime item) => null;

  @override
  LibraryCollectionValueSummary? resolveCollectionValueSummary(
    Iterable<ShelfEntry> entries,
  ) =>
      null;
}
