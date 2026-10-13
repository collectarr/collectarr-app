import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/features/collection/repositories/user_external_links_cache_repository.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_local_edit_change.dart';

final class LibraryExternalLinksEditChange implements LibraryLocalEditChange {
  LibraryExternalLinksEditChange({
    required this.libraryEntryRef,
    required Iterable<UserExternalLink> links,
  }) : links = List.unmodifiable(links);

  final LibraryEntryRef libraryEntryRef;
  final List<UserExternalLink> links;

  @override
  Future<void> persist(LocalDatabase database) {
    return UserExternalLinksCacheRepository(database)
        .replaceForLibraryEntry(libraryEntryRef, links);
  }
}
