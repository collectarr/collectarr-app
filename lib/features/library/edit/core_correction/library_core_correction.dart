import 'dart:convert';

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/core/api/dto/canonical_correction_target.dart';
import 'package:collectarr_app/core/models/catalog_edit_metadata.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
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
    required this.currentFields,
    required this.changes,
  });

  final LibraryCoreCorrectionSource source;
  final String entityType;
  final String entityId;
  final MetadataFieldScope scope;
  final String baseHash;
  final Map<String, Object?> currentFields;
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
  required ApiClient apiClient,
}) async {
  final target = _targetFor(source.request);
  final snapshot = await apiClient.getCanonicalCorrectionTarget(
    kind: source.request.type.kind,
    entityId: target.entityId,
    scope: target.scope.apiValue,
  );
  final fieldByKey = <String, CanonicalCorrectionField>{
    for (final field in snapshot.fieldSchema) field.key: field,
  };
  final changes = <LibraryCoreCorrectionChange>[];
  for (final entry in source.proposedFields.entries) {
    final field = fieldByKey[entry.key];
    if (field == null || !field.writable) continue;
    final before = snapshot.fields[entry.key];
    final after = entry.value;
    if (!_valuesEqual(before, after)) {
      changes.add(
        LibraryCoreCorrectionChange(
          key: entry.key,
          label: field.label,
          before: before,
          after: after,
        ),
      );
    }
  }
  if (changes.isEmpty) {
    throw StateError('There are no changed Core fields against the current Core snapshot.');
  }
  return LibraryResolvedCoreCorrection(
    source: source,
    entityType: snapshot.entityType,
    entityId: target.entityId,
    scope: MetadataFieldScope.fromApiValue(target.scope.apiValue),
    baseHash: snapshot.hash,
    currentFields: snapshot.fields,
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
      apiClient: ref.read(apiClientProvider),
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
                Expanded(child: _valueColumn('Core current', change.before)),
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
  final scope = request.resolvedScope;
  final catalogRef = request.kindItem.catalogRef;
  final entityId = switch (scope) {
    LibraryEntityScope.work => (catalogRef.rootId ?? catalogRef.id).trim(),
    LibraryEntityScope.release => catalogRef.id.trim(),
    LibraryEntityScope.copy => '',
  };
  if (entityId.isEmpty) {
    throw StateError(
      'Core correction requires a concrete ${scope.name} entity reference.',
    );
  }
  return _LibraryCoreCorrectionTarget(scope: scope, entityId: entityId);
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
