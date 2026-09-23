import 'dart:convert';

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/core/api/dto/canonical_correction_target.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_edit_contributors.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:dio/dio.dart';

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
    required this.baseRevision,
    required this.baseHash,
    required this.currentFields,
    required this.fieldSchema,
  });

  final LibraryCoreCorrectionSource source;
  final String entityType;
  final String entityId;
  final MetadataFieldScope scope;
  final String baseRevision;
  final String baseHash;
  final Map<String, Object?> currentFields;
  final List<CanonicalCorrectionField> fieldSchema;

  CatalogMediaKind get kind => source.request.type.kind;
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
  final target = resolveLibraryCoreCorrectionTargetForKind(
    kind: source.request.type.kind,
    node: source.request.node,
    requestedScope: source.request.scope,
    catalogRef: source.request.kindItem.reference,
  );
  final snapshot = await apiClient.getCanonicalCorrectionTarget(
    kind: source.request.type.kind,
    entityId: target.entityId,
    scope: target.scope.apiValue,
  );
  return LibraryResolvedCoreCorrection(
    source: source,
    entityType: snapshot.entityType,
    entityId: target.entityId,
    scope: MetadataFieldScope.fromApiValue(target.scope.apiValue),
    baseRevision: snapshot.revision,
    baseHash: snapshot.hash,
    currentFields: snapshot.fields,
    fieldSchema: snapshot.fieldSchema,
  );
}

bool _isSupportedCoreType(String valueType) => switch (valueType) {
      'string' ||
      'integer' ||
      'partial_date' ||
      'string_list' ||
      'link_list' ||
      'track_list' =>
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
    'partial_date' => value is String || value is Map,
    'string_list' => value is List && value.every((entry) => entry is String),
    'link_list' ||
    'track_list' =>
      value is List && value.every((entry) => entry is Map),
    _ => false,
  };
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
          field.scope != value.scope.apiValue ||
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
      'string_list' || 'link_list' || 'track_list' || 'partial_date' => true,
      _ => false,
    };
    return TextFormField(
      controller: controller,
      minLines: multiline ? 2 : 1,
      maxLines: multiline ? 5 : 1,
      keyboardType: field.valueType == 'integer'
          ? const TextInputType.numberWithOptions(signed: true)
          : null,
      decoration: InputDecoration(
        labelText: field.label,
        helperText: '${field.valueType} | Core current: $currentPreview',
        errorText: _fieldErrors[field.key],
      ),
      onChanged: (_) {
        _touchedFields.add(field.key);
        _fieldErrors.remove(field.key);
        setState(() => _error = null);
      },
    );
  }

  TextEditingController _fieldController(
    LibraryResolvedCoreCorrection value,
    CanonicalCorrectionField field,
  ) {
    return _fieldControllers.putIfAbsent(field.key, () {
      final hasProposal = widget.source.proposedFields.containsKey(field.key);
      final proposed = widget.source.proposedFields[field.key];
      final changedByKind = hasProposal &&
          !_valuesEqual(widget.source.originalFields[field.key], proposed);
      final initial =
          changedByKind && _isCompatibleWithCoreType(field.valueType, proposed)
              ? proposed
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
    for (final field in _editableFields(value)) {
      final hasKindProposal =
          widget.source.proposedFields.containsKey(field.key);
      final kindProposal = widget.source.proposedFields[field.key];
      final changedByKind = hasKindProposal &&
          !_valuesEqual(widget.source.originalFields[field.key], kindProposal);
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
            scope: value.scope.apiValue,
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
      case 'link_list' || 'track_list':
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
  if ((valueType == 'link_list' || valueType == 'track_list') &&
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
