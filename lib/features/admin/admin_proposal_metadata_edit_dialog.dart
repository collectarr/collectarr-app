import 'dart:convert';

import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/admin/admin_primitives.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';
import 'package:collectarr_app/features/library/config/library_metadata_correction_source.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:flutter/material.dart';

class AdminProposalMetadataEditResult {
  const AdminProposalMetadataEditResult({
    required this.query,
    required this.providerItemId,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.metadataPayload,
  });

  final String query;
  final String? providerItemId;
  final String? title;
  final String? summary;
  final String? imageUrl;
  final JsonMap metadataPayload;
}

class AdminProposalMetadataEditDialog extends StatefulWidget {
  const AdminProposalMetadataEditDialog({required this.proposal});

  final AdminMetadataProposal proposal;

  @override
  State<AdminProposalMetadataEditDialog> createState() =>
      _AdminProposalMetadataEditDialogState();
}

class _AdminProposalMetadataEditDialogState
    extends State<AdminProposalMetadataEditDialog> {
  late final TextEditingController _queryController;
  late final TextEditingController _providerItemIdController;
  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _payloadController;
  late CatalogMediaKind _catalogKind;
  late Map<String, TextEditingController> _kindFieldControllers;
  late String _kind;
  var _showRawPayload = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final proposal = widget.proposal;
    final payload = JsonMap.from(
      proposal.metadataPayload ?? JsonMap(),
    );
    _kind = inferAdminProposalKind(proposal.provider, payload);
    _catalogKind = catalogMediaKindFromValue(_kind);
    _queryController = TextEditingController(text: proposal.query);
    _providerItemIdController =
        TextEditingController(text: proposal.providerItemId ?? '');
    _titleController = TextEditingController(text: proposal.title ?? '');
    _summaryController = TextEditingController(text: proposal.summary ?? '');
    _imageUrlController = TextEditingController(text: proposal.imageUrl ?? '');
    _kindFieldControllers = _createKindFieldControllers(
      _catalogKind,
      Map<String, Object?>.from(payload),
    );
    _payloadController = TextEditingController(
      text: const JsonEncoder.withIndent('  ').convert(payload),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    _providerItemIdController.dispose();
    _titleController.dispose();
    _summaryController.dispose();
    _imageUrlController.dispose();
    _disposeKindFieldControllers();
    _payloadController.dispose();
    super.dispose();
  }

  LibraryAdminContributor? get _adminContributor =>
      libraryAdminContributorForKind(_catalogKind);

  List<LibraryAdminProposalField> get _adminProposalFields =>
      _adminContributor?.proposalFields ?? const [];

  Map<String, TextEditingController> _createKindFieldControllers(
    CatalogMediaKind kind,
    Map<String, Object?> payload,
  ) {
    final contributor = libraryAdminContributorForKind(kind);
    if (contributor == null) {
      return <String, TextEditingController>{};
    }
    final values = LibraryMetadataCorrectionValues.fromSerialized(payload);
    return {
      for (final field in contributor.proposalFields)
        field.key: TextEditingController(text: field.read(values)),
    };
  }

  void _disposeKindFieldControllers() {
    for (final controller in _kindFieldControllers.values) {
      controller.dispose();
    }
  }

  Widget _kindProposalField(LibraryAdminProposalField field) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextFormField(
        controller: _kindFieldControllers[field.key],
        minLines: field.minLines,
        maxLines: field.maxLines,
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
          alignLabelWithHint: field.minLines > 1,
        ),
      ),
    );
  }

  JsonMap? _payloadForKindSwitch() {
    final rawPayload = _payloadController.text.trim();
    try {
      final decoded = rawPayload.isEmpty ? JsonMap() : jsonDecode(rawPayload);
      if (decoded is! Map) {
        throw const FormatException('Metadata payload must be a JSON object.');
      }
      final values = LibraryMetadataCorrectionValues.fromSerialized(
        Map<String, Object?>.from(decoded),
      );
      for (final field in _adminProposalFields) {
        field.write(values, _kindFieldControllers[field.key]!.text);
      }
      return JsonMap.from(values.toSerialized());
    } on FormatException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
      return null;
    }
  }

  void _save() {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() => _errorMessage = 'Query is required.');
      return;
    }
    final rawPayload = _payloadController.text.trim();
    JsonMap payload;
    try {
      final decoded = rawPayload.isEmpty ? JsonMap() : jsonDecode(rawPayload);
      if (decoded is! JsonMap) {
        setState(() {
          _errorMessage = 'Metadata payload must be a JSON object.';
        });
        return;
      }
      payload = decoded;
    } catch (_) {
      setState(() {
        _errorMessage = 'Metadata payload contains invalid JSON.';
      });
      return;
    }
    final semanticValues = LibraryMetadataCorrectionValues.fromSerialized(
      Map<String, Object?>.from(payload),
    );
    semanticValues.write('kind', _kind);
    for (final contributor in libraryAdminContributors) {
      if (contributor.kind == _catalogKind) {
        continue;
      }
      for (final field in contributor.proposalFields) {
        semanticValues.remove(field.key);
      }
    }
    try {
      for (final field in _adminProposalFields) {
        field.write(
          semanticValues,
          _kindFieldControllers[field.key]!.text,
        );
      }
    } on FormatException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
      return;
    }
    setState(() {
      _errorMessage = null;
    });
    Navigator.of(context).pop(
      AdminProposalMetadataEditResult(
        query: query,
        providerItemId: _emptyToNull(_providerItemIdController.text),
        title: _emptyToNull(_titleController.text),
        summary: _emptyToNull(_summaryController.text),
        imageUrl: _emptyToNull(_imageUrlController.text),
        metadataPayload: JsonMap.from(
          semanticValues.toSerialized(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      title: Text('Edit proposal metadata - ${widget.proposal.displayTitle}'),
      content: SizedBox(
        width: 980,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: 220,
                    child: CompactSearchDropdownFormField<String>(
                      initialValue: _kind,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Kind',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'comic', child: Text('Comic')),
                        DropdownMenuItem(value: 'manga', child: Text('Manga')),
                        DropdownMenuItem(value: 'anime', child: Text('Anime')),
                        DropdownMenuItem(value: 'book', child: Text('Book')),
                        DropdownMenuItem(value: 'game', child: Text('Game')),
                        DropdownMenuItem(
                          value: 'boardgame',
                          child: Text('Board game'),
                        ),
                        DropdownMenuItem(value: 'movie', child: Text('Movie')),
                        DropdownMenuItem(value: 'tv', child: Text('TV')),
                        DropdownMenuItem(value: 'music', child: Text('Music')),
                      ],
                      onChanged: (value) {
                        if (value == null || value == _kind) {
                          return;
                        }
                        final payload = _payloadForKindSwitch();
                        if (payload == null) {
                          return;
                        }
                        _disposeKindFieldControllers();
                        setState(() {
                          _kind = value;
                          _catalogKind = catalogMediaKindFromValue(value);
                          _kindFieldControllers = _createKindFieldControllers(
                              _catalogKind, payload);
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      controller: _queryController,
                      decoration: const InputDecoration(
                        labelText: 'Query',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      controller: _providerItemIdController,
                      decoration: const InputDecoration(
                        labelText: 'Provider item id',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _summaryController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Summary',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              for (final field in _adminProposalFields)
                _kindProposalField(field),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                value: _showRawPayload,
                contentPadding: EdgeInsets.zero,
                title: const Text('Show raw payload JSON'),
                subtitle: const Text('Advanced/manual override fields'),
                onChanged: (value) => setState(() {
                  _showRawPayload = value;
                }),
              ),
              if (_showRawPayload)
                TextFormField(
                  controller: _payloadController,
                  minLines: 8,
                  maxLines: 12,
                  decoration: const InputDecoration(
                    labelText: 'Metadata payload JSON',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Consolas',
                      ),
                )
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Kind-aware editor is active. Enable raw JSON only for advanced fields.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                AdminMessageRow(message: _errorMessage!, isError: true),
              ],
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save changes'),
        ),
      ],
    );
  }
}

String inferAdminProposalKind(String provider, JsonMap? payload) {
  final map = payload ?? JsonMap();
  final explicit = _emptyToNull(map['kind']?.toString() ?? '');
  if (explicit != null) {
    return explicit;
  }
  if (_payloadTrackRows(map['tracks']).isNotEmpty) {
    return 'music';
  }
  if (_payloadStringList(map['platforms']).isNotEmpty) {
    return 'game';
  }
  if (_payloadStringList(map['chapters']).isNotEmpty) {
    return 'manga';
  }
  if (_payloadStringList(map['episodes']).isNotEmpty) {
    return 'tv';
  }
  return switch (provider) {
    'gcd' || 'comicvine' => 'comic',
    'anilist' => 'anime',
    'igdb' => 'game',
    'tmdb' => 'movie',
    _ => 'comic',
  };
}

List<String> _payloadStringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return [
    for (final row in value)
      if (row != null && row.toString().trim().isNotEmpty)
        row.toString().trim(),
  ];
}

List<JsonMap> _payloadTrackRows(Object? value) {
  if (value is! List) {
    return const [];
  }
  return [
    for (final row in value)
      if (row is JsonMap) row,
  ];
}

String? _emptyToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
