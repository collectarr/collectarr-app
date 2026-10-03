import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/user_external_links_cache_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata_children.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_models.dart';

class AnimeEditController {
  AnimeEditController({
    this.ref,
    required this.itemId,
    required this.catalogRef,
    this.initialCreators = const <AnimeCreditInput>[],
    this.initialTrailerLinks = const <TrailerLinkDto>[],
  });

  final WidgetRef? ref;
  final String itemId;
  final CatalogEntityRef catalogRef;
  LibraryEntryRef get libraryEntryRef => LibraryEntryRef(
        kind: catalogRef.kind,
        id: LibraryEntryId(itemId),
      );
  final List<AnimeCreditInput> initialCreators;
  final List<TrailerLinkDto> initialTrailerLinks;

  final List<EditableAnimeCredit> castCredits = [];
  final List<EditableAnimeCredit> crewCredits = [];
  final List<EditableUserExternalLink> userLinkEdits = [];
  final List<EditableUserExternalLink> userTrailerEdits = [];

  void initializeAnimeEditors() {
    final creators = initialCreators;
    castCredits.addAll(
      splitAnimeCredits(creators, kind: AnimeCreditKind.cast),
    );
    crewCredits.addAll(
      splitAnimeCredits(creators, kind: AnimeCreditKind.crew),
    );
  }

  List<AnimePersonMetadata> buildUpdatedCreators() {
    final edited = [
      ...castCredits,
      ...crewCredits,
    ].where((credit) => credit.nameController.text.trim().isNotEmpty).toList();
    final ordered = [
      for (var index = 0; index < edited.length; index++)
        (credit: edited[index], index: index),
    ]..sort((left, right) {
        final leftPosition =
            left.credit.originalIndex ?? initialCreators.length + left.index;
        final rightPosition =
            right.credit.originalIndex ?? initialCreators.length + right.index;
        return leftPosition.compareTo(rightPosition);
      });
    var nextSequence = initialCreators
            .map((credit) => credit.source?.sequence ?? -1)
            .fold<int>(
                -1, (current, value) => value > current ? value : current) +
        1;
    return [
      for (final row in ordered)
        row.credit.toMetadata(
          newSequence: row.credit.source == null ? nextSequence++ : null,
        ),
    ];
  }

  Future<void> loadUserExternalLinks() async {
    if (ref == null) {
      return;
    }
    final db = ref!.read(localDatabaseProvider);
    final repo = UserExternalLinksCacheRepository(db);
    final links = [
      ...await repo.listByLibraryEntryRef(libraryEntryRef),
      for (final link in initialTrailerLinks.where((link) => !link.isAutomatic))
        UserExternalLink(
          id: 'seed-$itemId-${link.kind}-${link.url.hashCode}',
          libraryEntryRef: libraryEntryRef,
          label: link.title ?? link.description ?? link.url,
          url: link.url,
          kind: link.kind == 'trailer' ? 'trailer' : 'custom',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
    ];
    final seen = <String>{};
    for (final link in links) {
      final key = '${link.kind}|${link.label}|${link.url}';
      if (!seen.add(key)) {
        continue;
      }
      final editable = EditableUserExternalLink.fromUserExternalLink(link);
      if (editable.kind == 'trailer') {
        userTrailerEdits.add(editable);
      } else {
        userLinkEdits.add(editable);
      }
    }
  }

  void dispose() {
    for (final credit in castCredits) {
      credit.dispose();
    }
    for (final credit in crewCredits) {
      credit.dispose();
    }
    for (final link in userLinkEdits) {
      link.dispose();
    }
    for (final link in userTrailerEdits) {
      link.dispose();
    }
  }

  List<TrailerLinkDto>? buildUpdatedTrailerUrls(List<TrailerLinkDto> existing) {
    final preservedTrailers = existing
        .where((link) => link.isTrailerLink && link.isAutomatic)
        .toList(growable: false);
    final providerExternalLinks = existing
        .where((link) => link.isExternalLink && link.isAutomatic)
        .toList(growable: false);
    final merged = <TrailerLinkDto>[
      ...preservedTrailers,
      ...providerExternalLinks,
    ];
    return merged.isEmpty ? null : List<TrailerLinkDto>.unmodifiable(merged);
  }

  Future<void> persistUserExternalLinks() async {
    if (ref == null) {
      return;
    }
    final db = ref!.read(localDatabaseProvider);
    final repo = UserExternalLinksCacheRepository(db);
    final links = <UserExternalLink>[];
    for (final link in userLinkEdits) {
      final resolved = link.toUserExternalLink();
      if (resolved != null) {
        links.add(resolved);
      }
    }
    for (final link in userTrailerEdits) {
      final resolved = link.toUserExternalLink();
      if (resolved != null) {
        links.add(resolved);
      }
    }
    await repo.replaceForLibraryEntry(libraryEntryRef, links);
    await enqueueLibraryEntrySnapshot(db, libraryEntryRef);
  }
}
