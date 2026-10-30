import 'dart:async';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/mutations/library_entry_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/library/covers/provider_cover_fetch.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Catalog image links shared by every kind's Catalog Item contract.
const _catalogImageKeys = {'cover_image_url', 'thumbnail_image_url'};

/// Wider covers are scaled to this width, twice the largest card cover.
const kProviderCoverMaxWidth = 600;

/// Whether [url] is a provider's image rather than one served by Core at
/// [coreBaseUrl]. Core images stay links and are cached; provider images are
/// kept with the entry.
bool isProviderImageUrl(String url, String coreBaseUrl) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
    return false;
  }
  final core = Uri.tryParse(coreBaseUrl.trim());
  return core == null || core.host != uri.host || core.port != uri.port;
}

/// Scales a downloaded cover to [kProviderCoverMaxWidth]; smaller covers keep
/// their original bytes. Throws when the bytes are not an image.
Uint8List normalizeProviderCover(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const FormatException('Not an image');
  if (decoded.width <= kProviderCoverMaxWidth) return bytes;
  return img.encodeJpg(
      img.copyResize(decoded,
          width: kProviderCoverMaxWidth,
          interpolation: img.Interpolation.average),
      quality: 85);
}

Future<Uint8List> _normalizeOffThread(Uint8List bytes) =>
    compute(normalizeProviderCover, bytes);

typedef ProviderCoverProgress = ({int done, int stored, int total});

/// Downloads the provider covers of a kind's entries and keeps them locally.
final class ProviderCoverLocalizer {
  const ProviderCoverLocalizer({
    required this.database,
    required this.mutations,
    required this.coreBaseUrl,
    this.fetch = fetchProviderCover,
    this.normalize = _normalizeOffThread,
    this.concurrency = 4,
    this.batchSize = 20,
  });

  final LocalDatabase database;
  final LibraryEntryMutations mutations;
  final String coreBaseUrl;
  final Future<Uint8List?> Function(Uri url) fetch;
  final Future<Uint8List> Function(Uint8List bytes) normalize;
  final int concurrency;
  final int batchSize;

  /// Entries of [kind] that show a provider cover and have no local one.
  Future<List<LibraryEntryRef>> pendingEntries(CatalogMediaKind kind) async {
    final records = await LibraryEntryStore(database).list(kind: kind);
    final refs = {
      for (final record in records)
        if (_providerCoverUrl(record) != null)
          LibraryEntryRef(kind: record.kind, id: LibraryEntryId(record.id)):
              record,
    };
    final types = await ItemImageRepository(database)
        .typesForLibraryEntryRefs(refs.keys.toList());
    return [
      for (final ref in refs.keys)
        if (!(types[ref]?.contains('front_cover') ?? false)) ref,
    ];
  }

  /// Downloads and stores the covers of [entries]; a failed download keeps
  /// the entry's link so it can be retried.
  Future<ProviderCoverProgress> localize(
    List<LibraryEntryRef> entries, {
    void Function(ProviderCoverProgress progress)? onProgress,
  }) async {
    final store = LibraryEntryStore(database);
    var done = 0, stored = 0, next = 0;
    final batch = <LibraryEntryRef, Uint8List>{};
    final dropped = <LibraryEntryRef, Set<String>>{};

    Future<void> flush() async {
      if (batch.isEmpty) return;
      final covers = Map.of(batch), keys = Map.of(dropped);
      batch.clear();
      dropped.clear();
      await mutations.storeProviderCovers(covers, droppedCatalogKeys: keys);
      stored += covers.length;
    }

    Future<void> worker() async {
      while (next < entries.length) {
        final ref = entries[next++];
        final record = await store.find(ref.kind, ref.id.value);
        final url = record == null ? null : _providerCoverUrl(record);
        final bytes = url == null ? null : await fetch(Uri.parse(url));
        if (record != null && bytes != null) {
          try {
            batch[ref] = await normalize(bytes);
            dropped[ref] = {
              for (final key in _catalogImageKeys)
                if (record.catalogData[key] case final String value
                    when isProviderImageUrl(value, coreBaseUrl))
                  key,
            };
            if (batch.length >= batchSize) await flush();
          } on FormatException {
            // Not an image: the link stays for a later retry.
          }
        }
        done++;
        onProgress?.call((done: done, stored: stored, total: entries.length));
      }
    }

    await Future.wait([for (var i = 0; i < concurrency; i++) worker()]);
    await flush();
    final result = (done: done, stored: stored, total: entries.length);
    onProgress?.call(result);
    return result;
  }

  String? _providerCoverUrl(LibraryEntryRecord record) =>
      switch (record.catalogData['cover_image_url']) {
        final String url when isProviderImageUrl(url, coreBaseUrl) => url,
        _ => null,
      };
}
