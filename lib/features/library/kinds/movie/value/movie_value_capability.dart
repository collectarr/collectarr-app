import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_value_capability.dart';

class MovieValueCapability implements LibraryValueCapability {
  const MovieValueCapability();

  @override
  LibraryCollectionValueSummary? resolveCollectionValueSummary(
    Iterable<LibraryWorkspaceContext> entries,
  ) {
    final valuedEntries = entries
        .where(
          (entry) =>
              entry.isEntry &&
              entry.marketValueCents != null &&
              entry.currency?.trim().isNotEmpty == true,
        )
        .toList(growable: false);
    if (valuedEntries.isEmpty) return null;

    final currencies = {
      for (final entry in valuedEntries) entry.currency!.trim(),
    };
    return LibraryCollectionValueSummary(
      valuedCount: valuedEntries.length,
      totalValueCents: currencies.length > 1
          ? null
          : valuedEntries.fold<int>(
              0,
              (total, entry) => total + entry.marketValueCents!,
            ),
      currency: currencies.length == 1 ? currencies.single : null,
      hasMixedCurrencies: currencies.length > 1,
    );
  }
}
