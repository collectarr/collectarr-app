import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/domain/owned_copy_v1.dart';
import 'package:collectarr_app/features/library/state/catalog_item_v1_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class OwnedCopyV1CustomFieldsEditor extends ConsumerStatefulWidget {
  const OwnedCopyV1CustomFieldsEditor({
    required this.kind,
    required this.initial,
    required this.onChanged,
    required this.onValidationChanged,
    super.key,
  });

  final CatalogMediaKind kind;
  final List<OwnedCopyCustomFieldV1> initial;
  final ValueChanged<List<OwnedCopyCustomFieldV1>> onChanged;
  final ValueChanged<String?> onValidationChanged;

  @override
  ConsumerState<OwnedCopyV1CustomFieldsEditor> createState() =>
      _OwnedCopyV1CustomFieldsEditorState();
}

final class _OwnedCopyV1CustomFieldsEditorState
    extends ConsumerState<OwnedCopyV1CustomFieldsEditor> {
  late final Map<String, OwnedCopyValueV1?> _values = {
    for (final field in widget.initial) field.fieldDefinitionId: field.value,
  };
  late final Map<String, CustomFieldValueType> _types = {
    for (final field in widget.initial)
      field.fieldDefinitionId: field.valueType,
  };
  final Map<String, TextEditingController> _controllers = {};
  String? _error;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final definitions = ref.watch(
      ownedCopyV1CustomFieldsProvider(widget.kind),
    );
    return definitions.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(8),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Text('Could not load custom fields: $error'),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        for (final definition in items) {
          _types[definition.id] = definition.valueType;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 4),
              child: Text('Custom fields',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            for (final definition in items) _field(definition),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _field(CustomFieldDefinition definition) {
    final current = _values[definition.id];
    final type = definition.valueType;
    switch (type) {
      case CustomFieldValueType.boolean:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: DropdownButtonFormField<bool?>(
            initialValue:
                current is OwnedCopyBooleanValueV1 ? current.value : null,
            decoration: InputDecoration(labelText: definition.name),
            items: const [
              DropdownMenuItem<bool?>(
                  value: null, child: Text('Not specified')),
              DropdownMenuItem<bool?>(value: true, child: Text('Yes')),
              DropdownMenuItem<bool?>(value: false, child: Text('No')),
            ],
            onChanged: (value) => _update(
              definition,
              value == null ? null : OwnedCopyBooleanValueV1(value),
            ),
          ),
        );
      case CustomFieldValueType.singleSelect:
        final options = definition.optionValues;
        final selected =
            current is OwnedCopyTextValueV1 && options.contains(current.value)
                ? current.value
                : null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: DropdownButtonFormField<String>(
            initialValue: selected,
            decoration: InputDecoration(labelText: definition.name),
            items: [
              for (final option in options)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: (value) => _update(
              definition,
              value == null ? null : OwnedCopyTextValueV1(value),
            ),
          ),
        );
      case CustomFieldValueType.multiSelect:
        final selected = current is OwnedCopyStringListValueV1
            ? current.value.toSet()
            : <String>{};
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InputDecorator(
            decoration: InputDecoration(labelText: definition.name),
            child: Wrap(
              spacing: 6,
              children: [
                for (final option in definition.optionValues)
                  FilterChip(
                    label: Text(option),
                    selected: selected.contains(option),
                    onSelected: (value) {
                      final updated = {...selected};
                      value ? updated.add(option) : updated.remove(option);
                      _update(
                        definition,
                        updated.isEmpty
                            ? null
                            : OwnedCopyStringListValueV1(updated),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      case CustomFieldValueType.currency:
        return Row(
          children: [
            Expanded(
              child: _textInput(
                definition,
                label: definition.name,
                initialText: current is OwnedCopyMoneyValueV1
                    ? current.value.toAmount().toStringAsFixed(2)
                    : '',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onText: (text) => _parseMoney(definition, text),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: _textInput(
                definition,
                suffix: 'currency',
                label: 'Currency',
                initialText: current is OwnedCopyMoneyValueV1
                    ? current.value.currency
                    : Money.defaultCurrency,
                onText: (text) {
                  final amount = _controller(definition.id).text;
                  final money = Money.parse(amount, text);
                  _update(definition,
                      money == null ? null : OwnedCopyMoneyValueV1(money));
                },
              ),
            ),
          ],
        );
      case CustomFieldValueType.date:
        return _textInput(
          definition,
          label: '${definition.name} (YYYY-MM-DD)',
          initialText: current is OwnedCopyPartialDateValueV1
              ? current.value.isoString ?? ''
              : '',
          onText: (text) {
            if (text.trim().isEmpty) {
              return _update(definition, null);
            }
            final value = PartialDate.tryParse(text.trim());
            if (value == null || value.isEmpty) {
              return _invalid('${definition.name} needs a valid date.');
            }
            _update(definition, OwnedCopyPartialDateValueV1(value));
          },
        );
      case CustomFieldValueType.number:
        return _textInput(
          definition,
          label: definition.name,
          initialText:
              current is OwnedCopyNumberValueV1 ? current.value.toString() : '',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onText: (text) {
            if (text.trim().isEmpty) return _update(definition, null);
            final value = num.tryParse(text.trim());
            if (value == null || !value.isFinite) {
              return _invalid('${definition.name} needs a valid number.');
            }
            _update(definition, OwnedCopyNumberValueV1(value));
          },
        );
      case CustomFieldValueType.text:
      case CustomFieldValueType.longText:
      case CustomFieldValueType.time:
      case CustomFieldValueType.url:
      case CustomFieldValueType.person:
        return _textInput(
          definition,
          label: definition.name,
          initialText: current is OwnedCopyTextValueV1 ? current.value : '',
          maxLines: type == CustomFieldValueType.longText ? 4 : 1,
          onText: (text) => _update(
            definition,
            text.trim().isEmpty ? null : OwnedCopyTextValueV1(text.trim()),
          ),
        );
    }
  }

  Widget _textInput(
    CustomFieldDefinition definition, {
    required String label,
    required String initialText,
    String? suffix,
    TextInputType? keyboardType,
    int maxLines = 1,
    required ValueChanged<String> onText,
  }) {
    final key = suffix == null ? definition.id : '${definition.id}:$suffix';
    final controller = _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: initialText),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        minLines: maxLines == 1 ? null : 2,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        onChanged: onText,
      ),
    );
  }

  TextEditingController _controller(String key) =>
      _controllers.putIfAbsent(key, TextEditingController.new);

  void _parseMoney(CustomFieldDefinition definition, String amount) {
    final currency = _controller('${definition.id}:currency').text;
    if (amount.trim().isEmpty) {
      return _update(definition, null);
    }
    final money = Money.parse(amount, currency);
    if (money == null) {
      return _invalid('${definition.name} needs a valid amount.');
    }
    _update(definition, OwnedCopyMoneyValueV1(money));
  }

  void _invalid(String message) {
    setState(() => _error = message);
    widget.onValidationChanged(message);
  }

  void _update(CustomFieldDefinition definition, OwnedCopyValueV1? value) {
    setState(() {
      _error = null;
      _values[definition.id] = value;
    });
    widget.onValidationChanged(null);
    widget.onChanged(_buildFields());
  }

  List<OwnedCopyCustomFieldV1> _buildFields() => [
        for (final entry in _values.entries)
          if (entry.value != null)
            OwnedCopyCustomFieldV1(
              fieldDefinitionId: entry.key,
              valueType: _types[entry.key] ?? _typeFor(entry.value!),
              value: entry.value,
            ),
      ];

  CustomFieldValueType _typeFor(OwnedCopyValueV1 value) => switch (value) {
        OwnedCopyTextValueV1() => CustomFieldValueType.text,
        OwnedCopyNumberValueV1() => CustomFieldValueType.number,
        OwnedCopyBooleanValueV1() => CustomFieldValueType.boolean,
        OwnedCopyStringListValueV1() => CustomFieldValueType.multiSelect,
        OwnedCopyPartialDateValueV1() => CustomFieldValueType.date,
        OwnedCopyMoneyValueV1() => CustomFieldValueType.currency,
      };
}
