import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'dart:convert';

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/canonical_correction_target.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
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
  return showDialog<bool>(
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
  final Map<String, TextEditingController> _fieldControllers = {};
  final Set<String> _touchedFields = {};
  final Map<String, String> _fieldErrors = {};
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
  void dispose() {
    for (final controller in _fieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
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
    final fields = _editableFields(value).toList(growable: false);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${request.type.identity.singularLabel} · ${value.scope}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            '${value.entityType} / ${value.entityId}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (request.target is EntryTargetRef) ...[
            const SizedBox(height: 8),
            const Chip(
              avatar: Icon(Icons.subdirectory_arrow_right, size: 16),
              label: Text('Entry context → Core Catalog Item'),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Editable Core fields for this kind and scope (${fields.length})',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          if (fields.isEmpty)
            const Text('Core has no writable fields for this target.'),
          for (final field in fields) ...[
            _fieldEditor(value, field),
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

  Iterable<CanonicalCorrectionField> _editableFields(
    LibraryResolvedCoreCorrection value,
  ) sync* {
    for (final field in value.fieldSchema) {
      if (!field.writable ||
          field.scope != value.scope ||
          field.entityType != value.entityType ||
          !_isSupportedCoreType(field.valueType)) {
        continue;
      }
      yield field;
    }
  }

  Widget _fieldEditor(
    LibraryResolvedCoreCorrection value,
    CanonicalCorrectionField field,
  ) {
    final controller = _fieldController(value, field);
    final currentValue = _displayValue(value.currentFields[field.key]);
    final currentPreview = currentValue.length > 120
        ? '${currentValue.substring(0, 117)}...'
        : currentValue;
    final multiline = switch (field.valueType) {
      'string_list' || 'link_list' || 'object_list' || 'partial_date' => true,
      _ => false,
    };
    return LibraryFormField(
      label: field.label,
      child: LibraryTextFormControl(
        controller: controller,
        minLines: multiline ? 2 : 1,
        maxLines: multiline ? 5 : 1,
        keyboardType: switch (field.valueType) {
          'integer' => const TextInputType.numberWithOptions(signed: true),
          'number' => const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
          _ => null,
        },
        decoration: InputDecoration(
          helperText: '${field.valueType} | Core current: $currentPreview',
          errorText: _fieldErrors[field.key],
        ),
        onChanged: (_) {
          _touchedFields.add(field.key);
          _fieldErrors.remove(field.key);
          setState(() => _error = null);
        },
      ),
    );
  }

  TextEditingController _fieldController(
    LibraryResolvedCoreCorrection value,
    CanonicalCorrectionField field,
  ) {
    return _fieldControllers.putIfAbsent(field.key, () {
      final kindChanges = libraryCoreKindCorrectionChanges(
        originalFields: widget.source.originalFields,
        proposedFields: widget.source.proposedFields,
        fieldSchema: value.fieldSchema,
        scope: value.scope,
        entityType: value.entityType,
      );
      final changedByKind = kindChanges.containsKey(field.key);
      final initial = changedByKind
          ? kindChanges[field.key]
          : value.currentFields[field.key];
      return TextEditingController(
        text: _textForCoreValue(field.valueType, initial),
      );
    });
  }

  Future<void> _propose(LibraryResolvedCoreCorrection value) async {
    setState(() {
      _isSending = true;
      _error = null;
      _fieldErrors.clear();
    });
    final proposedFields = <String, Object?>{};
    final errors = <String, String>{};
    final kindChanges = libraryCoreKindCorrectionChanges(
      originalFields: widget.source.originalFields,
      proposedFields: widget.source.proposedFields,
      fieldSchema: value.fieldSchema,
      scope: value.scope,
      entityType: value.entityType,
    );
    for (final field in _editableFields(value)) {
      final changedByKind = kindChanges.containsKey(field.key);
      if (!changedByKind && !_touchedFields.contains(field.key)) continue;

      final parsed = _parseCoreValue(
        field.valueType,
        _fieldControllers[field.key]?.text ?? '',
      );
      if (parsed.error != null) {
        errors[field.key] = parsed.error!;
        continue;
      }
      if (!_isCompatibleWithCoreType(field.valueType, parsed.value)) {
        errors[field.key] = 'Value does not match Core field type.';
        continue;
      }
      if (!_valuesEqual(value.currentFields[field.key], parsed.value)) {
        proposedFields[field.key] = parsed.value;
      }
    }
    if (errors.isNotEmpty) {
      setState(() {
        _isSending = false;
        _fieldErrors.addAll(errors);
        _error = 'Fix the highlighted values before submitting.';
      });
      return;
    }
    if (proposedFields.isEmpty) {
      setState(() {
        _isSending = false;
        _error = 'There are no changed Core fields to propose.';
      });
      return;
    }
    try {
      await ref.read(apiClientProvider).proposeCanonicalCorrection(
            kind: value.kind,
            entityType: value.entityType,
            entityId: value.entityId,
            scope: value.scope,
            baseRevision: value.baseRevision,
            baseHash: value.baseHash,
            proposedFields: proposedFields,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      if (_isStale(error)) {
        setState(() {
          _isSending = false;
          _error =
              'Core changed this target. The current snapshot was refreshed; review the diff and resubmit explicitly.';
          _resolved = resolveLibraryCoreCorrection(
            source: widget.source,
            apiClient: ref.read(apiClientProvider),
          );
        });
        return;
      }
      setState(() {
        _isSending = false;
        _error = _errorMessage(error);
      });
    }
  }

  bool _isStale(Object error) {
    return error is DioException && error.response?.statusCode == 409;
  }

  ({Object? value, String? error}) _parseCoreValue(
    String valueType,
    String text,
  ) {
    switch (valueType) {
      case 'string':
        return (value: text.isEmpty ? null : text, error: null);
      case 'integer':
        if (text.trim().isEmpty) return (value: null, error: null);
        final parsed = int.tryParse(text.trim());
        return parsed == null
            ? (value: null, error: 'Enter a whole number.')
            : (value: parsed, error: null);
      case 'number':
        if (text.trim().isEmpty) return (value: null, error: null);
        final parsed = double.tryParse(text.trim());
        return parsed == null || !parsed.isFinite
            ? (value: null, error: 'Enter a valid number.')
            : (value: parsed, error: null);
      case 'boolean':
        if (text.trim().isEmpty) return (value: null, error: null);
        return switch (text.trim().toLowerCase()) {
          'true' => (value: true, error: null),
          'false' => (value: false, error: null),
          _ => (value: null, error: 'Enter true or false.'),
        };
      case 'partial_date':
        if (text.trim().isEmpty) return (value: null, error: null);
        if (!text.trimLeft().startsWith('{')) {
          return (value: text.trim(), error: null);
        }
        try {
          final decoded = jsonDecode(text);
          return decoded is Map
              ? (value: decoded, error: null)
              : (value: null, error: 'Enter a date or a JSON date object.');
        } on FormatException {
          return (value: null, error: 'Enter a valid date or JSON object.');
        }
      case 'string_list':
        return (
          value: text
              .split(RegExp(r'[\r\n]+'))
              .map((entry) => entry.trim())
              .where((entry) => entry.isNotEmpty)
              .toList(growable: false),
          error: null,
        );
      case 'link_list' || 'object_list':
        if (text.trim().isEmpty) return (value: <Object?>[], error: null);
        try {
          final decoded = jsonDecode(text);
          if (decoded is List && decoded.every((entry) => entry is Map)) {
            return (value: decoded, error: null);
          }
          return (value: null, error: 'Enter a JSON list of objects.');
        } on FormatException {
          return (value: null, error: 'Enter a valid JSON list of objects.');
        }
      default:
        return (value: null, error: 'Unsupported Core field type.');
    }
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

String _displayValue(Object? value) {
  if (value == null) return '—';
  if (value is Iterable) return value.join(', ');
  if (value is Map) return jsonEncode(_sortJson(value));
  return value.toString().trim().isEmpty ? '—' : value.toString();
}

String _textForCoreValue(String valueType, Object? value) {
  if (value == null) return '';
  if (valueType == 'string_list' && value is Iterable) {
    return value.join('\n');
  }
  if ((valueType == 'link_list' || valueType == 'object_list') &&
      value is Iterable) {
    return const JsonEncoder.withIndent('  ').convert(value);
  }
  if (valueType == 'partial_date' && value is Map) {
    return const JsonEncoder.withIndent('  ').convert(value);
  }
  return value.toString();
}

String _errorMessage(Object error) {
  if (error is FormatException) return error.message;
  final text = error.toString();
  return text.startsWith('Exception: ')
      ? text.substring('Exception: '.length)
      : text;
}
