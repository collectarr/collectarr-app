import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/anime/entries/anime_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_personal_data.dart';
import 'package:flutter/foundation.dart';

/// Complete Anime-collection item state. Reading progress is a separate concern.
@immutable
final class AnimeLibraryEntry implements JsonEncodable {
  const AnimeLibraryEntry({
    required this.id,
    required this.metadata,
    this.sourceCatalogRef,
    this.createdAt,
    this.personal = const AnimePersonalData(),
    required this.updatedAt,
    this.deletedAt,
  });

  final LibraryEntryId id;
  final AnimeMetadata metadata;
  final CatalogItemRef? sourceCatalogRef;
  final AnimePersonalData personal;

  CatalogItemDto get catalogItem => CatalogItemDto.raw(
        id: id.value,
        mediaKind: CatalogMediaKind.anime,
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
  AnimeEntryDetails get details => personal.details;

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

  factory AnimeLibraryEntry.fromJson(Map<String, dynamic> json) {
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
        'An Anime library entry requires typed catalog metadata.',
      );
    }

    return AnimeLibraryEntry(
      id: LibraryEntryId(json['id'] as String),
      metadata: AnimeMetadata.fromJson(
        Map<String, dynamic>.from(rawCatalogData),
      ),
      personal: AnimePersonalData.fromJson(json),
      sourceCatalogRef: json['source_catalog_ref'] is Map
          ? CatalogItemRef.fromJson(
              Map<String, dynamic>.from(json['source_catalog_ref'] as Map))
          : null,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']) ?? DateTime.utc(1970),
      deletedAt: _date(json['deleted_at']),
    );
  }

  AnimeLibraryEntry copyWith({
    LibraryEntryId? id,
    AnimeMetadata? metadata,
    AnimePersonalData? personal,
    Object? createdAt = _unset,
    Object? isDigital = _unset,
    Object? condition = _unset,
    Object? grade = _unset,
    Object? purchaseDate = _unset,
    Object? pricePaidCents = _unset,
    Object? currency = _unset,
    Object? personalNotes = _unset,
    Object? indexNumber = _unset,
    Object? tags = _unset,
    DateTime? updatedAt,
    Object? deletedAt = _unset,
    Object? soldAt = _unset,
    Object? sellPriceCents = _unset,
    Object? soldTo = _unset,
    Object? ownerUserId = _unset,
    Object? ownerLabel = _unset,
    Object? locationId = _unset,
    Object? purchaseStore = _unset,
    Object? collectionStatus = _unset,
    Object? marketValueCents = _unset,
    AnimeEntryDetails? details,
  }) {
    return AnimeLibraryEntry(
      id: id ?? this.id,
      metadata: metadata ?? this.metadata,
      personal: personal ??
          AnimePersonalData(
            isDigital: identical(isDigital, _unset)
                ? this.isDigital
                : isDigital as bool?,
            condition: identical(condition, _unset)
                ? this.condition
                : condition as String?,
            grade: identical(grade, _unset) ? this.grade : grade as String?,
            purchaseDate: identical(purchaseDate, _unset)
                ? this.purchaseDate
                : purchaseDate as DateTime?,
            pricePaidCents: identical(pricePaidCents, _unset)
                ? this.pricePaidCents
                : pricePaidCents as int?,
            currency: identical(currency, _unset)
                ? this.currency
                : currency as String?,
            personalNotes: identical(personalNotes, _unset)
                ? this.personalNotes
                : personalNotes as String?,
            indexNumber: identical(indexNumber, _unset)
                ? this.indexNumber
                : indexNumber as int?,
            tags: identical(tags, _unset) ? this.tags : tags as String?,
            soldAt:
                identical(soldAt, _unset) ? this.soldAt : soldAt as DateTime?,
            sellPriceCents: identical(sellPriceCents, _unset)
                ? this.sellPriceCents
                : sellPriceCents as int?,
            soldTo: identical(soldTo, _unset) ? this.soldTo : soldTo as String?,
            ownerUserId: identical(ownerUserId, _unset)
                ? this.ownerUserId
                : ownerUserId as String?,
            ownerLabel: identical(ownerLabel, _unset)
                ? this.ownerLabel
                : ownerLabel as String?,
            locationId: identical(locationId, _unset)
                ? this.locationId
                : locationId as String?,
            purchaseStore: identical(purchaseStore, _unset)
                ? this.purchaseStore
                : purchaseStore as String?,
            collectionStatus: identical(collectionStatus, _unset)
                ? this.collectionStatus
                : collectionStatus as String?,
            marketValueCents: identical(marketValueCents, _unset)
                ? this.marketValueCents
                : marketValueCents as int?,
            details: details ?? this.details,
          ),
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
