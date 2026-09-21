import 'dart:convert';

import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/core/models/catalog_edit_metadata.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/state/api_provider.dart';

/// Raw edit values held until Core's canonical field schema resolves the
/// exact field scope and entity type. No owned, tracking, or personal values
/// are accepted here.
final class LibraryCoreCorrectionSource {
  const LibraryCoreCorrectionSource({
    required this.request,
    required this.originalFields,
    required this.proposedFields,
    this.description,
  });

  final LibraryEditDialogRequest request;
  final Map<String, Object?> originalFields;
  final Map<String, Object?> proposedFields;
  final String? description;

  factory LibraryCoreCorrectionSource.fromCommonMetadata({
    required LibraryEditDialogRequest request,
    required CatalogEditMetadata original,
    required CatalogEditMetadata proposed,
  }) {
    return LibraryCoreCorrectionSource(
      request: request,
      originalFields: _commonMetadataFields(original),
      proposedFields: _commonMetadataFields(proposed),
    );
  }

  factory LibraryCoreCorrectionSource.fromTypedFields({
    required LibraryEditDialogRequest request,
    required Map<String, Object?> originalFields,
    required Map<String, Object?> proposedFields,
    String? description,
  }) {
    return LibraryCoreCorrectionSource(
      request: request,
      originalFields: Map.unmodifiable(originalFields),
      proposedFields: Map.unmodifiable(proposedFields),
      description: description,
    );
  }
}

final class LibraryResolvedCoreCorrection {
  const LibraryResolvedCoreCorrection({
    required this.source,
    required this.entityType,
    required this.entityId,
    required this.scope,
    required this.baseHash,
    required this.changes,
  });

  final LibraryCoreCorrectionSource source;
  final String entityType;
  final String entityId;
  final MetadataFieldScope scope;
  final String baseHash;
  final List<LibraryCoreCorrectionChange> changes;

  CatalogMediaKind get kind => source.request.type.kind;

  Map<String, Object?> get proposedFields => {
        for (final change in changes) change.key: change.after,
      };
}

final class LibraryCoreCorrectionChange {
  const LibraryCoreCorrectionChange({
    required this.key,
    required this.label,
    required this.before,
    required this.after,
  });

  final String key;
  final String label;
  final Object? before;
  final Object? after;
}

/// Resolves an edit into one exact Core canonical target.
///
/// A copy intentionally resolves to its parent Release. The source values
/// still come from the release editor, and Core fields are selected from the
/// field contract, so Copy-only values can never cross this boundary.
Future<LibraryResolvedCoreCorrection> resolveLibraryCoreCorrection({
  required LibraryCoreCorrectionSource source,
}) async {
  final target = _targetFor(source.request);
  final changedKeys = <String>{
    ...source.originalFields.keys,
    ...source.proposedFields.keys,
  };
  final candidates = changedKeys
      .map((key) => _canonicalFieldSpec(source.request.type.kind, key))
      .whereType<_CanonicalFieldSpec>()
      .where((field) {
    if (target.scope == LibraryEntityScope.work) {
      return field.scope == MetadataFieldScope.work;
    }
    return field.scope != MetadataFieldScope.work &&
        field.scope != MetadataFieldScope.media &&
        field.scope != MetadataFieldScope.track &&
        field.scope != MetadataFieldScope.ownedCopy &&
        field.scope != MetadataFieldScope.trackingRecord;
  }).toList(growable: false);

  if (candidates.isEmpty) {
    throw StateError(
      target.scope == LibraryEntityScope.work
          ? 'This edit has no Core-owned Work fields to propose.'
          : 'This edit has no Core-owned Release fields to propose.',
    );
  }

  // A proposal is one exact Core scope/entity target. Do not silently merge
  // fields from another canonical entity just because the edit draft contains
  // them too.
  final selected = candidates.first;
  final selectedSpecs = candidates.where((field) {
    return field.scope == selected.scope &&
        field.entityType == selected.entityType;
  });
  final selectedByKey = <String, _CanonicalFieldSpec>{
    for (final field in selectedSpecs) field.key: field,
  };
  final changes = <LibraryCoreCorrectionChange>[];
  for (final entry in selectedByKey.entries) {
    final before = source.originalFields[entry.key];
    final after = source.proposedFields[entry.key];
    if (!_valuesEqual(before, after)) {
      changes.add(
        LibraryCoreCorrectionChange(
          key: entry.key,
          label: entry.value.label,
          before: before,
          after: after,
        ),
      );
    }
  }
  if (changes.isEmpty) {
    throw StateError('There are no changed Core fields to propose.');
  }

  final baseFields = <String, Object?>{
    for (final field in selectedSpecs)
      if (source.originalFields.containsKey(field.key))
        field.key: source.originalFields[field.key],
  };
  return LibraryResolvedCoreCorrection(
    source: source,
    entityType: selected.entityType,
    entityId: target.entityId,
    scope: selected.scope,
    baseHash: _hashFields(baseFields),
    changes: changes,
  );
}

Future<bool?> showLibraryCoreCorrectionReview({
  required BuildContext context,
  required LibraryCoreCorrectionSource source,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _LibraryCoreCorrectionReviewDialog(source: source),
  );
}

final class _LibraryCoreCorrectionReviewDialog extends ConsumerStatefulWidget {
  const _LibraryCoreCorrectionReviewDialog({required this.source});

  final LibraryCoreCorrectionSource source;

  @override
  ConsumerState<_LibraryCoreCorrectionReviewDialog> createState() =>
      _LibraryCoreCorrectionReviewDialogState();
}

final class _LibraryCoreCorrectionReviewDialogState
    extends ConsumerState<_LibraryCoreCorrectionReviewDialog> {
  late final Future<LibraryResolvedCoreCorrection> _resolved;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolved = resolveLibraryCoreCorrection(
      source: widget.source,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Core | Your proposal'),
      content: SizedBox(
        width: 640,
        child: FutureBuilder<LibraryResolvedCoreCorrection>(
          future: _resolved,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(
                _errorMessage(snapshot.error!),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              );
            }
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final value = snapshot.data!;
            return _proposalContent(value);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FutureBuilder<LibraryResolvedCoreCorrection>(
          future: _resolved,
          builder: (context, snapshot) => FilledButton.icon(
            onPressed: _isSending || !snapshot.hasData
                ? null
                : () => _propose(snapshot.data!),
            icon: _isSending
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: const Text('Propose to Core'),
          ),
        ),
      ],
    );
  }

  Widget _proposalContent(LibraryResolvedCoreCorrection value) {
    final request = widget.source.request;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${request.type.identity.singularLabel} · ${value.scope.apiValue}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            '${value.entityType} / ${value.entityId}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (request.node?.scope == LibraryEntityScope.copy) ...[
            const SizedBox(height: 8),
            const Chip(
              avatar: Icon(Icons.subdirectory_arrow_right, size: 16),
              label: Text('Copy context → parent Release'),
            ),
          ],
          const SizedBox(height: 16),
          for (final change in value.changes) ...[
            _changeRow(change),
            const SizedBox(height: 10),
          ],
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    );
  }

  Widget _changeRow(LibraryCoreCorrectionChange change) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(change.label,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _valueColumn('Current', change.before)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, size: 16),
                ),
                Expanded(child: _valueColumn('Your proposal', change.after)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _valueColumn(String label, Object? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(_displayValue(value)),
      ],
    );
  }

  Future<void> _propose(LibraryResolvedCoreCorrection value) async {
    setState(() {
      _isSending = true;
      _error = null;
    });
    try {
      await ref.read(apiClientProvider).proposeCanonicalCorrection(
            kind: value.kind,
            entityType: value.entityType,
            entityId: value.entityId,
            scope: value.scope.apiValue,
            baseHash: value.baseHash,
            proposedFields: value.proposedFields,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _error = _errorMessage(error);
      });
    }
  }
}

final class _LibraryCoreCorrectionTarget {
  const _LibraryCoreCorrectionTarget({
    required this.scope,
    required this.entityId,
  });

  final LibraryEntityScope scope;
  final String entityId;
}

_LibraryCoreCorrectionTarget _targetFor(LibraryEditDialogRequest request) {
  final node = request.node;
  if (node case LibraryCopyRef(:final releaseId)) {
    if (releaseId.trim().isEmpty) {
      throw StateError('Copy correction requires a concrete parent Release.');
    }
    return _LibraryCoreCorrectionTarget(
      scope: LibraryEntityScope.release,
      entityId: releaseId,
    );
  }
  if (node case LibraryReleaseRef(:final releaseId)) {
    if (releaseId.trim().isEmpty) {
      throw StateError('Release correction requires a concrete Release.');
    }
    return _LibraryCoreCorrectionTarget(
      scope: LibraryEntityScope.release,
      entityId: releaseId,
    );
  }
  if (node case LibraryWorkRef(:final workId)) {
    if (workId.trim().isEmpty) {
      throw StateError('Work correction requires a concrete Work.');
    }
    return _LibraryCoreCorrectionTarget(
      scope: LibraryEntityScope.work,
      entityId: workId,
    );
  }
  final rootId = request.kindItem.catalogRef.rootId?.trim();
  if (rootId == null || rootId.isEmpty) {
    throw StateError('Core correction requires a concrete Work or Release.');
  }
  return _LibraryCoreCorrectionTarget(
    scope: request.resolvedScope == LibraryEntityScope.release
        ? LibraryEntityScope.release
        : LibraryEntityScope.work,
    entityId: rootId,
  );
}

Map<String, Object?> _commonMetadataFields(CatalogEditMetadata metadata) => {
      'title': metadata.title,
      'display_title': metadata.displayTitle,
      'localized_title': metadata.localizedTitle,
      'original_title': metadata.originalTitle,
      'title_extension': metadata.titleExtension,
      'search_aliases': metadata.searchAliases,
      'sort_key': metadata.sortKey,
      'synopsis': metadata.synopsis,
      'cover_image_url': metadata.coverImageUrl,
      'thumbnail_image_url': metadata.thumbnailImageUrl,
      if (metadata.releaseDate != null)
        'release_date':
            metadata.releaseDate!.toIso8601String().split('T').first,
    };

String _hashFields(Map<String, Object?> fields) {
  return sha256.convert(utf8.encode(jsonEncode(_sortJson(fields)))).toString();
}

Object? _sortJson(Object? value) {
  if (value is Map) {
    final entries = value.entries.toList()
      ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
    return <String, Object?>{
      for (final entry in entries) entry.key.toString(): _sortJson(entry.value),
    };
  }
  if (value is Iterable) return [for (final entry in value) _sortJson(entry)];
  if (value is DateTime) return value.toIso8601String();
  return value;
}

bool _valuesEqual(Object? left, Object? right) {
  return jsonEncode(_sortJson(left)) == jsonEncode(_sortJson(right));
}

String _displayValue(Object? value) {
  if (value == null) return '—';
  if (value is Iterable) return value.join(', ');
  if (value is Map) return jsonEncode(_sortJson(value));
  return value.toString().trim().isEmpty ? '—' : value.toString();
}

String _errorMessage(Object error) {
  if (error is FormatException) return error.message;
  final text = error.toString();
  return text.startsWith('Exception: ')
      ? text.substring('Exception: '.length)
      : text;
}

final class _CanonicalFieldSpec {
  const _CanonicalFieldSpec({
    required this.key,
    required this.scope,
    required this.entityType,
    required this.label,
  });

  final String key;
  final MetadataFieldScope scope;
  final String entityType;
  final String label;
}

_CanonicalFieldSpec? _canonicalFieldSpec(CatalogMediaKind kind, String key) {
  final workEntity = switch (kind) {
    CatalogMediaKind.book => 'book_work',
    CatalogMediaKind.comic => 'comic_work',
    CatalogMediaKind.manga => 'manga_work',
    CatalogMediaKind.anime => 'anime_series',
    CatalogMediaKind.movie => 'movie_work',
    CatalogMediaKind.tv => 'tv_release',
    CatalogMediaKind.game => 'game_work',
    CatalogMediaKind.boardgame => 'boardgame_work',
    CatalogMediaKind.music => 'music_release_group',
    _ => null,
  };
  if (workEntity == null) return null;

  const workKeys = <String>{
    'title',
    'original_title',
    'localized_title',
    'title_extension',
    'sort_key',
    'search_aliases',
    'item_number',
    'genres',
    'audience_rating',
  };
  if (workKeys.contains(key)) {
    return _CanonicalFieldSpec(
      key: key,
      scope: MetadataFieldScope.work,
      entityType: workEntity,
      label: _fieldLabel(key),
    );
  }

  const releaseKeys = <String>{
    'physical_format',
    'edition_title',
    'release_date',
    'publisher',
    'imprint',
    'subtitle',
    'series_group',
    'barcode',
    'variant_name',
    'page_count',
    'catalog_number',
    'release_status',
    'country',
    'language',
  };
  if (!releaseKeys.contains(key)) return null;
  final release = _canonicalReleaseFieldTarget(kind, key);
  if (release == null) return null;
  return _CanonicalFieldSpec(
    key: key,
    scope: release.scope,
    entityType: release.entityType,
    label: _fieldLabel(key),
  );
}

({MetadataFieldScope scope, String entityType})? _canonicalReleaseFieldTarget(
  CatalogMediaKind kind,
  String key,
) {
  if (key == 'physical_format') {
    return switch (kind) {
      CatalogMediaKind.book => (
          scope: MetadataFieldScope.edition,
          entityType: 'book_edition'
        ),
      CatalogMediaKind.boardgame => (
          scope: MetadataFieldScope.edition,
          entityType: 'boardgame_edition'
        ),
      CatalogMediaKind.comic => (
          scope: MetadataFieldScope.issue,
          entityType: 'comic_issue'
        ),
      CatalogMediaKind.manga => (
          scope: MetadataFieldScope.issue,
          entityType: 'manga_work'
        ),
      CatalogMediaKind.music => (
          scope: MetadataFieldScope.release,
          entityType: 'music_release'
        ),
      CatalogMediaKind.anime => (
          scope: MetadataFieldScope.release,
          entityType: 'anime_series'
        ),
      CatalogMediaKind.movie => (
          scope: MetadataFieldScope.release,
          entityType: 'movie_release'
        ),
      CatalogMediaKind.tv => (
          scope: MetadataFieldScope.release,
          entityType: 'tv_release'
        ),
      CatalogMediaKind.game => (
          scope: MetadataFieldScope.release,
          entityType: 'game_release'
        ),
      _ => null,
    };
  }
  if (key == 'edition_title') {
    return switch (kind) {
      CatalogMediaKind.book => (
          scope: MetadataFieldScope.edition,
          entityType: 'book_edition'
        ),
      CatalogMediaKind.boardgame => (
          scope: MetadataFieldScope.edition,
          entityType: 'boardgame_edition'
        ),
      CatalogMediaKind.comic => (
          scope: MetadataFieldScope.issue,
          entityType: 'comic_issue'
        ),
      CatalogMediaKind.manga => (
          scope: MetadataFieldScope.issue,
          entityType: 'manga_work'
        ),
      CatalogMediaKind.anime => (
          scope: MetadataFieldScope.episode,
          entityType: 'anime_episode'
        ),
      CatalogMediaKind.music => (
          scope: MetadataFieldScope.release,
          entityType: 'music_release'
        ),
      CatalogMediaKind.movie => (
          scope: MetadataFieldScope.release,
          entityType: 'movie_release'
        ),
      CatalogMediaKind.tv => (
          scope: MetadataFieldScope.release,
          entityType: 'tv_release'
        ),
      CatalogMediaKind.game => (
          scope: MetadataFieldScope.release,
          entityType: 'game_release'
        ),
      _ => null,
    };
  }
  if (kind == CatalogMediaKind.game && key == 'age_rating') return null;
  return switch (kind) {
    CatalogMediaKind.book => (
        scope: MetadataFieldScope.edition,
        entityType: 'book_edition'
      ),
    CatalogMediaKind.boardgame => (
        scope: MetadataFieldScope.edition,
        entityType: 'boardgame_edition'
      ),
    CatalogMediaKind.comic => (
        scope: MetadataFieldScope.issue,
        entityType: 'comic_issue'
      ),
    CatalogMediaKind.manga => (
        scope: MetadataFieldScope.issue,
        entityType: 'manga_work'
      ),
    CatalogMediaKind.anime => (
        scope: MetadataFieldScope.episode,
        entityType: 'anime_episode'
      ),
    CatalogMediaKind.music => (
        scope: MetadataFieldScope.release,
        entityType: 'music_release'
      ),
    CatalogMediaKind.movie => (
        scope: MetadataFieldScope.release,
        entityType: 'movie_release'
      ),
    CatalogMediaKind.tv => (
        scope: MetadataFieldScope.release,
        entityType: 'tv_release'
      ),
    CatalogMediaKind.game => (
        scope: MetadataFieldScope.release,
        entityType: 'game_release'
      ),
    _ => null,
  };
}

String _fieldLabel(String key) {
  return key
      .split('_')
      .map((part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
