import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_personal_data.dart';
import 'package:flutter/foundation.dart';

/// Complete Book-collection item state. Reading progress is a separate concern.
@immutable
final class BookLibraryEntry implements JsonEncodable {
  const BookLibraryEntry({
    required this.id,
    required this.metadata,
    this.sourceCatalogRef,
    this.createdAt,
    this.personal = const BookPersonalData(),
    required this.updatedAt,
    this.deletedAt,
  });

  final LibraryEntryId id;
  final BookCatalogMetadata metadata;
  final CatalogItemRef? sourceCatalogRef;
  final BookPersonalData personal;

  CatalogItemDto get catalogItem => CatalogItemDto.raw(
        id: id.value,
        mediaKind: CatalogMediaKind.book,
        kindData: metadata.toJson(),
        origin: CatalogItemOrigin.privateLocal,
      );
  final DateTime? createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool? get isDigital => personal.isDigital;
  String? get condition => personal.condition;
  String? get grade => personal.grade;
  DateTime? get purchaseDate => personal.purchaseDate;
  int? get pricePaidCents => personal.pricePaidCents;
  String? get currency => personal.currency;
  String? get personalNotes => personal.personalNotes;
  int? get indexNumber => personal.indexNumber;
  String? get tags => personal.tags;
  DateTime? get soldAt => personal.soldAt;
  int? get sellPriceCents => personal.sellPriceCents;
  String? get soldTo => personal.soldTo;
  String? get ownerUserId => personal.ownerUserId;
  String? get ownerLabel => personal.ownerLabel;
  String? get locationId => personal.locationId;
  String? get purchaseStore => personal.purchaseStore;
  String? get collectionStatus => personal.collectionStatus;
  int? get marketValueCents => personal.marketValueCents;
  BookEntryDetails get details => personal.details;

  String get itemId => id.value;
  bool get isDeleted => deletedAt != null;
  bool get isSold => soldAt != null;

  @override
  Map<String, dynamic> toJson() => {
        'id': id.value,
        'catalog_data': metadata.toJson(),
        'source_catalog_ref': sourceCatalogRef?.toJson(),
        'created_at': createdAt?.toUtc().toIso8601String(),
        ...personal.toJson(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
      };

  factory BookLibraryEntry.fromJson(Map<String, dynamic> json) {
    const obsoleteIdentityFields = {'catalog_ref', 'target_ref'};
    final obsoleteFields =
        json.keys.where(obsoleteIdentityFields.contains).toList();
    if (obsoleteFields.isNotEmpty) {
      throw FormatException(
        'Local library entry contains unsupported identity fields: '
        '${obsoleteFields.toList()..sort()}.',
      );
    }

    final rawCatalogData = json['catalog_data'];
    if (rawCatalogData is! Map) {
      throw const FormatException(
        'A Book library entry requires typed catalog metadata.',
      );
    }

    return BookLibraryEntry(
      id: LibraryEntryId(json['id'] as String),
      metadata: BookCatalogMetadata.fromJson(
        Map<String, dynamic>.from(rawCatalogData),
      ),
      personal: BookPersonalData.fromJson(json),
      sourceCatalogRef: json['source_catalog_ref'] is Map
          ? CatalogItemRef.fromJson(
              Map<String, dynamic>.from(json['source_catalog_ref'] as Map))
          : null,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']) ?? DateTime.utc(1970),
      deletedAt: _date(json['deleted_at']),
    );
  }

  BookLibraryEntry copyWith({
    LibraryEntryId? id,
    BookCatalogMetadata? metadata,
    BookPersonalData? personal,
    Object? createdAt = _unset,
    DateTime? updatedAt,
    Object? deletedAt = _unset,
  }) {
    return BookLibraryEntry(
      id: id ?? this.id,
      metadata: metadata ?? this.metadata,
      personal: personal ?? this.personal,
      sourceCatalogRef: sourceCatalogRef,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, _unset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}

const Object _unset = Object();

DateTime? _date(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
