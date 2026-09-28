import 'dart:convert';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/domain/owned_copy_v1.dart';
import 'package:flutter/material.dart';

/// Editable App-owned copy values. Catalog Item data is intentionally absent.
final class OwnedCopyV1FormDraft {
  const OwnedCopyV1FormDraft({
    required this.kind,
    this.status = OwnedCopyStatusV1.inCollection,
    this.quantity = 1,
    this.indexNumber,
    this.locationId,
    this.owner,
    this.loanedTo,
    this.loanDueDate,
    this.isDigital,
    this.condition,
    this.purchaseDate,
    this.purchasePrice,
    this.purchaseStore,
    this.currentValue,
    this.soldAt,
    this.soldTo,
    this.salePrice,
    this.rating,
    this.notes,
    this.tags = const [],
    this.personalImages = const [],
    this.customFields = const [],
    this.kindDetails,
    this.validationError,
  });

  final CatalogMediaKind kind;
  final OwnedCopyStatusV1 status;
  final int quantity;
  final int? indexNumber;
  final String? locationId;
  final OwnedCopyOwnerV1? owner;
  final String? loanedTo;
  final PartialDate? loanDueDate;
  final bool? isDigital;
  final String? condition;
  final PartialDate? purchaseDate;
  final Money? purchasePrice;
  final String? purchaseStore;
  final Money? currentValue;
  final PartialDate? soldAt;
  final String? soldTo;
  final Money? salePrice;
  final int? rating;
  final String? notes;
  final List<String> tags;
  final List<OwnedCopyPersonalImageV1> personalImages;
  final List<OwnedCopyCustomFieldV1> customFields;
  final OwnedCopyKindDetailsV1? kindDetails;
  final String? validationError;

  factory OwnedCopyV1FormDraft.empty(CatalogMediaKind kind) =>
      OwnedCopyV1FormDraft(kind: kind);

  factory OwnedCopyV1FormDraft.fromCopy(OwnedCopyV1 copy) =>
      OwnedCopyV1FormDraft(
        kind: copy.catalogItem.kind,
        status: copy.status,
        indexNumber: copy.indexNumber,
        locationId: copy.locationId,
        owner: copy.owner,
        loanedTo: copy.loanedTo,
        loanDueDate: copy.loanDueDate,
        isDigital: copy.isDigital,
        condition: copy.condition,
        purchaseDate: copy.purchaseDate,
        purchasePrice: copy.purchasePrice,
        purchaseStore: copy.purchaseStore,
        currentValue: copy.currentValue,
        soldAt: copy.soldAt,
        soldTo: copy.soldTo,
        salePrice: copy.salePrice,
        rating: copy.rating,
        notes: copy.notes,
        tags: copy.tags,
        personalImages: copy.personalImages,
        customFields: copy.customFields,
        kindDetails: copy.kindDetails,
      );

  OwnedCopyV1FormDraft withValidationError(String? error) =>
      OwnedCopyV1FormDraft(
        kind: kind,
        status: status,
        quantity: quantity,
        indexNumber: indexNumber,
        locationId: locationId,
        owner: owner,
        loanedTo: loanedTo,
        loanDueDate: loanDueDate,
        isDigital: isDigital,
        condition: condition,
        purchaseDate: purchaseDate,
        purchasePrice: purchasePrice,
        purchaseStore: purchaseStore,
        currentValue: currentValue,
        soldAt: soldAt,
        soldTo: soldTo,
        salePrice: salePrice,
        rating: rating,
        notes: notes,
        tags: tags,
        personalImages: personalImages,
        customFields: customFields,
        kindDetails: kindDetails,
        validationError: error,
      );

  OwnedCopyV1 buildCopy(OwnedCopyV1 source) => OwnedCopyV1(
        ref: source.ref,
        catalogItem: source.catalogItem,
        status: status,
        createdAt: source.createdAt,
        updatedAt: DateTime.now().toUtc(),
        indexNumber: indexNumber,
        locationId: locationId,
        owner: owner,
        loanedTo: loanedTo,
        loanDueDate: loanDueDate,
        isDigital: isDigital,
        condition: condition,
        purchaseDate: purchaseDate,
        purchasePrice: purchasePrice,
        purchaseStore: purchaseStore,
        currentValue: currentValue,
        soldAt: soldAt,
        soldTo: soldTo,
        salePrice: salePrice,
        rating: rating,
        notes: notes,
        tags: tags,
        personalImages: personalImages,
        customFields: customFields,
        kindDetails: kindDetails ?? source.kindDetails,
      );
}

/// Shared copy form used by Add and Edit across all nine kinds.
final class OwnedCopyV1Form extends StatefulWidget {
  const OwnedCopyV1Form({
    required this.initial,
    required this.onChanged,
    this.showQuantity = false,
    this.showAdvanced = false,
    super.key,
  });

  final OwnedCopyV1FormDraft initial;
  final ValueChanged<OwnedCopyV1FormDraft> onChanged;
  final bool showQuantity;
  final bool showAdvanced;

  @override
  State<OwnedCopyV1Form> createState() => _OwnedCopyV1FormState();
}

final class _OwnedCopyV1FormState extends State<OwnedCopyV1Form> {
  late OwnedCopyStatusV1 _status = widget.initial.status;
  late bool _isDigital = widget.initial.isDigital ?? false;
  late int _quantity = widget.initial.quantity;
  late final Map<String, TextEditingController> _fields = {
    'index_number': _controller(widget.initial.indexNumber?.toString()),
    'location_id': _controller(widget.initial.locationId),
    'owner_id': _controller(widget.initial.owner?.id),
    'owner_label': _controller(widget.initial.owner?.label),
    'loaned_to': _controller(widget.initial.loanedTo),
    'loan_due_date': _controller(widget.initial.loanDueDate?.isoString),
    'condition': _controller(widget.initial.condition),
    'purchase_date': _controller(widget.initial.purchaseDate?.isoString),
    'purchase_price': _controller(_moneyAmount(widget.initial.purchasePrice)),
    'purchase_currency': _controller(widget.initial.purchasePrice?.currency),
    'purchase_store': _controller(widget.initial.purchaseStore),
    'current_value': _controller(_moneyAmount(widget.initial.currentValue)),
    'current_currency': _controller(widget.initial.currentValue?.currency),
    'sold_at': _controller(widget.initial.soldAt?.isoString),
    'sold_to': _controller(widget.initial.soldTo),
    'sale_price': _controller(_moneyAmount(widget.initial.salePrice)),
    'sale_currency': _controller(widget.initial.salePrice?.currency),
    'rating': _controller(widget.initial.rating?.toString()),
    'notes': _controller(widget.initial.notes),
    'tags': _controller(widget.initial.tags.join('\n')),
    'personal_images': _controller(jsonEncode([
      for (final image in widget.initial.personalImages) image.toJson(),
    ])),
    'custom_fields': _controller(jsonEncode([
      for (final field in widget.initial.customFields) field.toJson(),
    ])),
    for (final entry in _ownedKindFieldValues(
      widget.initial.kind,
      widget.initial.kindDetails,
    ).entries)
      entry.key: _controller(entry.value),
  };
  String? _error;

  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<OwnedCopyStatusV1>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Copy status'),
                  items: [
                    for (final status in OwnedCopyStatusV1.values)
                      DropdownMenuItem(
                        value: status,
                        child: Text(status.apiValue.replaceAll('_', ' ')),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _status = value);
                    _emit();
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: _textField(
                  'index_number',
                  'Index',
                  keyboardType: TextInputType.number,
                ),
              ),
              if (widget.showQuantity) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<int>(
                    initialValue: _quantity,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    items: [
                      for (var quantity = 1; quantity <= 20; quantity++)
                        DropdownMenuItem(
                          value: quantity,
                          child: Text('$quantity'),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _quantity = value);
                      _emit();
                    },
                  ),
                ),
              ],
            ],
          ),
          ExpansionTile(
            title: const Text('Owned copy details'),
            tilePadding: EdgeInsets.zero,
            children: [
              if (_status == OwnedCopyStatusV1.loaned)
                Row(
                  children: [
                    Expanded(child: _textField('loaned_to', 'Loaned to')),
                    const SizedBox(width: 8),
                    Expanded(
                      child:
                          _textField('loan_due_date', 'Due date (YYYY-MM-DD)'),
                    ),
                  ],
                ),
              _textField('location_id', 'Location ID'),
              Row(
                children: [
                  Expanded(child: _textField('owner_id', 'Owner ID')),
                  const SizedBox(width: 8),
                  Expanded(child: _textField('owner_label', 'Owner name')),
                ],
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Digital copy'),
                value: _isDigital,
                onChanged: (value) {
                  setState(() => _isDigital = value);
                  _emit();
                },
              ),
              _textField('condition', 'Condition'),
              Row(
                children: [
                  Expanded(child: _textField('purchase_date', 'Purchase date')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _textField('purchase_store', 'Purchase store')),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      'purchase_price',
                      'Purchase price',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                      width: 88,
                      child: _textField('purchase_currency', 'Currency')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _textField(
                      'current_value',
                      'Current value',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                      width: 88,
                      child: _textField('current_currency', 'Currency')),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _textField('sold_at', 'Sale date')),
                  const SizedBox(width: 8),
                  Expanded(child: _textField('sold_to', 'Buyer')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _textField(
                      'sale_price',
                      'Sale price',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                      width: 88,
                      child: _textField('sale_currency', 'Currency')),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: _textField(
                      'rating',
                      'Rating',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _textField(
                      'tags',
                      'Tags (one per line)',
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
              _textField('notes', 'Notes', minLines: 2, maxLines: 4),
              if (widget.showAdvanced) ...[
                _textField('personal_images', 'Personal images JSON',
                    minLines: 3, maxLines: 6),
                _textField('custom_fields', 'Custom fields JSON',
                    minLines: 3, maxLines: 6),
              ],
              if (widget.showAdvanced) ..._kindDetailsFields(),
              if (_error != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _error!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );

  Widget _textField(
    String key,
    String label, {
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          controller: _fields[key],
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          decoration: InputDecoration(labelText: label),
          onChanged: (_) => _emit(),
        ),
      );

  List<Widget> _kindDetailsFields() {
    final fields = <Widget>[];
    switch (widget.initial.kind) {
      case CatalogMediaKind.boardgame:
        fields
          ..add(_textField('kind_completeness', 'Completeness'))
          ..add(_boolField('kind_has_sleeves', 'Has sleeves'))
          ..add(_boolField('kind_painted_miniatures', 'Painted miniatures'));
        break;
      case CatalogMediaKind.comic:
        fields
          ..add(_textField('kind_grade', 'Grade'))
          ..add(_textField('kind_grading_company', 'Grading company'))
          ..add(_textField('kind_custom_label', 'Custom label'));
        break;
      case CatalogMediaKind.game:
        fields
          ..add(_textField('kind_completeness', 'Completeness'))
          ..add(_boolField('kind_has_box', 'Has box'))
          ..add(_boolField('kind_has_manual', 'Has manual'));
        break;
      case CatalogMediaKind.music:
        fields
          ..add(_textField('kind_package_condition', 'Package condition'))
          ..add(_textField('kind_media_condition', 'Media condition'))
          ..add(_textField('kind_last_cleaned_date', 'Last cleaned date'))
          ..add(
            _textField(
              'kind_signed_by',
              'Signed by (one name per line)',
              minLines: 1,
              maxLines: 3,
            ),
          )
          ..add(
            _textField(
              'kind_disc_storage',
              'Disc storage (number | device | slot)',
              minLines: 2,
              maxLines: 5,
            ),
          );
        break;
      case CatalogMediaKind.anime:
      case CatalogMediaKind.book:
      case CatalogMediaKind.manga:
      case CatalogMediaKind.movie:
      case CatalogMediaKind.tv:
      case CatalogMediaKind.unknown:
        break;
    }
    return fields;
  }

  Widget _boolField(String key, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: DropdownButtonFormField<String>(
          initialValue: _fields[key]!.text,
          decoration: InputDecoration(labelText: label),
          items: const [
            DropdownMenuItem(value: '', child: Text('Not specified')),
            DropdownMenuItem(value: 'true', child: Text('Yes')),
            DropdownMenuItem(value: 'false', child: Text('No')),
          ],
          onChanged: (value) {
            _fields[key]!.text = value ?? '';
            _emit();
          },
        ),
      );

  TextEditingController _controller(String? value) =>
      TextEditingController(text: value ?? '');

  void _emit() {
    try {
      final index = _parseOptionalInt('index_number');
      if (index != null && index < 0) {
        throw const FormatException('Index cannot be negative.');
      }
      final rating = _parseOptionalInt('rating');
      if (rating != null && rating < 0) {
        throw const FormatException('Rating cannot be negative.');
      }
      final ownerId = _value('owner_id');
      final ownerLabel = _value('owner_label');
      if ((ownerId == null) != (ownerLabel == null)) {
        throw const FormatException(
            'Owner ID and owner name must be entered together.');
      }
      final images = _decodeJsonList('personal_images')
          .map((row) => OwnedCopyPersonalImageV1.fromJson(row))
          .toList(growable: false);
      final customFields = _decodeJsonList('custom_fields')
          .map((row) => OwnedCopyCustomFieldV1.fromJson(row))
          .toList(growable: false);
      final loanDueDate = _parseDate('loan_due_date');
      if (loanDueDate != null && loanDueDate.day == null) {
        throw const FormatException('Loan due date must include a day.');
      }
      final draft = OwnedCopyV1FormDraft(
        kind: widget.initial.kind,
        status: _status,
        quantity: _quantity,
        indexNumber: index,
        locationId: _value('location_id'),
        owner: ownerId == null
            ? null
            : OwnedCopyOwnerV1(id: ownerId, label: ownerLabel!),
        loanedTo: _value('loaned_to'),
        loanDueDate: loanDueDate,
        isDigital: _isDigital,
        condition: _value('condition'),
        purchaseDate: _parseDate('purchase_date'),
        purchasePrice: _parseMoney('purchase_price', 'purchase_currency'),
        purchaseStore: _value('purchase_store'),
        currentValue: _parseMoney('current_value', 'current_currency'),
        soldAt: _parseDate('sold_at'),
        soldTo: _value('sold_to'),
        salePrice: _parseMoney('sale_price', 'sale_currency'),
        rating: rating,
        notes: _value('notes'),
        tags: _fields['tags']!
            .text
            .split('\n')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(growable: false),
        personalImages: images,
        customFields: customFields,
        kindDetails: _parseKindDetails(),
      );
      setState(() => _error = null);
      widget.onChanged(draft);
    } catch (error) {
      setState(() => _error = error.toString());
      widget.onChanged(widget.initial.withValidationError(error.toString()));
    }
  }

  int? _parseOptionalInt(String key) {
    final raw = _fields[key]!.text.trim();
    if (raw.isEmpty) return null;
    final value = int.tryParse(raw);
    if (value == null) throw FormatException('$key must be a whole number.');
    return value;
  }

  PartialDate? _parseDate(String key) {
    final raw = _fields[key]!.text.trim();
    if (raw.isEmpty) return null;
    final value = PartialDate.tryParse(raw);
    if (value == null) {
      throw FormatException('$key must be YYYY, YYYY-MM, or YYYY-MM-DD.');
    }
    return value;
  }

  Money? _parseMoney(String amountKey, String currencyKey) {
    final raw = _fields[amountKey]!.text.trim();
    if (raw.isEmpty) return null;
    final value = Money.parse(raw, _fields[currencyKey]!.text);
    if (value == null) {
      throw FormatException('$amountKey must be a valid amount.');
    }
    return value;
  }

  String? _value(String key) {
    final value = _fields[key]!.text.trim();
    return value.isEmpty ? null : value;
  }

  List<Map<String, Object?>> _decodeJsonList(String key) {
    final value = jsonDecode(_fields[key]!.text);
    if (value is! List || value.any((row) => row is! Map)) {
      throw FormatException('$key must be a JSON array of objects.');
    }
    return [for (final row in value) Map<String, Object?>.from(row as Map)];
  }

  OwnedCopyKindDetailsV1 _parseKindDetails() {
    String? value(String key) => _value('kind_$key');
    bool? boolean(String key) {
      final raw = value(key);
      if (raw == null) return null;
      if (raw == 'true') return true;
      if (raw == 'false') return false;
      throw FormatException('$key must be Yes or No.');
    }

    switch (widget.initial.kind) {
      case CatalogMediaKind.boardgame:
        return BoardGameOwnedCopyDetailsV1(
          completeness: value('completeness'),
          hasSleeves: boolean('has_sleeves'),
          paintedMiniatures: boolean('painted_miniatures'),
        );
      case CatalogMediaKind.comic:
        return ComicOwnedCopyDetailsV1(
          grade: value('grade'),
          gradingCompany: value('grading_company'),
          customLabel: value('custom_label'),
        );
      case CatalogMediaKind.game:
        return GameOwnedCopyDetailsV1(
          completeness: value('completeness'),
          hasBox: boolean('has_box'),
          hasManual: boolean('has_manual'),
        );
      case CatalogMediaKind.music:
        final storage = <MusicOwnedDiscStorageV1>[];
        for (final line in _fields['kind_disc_storage']!.text.split('\n')) {
          final value = line.trim();
          if (value.isEmpty) continue;
          final parts = value.split('|').map((part) => part.trim()).toList();
          if (parts.length != 3) {
            throw const FormatException(
              'Disc storage rows must use: number | device | slot.',
            );
          }
          final number = int.tryParse(parts[0]);
          if (number == null || number < 1) {
            throw const FormatException(
              'Disc storage numbers must be positive whole numbers.',
            );
          }
          storage.add(
            MusicOwnedDiscStorageV1(
              discNumber: number,
              storageDevice: parts[1].isEmpty ? null : parts[1],
              slot: parts[2].isEmpty ? null : parts[2],
            ),
          );
        }
        return MusicOwnedCopyDetailsV1(
          packageCondition: value('package_condition'),
          mediaCondition: value('media_condition'),
          lastCleanedDate: _parseDate('kind_last_cleaned_date'),
          signedBy: _fields['kind_signed_by']!
              .text
              .split('\n')
              .map((name) => name.trim())
              .where((name) => name.isNotEmpty),
          discStorage: storage,
        );
      case CatalogMediaKind.anime:
        return const AnimeOwnedCopyDetailsV1();
      case CatalogMediaKind.book:
        return BookOwnedCopyDetailsV1.fromJson(const {});
      case CatalogMediaKind.manga:
        return const MangaOwnedCopyDetailsV1();
      case CatalogMediaKind.movie:
        return const MovieOwnedCopyDetailsV1();
      case CatalogMediaKind.tv:
        return const TvOwnedCopyDetailsV1();
      case CatalogMediaKind.unknown:
        throw const FormatException('Unknown Owned Copy kind.');
    }
  }
}

Map<String, String?> _ownedKindFieldValues(
  CatalogMediaKind kind,
  OwnedCopyKindDetailsV1? details,
) {
  String? boolText(bool? value) => value?.toString();
  final resolved = details ?? OwnedCopyKindDetailsV1.fromJson(kind, const {});
  final values = <String, String?>{};
  switch (resolved) {
    case BoardGameOwnedCopyDetailsV1():
      values.addAll({
        'kind_completeness': resolved.completeness,
        'kind_has_sleeves': boolText(resolved.hasSleeves),
        'kind_painted_miniatures': boolText(resolved.paintedMiniatures),
      });
    case ComicOwnedCopyDetailsV1():
      values.addAll({
        'kind_grade': resolved.grade,
        'kind_grading_company': resolved.gradingCompany,
        'kind_custom_label': resolved.customLabel,
      });
    case GameOwnedCopyDetailsV1():
      values.addAll({
        'kind_completeness': resolved.completeness,
        'kind_has_box': boolText(resolved.hasBox),
        'kind_has_manual': boolText(resolved.hasManual),
      });
    case MusicOwnedCopyDetailsV1():
      values.addAll({
        'kind_package_condition': resolved.packageCondition,
        'kind_media_condition': resolved.mediaCondition,
        'kind_last_cleaned_date': resolved.lastCleanedDate?.isoString,
        'kind_signed_by': resolved.signedBy.join('\n'),
        'kind_disc_storage': resolved.discStorage
            .map(
              (disc) =>
                  '${disc.discNumber} | ${disc.storageDevice ?? ''} | ${disc.slot ?? ''}',
            )
            .join('\n'),
      });
    case AnimeOwnedCopyDetailsV1():
    case BookOwnedCopyDetailsV1():
    case MangaOwnedCopyDetailsV1():
    case MovieOwnedCopyDetailsV1():
    case TvOwnedCopyDetailsV1():
      break;
  }
  return values;
}

String? _moneyAmount(Money? money) => money?.toAmount().toStringAsFixed(2);
