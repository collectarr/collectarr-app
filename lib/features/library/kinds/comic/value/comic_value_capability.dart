import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_value_capability.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';

class ComicValueCapability implements LibraryValueCapability {
  const ComicValueCapability();

  @override
  LibraryCollectionValueSummary? resolveCollectionValueSummary(
    Iterable<LibraryWorkspaceContext> entries,
  ) {
    final valuedEntries = [
      for (final entry in entries)
        if (entry.isEntry)
          (
            entry: entry,
            personalState: _comicLibraryEntry(entry),
          ),
    ].where((candidate) {
      final libraryEntry = candidate.personalState;
      return libraryEntry != null &&
          libraryEntry.personal.details.coverPriceCents != null &&
          libraryEntry.personal.currency != null;
    }).toList(growable: false);
    if (valuedEntries.isEmpty) {
      return null;
    }
    final currencies = {
      for (final candidate in valuedEntries)
        candidate.personalState!.personal.currency!,
    };
    return LibraryCollectionValueSummary(
      valuedCount: valuedEntries.length,
      totalValueCents: currencies.length > 1
          ? null
          : valuedEntries.fold<int>(
              0,
              (total, candidate) {
                return total +
                    candidate.personalState!.personal.details.coverPriceCents!;
              },
            ),
      currency: currencies.length == 1 ? currencies.single : null,
      hasMixedCurrencies: currencies.length > 1,
    );
  }

  static ComicLibraryEntry? _comicLibraryEntry(LibraryWorkspaceContext entry) {
    return ComicLibraryEntryProjection.fromDispatch(entry.libraryEntryDispatch);
  }
}
