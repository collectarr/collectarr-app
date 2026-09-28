import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_copy_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:flutter/foundation.dart';

enum OwnedCopyStatusV1 {
  inCollection('in_collection'),
  loaned('loaned'),
  sold('sold');

  const OwnedCopyStatusV1(this.apiValue);

  final String apiValue;

  static OwnedCopyStatusV1 fromApiValue(Object? value) {
    for (final status in values) {
      if (status.apiValue == value) return status;
    }
    throw FormatException('Unsupported Owned Copy status: $value');
  }
}

/// Type-safe JSON value for App-owned custom fields.
sealed class OwnedCopyValueV1 {
  const OwnedCopyValueV1();

  Object? get value;

  static OwnedCopyValueV1 fromJson(Object? raw) {
    if (raw is String) return OwnedCopyTextValueV1(raw);
    if (raw is bool) return OwnedCopyBooleanValueV1(raw);
    if (raw is int) return OwnedCopyNumberValueV1(raw);
    if (raw is double && raw.isFinite) return OwnedCopyNumberValueV1(raw);
    if (raw is List && raw.every((entry) => entry is String)) {
      return OwnedCopyStringListValueV1(raw.cast<String>());
    }
    if (raw is Map) {
      final json = Map<String, Object?>.from(raw);
      return switch (json['type']) {
        'partial_date' => _partialDateValueFromJson(json),
        'money' => OwnedCopyMoneyValueV1.fromJson(json),
        _ => throw FormatException(
            'Unsupported typed Owned Copy value: ${json['type']}',
          ),
      };
    }
    throw FormatException('Unsupported Owned Copy custom value: $raw');
  }
}

OwnedCopyValueV1 _partialDateValueFromJson(Map<String, Object?> json) {
  _requireOnlyDetails(json, 'custom date', const {'type', 'value'});
  final value = _optionalPartialDate(json['value']);
  if (value == null) {
    throw const FormatException('Custom date must have a value.');
  }
  return OwnedCopyPartialDateValueV1(value);
}

final class OwnedCopyTextValueV1 extends OwnedCopyValueV1 {
  const OwnedCopyTextValueV1(this.value);

  @override
  final String value;
}

final class OwnedCopyNumberValueV1 extends OwnedCopyValueV1 {
  OwnedCopyNumberValueV1(this.value) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, 'value', 'Must be a finite number.');
    }
  }

  @override
  final num value;
}

final class OwnedCopyBooleanValueV1 extends OwnedCopyValueV1 {
  const OwnedCopyBooleanValueV1(this.value);

  @override
  final bool value;
}

final class OwnedCopyStringListValueV1 extends OwnedCopyValueV1 {
  OwnedCopyStringListValueV1(Iterable<String> value)
      : value = List.unmodifiable(value);

  @override
  final List<String> value;
}

final class OwnedCopyPartialDateValueV1 extends OwnedCopyValueV1 {
  OwnedCopyPartialDateValueV1(this.value) {
    if (value.isEmpty || !_isValidPartialDate(value)) {
      throw ArgumentError.value(
          value, 'value', 'Must be a valid partial date.');
    }
  }

  @override
  final PartialDate value;
}

final class OwnedCopyMoneyValueV1 extends OwnedCopyValueV1 {
  const OwnedCopyMoneyValueV1(this.value);

  @override
  final Money value;

  factory OwnedCopyMoneyValueV1.fromJson(Map<String, Object?> json) {
    _requireOnlyDetails(
        json, 'custom money', const {'type', 'cents', 'currency'});
    if (json['type'] != 'money') {
      throw const FormatException('Custom money value needs type "money".');
    }
    final cents = json['cents'];
    final currency = json['currency'];
    if (cents is! int || currency is! String || currency.trim().isEmpty) {
      throw const FormatException(
          'Money custom field needs cents and currency.');
    }
    final money = Money.fromCents(cents, currency);
    if (money == null) {
      throw const FormatException(
        'Money custom field is outside the supported range.',
      );
    }
    return OwnedCopyMoneyValueV1(money);
  }
}

@immutable
final class OwnedCopyCustomFieldV1 {
  OwnedCopyCustomFieldV1({
    required this.fieldDefinitionId,
    required this.valueType,
    this.value,
  }) {
    if (fieldDefinitionId.trim().isEmpty) {
      throw ArgumentError.value(
        fieldDefinitionId,
        'fieldDefinitionId',
        'A custom field definition ID is required.',
      );
    }
    if (!_customValueMatchesType(valueType, value)) {
      throw ArgumentError.value(
        value,
        'value',
        'The custom field value must match ${valueType.apiValue}.',
      );
    }
  }

  final String fieldDefinitionId;
  final CustomFieldValueType valueType;
  final OwnedCopyValueV1? value;

  factory OwnedCopyCustomFieldV1.fromJson(Map<String, Object?> json) {
    _requireOnlyDetails(
      json,
      'custom field',
      const {'field_definition_id', 'value_type', 'value'},
    );
    final id = json['field_definition_id'];
    final type = json['value_type'];
    if (id is! String || id.trim().isEmpty || type is! String) {
      throw const FormatException(
        'Owned Copy custom field needs an ID and value type.',
      );
    }
    CustomFieldValueType? valueType;
    for (final candidate in CustomFieldValueType.values) {
      if (candidate.apiValue == type) {
        valueType = candidate;
        break;
      }
    }
    if (valueType == null) {
      throw FormatException('Unsupported custom field type: $type');
    }
    final fieldValue = json.containsKey('value') && json['value'] != null
        ? OwnedCopyValueV1.fromJson(json['value'])
        : null;
    if (!_customValueMatchesType(valueType, fieldValue)) {
      throw FormatException(
        'Custom field $id has a value that does not match type $type.',
      );
    }
    return OwnedCopyCustomFieldV1(
      fieldDefinitionId: id,
      valueType: valueType,
      value: fieldValue,
    );
  }

  Map<String, Object?> toJson() => {
        'field_definition_id': fieldDefinitionId,
        'value_type': valueType.apiValue,
        'value': _serializeOwnedCopyValue(value),
      };
}

@immutable
final class OwnedCopyOwnerV1 {
  OwnedCopyOwnerV1({required String id, required String label})
      : id = id.trim(),
        label = label.trim() {
    if (this.id.isEmpty || this.label.isEmpty) {
      throw ArgumentError('An Owned Copy owner needs an ID and a label.');
    }
  }

  final String id;
  final String label;

  Map<String, Object?> toJson() => {'id': id, 'label': label};

  factory OwnedCopyOwnerV1.fromJson(Map<String, Object?> json) {
    _requireOnlyDetails(json, 'owner', const {'id', 'label'});
    final id = json['id'];
    final label = json['label'];
    if (id is! String || label is! String) {
      throw const FormatException('Owned Copy owner needs an ID and a label.');
    }
    return OwnedCopyOwnerV1(id: id, label: label);
  }
}

@immutable
final class OwnedCopyPersonalImageV1 {
  OwnedCopyPersonalImageV1({
    required this.id,
    required Uint8List data,
    this.description,
    this.imageType = 'other',
    this.position = 0,
  })  : _data = Uint8List.fromList(data),
        assert(id != ''),
        assert(position >= 0) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'An image ID is required.');
    }
    if (position < 0) {
      throw ArgumentError.value(position, 'position', 'Cannot be negative.');
    }
    if (imageType.trim().isEmpty) {
      throw ArgumentError.value(
        imageType,
        'imageType',
        'An image type is required.',
      );
    }
    if (data.isEmpty) {
      throw ArgumentError.value(data, 'data', 'An image cannot be empty.');
    }
  }

  final String id;
  final Uint8List _data;
  Uint8List get data => Uint8List.fromList(_data);
  final String? description;
  final String imageType;
  final int position;

  factory OwnedCopyPersonalImageV1.fromJson(Map<String, Object?> json) {
    _requireOnlyDetails(
      json,
      'personal image',
      const {'id', 'data', 'description', 'image_type', 'position'},
    );
    final id = json['id'];
    final encoded = json['data'];
    if (id is! String || id.trim().isEmpty || encoded is! String) {
      throw const FormatException(
          'Personal image needs an ID and base64 data.');
    }
    final position = json['position'];
    if (json.containsKey('position') && position is! int) {
      throw const FormatException(
          'Personal image position must be an integer.');
    }
    final description = _optionalString(json['description'], 'description');
    final imageType = json.containsKey('image_type')
        ? _requiredString(json['image_type'], 'image_type')
        : 'other';
    return OwnedCopyPersonalImageV1(
      id: id,
      data: Uint8List.fromList(_decodeBase64(encoded)),
      description: description,
      imageType: imageType,
      position: position as int? ?? 0,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'data': _encodeBase64(data),
        'description': description,
        'image_type': imageType,
        'position': position,
      };
}

/// Typed App-owned fields that differ by kind.
sealed class OwnedCopyKindDetailsV1 {
  const OwnedCopyKindDetailsV1();

  CatalogMediaKind get kind;
  Map<String, Object?> toJson();

  static OwnedCopyKindDetailsV1 fromJson(
    CatalogMediaKind kind,
    Map<String, Object?> json,
  ) =>
      switch (kind) {
        CatalogMediaKind.anime => AnimeOwnedCopyDetailsV1.fromJson(json),
        CatalogMediaKind.boardgame =>
          BoardGameOwnedCopyDetailsV1.fromJson(json),
        CatalogMediaKind.book => BookOwnedCopyDetailsV1.fromJson(json),
        CatalogMediaKind.comic => ComicOwnedCopyDetailsV1.fromJson(json),
        CatalogMediaKind.game => GameOwnedCopyDetailsV1.fromJson(json),
        CatalogMediaKind.manga => MangaOwnedCopyDetailsV1.fromJson(json),
        CatalogMediaKind.movie => MovieOwnedCopyDetailsV1.fromJson(json),
        CatalogMediaKind.music => MusicOwnedCopyDetailsV1.fromJson(json),
        CatalogMediaKind.tv => TvOwnedCopyDetailsV1.fromJson(json),
        CatalogMediaKind.unknown =>
          throw const FormatException('Unknown Owned Copy kind.'),
      };
}

@immutable
final class AnimeOwnedCopyDetailsV1 extends OwnedCopyKindDetailsV1 {
  const AnimeOwnedCopyDetailsV1();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;
  @override
  Map<String, Object?> toJson() => const {};

  factory AnimeOwnedCopyDetailsV1.fromJson(Map<String, Object?> json) {
    _requireEmptyDetails(json, 'anime');
    return const AnimeOwnedCopyDetailsV1();
  }
}

@immutable
final class BoardGameOwnedCopyDetailsV1 extends OwnedCopyKindDetailsV1 {
  const BoardGameOwnedCopyDetailsV1({
    this.completeness,
    this.hasSleeves,
    this.paintedMiniatures,
  });

  final String? completeness;
  final bool? hasSleeves;
  final bool? paintedMiniatures;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;
  @override
  Map<String, Object?> toJson() => {
        'completeness': completeness,
        'has_sleeves': hasSleeves,
        'painted_miniatures': paintedMiniatures,
      };

  factory BoardGameOwnedCopyDetailsV1.fromJson(Map<String, Object?> json) {
    _requireOnlyDetails(
      json,
      'boardgame',
      const {'completeness', 'has_sleeves', 'painted_miniatures'},
    );
    return BoardGameOwnedCopyDetailsV1(
      completeness: _optionalString(json['completeness'], 'completeness'),
      hasSleeves: _optionalBool(json['has_sleeves'], 'has_sleeves'),
      paintedMiniatures:
          _optionalBool(json['painted_miniatures'], 'painted_miniatures'),
    );
  }
}

@immutable
final class BookOwnedCopyDetailsV1 extends OwnedCopyKindDetailsV1 {
  const BookOwnedCopyDetailsV1();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;
  @override
  Map<String, Object?> toJson() => const {};

  factory BookOwnedCopyDetailsV1.fromJson(Map<String, Object?> json) {
    _requireEmptyDetails(json, 'book');
    return const BookOwnedCopyDetailsV1();
  }
}

@immutable
final class ComicOwnedCopyDetailsV1 extends OwnedCopyKindDetailsV1 {
  const ComicOwnedCopyDetailsV1({
    this.grade,
    this.gradingCompany,
    this.customLabel,
  });

  final String? grade;
  final String? gradingCompany;
  final String? customLabel;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;
  @override
  Map<String, Object?> toJson() => {
        'grade': grade,
        'grading_company': gradingCompany,
        'custom_label': customLabel,
      };

  factory ComicOwnedCopyDetailsV1.fromJson(Map<String, Object?> json) {
    _requireOnlyDetails(
      json,
      'comic',
      const {'grade', 'grading_company', 'custom_label'},
    );
    return ComicOwnedCopyDetailsV1(
      grade: _optionalString(json['grade'], 'grade'),
      gradingCompany:
          _optionalString(json['grading_company'], 'grading_company'),
      customLabel: _optionalString(json['custom_label'], 'custom_label'),
    );
  }
}

@immutable
final class GameOwnedCopyDetailsV1 extends OwnedCopyKindDetailsV1 {
  const GameOwnedCopyDetailsV1(
      {this.completeness, this.hasBox, this.hasManual});

  final String? completeness;
  final bool? hasBox;
  final bool? hasManual;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;
  @override
  Map<String, Object?> toJson() => {
        'completeness': completeness,
        'has_box': hasBox,
        'has_manual': hasManual,
      };

  factory GameOwnedCopyDetailsV1.fromJson(Map<String, Object?> json) {
    _requireOnlyDetails(
      json,
      'game',
      const {'completeness', 'has_box', 'has_manual'},
    );
    return GameOwnedCopyDetailsV1(
      completeness: _optionalString(json['completeness'], 'completeness'),
      hasBox: _optionalBool(json['has_box'], 'has_box'),
      hasManual: _optionalBool(json['has_manual'], 'has_manual'),
    );
  }
}

@immutable
final class MangaOwnedCopyDetailsV1 extends OwnedCopyKindDetailsV1 {
  const MangaOwnedCopyDetailsV1();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;
  @override
  Map<String, Object?> toJson() => const {};

  factory MangaOwnedCopyDetailsV1.fromJson(Map<String, Object?> json) {
    _requireEmptyDetails(json, 'manga');
    return const MangaOwnedCopyDetailsV1();
  }
}

@immutable
final class MovieOwnedCopyDetailsV1 extends OwnedCopyKindDetailsV1 {
  const MovieOwnedCopyDetailsV1();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;
  @override
  Map<String, Object?> toJson() => const {};

  factory MovieOwnedCopyDetailsV1.fromJson(Map<String, Object?> json) {
    _requireEmptyDetails(json, 'movie');
    return const MovieOwnedCopyDetailsV1();
  }
}

@immutable
final class MusicOwnedDiscStorageV1 {
  MusicOwnedDiscStorageV1({
    required this.discNumber,
    this.storageDevice,
    this.slot,
  }) {
    if (discNumber < 1) {
      throw ArgumentError.value(
        discNumber,
        'discNumber',
        'Disc numbers begin at 1.',
      );
    }
  }

  final int discNumber;
  final String? storageDevice;
  final String? slot;

  factory MusicOwnedDiscStorageV1.fromJson(Map<String, Object?> json) {
    _requireOnlyDetails(
      json,
      'music disc storage',
      const {'disc_number', 'storage_device', 'slot'},
    );
    final discNumber = json['disc_number'];
    if (discNumber is! int || discNumber < 1) {
      throw const FormatException('Disc storage needs a positive disc number.');
    }
    return MusicOwnedDiscStorageV1(
      discNumber: discNumber,
      storageDevice: _optionalString(json['storage_device'], 'storage_device'),
      slot: _optionalString(json['slot'], 'slot'),
    );
  }

  Map<String, Object?> toJson() => {
        'disc_number': discNumber,
        'storage_device': storageDevice,
        'slot': slot,
      };
}

@immutable
final class MusicOwnedCopyDetailsV1 extends OwnedCopyKindDetailsV1 {
  MusicOwnedCopyDetailsV1({
    this.packageCondition,
    this.mediaCondition,
    this.lastCleanedDate,
    Iterable<String> signedBy = const [],
    Iterable<MusicOwnedDiscStorageV1> discStorage = const [],
  })  : signedBy = List.unmodifiable(signedBy),
        discStorage = List.unmodifiable(discStorage) {
    final discNumbers = this.discStorage.map((value) => value.discNumber);
    if (discNumbers.toSet().length != discNumbers.length) {
      throw ArgumentError('Disc storage can contain only one entry per disc.');
    }
  }

  final String? packageCondition;
  final String? mediaCondition;
  final PartialDate? lastCleanedDate;
  final List<String> signedBy;
  final List<MusicOwnedDiscStorageV1> discStorage;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;
  @override
  Map<String, Object?> toJson() => {
        'package_condition': packageCondition,
        'media_condition': mediaCondition,
        'last_cleaned_date': lastCleanedDate?.toJson(),
        'signed_by': signedBy,
        'disc_storage': discStorage.map((value) => value.toJson()).toList(),
      };

  factory MusicOwnedCopyDetailsV1.fromJson(Map<String, Object?> json) {
    _requireOnlyDetails(
      json,
      'music',
      const {
        'package_condition',
        'media_condition',
        'last_cleaned_date',
        'signed_by',
        'disc_storage',
      },
    );
    return MusicOwnedCopyDetailsV1(
      packageCondition:
          _optionalString(json['package_condition'], 'package_condition'),
      mediaCondition:
          _optionalString(json['media_condition'], 'media_condition'),
      lastCleanedDate: _optionalPartialDate(json['last_cleaned_date']),
      signedBy: _optionalStringList(json, 'signed_by'),
      discStorage: _optionalObjectList(
        json,
        'disc_storage',
        MusicOwnedDiscStorageV1.fromJson,
      ),
    );
  }
}

@immutable
final class TvOwnedCopyDetailsV1 extends OwnedCopyKindDetailsV1 {
  const TvOwnedCopyDetailsV1();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;
  @override
  Map<String, Object?> toJson() => const {};

  factory TvOwnedCopyDetailsV1.fromJson(Map<String, Object?> json) {
    _requireEmptyDetails(json, 'tv');
    return const TvOwnedCopyDetailsV1();
  }
}

/// App-owned record for one distinguishable copy of a Catalog Item.
///
/// Catalog data never appears in this model. A bulk Add command creates one
/// instance per copy instead of storing a quantity on a row.
@immutable
final class OwnedCopyV1 {
  OwnedCopyV1({
    required this.ref,
    required this.catalogItem,
    required this.status,
    required DateTime createdAt,
    required DateTime updatedAt,
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
    Iterable<String> tags = const [],
    Iterable<OwnedCopyPersonalImageV1> personalImages = const [],
    Iterable<OwnedCopyCustomFieldV1> customFields = const [],
    required this.kindDetails,
  })  : createdAt = createdAt.toUtc(),
        updatedAt = updatedAt.toUtc(),
        tags = List.unmodifiable(tags),
        personalImages = List.unmodifiable(personalImages),
        customFields = List.unmodifiable(customFields) {
    if (ref.catalogItem != catalogItem) {
      throw ArgumentError(
          'Owned Copy reference and Catalog Item do not match.');
    }
    if (kindDetails.kind != catalogItem.kind) {
      throw ArgumentError(
          'Owned Copy details kind does not match its Catalog Item.');
    }
    if (indexNumber != null && indexNumber! < 0) {
      throw ArgumentError.value(
          indexNumber, 'indexNumber', 'Cannot be negative.');
    }
    if (rating != null && rating! < 0) {
      throw ArgumentError.value(rating, 'rating', 'Cannot be negative.');
    }
    if (createdAt.isAfter(updatedAt)) {
      throw ArgumentError('Owned Copy creation time cannot follow its update.');
    }
  }

  final OwnedCopyRef ref;
  final CatalogItemRef catalogItem;
  final OwnedCopyStatusV1 status;
  final DateTime createdAt;
  final DateTime updatedAt;
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
  final OwnedCopyKindDetailsV1 kindDetails;

  Map<String, Object?> toJson() => {
        'id': ref.copyId,
        'catalog_item': catalogItem.toJson(),
        'status': status.apiValue,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'index_number': indexNumber,
        'location_id': locationId,
        'owner': owner?.toJson(),
        'loaned_to': loanedTo,
        'loan_due_date': loanDueDate?.toJson(),
        'is_digital': isDigital,
        'condition': condition,
        'purchase_date': purchaseDate?.toJson(),
        'purchase_price': _moneyToJson(purchasePrice),
        'purchase_store': purchaseStore,
        'current_value': _moneyToJson(currentValue),
        'sold_at': soldAt?.toJson(),
        'sold_to': soldTo,
        'sale_price': _moneyToJson(salePrice),
        'rating': rating,
        'notes': notes,
        'tags': tags,
        'personal_images':
            personalImages.map((image) => image.toJson()).toList(),
        'custom_fields': customFields.map((field) => field.toJson()).toList(),
        'kind_details': kindDetails.toJson(),
      };

  factory OwnedCopyV1.fromJson(Map<String, Object?> json) {
    _requireOnlyDetails(
      json,
      'owned_copy',
      const {
        'id',
        'catalog_item',
        'status',
        'created_at',
        'updated_at',
        'index_number',
        'location_id',
        'owner',
        'loaned_to',
        'loan_due_date',
        'is_digital',
        'condition',
        'purchase_date',
        'purchase_price',
        'purchase_store',
        'current_value',
        'sold_at',
        'sold_to',
        'sale_price',
        'rating',
        'notes',
        'tags',
        'personal_images',
        'custom_fields',
        'kind_details',
      },
    );
    final rawItem = json['catalog_item'];
    if (rawItem is! Map) {
      throw const FormatException('Owned Copy needs a Catalog Item reference.');
    }
    final item = CatalogItemRef.fromJson(Map<String, Object?>.from(rawItem));
    final id = json['id'];
    final createdAt = _requiredDateTime(json['created_at'], 'created_at');
    final updatedAt = _requiredDateTime(json['updated_at'], 'updated_at');
    if (id is! String || id.trim().isEmpty) {
      throw const FormatException('Owned Copy needs an ID and timestamps.');
    }
    final rawDetails = json['kind_details'];
    if (rawDetails is! Map) {
      throw const FormatException('Invalid Owned Copy kind details.');
    }
    final details = OwnedCopyKindDetailsV1.fromJson(
      item.kind,
      Map<String, Object?>.from(rawDetails),
    );
    return OwnedCopyV1(
      ref: OwnedCopyRef(kind: item.kind, itemId: item.id, copyId: id),
      catalogItem: item,
      status: OwnedCopyStatusV1.fromApiValue(json['status']),
      createdAt: createdAt,
      updatedAt: updatedAt,
      indexNumber: _optionalInt(json['index_number'], 'index_number'),
      locationId: _optionalString(json['location_id'], 'location_id'),
      owner: _ownerFromJson(json['owner']),
      loanedTo: _optionalString(json['loaned_to'], 'loaned_to'),
      loanDueDate: _optionalPartialDate(json['loan_due_date']),
      isDigital: _optionalBool(json['is_digital'], 'is_digital'),
      condition: _optionalString(json['condition'], 'condition'),
      purchaseDate: _optionalPartialDate(json['purchase_date']),
      purchasePrice: _moneyFromJson(json['purchase_price']),
      purchaseStore: _optionalString(json['purchase_store'], 'purchase_store'),
      currentValue: _moneyFromJson(json['current_value']),
      soldAt: _optionalPartialDate(json['sold_at']),
      soldTo: _optionalString(json['sold_to'], 'sold_to'),
      salePrice: _moneyFromJson(json['sale_price']),
      rating: _optionalInt(json['rating'], 'rating'),
      notes: _optionalString(json['notes'], 'notes'),
      tags: _optionalStringList(json, 'tags'),
      personalImages: _optionalObjectList(
        json,
        'personal_images',
        OwnedCopyPersonalImageV1.fromJson,
      ),
      customFields: _optionalObjectList(
        json,
        'custom_fields',
        OwnedCopyCustomFieldV1.fromJson,
      ),
      kindDetails: details,
    );
  }
}

Object? _serializeOwnedCopyValue(OwnedCopyValueV1? value) => switch (value) {
      null => null,
      OwnedCopyTextValueV1(:final value) => value,
      OwnedCopyNumberValueV1(:final value) => value,
      OwnedCopyBooleanValueV1(:final value) => value,
      OwnedCopyStringListValueV1(:final value) => value,
      OwnedCopyPartialDateValueV1(:final value) => {
          'type': 'partial_date',
          'value': value.toJson(),
        },
      OwnedCopyMoneyValueV1(:final value) => {
          'type': 'money',
          'cents': value.cents,
          'currency': value.currency,
        },
    };

Map<String, Object?>? _moneyToJson(Money? value) =>
    value == null ? null : {'cents': value.cents, 'currency': value.currency};

OwnedCopyOwnerV1? _ownerFromJson(Object? raw) {
  if (raw == null) return null;
  if (raw is! Map) throw const FormatException('Invalid Owned Copy owner.');
  return OwnedCopyOwnerV1.fromJson(Map<String, Object?>.from(raw));
}

Money? _moneyFromJson(Object? raw) {
  if (raw == null) return null;
  if (raw is! Map) throw const FormatException('Invalid Owned Copy money.');
  _requireOnlyDetails(
    Map<String, Object?>.from(raw),
    'money',
    const {'cents', 'currency'},
  );
  final cents = raw['cents'];
  final currency = raw['currency'];
  if (cents is! int || currency is! String || currency.trim().isEmpty) {
    throw const FormatException('Owned Copy money needs cents and currency.');
  }
  final money = Money.fromCents(cents, currency);
  if (money == null) {
    throw const FormatException(
      'Owned Copy money is outside the supported range.',
    );
  }
  return money;
}

DateTime _requiredDateTime(Object? value, String field) {
  if (value is! String ||
      !RegExp(r'(?:[zZ]|[+-]\d{2}:\d{2})$').hasMatch(value)) {
    throw FormatException('Owned Copy $field must be a zoned date and time.');
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw FormatException('Owned Copy $field must be a valid date and time.');
  }
  return parsed;
}

PartialDate? _optionalPartialDate(Object? value) {
  if (value == null) return null;
  if (value is! Map) {
    throw const FormatException('Owned Copy partial date must be an object.');
  }
  final json = Map<String, Object?>.from(value);
  _requireOnlyDetails(json, 'partial date', const {'year', 'month', 'day'});
  final year = _optionalInt(json['year'], 'date.year');
  final month = _optionalInt(json['month'], 'date.month');
  final day = _optionalInt(json['day'], 'date.day');
  final parsed = PartialDate(year: year, month: month, day: day);
  if (parsed.isEmpty || !_isValidPartialDate(parsed)) {
    throw const FormatException('Invalid Owned Copy partial date.');
  }
  return parsed;
}

bool _isValidPartialDate(PartialDate value) {
  final year = value.year;
  final month = value.month;
  final day = value.day;
  if (year != null && (year < 1 || year > 9999) ||
      month != null && (month < 1 || month > 12) ||
      day != null && (day < 1 || day > 31)) {
    return false;
  }
  if (year != null && month != null && day != null) {
    final exact = DateTime.utc(year, month, day);
    return exact.year == year && exact.month == month && exact.day == day;
  }
  return true;
}

bool _customValueMatchesType(
  CustomFieldValueType type,
  OwnedCopyValueV1? value,
) {
  if (value == null) return true;
  return switch (type) {
    CustomFieldValueType.text ||
    CustomFieldValueType.longText ||
    CustomFieldValueType.time ||
    CustomFieldValueType.singleSelect ||
    CustomFieldValueType.url ||
    CustomFieldValueType.person =>
      value is OwnedCopyTextValueV1,
    CustomFieldValueType.number => value is OwnedCopyNumberValueV1,
    CustomFieldValueType.currency => value is OwnedCopyMoneyValueV1,
    CustomFieldValueType.date => value is OwnedCopyPartialDateValueV1,
    CustomFieldValueType.boolean => value is OwnedCopyBooleanValueV1,
    CustomFieldValueType.multiSelect => value is OwnedCopyStringListValueV1,
  };
}

int? _optionalInt(Object? value, String field) {
  if (value == null) return null;
  if (value is int) return value;
  throw FormatException('Owned Copy $field must be an integer.');
}

List<String> _stringList(Object? value, String field) {
  if (value is! List || value.any((entry) => entry is! String)) {
    throw FormatException('Owned Copy $field must be a list of strings.');
  }
  return value.cast<String>();
}

List<String> _optionalStringList(Map<String, Object?> json, String field) {
  if (!json.containsKey(field)) return const [];
  return _stringList(json[field], field);
}

List<T> _objectList<T>(
  Object? value,
  String field,
  T Function(Map<String, Object?>) decode,
) {
  if (value is! List || value.any((entry) => entry is! Map)) {
    throw FormatException('Owned Copy $field must be a list of objects.');
  }
  return [
    for (final row in value) decode(Map<String, Object?>.from(row as Map)),
  ];
}

List<T> _optionalObjectList<T>(
  Map<String, Object?> json,
  String field,
  T Function(Map<String, Object?>) decode,
) {
  if (!json.containsKey(field)) return const [];
  return _objectList(json[field], field, decode);
}

List<int> _decodeBase64(String value) {
  try {
    return UriData.parse('data:application/octet-stream;base64,$value')
        .contentAsBytes();
  } on FormatException {
    throw const FormatException('Personal image data is not valid base64.');
  }
}

String _encodeBase64(Uint8List value) =>
    Uri.dataFromBytes(value).toString().split(',').last;

void _requireEmptyDetails(Map<String, Object?> json, String kind) {
  _requireOnlyDetails(json, kind, const {});
}

void _requireOnlyDetails(
  Map<String, Object?> json,
  String scope,
  Set<String> allowedFields,
) {
  final unknownFields = json.keys.where((key) => !allowedFields.contains(key));
  if (unknownFields.isNotEmpty) {
    throw FormatException(
      'Unsupported $scope field(s): ${unknownFields.join(', ')}.',
    );
  }
}

String? _optionalString(Object? value, String field) {
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('Owned Copy $field must be text.');
}

String _requiredString(Object? value, String field) {
  if (value is String && value.trim().isNotEmpty) return value;
  throw FormatException('Owned Copy $field must be non-empty text.');
}

bool? _optionalBool(Object? value, String field) {
  if (value == null) return null;
  if (value is bool) return value;
  throw FormatException('Owned Copy $field must be a boolean.');
}
