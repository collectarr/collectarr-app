part of 'catalog_item_v1_workspace_page.dart';

final class _CatalogItemCommonFields extends StatelessWidget {
  const _CatalogItemCommonFields({
    required this.titleController,
    required this.sortTitleController,
    required this.subtitleController,
    required this.releaseYearController,
    required this.releaseMonthController,
    required this.releaseDayController,
  });

  final TextEditingController titleController;
  final TextEditingController sortTitleController;
  final TextEditingController subtitleController;
  final TextEditingController releaseYearController;
  final TextEditingController releaseMonthController;
  final TextEditingController releaseDayController;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Title *'),
          ),
          TextField(
            controller: sortTitleController,
            decoration: const InputDecoration(labelText: 'Sort Title'),
          ),
          TextField(
            controller: subtitleController,
            decoration: const InputDecoration(labelText: 'Subtitle'),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Release date',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: releaseYearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          hintText: 'YYYY',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: releaseMonthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Month',
                          hintText: 'MM',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: releaseDayController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Day',
                          hintText: 'DD',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
}

final class _SelectedCatalogItemDetails extends StatelessWidget {
  const _SelectedCatalogItemDetails({
    required this.summary,
    required this.details,
    required this.loading,
    required this.error,
    required this.accent,
  });

  final CatalogItemSummaryV1Dto summary;
  final CatalogItemV1Dto? details;
  final bool loading;
  final String? error;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final rows = details == null ? const <String>[] : _summaryRows(details!);
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.album_outlined, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    summary.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (loading)
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 6),
              Text(
                'Could not load item details: $error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ] else if (rows.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(rows.join(' Â· ')),
            ],
          ],
        ),
      ),
    );
  }
}

List<String> _summaryRows(CatalogItemV1Dto item) {
  final details = item.details.toJson();
  const skip = {
    'kind',
    'title',
    'sort_title',
    'subtitle',
    'images',
    'tracks',
    'episodes',
    'credits',
    'contributors',
    'links',
    'identifiers',
  };
  final schema = _kindDetailsSchema(catalogMediaKindFromApiValue(item.kind));
  final properties = schema['properties'] as Map<String, dynamic>;
  final rows = <String>[];
  for (final entry in properties.entries) {
    if (skip.contains(entry.key)) continue;
    final text = _summaryText(details[entry.key]);
    if (text == null) continue;
    final fieldSchema = entry.value as Map<String, dynamic>;
    final label = fieldSchema['title'] as String? ?? _humanize(entry.key);
    rows.add('$label $text');
    if (rows.length == 6) break;
  }
  return rows;
}

List<String> _visibleCatalogColumnRows(
  CatalogItemV1Dto item,
  Set<String> visibleColumns,
) {
  final details = item.details.toJson();
  final schema = _kindDetailsSchema(catalogMediaKindFromApiValue(item.kind));
  final properties = schema['properties'] as Map<String, dynamic>;
  return [
    for (final entry in properties.entries)
      if (visibleColumns.contains(entry.key))
        if (_summaryText(details[entry.key]) case final String value)
          '${(entry.value as Map<String, dynamic>)['title'] as String? ?? _humanize(entry.key)} $value',
  ];
}

List<String> _catalogNames(Object? value) {
  if (value is! List) return const [];
  return [
    for (final entry in value)
      if (entry is String && entry.trim().isNotEmpty)
        entry.trim()
      else if (entry is Map && entry['name'] is String)
        (entry['name'] as String).trim(),
  ];
}

String? _summaryText(Object? value) {
  if (value is String) return value.trim().isEmpty ? null : value.trim();
  if (value is num || value is bool) return value.toString();
  if (value is List) {
    final values = _catalogNames(value);
    return values.isEmpty ? null : values.join(', ');
  }
  if (value is Map && value['year'] is int) {
    final year = value['year'];
    final month = value['month'];
    final day = value['day'];
    if (month is int && day is int) {
      return '$year-${month.toString().padLeft(2, '0')}-'
          '${day.toString().padLeft(2, '0')}';
    }
    if (month is int) return '$year-${month.toString().padLeft(2, '0')}';
    return '$year';
  }
  return null;
}

Map<String, dynamic> _kindDetailsSchema(CatalogMediaKind kind) {
  return catalogItemV1WriteSchemaForKind(kind);
}

Map<String, dynamic> _kindDetailValues(
  CatalogMediaKind kind,
  Map<String, dynamic> details,
) {
  final properties =
      _kindDetailsSchema(kind)['properties'] as Map<String, dynamic>;
  final values = <String, dynamic>{};
  for (final entry in properties.entries) {
    if (_commonCatalogKeys.contains(entry.key) || entry.key == 'kind') continue;
    if (details.containsKey(entry.key)) {
      values[entry.key] = _sanitizeCatalogValue(
        details[entry.key],
        entry.value as Map<String, dynamic>,
      );
    }
  }
  return values;
}

Map<String, dynamic> _sanitizeKindWriteDetails(
  CatalogMediaKind kind,
  Map<String, dynamic> details,
) {
  final properties =
      _kindDetailsSchema(kind)['properties'] as Map<String, dynamic>;
  final sanitized = <String, dynamic>{};
  for (final entry in properties.entries) {
    if (details.containsKey(entry.key)) {
      sanitized[entry.key] = _sanitizeCatalogValue(
        details[entry.key],
        entry.value as Map<String, dynamic>,
      );
    }
  }
  return sanitized;
}

const _commonCatalogKeys = {'title', 'sort_title', 'subtitle', 'release_date'};

List<String> _catalogIdentitySearchValues(Map<String, dynamic> details) {
  const uniqueIdentifierTypes = {
    'barcode',
    'ean',
    'gtin',
    'isbn',
    'isbn10',
    'isbn13',
    'upc',
  };
  final values = <String>{};
  void add(Object? value) {
    if (value is String && value.trim().isNotEmpty) values.add(value.trim());
  }

  add(details['barcode']);
  final identifiers = details['identifiers'];
  if (identifiers is List) {
    for (final identifier in identifiers) {
      if (identifier is! Map) continue;
      final rawType = identifier['identifier_type'];
      if (rawType is! String) continue;
      final type =
          rawType.trim().toLowerCase().replaceAll('-', '').replaceAll('_', '');
      if (uniqueIdentifierTypes.contains(type)) add(identifier['value']);
    }
  }
  return values.toList(growable: false);
}

Object? _sanitizeCatalogValue(
  Object? value,
  Map<String, dynamic> schema,
) {
  final defs = catalogItemV1SchemaDefinitions;
  if (schema[r'$ref'] case final String ref) {
    final definition = defs[ref.split('/').last];
    if (definition is Map<String, dynamic>) {
      return _sanitizeCatalogValue(value, definition);
    }
  }
  if (schema['anyOf'] case final List<dynamic> variants) {
    final nonNull = variants.cast<Map<String, dynamic>>().where(
          (candidate) => candidate['type'] != 'null',
        );
    if (nonNull.isNotEmpty) {
      return _sanitizeCatalogValue(value, nonNull.first);
    }
  }
  if (schema['type'] == 'array' && value is List) {
    final itemSchema = schema['items'];
    if (itemSchema is Map<String, dynamic>) {
      return [
        for (final item in value) _sanitizeCatalogValue(item, itemSchema),
      ];
    }
  }
  if (schema['type'] == 'object' && value is Map) {
    final properties = schema['properties'];
    if (properties is Map<String, dynamic>) {
      return {
        for (final entry in properties.entries)
          if (value.containsKey(entry.key))
            entry.key: _sanitizeCatalogValue(
              value[entry.key],
              entry.value as Map<String, dynamic>,
            ),
      };
    }
  }
  return value;
}

final class _CatalogItemV1KindFields extends StatefulWidget {
  const _CatalogItemV1KindFields({
    required this.kind,
    required this.values,
    required this.onChanged,
  });

  final CatalogMediaKind kind;
  final Map<String, dynamic> values;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  State<_CatalogItemV1KindFields> createState() =>
      _CatalogItemV1KindFieldsState();
}

final class _CatalogItemV1KindFieldsState
    extends State<_CatalogItemV1KindFields> {
  late final Map<String, dynamic> _properties =
      _kindDetailsSchema(widget.kind)['properties'] as Map<String, dynamic>;
  late Map<String, dynamic> _values =
      _kindDetailValues(widget.kind, widget.values);

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[];
    for (final entry in _properties.entries) {
      final key = entry.key;
      if (_commonCatalogKeys.contains(key) || key == 'kind') continue;
      final schema = entry.value as Map<String, dynamic>;
      final label = schema['title'] as String? ?? _humanize(key);
      fields.add(
        _CatalogItemSchemaField(
          key: ValueKey('catalog-field-${widget.kind.apiValue}-$key'),
          label: label,
          schema: schema,
          value: _values[key],
          onChanged: (value) => _setValue(key, value),
        ),
      );
    }
    if (fields.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Kind details', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          ...fields,
        ],
      ),
    );
  }

  void _setValue(String key, Object? value) {
    _values = Map<String, dynamic>.from(_values)..[key] = value;
    widget.onChanged(Map<String, dynamic>.from(_values));
  }
}

/// Renders primitive and repeated child fields from the pinned Core schema.
/// Object arrays are edited as rows, so users never need to hand-write JSON
/// for tracks, episodes, credits, images, identifiers, or similar children.
final class _CatalogItemSchemaField extends StatefulWidget {
  const _CatalogItemSchemaField({
    required this.label,
    required this.schema,
    required this.value,
    required this.onChanged,
    this.depth = 0,
    super.key,
  });

  final String label;
  final Map<String, dynamic> schema;
  final Object? value;
  final ValueChanged<Object?> onChanged;
  final int depth;

  @override
  State<_CatalogItemSchemaField> createState() =>
      _CatalogItemSchemaFieldState();
}

final class _CatalogItemSchemaFieldState
    extends State<_CatalogItemSchemaField> {
  late final TextEditingController _controller = TextEditingController(
    text: _fieldText(widget.value, widget.schema),
  );
  String? _lastEmittedText;

  @override
  void didUpdateWidget(covariant _CatalogItemSchemaField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _lastEmittedText == null &&
        _fieldText(oldWidget.value, widget.schema) !=
            _fieldText(widget.value, widget.schema)) {
      _controller.value = TextEditingValue(
        text: _fieldText(widget.value, widget.schema),
        selection: TextSelection.collapsed(
          offset: _fieldText(widget.value, widget.schema).length,
        ),
      );
    }
    _lastEmittedText = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schema = _resolvedSchema(widget.schema);
    final enumValues = _enumValues(schema);
    if (enumValues != null) {
      final current = widget.value is String ? widget.value as String : null;
      return DropdownButtonFormField<String>(
        initialValue: current,
        decoration: InputDecoration(labelText: widget.label),
        items: [
          for (final value in enumValues)
            DropdownMenuItem(value: value, child: Text(value)),
        ],
        onChanged: widget.onChanged,
      );
    }

    final type = _fieldType(schema);
    if (type == 'boolean') {
      return SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(widget.label),
        value: widget.value == true,
        onChanged: widget.onChanged,
      );
    }
    if (type == 'array') return _buildArray(context, schema);
    if (type == 'object') return _buildObject(context, schema);

    return TextField(
      controller: _controller,
      keyboardType: type == 'integer' || type == 'number'
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(labelText: widget.label),
      onChanged: (text) {
        _lastEmittedText = text;
        widget.onChanged(_parseFieldText(text, schema));
      },
    );
  }

  Widget _buildArray(BuildContext context, Map<String, dynamic> schema) {
    final itemSchemaRaw = schema['items'];
    if (itemSchemaRaw is! Map<String, dynamic>) {
      return _unsupportedField(context);
    }
    final itemSchema = _resolvedSchema(itemSchemaRaw);
    final values = widget.value is List
        ? List<Object?>.from(widget.value as List)
        : <Object?>[];
    final itemType = _fieldType(itemSchema);
    if (itemType != 'object' && itemType != 'array') {
      return TextField(
        controller: _controller,
        minLines: 1,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: widget.label,
          helperText: 'Enter one value per line.',
          alignLabelWithHint: true,
        ),
        onChanged: (text) {
          _lastEmittedText = text;
          widget.onChanged(_parseFieldText(text, schema));
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton.icon(
                onPressed: () => widget.onChanged([
                  ...values,
                  _emptySchemaValue(itemSchema),
                ]),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          for (var index = 0; index < values.length; index++)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: 'Remove ${widget.label} item',
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          final updated = List<Object?>.from(values)
                            ..removeAt(index);
                          widget.onChanged(updated);
                        },
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ),
                    _CatalogItemSchemaField(
                      key: ValueKey(
                          'catalog-child-${widget.label}-$index-${widget.depth}'),
                      label: '${widget.label} ${index + 1}',
                      schema: itemSchema,
                      value: values[index],
                      depth: widget.depth + 1,
                      onChanged: (value) {
                        final updated = List<Object?>.from(values);
                        updated[index] = value;
                        widget.onChanged(updated);
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildObject(BuildContext context, Map<String, dynamic> schema) {
    final properties = schema['properties'];
    if (properties is! Map<String, dynamic>) {
      return _unsupportedField(context);
    }
    if (widget.value is! Map) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => widget.onChanged(_emptySchemaValue(schema)),
            icon: const Icon(Icons.add, size: 18),
            label: Text('Add ${widget.label}'),
          ),
        ),
      );
    }
    final value = Map<String, dynamic>.from(widget.value as Map);
    return Padding(
      padding: EdgeInsets.only(top: widget.depth == 0 ? 8 : 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.depth == 0)
            Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
          for (final entry in properties.entries)
            _CatalogItemSchemaField(
              key: ValueKey(
                  'catalog-object-${widget.label}-${entry.key}-${widget.depth}'),
              label:
                  (entry.value as Map<String, dynamic>)['title'] as String? ??
                      _humanize(entry.key),
              schema: entry.value as Map<String, dynamic>,
              value: value[entry.key],
              depth: widget.depth + 1,
              onChanged: (updatedValue) {
                widget.onChanged(Map<String, dynamic>.from(value)
                  ..[entry.key] = updatedValue);
              },
            ),
        ],
      ),
    );
  }

  Widget _unsupportedField(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          '${widget.label} uses an unsupported schema shape.',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
}

Map<String, dynamic> _resolvedSchema(Map<String, dynamic> schema) {
  final defs = catalogItemV1SchemaDefinitions;
  if (schema[r'$ref'] case final String ref) {
    final definition = defs[ref.split('/').last];
    if (definition is Map<String, dynamic>) return definition;
  }
  if (schema['anyOf'] case final List<dynamic> variants) {
    for (final variant in variants.whereType<Map<String, dynamic>>()) {
      if (variant['type'] != 'null') return _resolvedSchema(variant);
    }
  }
  return schema;
}

Object? _emptySchemaValue(Map<String, dynamic> schema) {
  final resolved = _resolvedSchema(schema);
  final type = _fieldType(resolved);
  if (type == 'object') {
    final properties = resolved['properties'];
    if (properties is Map<String, dynamic>) {
      return {
        for (final entry in properties.entries)
          entry.key: _emptySchemaValue(entry.value as Map<String, dynamic>),
      };
    }
    return <String, dynamic>{};
  }
  if (type == 'array') return <Object?>[];
  if (type == 'boolean') return false;
  if (type == 'string') return '';
  return null;
}

String _fieldType(Map<String, dynamic> schema) =>
    _resolvedSchema(schema)['type'] as String? ?? 'string';

List<String>? _enumValues(Map<String, dynamic> schema) {
  if (schema['enum'] case final List<dynamic> values) {
    return values.whereType<String>().toList(growable: false);
  }
  if (schema['anyOf'] case final List<dynamic> variants) {
    for (final variant in variants.cast<Map<String, dynamic>>()) {
      final nested = _enumValues(variant);
      if (nested != null) return nested;
    }
  }
  return null;
}

String _fieldText(Object? value, Map<String, dynamic> schema) {
  if (value == null) return '';
  if (_fieldType(schema) == 'array' && value is List) {
    final itemSchema = schema['items'];
    if (itemSchema is Map<String, dynamic> && itemSchema['type'] == 'string') {
      return value.whereType<String>().join('\n');
    }
    return jsonEncode(value);
  }
  if (_fieldType(schema) == 'object' || _fieldType(schema) == 'array') {
    return jsonEncode(value);
  }
  return value.toString();
}

Object? _parseFieldText(String text, Map<String, dynamic> schema) {
  final type = _fieldType(schema);
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return _schemaAllowsNull(schema)
        ? null
        : switch (type) {
            'array' => <Object?>[],
            'string' => '',
            _ => null,
          };
  }
  if (type == 'array') {
    final itemSchema = schema['items'];
    if (itemSchema is Map<String, dynamic> && itemSchema['type'] == 'string') {
      return text
          .split('\n')
          .map((entry) => entry.trim())
          .where((entry) => entry.isNotEmpty)
          .toList(growable: false);
    }
    if (itemSchema is Map<String, dynamic> && itemSchema['type'] == 'integer') {
      return text
          .split('\n')
          .map((entry) => int.tryParse(entry.trim()) ?? entry.trim())
          .where((entry) => entry.toString().isNotEmpty)
          .toList(growable: false);
    }
    try {
      final value = jsonDecode(text);
      return value is List ? value : text;
    } on FormatException {
      return text;
    }
  }
  if (type == 'object') {
    try {
      final value = jsonDecode(text);
      return value is Map ? value : text;
    } on FormatException {
      return text;
    }
  }
  if (type == 'integer') return int.tryParse(trimmed) ?? text;
  if (type == 'number') return num.tryParse(trimmed) ?? text;
  return text;
}

bool _schemaAllowsNull(Map<String, dynamic> schema) =>
    schema['anyOf'] is List &&
    (schema['anyOf'] as List).any(
      (variant) => variant is Map && variant['type'] == 'null',
    );

String _humanize(String value) => value
    .split('_')
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');
