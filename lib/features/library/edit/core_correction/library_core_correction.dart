import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'dart:convert';

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/canonical_correction_target.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/metadata/metadata_diff_panel.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:dio/dio.dart';

/// Raw edit values held until Core's canonical field schema resolves the
/// exact field scope and entity type. No entry, tracking, or personal values
/// are accepted here.
final class LibraryCoreCorrectionSource {
  const LibraryCoreCorrectionSource({
    required this.request,
    required this.coreCatalogRef,
    required this.originalFields,
    required this.proposedFields,
    this.description,
  });

  final LibraryEditDialogRequest request;
  final Map<String, Object?> originalFields;
  final Map<String, Object?> proposedFields;
  final String? description;
  final CatalogItemRef coreCatalogRef;

  factory LibraryCoreCorrectionSource.fromTypedFields({
    required LibraryEditDialogRequest request,
    required CatalogItemRef coreCatalogRef,
    required Map<String, Object?> originalFields,
    required Map<String, Object?> proposedFields,
    String? description,
  }) {
    return LibraryCoreCorrectionSource(
      request: request,
      coreCatalogRef: coreCatalogRef,
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
    required this.baseRevision,
    required this.baseHash,
    required this.currentFields,
    required this.fieldSchema,
  });

  final LibraryCoreCorrectionSource source;
  final String entityType;
  final String entityId;
  final String scope;
  final String baseRevision;
  final String baseHash;
  final Map<String, Object?> currentFields;
  final List<CanonicalCorrectionField> fieldSchema;

  CatalogMediaKind get kind => source.request.type.kind;
}

/// Returns changed canonical fields that are writable for the resolved Core
/// entity. The Core field schema is the sole allowlist; local and personal
/// values that are absent from it cannot enter a proposal.
Map<String, Object?> libraryCoreKindCorrectionChanges({
  required Map<String, Object?> originalFields,
  required Map<String, Object?> proposedFields,
  required List<CanonicalCorrectionField> fieldSchema,
  required String scope,
  required String entityType,
}) {
  final changes = <String, Object?>{};
  for (final field in fieldSchema) {
    if (!field.writable ||
        field.scope != scope ||
        field.entityType != entityType ||
        !_isSupportedCoreType(field.valueType) ||
        !proposedFields.containsKey(field.key)) {
      continue;
    }
    final proposed = proposedFields[field.key];
    if (_valuesEqual(originalFields[field.key], proposed) ||
        !_isCompatibleWithCoreType(field.valueType, proposed)) {
      continue;
    }
    changes[field.key] = proposed;
  }
  return Map.unmodifiable(changes);
}

/// Resolves an edit into one exact Core canonical target.
///
/// Local entries resolve through their optional source Core reference.
/// Personal fields are excluded by the Core field contract.
Future<LibraryResolvedCoreCorrection> resolveLibraryCoreCorrection({
  required LibraryCoreCorrectionSource source,
  required ApiClient apiClient,
}) async {
  final target = source.coreCatalogRef;
  if (target.kind != source.request.type.kind || target.id.trim().isEmpty) {
    throw StateError(
      'Core correction requires a valid Catalog Item reference for '
      '${source.request.type.kind.apiValue}.',
    );
  }
  final snapshot = await apiClient.getCanonicalCorrectionTarget(
    kind: target.kind,
    entityId: target.id,
    scope: 'catalog_item',
  );
  return LibraryResolvedCoreCorrection(
    source: source,
    entityType: snapshot.entityType,
    entityId: target.id,
    scope: 'catalog_item',
    baseRevision: snapshot.revision,
    baseHash: snapshot.hash,
    currentFields: snapshot.fields,
    fieldSchema: snapshot.fieldSchema,
  );
}

/// Resolves correction provenance at the edit boundary, before opening the
/// Core review. A local entry must carry an explicit source reference.
CatalogItemRef coreCatalogRefForEditRequest(
  LibraryEditDialogRequest request,
) =>
    switch (request.target) {
      CatalogTargetRef(:final ref) => ref,
      EntryTargetRef() => request.libraryEntry?.sourceCatalogRef ??
          (throw StateError(
            'This local entry has no source Core item to correct.',
          )),
      null => request.kindItem.catalogRef ??
          (throw StateError(
            'Core correction requires an explicit Catalog Item target.',
          )),
    };

bool _isSupportedCoreType(String valueType) => switch (valueType) {
      'string' ||
      'integer' ||
      'number' ||
      'boolean' ||
      'partial_date' ||
      'string_list' ||
      'link_list' ||
      'object_list' =>
        true,
      _ => false,
    };

/// Core's field schema is the allowlist for both field identity and value
/// shape. Unknown types fail closed so a kind payload cannot send a value
/// that Core would interpret differently.
bool _isCompatibleWithCoreType(String valueType, Object? value) {
  if (value == null) return true;
  return switch (valueType) {
    'string' => value is String,
    'integer' =>
      value is int || (value is num && value.isFinite && value % 1 == 0),
    'number' => value is num && value.isFinite,
    'boolean' => value is bool,
    'partial_date' => value is String || value is Map,
    'string_list' => value is List && value.every((entry) => entry is String),
    'link_list' ||
    'object_list' =>
      value is List && value.every((entry) => entry is Map),
    _ => false,
  };
}

Future<bool?> showLibraryCoreCorrectionReview({
  required BuildContext context,
  required LibraryCoreCorrectionSource source,
}) {
  final entry = LibraryEntryEditScope.maybeOf(context);
  final provenance = entry?.record.sourceCatalogRef;
  if (entry != null && provenance == null) {
    throw StateError('This local entry has no source Core item to correct.');
  }
  final resolved = entry != null
      ? LibraryCoreCorrectionSource(
          request: source.request,
          originalFields: source.originalFields,
          proposedFields: source.proposedFields,
          description: source.description,
          coreCatalogRef: provenance!,
        )
      : source;
  return showAppDialog<bool>(
    context: context,
    builder: (_) => _LibraryCoreCorrectionReviewDialog(source: resolved),
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
  late Future<LibraryResolvedCoreCorrection> _resolved;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolved = _resolve();
  }

  Future<LibraryResolvedCoreCorrection> _resolve() =>
      resolveLibraryCoreCorrection(
        source: widget.source,
        apiClient: ref.read(apiClientProvider),
      );

  Map<String, Object?> _changes(LibraryResolvedCoreCorrection value) =>
      libraryCoreKindCorrectionChanges(
        originalFields: widget.source.originalFields,
        proposedFields: widget.source.proposedFields,
        fieldSchema: value.fieldSchema,
        scope: value.scope,
        entityType: value.entityType,
      );

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      headerIcon: AppIcons.inlineEdit,
      title: Text(
          'Propose to Core — ${widget.source.request.kindItem.summary.primaryLabel}'),
      content: SizedBox(
        width: 760,
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
            return _proposalContent(snapshot.data!);
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
            onPressed: _isSending ||
                    !snapshot.hasData ||
                    _changes(snapshot.data!).isEmpty
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

  /// Only the Core fields this edit changed, each beside Core's value, in
  /// the comparison table; the edit dialog stays the place to change them.
  Widget _proposalContent(LibraryResolvedCoreCorrection value) {
    final palette = appPalette(context);
    final changes = _changes(value);
    final labels = {
      for (final field in value.fieldSchema) field.key: field.label,
    };
    // Edited catalog fields Core's schema does not take, named so the
    // reader knows they stay local.
    final refused = [
      for (final MapEntry(:key, value: proposed)
          in widget.source.proposedFields.entries)
        if (!changes.containsKey(key) &&
            !labels.containsKey(key) &&
            !_valuesEqual(widget.source.originalFields[key], proposed))
          _fieldLabel(key),
    ];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            changes.isEmpty
                ? 'Your edits match Core. Change a catalog field in the '
                    'editor to propose it; personal fields stay yours.'
                : 'Core reviewers will see these changes. Personal fields '
                    'are never sent.',
            style: TextStyle(color: palette.textMuted),
          ),
          const SizedBox(height: 12),
          if (changes.isNotEmpty)
            MetadataDiffPanel(
              key: const ValueKey('core-proposal-changes'),
              title: 'Your changes',
              showOnlyDifferences: false,
              entries: [
                for (final MapEntry(:key, value: proposed) in changes.entries)
                  MetadataDiffEntry(
                    label: labels[key] ?? key,
                    localValue: coreValueText(proposed),
                    serverValue: coreValueText(value.currentFields[key]),
                  ),
              ],
            ),
          if (refused.isNotEmpty)
            Text(
              'Core does not take proposals for ${refused.join(', ')} yet; '
              'save to keep them in your library.',
              key: const ValueKey('core-proposal-refused'),
              style: TextStyle(color: palette.difference),
            ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
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
            scope: value.scope,
            baseRevision: value.baseRevision,
            baseHash: value.baseHash,
            proposedFields: _changes(value),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        if (_isStale(error)) {
          _error = 'Core changed this item meanwhile. The table now shows '
              "Core's current values; check them and propose again.";
          _resolved = _resolve();
        } else {
          _error = _errorMessage(error);
        }
      });
    }
  }

  bool _isStale(Object error) {
    return error is DioException && error.response?.statusCode == 409;
  }
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

/// A Core value as the comparison shows it: dates formatted, lists joined
/// and named objects by their name.
String coreValueText(Object? value) {
  if (value == null) return '';
  if (value is Map) {
    final date = value.keys.any(const {'year', 'month', 'day'}.contains)
        ? PartialDate.tryParse(value)
        : null;
    if (date != null) return AppFormats.current.formatPartialDate(date);
    final name = value['name'] ?? value['title'] ?? value['url'];
    final role = value['role'];
    if (name != null) return role == null ? '$name' : '$role - $name';
    return jsonEncode(_sortJson(value));
  }
  if (value is Iterable) return value.map(coreValueText).join(', ');
  return value.toString().trim();
}

String _fieldLabel(String key) {
  final words = key.split('_').where((word) => word.isNotEmpty).join(' ');
  return words.isEmpty ? key : words[0].toUpperCase() + words.substring(1);
}

String _errorMessage(Object error) {
  if (error is FormatException) return error.message;
  final text = error.toString();
  return text.startsWith('Exception: ')
      ? text.substring('Exception: '.length)
      : text;
}
