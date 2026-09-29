import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

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
  LibraryCollectionValueSummary? resolveCollectionValueSummary(
    Iterable<LibraryWorkspaceSource> entries,
  );
}

class DefaultLibraryValueCapability implements LibraryValueCapability {
  const DefaultLibraryValueCapability();

  @override
  LibraryCollectionValueSummary? resolveCollectionValueSummary(
    Iterable<LibraryWorkspaceSource> entries,
  ) =>
      null;
}
