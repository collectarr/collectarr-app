import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/features/collection/repositories/user_external_links_cache_repository.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_external_links_edit_session.dart';
import 'package:collectarr_app/features/library/edit/draft/editable_user_external_link.dart';
import 'package:flutter/material.dart';

/// Entry-local links edited alongside the rest of a kind's entry draft.
final class LibraryUserExternalLinksDraft {
  LibraryEntryRef? _libraryEntryRef;
  bool _loaded = false;
  bool _changed = false;

  final List<EditableUserExternalLink> userLinks = [];
  final List<EditableUserExternalLink> trailers = [];

  bool get isLoaded => _loaded;
  bool get isEditable => _libraryEntryRef != null;

  Future<void> load(
    LocalDatabase database,
    LibraryEntryRef libraryEntryRef,
  ) async {
    if (_loaded) return;
    _libraryEntryRef = libraryEntryRef;
    final stored = await UserExternalLinksCacheRepository(database)
        .listByLibraryEntryRef(libraryEntryRef);
    final seen = <String>{};
    for (final link in stored) {
      if (!seen.add(_dedupeKey(link.kind, link.label, link.url))) continue;
      _addEditable(link);
    }
    _loaded = true;
  }

  EditableUserExternalLink add({required String kind}) {
    final ref = _libraryEntryRef;
    if (ref == null) {
      throw StateError('User links can only be edited for a library entry.');
    }
    final link = EditableUserExternalLink(
      labelController: TextEditingController(),
      urlController: TextEditingController(),
      kind: kind,
      libraryEntryRef: ref,
    );
    (kind == 'trailer' ? trailers : userLinks).add(link);
    markChanged();
    return link;
  }

  void markChanged() => _changed = true;

  LibraryExternalLinksEditChange? buildEditChange(
    LibraryEntryRef libraryEntryRef,
  ) {
    if (!_changed) return null;
    if (_libraryEntryRef != libraryEntryRef) {
      throw StateError(
        'User links belong to ${_libraryEntryRef?.key}, not ${libraryEntryRef.key}.',
      );
    }
    final links = <UserExternalLink>[];
    for (final editable in [...userLinks, ...trailers]) {
      final link = editable.toUserExternalLink();
      if (link != null) links.add(link);
    }
    return LibraryExternalLinksEditChange(
      libraryEntryRef: libraryEntryRef,
      links: links,
    );
  }

  void dispose() {
    for (final link in [...userLinks, ...trailers]) {
      link.dispose();
    }
    userLinks.clear();
    trailers.clear();
  }

  void _addEditable(UserExternalLink link) {
    final editable = EditableUserExternalLink.fromUserExternalLink(link);
    if (editable.kind == 'trailer') {
      trailers.add(editable);
    } else {
      userLinks.add(editable);
    }
  }

  String _dedupeKey(String kind, String label, String url) =>
      '$kind|$label|$url';
}
