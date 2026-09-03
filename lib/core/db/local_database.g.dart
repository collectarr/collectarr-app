// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $CatalogCacheTable extends CatalogCache
    with TableInfo<$CatalogCacheTable, CatalogCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, kind, payloadJson, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_cache';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CatalogCacheTable createAlias(String alias) {
    return $CatalogCacheTable(attachedDatabase, alias);
  }
}

class CatalogCacheData extends DataClass
    implements Insertable<CatalogCacheData> {
  final String id;
  final String kind;
  final String payloadJson;
  final DateTime cachedAt;
  const CatalogCacheData(
      {required this.id,
      required this.kind,
      required this.payloadJson,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['payload_json'] = Variable<String>(payloadJson);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CatalogCacheCompanion toCompanion(bool nullToAbsent) {
    return CatalogCacheCompanion(
      id: Value(id),
      kind: Value(kind),
      payloadJson: Value(payloadJson),
      cachedAt: Value(cachedAt),
    );
  }

  factory CatalogCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogCacheData(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CatalogCacheData copyWith(
          {String? id,
          String? kind,
          String? payloadJson,
          DateTime? cachedAt}) =>
      CatalogCacheData(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        payloadJson: payloadJson ?? this.payloadJson,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CatalogCacheData copyWithCompanion(CatalogCacheCompanion data) {
    return CatalogCacheData(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCacheData(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, payloadJson, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogCacheData &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.payloadJson == this.payloadJson &&
          other.cachedAt == this.cachedAt);
}

class CatalogCacheCompanion extends UpdateCompanion<CatalogCacheData> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> payloadJson;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CatalogCacheCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogCacheCompanion.insert({
    required String id,
    required String kind,
    required String payloadJson,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        kind = Value(kind),
        payloadJson = Value(payloadJson),
        cachedAt = Value(cachedAt);
  static Insertable<CatalogCacheData> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? payloadJson,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? kind,
      Value<String>? payloadJson,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return CatalogCacheCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      payloadJson: payloadJson ?? this.payloadJson,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCacheCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OwnedItemsCacheTable extends OwnedItemsCache
    with TableInfo<$OwnedItemsCacheTable, OwnedItemsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OwnedItemsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isDigitalMeta =
      const VerificationMeta('isDigital');
  @override
  late final GeneratedColumn<bool> isDigital = GeneratedColumn<bool>(
      'is_digital', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_digital" IN (0, 1))'));
  static const VerificationMeta _anchorTypeMeta =
      const VerificationMeta('anchorType');
  @override
  late final GeneratedColumn<String> anchorType = GeneratedColumn<String>(
      'anchor_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editionIdMeta =
      const VerificationMeta('editionId');
  @override
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
      'edition_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bundleReleaseIdMeta =
      const VerificationMeta('bundleReleaseId');
  @override
  late final GeneratedColumn<String> bundleReleaseId = GeneratedColumn<String>(
      'bundle_release_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _conditionMeta =
      const VerificationMeta('condition');
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
      'condition', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
      'grade', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purchaseDateMeta =
      const VerificationMeta('purchaseDate');
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
      'purchase_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _pricePaidCentsMeta =
      const VerificationMeta('pricePaidCents');
  @override
  late final GeneratedColumn<int> pricePaidCents = GeneratedColumn<int>(
      'price_paid_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _personalNotesMeta =
      const VerificationMeta('personalNotes');
  @override
  late final GeneratedColumn<String> personalNotes = GeneratedColumn<String>(
      'personal_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _indexNumberMeta =
      const VerificationMeta('indexNumber');
  @override
  late final GeneratedColumn<int> indexNumber = GeneratedColumn<int>(
      'index_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _coverPriceCentsMeta =
      const VerificationMeta('coverPriceCents');
  @override
  late final GeneratedColumn<int> coverPriceCents = GeneratedColumn<int>(
      'cover_price_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _rawOrSlabbedMeta =
      const VerificationMeta('rawOrSlabbed');
  @override
  late final GeneratedColumn<String> rawOrSlabbed = GeneratedColumn<String>(
      'raw_or_slabbed', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gradingCompanyMeta =
      const VerificationMeta('gradingCompany');
  @override
  late final GeneratedColumn<String> gradingCompany = GeneratedColumn<String>(
      'grading_company', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _graderNotesMeta =
      const VerificationMeta('graderNotes');
  @override
  late final GeneratedColumn<String> graderNotes = GeneratedColumn<String>(
      'grader_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _signedByMeta =
      const VerificationMeta('signedBy');
  @override
  late final GeneratedColumn<String> signedBy = GeneratedColumn<String>(
      'signed_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _labelTypeMeta =
      const VerificationMeta('labelType');
  @override
  late final GeneratedColumn<String> labelType = GeneratedColumn<String>(
      'label_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customLabelMeta =
      const VerificationMeta('customLabel');
  @override
  late final GeneratedColumn<String> customLabel = GeneratedColumn<String>(
      'custom_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pageQualityMeta =
      const VerificationMeta('pageQuality');
  @override
  late final GeneratedColumn<String> pageQuality = GeneratedColumn<String>(
      'page_quality', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _certificationNumberMeta =
      const VerificationMeta('certificationNumber');
  @override
  late final GeneratedColumn<String> certificationNumber =
      GeneratedColumn<String>('certification_number', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _keyComicMeta =
      const VerificationMeta('keyComic');
  @override
  late final GeneratedColumn<bool> keyComic = GeneratedColumn<bool>(
      'key_comic', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("key_comic" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _keyReasonMeta =
      const VerificationMeta('keyReason');
  @override
  late final GeneratedColumn<String> keyReason = GeneratedColumn<String>(
      'key_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _keyCategoryMeta =
      const VerificationMeta('keyCategory');
  @override
  late final GeneratedColumn<String> keyCategory = GeneratedColumn<String>(
      'key_category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _keySeverityMeta =
      const VerificationMeta('keySeverity');
  @override
  late final GeneratedColumn<String> keySeverity = GeneratedColumn<String>(
      'key_severity', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _readStatusMeta =
      const VerificationMeta('readStatus');
  @override
  late final GeneratedColumn<String> readStatus = GeneratedColumn<String>(
      'read_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _finishedAtMeta =
      const VerificationMeta('finishedAt');
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
      'finished_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _soldAtMeta = const VerificationMeta('soldAt');
  @override
  late final GeneratedColumn<DateTime> soldAt = GeneratedColumn<DateTime>(
      'sold_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _sellPriceCentsMeta =
      const VerificationMeta('sellPriceCents');
  @override
  late final GeneratedColumn<int> sellPriceCents = GeneratedColumn<int>(
      'sell_price_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _soldToMeta = const VerificationMeta('soldTo');
  @override
  late final GeneratedColumn<String> soldTo = GeneratedColumn<String>(
      'sold_to', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerUserIdMeta =
      const VerificationMeta('ownerUserId');
  @override
  late final GeneratedColumn<String> ownerUserId = GeneratedColumn<String>(
      'owner_user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerLabelMeta =
      const VerificationMeta('ownerLabel');
  @override
  late final GeneratedColumn<String> ownerLabel = GeneratedColumn<String>(
      'owner_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationIdMeta =
      const VerificationMeta('locationId');
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
      'location_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _featuresMeta =
      const VerificationMeta('features');
  @override
  late final GeneratedColumn<String> features = GeneratedColumn<String>(
      'features', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hdrFormatsJsonMeta =
      const VerificationMeta('hdrFormatsJson');
  @override
  late final GeneratedColumn<String> hdrFormatsJson = GeneratedColumn<String>(
      'hdr_formats_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purchaseStoreMeta =
      const VerificationMeta('purchaseStore');
  @override
  late final GeneratedColumn<String> purchaseStore = GeneratedColumn<String>(
      'purchase_store', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _boxSetIdMeta =
      const VerificationMeta('boxSetId');
  @override
  late final GeneratedColumn<String> boxSetId = GeneratedColumn<String>(
      'box_set_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _boxSetNameMeta =
      const VerificationMeta('boxSetName');
  @override
  late final GeneratedColumn<String> boxSetName = GeneratedColumn<String>(
      'box_set_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _storageDeviceMeta =
      const VerificationMeta('storageDevice');
  @override
  late final GeneratedColumn<String> storageDevice = GeneratedColumn<String>(
      'storage_device', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _storageSlotMeta =
      const VerificationMeta('storageSlot');
  @override
  late final GeneratedColumn<String> storageSlot = GeneratedColumn<String>(
      'storage_slot', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
      'region', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _packagingMeta =
      const VerificationMeta('packaging');
  @override
  late final GeneratedColumn<String> packaging = GeneratedColumn<String>(
      'packaging', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _distributorMeta =
      const VerificationMeta('distributor');
  @override
  late final GeneratedColumn<String> distributor = GeneratedColumn<String>(
      'distributor', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _collectionStatusMeta =
      const VerificationMeta('collectionStatus');
  @override
  late final GeneratedColumn<String> collectionStatus = GeneratedColumn<String>(
      'collection_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastBagBoardDateMeta =
      const VerificationMeta('lastBagBoardDate');
  @override
  late final GeneratedColumn<DateTime> lastBagBoardDate =
      GeneratedColumn<DateTime>('last_bag_board_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _marketValueCentsMeta =
      const VerificationMeta('marketValueCents');
  @override
  late final GeneratedColumn<int> marketValueCents = GeneratedColumn<int>(
      'market_value_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _gameCompletenessMeta =
      const VerificationMeta('gameCompleteness');
  @override
  late final GeneratedColumn<String> gameCompleteness = GeneratedColumn<String>(
      'game_completeness', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gameHasBoxMeta =
      const VerificationMeta('gameHasBox');
  @override
  late final GeneratedColumn<bool> gameHasBox = GeneratedColumn<bool>(
      'game_has_box', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("game_has_box" IN (0, 1))'));
  static const VerificationMeta _gameHasManualMeta =
      const VerificationMeta('gameHasManual');
  @override
  late final GeneratedColumn<bool> gameHasManual = GeneratedColumn<bool>(
      'game_has_manual', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("game_has_manual" IN (0, 1))'));
  static const VerificationMeta _gamePriceChartingIdMeta =
      const VerificationMeta('gamePriceChartingId');
  @override
  late final GeneratedColumn<String> gamePriceChartingId =
      GeneratedColumn<String>('game_price_charting_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gameCoreRegionMeta =
      const VerificationMeta('gameCoreRegion');
  @override
  late final GeneratedColumn<String> gameCoreRegion = GeneratedColumn<String>(
      'game_core_region', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gameValueIsLockedMeta =
      const VerificationMeta('gameValueIsLocked');
  @override
  late final GeneratedColumn<bool> gameValueIsLocked = GeneratedColumn<bool>(
      'game_value_is_locked', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("game_value_is_locked" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemId,
        createdAt,
        isDigital,
        anchorType,
        editionId,
        variantId,
        bundleReleaseId,
        condition,
        grade,
        purchaseDate,
        pricePaidCents,
        currency,
        personalNotes,
        quantity,
        indexNumber,
        coverPriceCents,
        rawOrSlabbed,
        gradingCompany,
        graderNotes,
        signedBy,
        labelType,
        customLabel,
        pageQuality,
        certificationNumber,
        keyComic,
        keyReason,
        keyCategory,
        keySeverity,
        rating,
        readStatus,
        startedAt,
        finishedAt,
        tags,
        updatedAt,
        deletedAt,
        soldAt,
        sellPriceCents,
        soldTo,
        ownerUserId,
        ownerLabel,
        locationId,
        features,
        hdrFormatsJson,
        purchaseStore,
        boxSetId,
        boxSetName,
        storageDevice,
        storageSlot,
        region,
        packaging,
        distributor,
        collectionStatus,
        lastBagBoardDate,
        marketValueCents,
        gameCompleteness,
        gameHasBox,
        gameHasManual,
        gamePriceChartingId,
        gameCoreRegion,
        gameValueIsLocked
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'owned_items_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<OwnedItemsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('is_digital')) {
      context.handle(_isDigitalMeta,
          isDigital.isAcceptableOrUnknown(data['is_digital']!, _isDigitalMeta));
    }
    if (data.containsKey('anchor_type')) {
      context.handle(
          _anchorTypeMeta,
          anchorType.isAcceptableOrUnknown(
              data['anchor_type']!, _anchorTypeMeta));
    }
    if (data.containsKey('edition_id')) {
      context.handle(_editionIdMeta,
          editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta));
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    }
    if (data.containsKey('bundle_release_id')) {
      context.handle(
          _bundleReleaseIdMeta,
          bundleReleaseId.isAcceptableOrUnknown(
              data['bundle_release_id']!, _bundleReleaseIdMeta));
    }
    if (data.containsKey('condition')) {
      context.handle(_conditionMeta,
          condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta));
    }
    if (data.containsKey('grade')) {
      context.handle(
          _gradeMeta, grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta));
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
          _purchaseDateMeta,
          purchaseDate.isAcceptableOrUnknown(
              data['purchase_date']!, _purchaseDateMeta));
    }
    if (data.containsKey('price_paid_cents')) {
      context.handle(
          _pricePaidCentsMeta,
          pricePaidCents.isAcceptableOrUnknown(
              data['price_paid_cents']!, _pricePaidCentsMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('personal_notes')) {
      context.handle(
          _personalNotesMeta,
          personalNotes.isAcceptableOrUnknown(
              data['personal_notes']!, _personalNotesMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('index_number')) {
      context.handle(
          _indexNumberMeta,
          indexNumber.isAcceptableOrUnknown(
              data['index_number']!, _indexNumberMeta));
    }
    if (data.containsKey('cover_price_cents')) {
      context.handle(
          _coverPriceCentsMeta,
          coverPriceCents.isAcceptableOrUnknown(
              data['cover_price_cents']!, _coverPriceCentsMeta));
    }
    if (data.containsKey('raw_or_slabbed')) {
      context.handle(
          _rawOrSlabbedMeta,
          rawOrSlabbed.isAcceptableOrUnknown(
              data['raw_or_slabbed']!, _rawOrSlabbedMeta));
    }
    if (data.containsKey('grading_company')) {
      context.handle(
          _gradingCompanyMeta,
          gradingCompany.isAcceptableOrUnknown(
              data['grading_company']!, _gradingCompanyMeta));
    }
    if (data.containsKey('grader_notes')) {
      context.handle(
          _graderNotesMeta,
          graderNotes.isAcceptableOrUnknown(
              data['grader_notes']!, _graderNotesMeta));
    }
    if (data.containsKey('signed_by')) {
      context.handle(_signedByMeta,
          signedBy.isAcceptableOrUnknown(data['signed_by']!, _signedByMeta));
    }
    if (data.containsKey('label_type')) {
      context.handle(_labelTypeMeta,
          labelType.isAcceptableOrUnknown(data['label_type']!, _labelTypeMeta));
    }
    if (data.containsKey('custom_label')) {
      context.handle(
          _customLabelMeta,
          customLabel.isAcceptableOrUnknown(
              data['custom_label']!, _customLabelMeta));
    }
    if (data.containsKey('page_quality')) {
      context.handle(
          _pageQualityMeta,
          pageQuality.isAcceptableOrUnknown(
              data['page_quality']!, _pageQualityMeta));
    }
    if (data.containsKey('certification_number')) {
      context.handle(
          _certificationNumberMeta,
          certificationNumber.isAcceptableOrUnknown(
              data['certification_number']!, _certificationNumberMeta));
    }
    if (data.containsKey('key_comic')) {
      context.handle(_keyComicMeta,
          keyComic.isAcceptableOrUnknown(data['key_comic']!, _keyComicMeta));
    }
    if (data.containsKey('key_reason')) {
      context.handle(_keyReasonMeta,
          keyReason.isAcceptableOrUnknown(data['key_reason']!, _keyReasonMeta));
    }
    if (data.containsKey('key_category')) {
      context.handle(
          _keyCategoryMeta,
          keyCategory.isAcceptableOrUnknown(
              data['key_category']!, _keyCategoryMeta));
    }
    if (data.containsKey('key_severity')) {
      context.handle(
          _keySeverityMeta,
          keySeverity.isAcceptableOrUnknown(
              data['key_severity']!, _keySeverityMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('read_status')) {
      context.handle(
          _readStatusMeta,
          readStatus.isAcceptableOrUnknown(
              data['read_status']!, _readStatusMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('finished_at')) {
      context.handle(
          _finishedAtMeta,
          finishedAt.isAcceptableOrUnknown(
              data['finished_at']!, _finishedAtMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sold_at')) {
      context.handle(_soldAtMeta,
          soldAt.isAcceptableOrUnknown(data['sold_at']!, _soldAtMeta));
    }
    if (data.containsKey('sell_price_cents')) {
      context.handle(
          _sellPriceCentsMeta,
          sellPriceCents.isAcceptableOrUnknown(
              data['sell_price_cents']!, _sellPriceCentsMeta));
    }
    if (data.containsKey('sold_to')) {
      context.handle(_soldToMeta,
          soldTo.isAcceptableOrUnknown(data['sold_to']!, _soldToMeta));
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
          _ownerUserIdMeta,
          ownerUserId.isAcceptableOrUnknown(
              data['owner_user_id']!, _ownerUserIdMeta));
    }
    if (data.containsKey('owner_label')) {
      context.handle(
          _ownerLabelMeta,
          ownerLabel.isAcceptableOrUnknown(
              data['owner_label']!, _ownerLabelMeta));
    }
    if (data.containsKey('location_id')) {
      context.handle(
          _locationIdMeta,
          locationId.isAcceptableOrUnknown(
              data['location_id']!, _locationIdMeta));
    }
    if (data.containsKey('features')) {
      context.handle(_featuresMeta,
          features.isAcceptableOrUnknown(data['features']!, _featuresMeta));
    }
    if (data.containsKey('hdr_formats_json')) {
      context.handle(
          _hdrFormatsJsonMeta,
          hdrFormatsJson.isAcceptableOrUnknown(
              data['hdr_formats_json']!, _hdrFormatsJsonMeta));
    }
    if (data.containsKey('purchase_store')) {
      context.handle(
          _purchaseStoreMeta,
          purchaseStore.isAcceptableOrUnknown(
              data['purchase_store']!, _purchaseStoreMeta));
    }
    if (data.containsKey('box_set_id')) {
      context.handle(_boxSetIdMeta,
          boxSetId.isAcceptableOrUnknown(data['box_set_id']!, _boxSetIdMeta));
    }
    if (data.containsKey('box_set_name')) {
      context.handle(
          _boxSetNameMeta,
          boxSetName.isAcceptableOrUnknown(
              data['box_set_name']!, _boxSetNameMeta));
    }
    if (data.containsKey('storage_device')) {
      context.handle(
          _storageDeviceMeta,
          storageDevice.isAcceptableOrUnknown(
              data['storage_device']!, _storageDeviceMeta));
    }
    if (data.containsKey('storage_slot')) {
      context.handle(
          _storageSlotMeta,
          storageSlot.isAcceptableOrUnknown(
              data['storage_slot']!, _storageSlotMeta));
    }
    if (data.containsKey('region')) {
      context.handle(_regionMeta,
          region.isAcceptableOrUnknown(data['region']!, _regionMeta));
    }
    if (data.containsKey('packaging')) {
      context.handle(_packagingMeta,
          packaging.isAcceptableOrUnknown(data['packaging']!, _packagingMeta));
    }
    if (data.containsKey('distributor')) {
      context.handle(
          _distributorMeta,
          distributor.isAcceptableOrUnknown(
              data['distributor']!, _distributorMeta));
    }
    if (data.containsKey('collection_status')) {
      context.handle(
          _collectionStatusMeta,
          collectionStatus.isAcceptableOrUnknown(
              data['collection_status']!, _collectionStatusMeta));
    }
    if (data.containsKey('last_bag_board_date')) {
      context.handle(
          _lastBagBoardDateMeta,
          lastBagBoardDate.isAcceptableOrUnknown(
              data['last_bag_board_date']!, _lastBagBoardDateMeta));
    }
    if (data.containsKey('market_value_cents')) {
      context.handle(
          _marketValueCentsMeta,
          marketValueCents.isAcceptableOrUnknown(
              data['market_value_cents']!, _marketValueCentsMeta));
    }
    if (data.containsKey('game_completeness')) {
      context.handle(
          _gameCompletenessMeta,
          gameCompleteness.isAcceptableOrUnknown(
              data['game_completeness']!, _gameCompletenessMeta));
    }
    if (data.containsKey('game_has_box')) {
      context.handle(
          _gameHasBoxMeta,
          gameHasBox.isAcceptableOrUnknown(
              data['game_has_box']!, _gameHasBoxMeta));
    }
    if (data.containsKey('game_has_manual')) {
      context.handle(
          _gameHasManualMeta,
          gameHasManual.isAcceptableOrUnknown(
              data['game_has_manual']!, _gameHasManualMeta));
    }
    if (data.containsKey('game_price_charting_id')) {
      context.handle(
          _gamePriceChartingIdMeta,
          gamePriceChartingId.isAcceptableOrUnknown(
              data['game_price_charting_id']!, _gamePriceChartingIdMeta));
    }
    if (data.containsKey('game_core_region')) {
      context.handle(
          _gameCoreRegionMeta,
          gameCoreRegion.isAcceptableOrUnknown(
              data['game_core_region']!, _gameCoreRegionMeta));
    }
    if (data.containsKey('game_value_is_locked')) {
      context.handle(
          _gameValueIsLockedMeta,
          gameValueIsLocked.isAcceptableOrUnknown(
              data['game_value_is_locked']!, _gameValueIsLockedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OwnedItemsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OwnedItemsCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      isDigital: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_digital']),
      anchorType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}anchor_type']),
      editionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edition_id']),
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
      bundleReleaseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}bundle_release_id']),
      condition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition']),
      grade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grade']),
      purchaseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}purchase_date']),
      pricePaidCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}price_paid_cents']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency']),
      personalNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}personal_notes']),
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      indexNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}index_number']),
      coverPriceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cover_price_cents']),
      rawOrSlabbed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_or_slabbed']),
      gradingCompany: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grading_company']),
      graderNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grader_notes']),
      signedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}signed_by']),
      labelType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label_type']),
      customLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}custom_label']),
      pageQuality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}page_quality']),
      certificationNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}certification_number']),
      keyComic: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}key_comic'])!,
      keyReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key_reason']),
      keyCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key_category']),
      keySeverity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key_severity']),
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating']),
      readStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}read_status']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      finishedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}finished_at']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      soldAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sold_at']),
      sellPriceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sell_price_cents']),
      soldTo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sold_to']),
      ownerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_user_id']),
      ownerLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_label']),
      locationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_id']),
      features: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}features']),
      hdrFormatsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}hdr_formats_json']),
      purchaseStore: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_store']),
      boxSetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}box_set_id']),
      boxSetName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}box_set_name']),
      storageDevice: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_device']),
      storageSlot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_slot']),
      region: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}region']),
      packaging: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}packaging']),
      distributor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}distributor']),
      collectionStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}collection_status']),
      lastBagBoardDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_bag_board_date']),
      marketValueCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}market_value_cents']),
      gameCompleteness: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}game_completeness']),
      gameHasBox: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}game_has_box']),
      gameHasManual: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}game_has_manual']),
      gamePriceChartingId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}game_price_charting_id']),
      gameCoreRegion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}game_core_region']),
      gameValueIsLocked: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}game_value_is_locked']),
    );
  }

  @override
  $OwnedItemsCacheTable createAlias(String alias) {
    return $OwnedItemsCacheTable(attachedDatabase, alias);
  }
}

class OwnedItemsCacheData extends DataClass
    implements Insertable<OwnedItemsCacheData> {
  final String id;
  final String itemId;
  final DateTime? createdAt;
  final bool? isDigital;
  final String? anchorType;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int quantity;
  final int? indexNumber;
  final int? coverPriceCents;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final String? labelType;
  final String? customLabel;
  final String? pageQuality;
  final String? certificationNumber;
  final bool keyComic;
  final String? keyReason;
  final String? keyCategory;
  final String? keySeverity;
  final int? rating;
  final String? readStatus;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? tags;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;
  final String? ownerUserId;
  final String? ownerLabel;
  final String? locationId;
  final String? features;
  final String? hdrFormatsJson;
  final String? purchaseStore;
  final String? boxSetId;
  final String? boxSetName;
  final String? storageDevice;
  final String? storageSlot;
  final String? region;
  final String? packaging;
  final String? distributor;
  final String? collectionStatus;
  final DateTime? lastBagBoardDate;
  final int? marketValueCents;
  final String? gameCompleteness;
  final bool? gameHasBox;
  final bool? gameHasManual;
  final String? gamePriceChartingId;
  final String? gameCoreRegion;
  final bool? gameValueIsLocked;
  const OwnedItemsCacheData(
      {required this.id,
      required this.itemId,
      this.createdAt,
      this.isDigital,
      this.anchorType,
      this.editionId,
      this.variantId,
      this.bundleReleaseId,
      this.condition,
      this.grade,
      this.purchaseDate,
      this.pricePaidCents,
      this.currency,
      this.personalNotes,
      required this.quantity,
      this.indexNumber,
      this.coverPriceCents,
      this.rawOrSlabbed,
      this.gradingCompany,
      this.graderNotes,
      this.signedBy,
      this.labelType,
      this.customLabel,
      this.pageQuality,
      this.certificationNumber,
      required this.keyComic,
      this.keyReason,
      this.keyCategory,
      this.keySeverity,
      this.rating,
      this.readStatus,
      this.startedAt,
      this.finishedAt,
      this.tags,
      required this.updatedAt,
      this.deletedAt,
      this.soldAt,
      this.sellPriceCents,
      this.soldTo,
      this.ownerUserId,
      this.ownerLabel,
      this.locationId,
      this.features,
      this.hdrFormatsJson,
      this.purchaseStore,
      this.boxSetId,
      this.boxSetName,
      this.storageDevice,
      this.storageSlot,
      this.region,
      this.packaging,
      this.distributor,
      this.collectionStatus,
      this.lastBagBoardDate,
      this.marketValueCents,
      this.gameCompleteness,
      this.gameHasBox,
      this.gameHasManual,
      this.gamePriceChartingId,
      this.gameCoreRegion,
      this.gameValueIsLocked});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || isDigital != null) {
      map['is_digital'] = Variable<bool>(isDigital);
    }
    if (!nullToAbsent || anchorType != null) {
      map['anchor_type'] = Variable<String>(anchorType);
    }
    if (!nullToAbsent || editionId != null) {
      map['edition_id'] = Variable<String>(editionId);
    }
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    if (!nullToAbsent || bundleReleaseId != null) {
      map['bundle_release_id'] = Variable<String>(bundleReleaseId);
    }
    if (!nullToAbsent || condition != null) {
      map['condition'] = Variable<String>(condition);
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<String>(grade);
    }
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate);
    }
    if (!nullToAbsent || pricePaidCents != null) {
      map['price_paid_cents'] = Variable<int>(pricePaidCents);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    if (!nullToAbsent || personalNotes != null) {
      map['personal_notes'] = Variable<String>(personalNotes);
    }
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || indexNumber != null) {
      map['index_number'] = Variable<int>(indexNumber);
    }
    if (!nullToAbsent || coverPriceCents != null) {
      map['cover_price_cents'] = Variable<int>(coverPriceCents);
    }
    if (!nullToAbsent || rawOrSlabbed != null) {
      map['raw_or_slabbed'] = Variable<String>(rawOrSlabbed);
    }
    if (!nullToAbsent || gradingCompany != null) {
      map['grading_company'] = Variable<String>(gradingCompany);
    }
    if (!nullToAbsent || graderNotes != null) {
      map['grader_notes'] = Variable<String>(graderNotes);
    }
    if (!nullToAbsent || signedBy != null) {
      map['signed_by'] = Variable<String>(signedBy);
    }
    if (!nullToAbsent || labelType != null) {
      map['label_type'] = Variable<String>(labelType);
    }
    if (!nullToAbsent || customLabel != null) {
      map['custom_label'] = Variable<String>(customLabel);
    }
    if (!nullToAbsent || pageQuality != null) {
      map['page_quality'] = Variable<String>(pageQuality);
    }
    if (!nullToAbsent || certificationNumber != null) {
      map['certification_number'] = Variable<String>(certificationNumber);
    }
    map['key_comic'] = Variable<bool>(keyComic);
    if (!nullToAbsent || keyReason != null) {
      map['key_reason'] = Variable<String>(keyReason);
    }
    if (!nullToAbsent || keyCategory != null) {
      map['key_category'] = Variable<String>(keyCategory);
    }
    if (!nullToAbsent || keySeverity != null) {
      map['key_severity'] = Variable<String>(keySeverity);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || readStatus != null) {
      map['read_status'] = Variable<String>(readStatus);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || soldAt != null) {
      map['sold_at'] = Variable<DateTime>(soldAt);
    }
    if (!nullToAbsent || sellPriceCents != null) {
      map['sell_price_cents'] = Variable<int>(sellPriceCents);
    }
    if (!nullToAbsent || soldTo != null) {
      map['sold_to'] = Variable<String>(soldTo);
    }
    if (!nullToAbsent || ownerUserId != null) {
      map['owner_user_id'] = Variable<String>(ownerUserId);
    }
    if (!nullToAbsent || ownerLabel != null) {
      map['owner_label'] = Variable<String>(ownerLabel);
    }
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    if (!nullToAbsent || features != null) {
      map['features'] = Variable<String>(features);
    }
    if (!nullToAbsent || hdrFormatsJson != null) {
      map['hdr_formats_json'] = Variable<String>(hdrFormatsJson);
    }
    if (!nullToAbsent || purchaseStore != null) {
      map['purchase_store'] = Variable<String>(purchaseStore);
    }
    if (!nullToAbsent || boxSetId != null) {
      map['box_set_id'] = Variable<String>(boxSetId);
    }
    if (!nullToAbsent || boxSetName != null) {
      map['box_set_name'] = Variable<String>(boxSetName);
    }
    if (!nullToAbsent || storageDevice != null) {
      map['storage_device'] = Variable<String>(storageDevice);
    }
    if (!nullToAbsent || storageSlot != null) {
      map['storage_slot'] = Variable<String>(storageSlot);
    }
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    if (!nullToAbsent || packaging != null) {
      map['packaging'] = Variable<String>(packaging);
    }
    if (!nullToAbsent || distributor != null) {
      map['distributor'] = Variable<String>(distributor);
    }
    if (!nullToAbsent || collectionStatus != null) {
      map['collection_status'] = Variable<String>(collectionStatus);
    }
    if (!nullToAbsent || lastBagBoardDate != null) {
      map['last_bag_board_date'] = Variable<DateTime>(lastBagBoardDate);
    }
    if (!nullToAbsent || marketValueCents != null) {
      map['market_value_cents'] = Variable<int>(marketValueCents);
    }
    if (!nullToAbsent || gameCompleteness != null) {
      map['game_completeness'] = Variable<String>(gameCompleteness);
    }
    if (!nullToAbsent || gameHasBox != null) {
      map['game_has_box'] = Variable<bool>(gameHasBox);
    }
    if (!nullToAbsent || gameHasManual != null) {
      map['game_has_manual'] = Variable<bool>(gameHasManual);
    }
    if (!nullToAbsent || gamePriceChartingId != null) {
      map['game_price_charting_id'] = Variable<String>(gamePriceChartingId);
    }
    if (!nullToAbsent || gameCoreRegion != null) {
      map['game_core_region'] = Variable<String>(gameCoreRegion);
    }
    if (!nullToAbsent || gameValueIsLocked != null) {
      map['game_value_is_locked'] = Variable<bool>(gameValueIsLocked);
    }
    return map;
  }

  OwnedItemsCacheCompanion toCompanion(bool nullToAbsent) {
    return OwnedItemsCacheCompanion(
      id: Value(id),
      itemId: Value(itemId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      isDigital: isDigital == null && nullToAbsent
          ? const Value.absent()
          : Value(isDigital),
      anchorType: anchorType == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorType),
      editionId: editionId == null && nullToAbsent
          ? const Value.absent()
          : Value(editionId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      bundleReleaseId: bundleReleaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(bundleReleaseId),
      condition: condition == null && nullToAbsent
          ? const Value.absent()
          : Value(condition),
      grade:
          grade == null && nullToAbsent ? const Value.absent() : Value(grade),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      pricePaidCents: pricePaidCents == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePaidCents),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      personalNotes: personalNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(personalNotes),
      quantity: Value(quantity),
      indexNumber: indexNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(indexNumber),
      coverPriceCents: coverPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPriceCents),
      rawOrSlabbed: rawOrSlabbed == null && nullToAbsent
          ? const Value.absent()
          : Value(rawOrSlabbed),
      gradingCompany: gradingCompany == null && nullToAbsent
          ? const Value.absent()
          : Value(gradingCompany),
      graderNotes: graderNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(graderNotes),
      signedBy: signedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(signedBy),
      labelType: labelType == null && nullToAbsent
          ? const Value.absent()
          : Value(labelType),
      customLabel: customLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(customLabel),
      pageQuality: pageQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(pageQuality),
      certificationNumber: certificationNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(certificationNumber),
      keyComic: Value(keyComic),
      keyReason: keyReason == null && nullToAbsent
          ? const Value.absent()
          : Value(keyReason),
      keyCategory: keyCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(keyCategory),
      keySeverity: keySeverity == null && nullToAbsent
          ? const Value.absent()
          : Value(keySeverity),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      readStatus: readStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(readStatus),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      soldAt:
          soldAt == null && nullToAbsent ? const Value.absent() : Value(soldAt),
      sellPriceCents: sellPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(sellPriceCents),
      soldTo:
          soldTo == null && nullToAbsent ? const Value.absent() : Value(soldTo),
      ownerUserId: ownerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUserId),
      ownerLabel: ownerLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerLabel),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      features: features == null && nullToAbsent
          ? const Value.absent()
          : Value(features),
      hdrFormatsJson: hdrFormatsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(hdrFormatsJson),
      purchaseStore: purchaseStore == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseStore),
      boxSetId: boxSetId == null && nullToAbsent
          ? const Value.absent()
          : Value(boxSetId),
      boxSetName: boxSetName == null && nullToAbsent
          ? const Value.absent()
          : Value(boxSetName),
      storageDevice: storageDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(storageDevice),
      storageSlot: storageSlot == null && nullToAbsent
          ? const Value.absent()
          : Value(storageSlot),
      region:
          region == null && nullToAbsent ? const Value.absent() : Value(region),
      packaging: packaging == null && nullToAbsent
          ? const Value.absent()
          : Value(packaging),
      distributor: distributor == null && nullToAbsent
          ? const Value.absent()
          : Value(distributor),
      collectionStatus: collectionStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionStatus),
      lastBagBoardDate: lastBagBoardDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBagBoardDate),
      marketValueCents: marketValueCents == null && nullToAbsent
          ? const Value.absent()
          : Value(marketValueCents),
      gameCompleteness: gameCompleteness == null && nullToAbsent
          ? const Value.absent()
          : Value(gameCompleteness),
      gameHasBox: gameHasBox == null && nullToAbsent
          ? const Value.absent()
          : Value(gameHasBox),
      gameHasManual: gameHasManual == null && nullToAbsent
          ? const Value.absent()
          : Value(gameHasManual),
      gamePriceChartingId: gamePriceChartingId == null && nullToAbsent
          ? const Value.absent()
          : Value(gamePriceChartingId),
      gameCoreRegion: gameCoreRegion == null && nullToAbsent
          ? const Value.absent()
          : Value(gameCoreRegion),
      gameValueIsLocked: gameValueIsLocked == null && nullToAbsent
          ? const Value.absent()
          : Value(gameValueIsLocked),
    );
  }

  factory OwnedItemsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OwnedItemsCacheData(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      isDigital: serializer.fromJson<bool?>(json['isDigital']),
      anchorType: serializer.fromJson<String?>(json['anchorType']),
      editionId: serializer.fromJson<String?>(json['editionId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      bundleReleaseId: serializer.fromJson<String?>(json['bundleReleaseId']),
      condition: serializer.fromJson<String?>(json['condition']),
      grade: serializer.fromJson<String?>(json['grade']),
      purchaseDate: serializer.fromJson<DateTime?>(json['purchaseDate']),
      pricePaidCents: serializer.fromJson<int?>(json['pricePaidCents']),
      currency: serializer.fromJson<String?>(json['currency']),
      personalNotes: serializer.fromJson<String?>(json['personalNotes']),
      quantity: serializer.fromJson<int>(json['quantity']),
      indexNumber: serializer.fromJson<int?>(json['indexNumber']),
      coverPriceCents: serializer.fromJson<int?>(json['coverPriceCents']),
      rawOrSlabbed: serializer.fromJson<String?>(json['rawOrSlabbed']),
      gradingCompany: serializer.fromJson<String?>(json['gradingCompany']),
      graderNotes: serializer.fromJson<String?>(json['graderNotes']),
      signedBy: serializer.fromJson<String?>(json['signedBy']),
      labelType: serializer.fromJson<String?>(json['labelType']),
      customLabel: serializer.fromJson<String?>(json['customLabel']),
      pageQuality: serializer.fromJson<String?>(json['pageQuality']),
      certificationNumber:
          serializer.fromJson<String?>(json['certificationNumber']),
      keyComic: serializer.fromJson<bool>(json['keyComic']),
      keyReason: serializer.fromJson<String?>(json['keyReason']),
      keyCategory: serializer.fromJson<String?>(json['keyCategory']),
      keySeverity: serializer.fromJson<String?>(json['keySeverity']),
      rating: serializer.fromJson<int?>(json['rating']),
      readStatus: serializer.fromJson<String?>(json['readStatus']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      tags: serializer.fromJson<String?>(json['tags']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      soldAt: serializer.fromJson<DateTime?>(json['soldAt']),
      sellPriceCents: serializer.fromJson<int?>(json['sellPriceCents']),
      soldTo: serializer.fromJson<String?>(json['soldTo']),
      ownerUserId: serializer.fromJson<String?>(json['ownerUserId']),
      ownerLabel: serializer.fromJson<String?>(json['ownerLabel']),
      locationId: serializer.fromJson<String?>(json['locationId']),
      features: serializer.fromJson<String?>(json['features']),
      hdrFormatsJson: serializer.fromJson<String?>(json['hdrFormatsJson']),
      purchaseStore: serializer.fromJson<String?>(json['purchaseStore']),
      boxSetId: serializer.fromJson<String?>(json['boxSetId']),
      boxSetName: serializer.fromJson<String?>(json['boxSetName']),
      storageDevice: serializer.fromJson<String?>(json['storageDevice']),
      storageSlot: serializer.fromJson<String?>(json['storageSlot']),
      region: serializer.fromJson<String?>(json['region']),
      packaging: serializer.fromJson<String?>(json['packaging']),
      distributor: serializer.fromJson<String?>(json['distributor']),
      collectionStatus: serializer.fromJson<String?>(json['collectionStatus']),
      lastBagBoardDate:
          serializer.fromJson<DateTime?>(json['lastBagBoardDate']),
      marketValueCents: serializer.fromJson<int?>(json['marketValueCents']),
      gameCompleteness: serializer.fromJson<String?>(json['gameCompleteness']),
      gameHasBox: serializer.fromJson<bool?>(json['gameHasBox']),
      gameHasManual: serializer.fromJson<bool?>(json['gameHasManual']),
      gamePriceChartingId:
          serializer.fromJson<String?>(json['gamePriceChartingId']),
      gameCoreRegion: serializer.fromJson<String?>(json['gameCoreRegion']),
      gameValueIsLocked: serializer.fromJson<bool?>(json['gameValueIsLocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'isDigital': serializer.toJson<bool?>(isDigital),
      'anchorType': serializer.toJson<String?>(anchorType),
      'editionId': serializer.toJson<String?>(editionId),
      'variantId': serializer.toJson<String?>(variantId),
      'bundleReleaseId': serializer.toJson<String?>(bundleReleaseId),
      'condition': serializer.toJson<String?>(condition),
      'grade': serializer.toJson<String?>(grade),
      'purchaseDate': serializer.toJson<DateTime?>(purchaseDate),
      'pricePaidCents': serializer.toJson<int?>(pricePaidCents),
      'currency': serializer.toJson<String?>(currency),
      'personalNotes': serializer.toJson<String?>(personalNotes),
      'quantity': serializer.toJson<int>(quantity),
      'indexNumber': serializer.toJson<int?>(indexNumber),
      'coverPriceCents': serializer.toJson<int?>(coverPriceCents),
      'rawOrSlabbed': serializer.toJson<String?>(rawOrSlabbed),
      'gradingCompany': serializer.toJson<String?>(gradingCompany),
      'graderNotes': serializer.toJson<String?>(graderNotes),
      'signedBy': serializer.toJson<String?>(signedBy),
      'labelType': serializer.toJson<String?>(labelType),
      'customLabel': serializer.toJson<String?>(customLabel),
      'pageQuality': serializer.toJson<String?>(pageQuality),
      'certificationNumber': serializer.toJson<String?>(certificationNumber),
      'keyComic': serializer.toJson<bool>(keyComic),
      'keyReason': serializer.toJson<String?>(keyReason),
      'keyCategory': serializer.toJson<String?>(keyCategory),
      'keySeverity': serializer.toJson<String?>(keySeverity),
      'rating': serializer.toJson<int?>(rating),
      'readStatus': serializer.toJson<String?>(readStatus),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'tags': serializer.toJson<String?>(tags),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'soldAt': serializer.toJson<DateTime?>(soldAt),
      'sellPriceCents': serializer.toJson<int?>(sellPriceCents),
      'soldTo': serializer.toJson<String?>(soldTo),
      'ownerUserId': serializer.toJson<String?>(ownerUserId),
      'ownerLabel': serializer.toJson<String?>(ownerLabel),
      'locationId': serializer.toJson<String?>(locationId),
      'features': serializer.toJson<String?>(features),
      'hdrFormatsJson': serializer.toJson<String?>(hdrFormatsJson),
      'purchaseStore': serializer.toJson<String?>(purchaseStore),
      'boxSetId': serializer.toJson<String?>(boxSetId),
      'boxSetName': serializer.toJson<String?>(boxSetName),
      'storageDevice': serializer.toJson<String?>(storageDevice),
      'storageSlot': serializer.toJson<String?>(storageSlot),
      'region': serializer.toJson<String?>(region),
      'packaging': serializer.toJson<String?>(packaging),
      'distributor': serializer.toJson<String?>(distributor),
      'collectionStatus': serializer.toJson<String?>(collectionStatus),
      'lastBagBoardDate': serializer.toJson<DateTime?>(lastBagBoardDate),
      'marketValueCents': serializer.toJson<int?>(marketValueCents),
      'gameCompleteness': serializer.toJson<String?>(gameCompleteness),
      'gameHasBox': serializer.toJson<bool?>(gameHasBox),
      'gameHasManual': serializer.toJson<bool?>(gameHasManual),
      'gamePriceChartingId': serializer.toJson<String?>(gamePriceChartingId),
      'gameCoreRegion': serializer.toJson<String?>(gameCoreRegion),
      'gameValueIsLocked': serializer.toJson<bool?>(gameValueIsLocked),
    };
  }

  OwnedItemsCacheData copyWith(
          {String? id,
          String? itemId,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<bool?> isDigital = const Value.absent(),
          Value<String?> anchorType = const Value.absent(),
          Value<String?> editionId = const Value.absent(),
          Value<String?> variantId = const Value.absent(),
          Value<String?> bundleReleaseId = const Value.absent(),
          Value<String?> condition = const Value.absent(),
          Value<String?> grade = const Value.absent(),
          Value<DateTime?> purchaseDate = const Value.absent(),
          Value<int?> pricePaidCents = const Value.absent(),
          Value<String?> currency = const Value.absent(),
          Value<String?> personalNotes = const Value.absent(),
          int? quantity,
          Value<int?> indexNumber = const Value.absent(),
          Value<int?> coverPriceCents = const Value.absent(),
          Value<String?> rawOrSlabbed = const Value.absent(),
          Value<String?> gradingCompany = const Value.absent(),
          Value<String?> graderNotes = const Value.absent(),
          Value<String?> signedBy = const Value.absent(),
          Value<String?> labelType = const Value.absent(),
          Value<String?> customLabel = const Value.absent(),
          Value<String?> pageQuality = const Value.absent(),
          Value<String?> certificationNumber = const Value.absent(),
          bool? keyComic,
          Value<String?> keyReason = const Value.absent(),
          Value<String?> keyCategory = const Value.absent(),
          Value<String?> keySeverity = const Value.absent(),
          Value<int?> rating = const Value.absent(),
          Value<String?> readStatus = const Value.absent(),
          Value<DateTime?> startedAt = const Value.absent(),
          Value<DateTime?> finishedAt = const Value.absent(),
          Value<String?> tags = const Value.absent(),
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<DateTime?> soldAt = const Value.absent(),
          Value<int?> sellPriceCents = const Value.absent(),
          Value<String?> soldTo = const Value.absent(),
          Value<String?> ownerUserId = const Value.absent(),
          Value<String?> ownerLabel = const Value.absent(),
          Value<String?> locationId = const Value.absent(),
          Value<String?> features = const Value.absent(),
          Value<String?> hdrFormatsJson = const Value.absent(),
          Value<String?> purchaseStore = const Value.absent(),
          Value<String?> boxSetId = const Value.absent(),
          Value<String?> boxSetName = const Value.absent(),
          Value<String?> storageDevice = const Value.absent(),
          Value<String?> storageSlot = const Value.absent(),
          Value<String?> region = const Value.absent(),
          Value<String?> packaging = const Value.absent(),
          Value<String?> distributor = const Value.absent(),
          Value<String?> collectionStatus = const Value.absent(),
          Value<DateTime?> lastBagBoardDate = const Value.absent(),
          Value<int?> marketValueCents = const Value.absent(),
          Value<String?> gameCompleteness = const Value.absent(),
          Value<bool?> gameHasBox = const Value.absent(),
          Value<bool?> gameHasManual = const Value.absent(),
          Value<String?> gamePriceChartingId = const Value.absent(),
          Value<String?> gameCoreRegion = const Value.absent(),
          Value<bool?> gameValueIsLocked = const Value.absent()}) =>
      OwnedItemsCacheData(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        isDigital: isDigital.present ? isDigital.value : this.isDigital,
        anchorType: anchorType.present ? anchorType.value : this.anchorType,
        editionId: editionId.present ? editionId.value : this.editionId,
        variantId: variantId.present ? variantId.value : this.variantId,
        bundleReleaseId: bundleReleaseId.present
            ? bundleReleaseId.value
            : this.bundleReleaseId,
        condition: condition.present ? condition.value : this.condition,
        grade: grade.present ? grade.value : this.grade,
        purchaseDate:
            purchaseDate.present ? purchaseDate.value : this.purchaseDate,
        pricePaidCents:
            pricePaidCents.present ? pricePaidCents.value : this.pricePaidCents,
        currency: currency.present ? currency.value : this.currency,
        personalNotes:
            personalNotes.present ? personalNotes.value : this.personalNotes,
        quantity: quantity ?? this.quantity,
        indexNumber: indexNumber.present ? indexNumber.value : this.indexNumber,
        coverPriceCents: coverPriceCents.present
            ? coverPriceCents.value
            : this.coverPriceCents,
        rawOrSlabbed:
            rawOrSlabbed.present ? rawOrSlabbed.value : this.rawOrSlabbed,
        gradingCompany:
            gradingCompany.present ? gradingCompany.value : this.gradingCompany,
        graderNotes: graderNotes.present ? graderNotes.value : this.graderNotes,
        signedBy: signedBy.present ? signedBy.value : this.signedBy,
        labelType: labelType.present ? labelType.value : this.labelType,
        customLabel: customLabel.present ? customLabel.value : this.customLabel,
        pageQuality: pageQuality.present ? pageQuality.value : this.pageQuality,
        certificationNumber: certificationNumber.present
            ? certificationNumber.value
            : this.certificationNumber,
        keyComic: keyComic ?? this.keyComic,
        keyReason: keyReason.present ? keyReason.value : this.keyReason,
        keyCategory: keyCategory.present ? keyCategory.value : this.keyCategory,
        keySeverity: keySeverity.present ? keySeverity.value : this.keySeverity,
        rating: rating.present ? rating.value : this.rating,
        readStatus: readStatus.present ? readStatus.value : this.readStatus,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
        tags: tags.present ? tags.value : this.tags,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        soldAt: soldAt.present ? soldAt.value : this.soldAt,
        sellPriceCents:
            sellPriceCents.present ? sellPriceCents.value : this.sellPriceCents,
        soldTo: soldTo.present ? soldTo.value : this.soldTo,
        ownerUserId: ownerUserId.present ? ownerUserId.value : this.ownerUserId,
        ownerLabel: ownerLabel.present ? ownerLabel.value : this.ownerLabel,
        locationId: locationId.present ? locationId.value : this.locationId,
        features: features.present ? features.value : this.features,
        hdrFormatsJson:
            hdrFormatsJson.present ? hdrFormatsJson.value : this.hdrFormatsJson,
        purchaseStore:
            purchaseStore.present ? purchaseStore.value : this.purchaseStore,
        boxSetId: boxSetId.present ? boxSetId.value : this.boxSetId,
        boxSetName: boxSetName.present ? boxSetName.value : this.boxSetName,
        storageDevice:
            storageDevice.present ? storageDevice.value : this.storageDevice,
        storageSlot: storageSlot.present ? storageSlot.value : this.storageSlot,
        region: region.present ? region.value : this.region,
        packaging: packaging.present ? packaging.value : this.packaging,
        distributor: distributor.present ? distributor.value : this.distributor,
        collectionStatus: collectionStatus.present
            ? collectionStatus.value
            : this.collectionStatus,
        lastBagBoardDate: lastBagBoardDate.present
            ? lastBagBoardDate.value
            : this.lastBagBoardDate,
        marketValueCents: marketValueCents.present
            ? marketValueCents.value
            : this.marketValueCents,
        gameCompleteness: gameCompleteness.present
            ? gameCompleteness.value
            : this.gameCompleteness,
        gameHasBox: gameHasBox.present ? gameHasBox.value : this.gameHasBox,
        gameHasManual:
            gameHasManual.present ? gameHasManual.value : this.gameHasManual,
        gamePriceChartingId: gamePriceChartingId.present
            ? gamePriceChartingId.value
            : this.gamePriceChartingId,
        gameCoreRegion:
            gameCoreRegion.present ? gameCoreRegion.value : this.gameCoreRegion,
        gameValueIsLocked: gameValueIsLocked.present
            ? gameValueIsLocked.value
            : this.gameValueIsLocked,
      );
  OwnedItemsCacheData copyWithCompanion(OwnedItemsCacheCompanion data) {
    return OwnedItemsCacheData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isDigital: data.isDigital.present ? data.isDigital.value : this.isDigital,
      anchorType:
          data.anchorType.present ? data.anchorType.value : this.anchorType,
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      bundleReleaseId: data.bundleReleaseId.present
          ? data.bundleReleaseId.value
          : this.bundleReleaseId,
      condition: data.condition.present ? data.condition.value : this.condition,
      grade: data.grade.present ? data.grade.value : this.grade,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      pricePaidCents: data.pricePaidCents.present
          ? data.pricePaidCents.value
          : this.pricePaidCents,
      currency: data.currency.present ? data.currency.value : this.currency,
      personalNotes: data.personalNotes.present
          ? data.personalNotes.value
          : this.personalNotes,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      indexNumber:
          data.indexNumber.present ? data.indexNumber.value : this.indexNumber,
      coverPriceCents: data.coverPriceCents.present
          ? data.coverPriceCents.value
          : this.coverPriceCents,
      rawOrSlabbed: data.rawOrSlabbed.present
          ? data.rawOrSlabbed.value
          : this.rawOrSlabbed,
      gradingCompany: data.gradingCompany.present
          ? data.gradingCompany.value
          : this.gradingCompany,
      graderNotes:
          data.graderNotes.present ? data.graderNotes.value : this.graderNotes,
      signedBy: data.signedBy.present ? data.signedBy.value : this.signedBy,
      labelType: data.labelType.present ? data.labelType.value : this.labelType,
      customLabel:
          data.customLabel.present ? data.customLabel.value : this.customLabel,
      pageQuality:
          data.pageQuality.present ? data.pageQuality.value : this.pageQuality,
      certificationNumber: data.certificationNumber.present
          ? data.certificationNumber.value
          : this.certificationNumber,
      keyComic: data.keyComic.present ? data.keyComic.value : this.keyComic,
      keyReason: data.keyReason.present ? data.keyReason.value : this.keyReason,
      keyCategory:
          data.keyCategory.present ? data.keyCategory.value : this.keyCategory,
      keySeverity:
          data.keySeverity.present ? data.keySeverity.value : this.keySeverity,
      rating: data.rating.present ? data.rating.value : this.rating,
      readStatus:
          data.readStatus.present ? data.readStatus.value : this.readStatus,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt:
          data.finishedAt.present ? data.finishedAt.value : this.finishedAt,
      tags: data.tags.present ? data.tags.value : this.tags,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      soldAt: data.soldAt.present ? data.soldAt.value : this.soldAt,
      sellPriceCents: data.sellPriceCents.present
          ? data.sellPriceCents.value
          : this.sellPriceCents,
      soldTo: data.soldTo.present ? data.soldTo.value : this.soldTo,
      ownerUserId:
          data.ownerUserId.present ? data.ownerUserId.value : this.ownerUserId,
      ownerLabel:
          data.ownerLabel.present ? data.ownerLabel.value : this.ownerLabel,
      locationId:
          data.locationId.present ? data.locationId.value : this.locationId,
      features: data.features.present ? data.features.value : this.features,
      hdrFormatsJson: data.hdrFormatsJson.present
          ? data.hdrFormatsJson.value
          : this.hdrFormatsJson,
      purchaseStore: data.purchaseStore.present
          ? data.purchaseStore.value
          : this.purchaseStore,
      boxSetId: data.boxSetId.present ? data.boxSetId.value : this.boxSetId,
      boxSetName:
          data.boxSetName.present ? data.boxSetName.value : this.boxSetName,
      storageDevice: data.storageDevice.present
          ? data.storageDevice.value
          : this.storageDevice,
      storageSlot:
          data.storageSlot.present ? data.storageSlot.value : this.storageSlot,
      region: data.region.present ? data.region.value : this.region,
      packaging: data.packaging.present ? data.packaging.value : this.packaging,
      distributor:
          data.distributor.present ? data.distributor.value : this.distributor,
      collectionStatus: data.collectionStatus.present
          ? data.collectionStatus.value
          : this.collectionStatus,
      lastBagBoardDate: data.lastBagBoardDate.present
          ? data.lastBagBoardDate.value
          : this.lastBagBoardDate,
      marketValueCents: data.marketValueCents.present
          ? data.marketValueCents.value
          : this.marketValueCents,
      gameCompleteness: data.gameCompleteness.present
          ? data.gameCompleteness.value
          : this.gameCompleteness,
      gameHasBox:
          data.gameHasBox.present ? data.gameHasBox.value : this.gameHasBox,
      gameHasManual: data.gameHasManual.present
          ? data.gameHasManual.value
          : this.gameHasManual,
      gamePriceChartingId: data.gamePriceChartingId.present
          ? data.gamePriceChartingId.value
          : this.gamePriceChartingId,
      gameCoreRegion: data.gameCoreRegion.present
          ? data.gameCoreRegion.value
          : this.gameCoreRegion,
      gameValueIsLocked: data.gameValueIsLocked.present
          ? data.gameValueIsLocked.value
          : this.gameValueIsLocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OwnedItemsCacheData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDigital: $isDigital, ')
          ..write('anchorType: $anchorType, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('bundleReleaseId: $bundleReleaseId, ')
          ..write('condition: $condition, ')
          ..write('grade: $grade, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('pricePaidCents: $pricePaidCents, ')
          ..write('currency: $currency, ')
          ..write('personalNotes: $personalNotes, ')
          ..write('quantity: $quantity, ')
          ..write('indexNumber: $indexNumber, ')
          ..write('coverPriceCents: $coverPriceCents, ')
          ..write('rawOrSlabbed: $rawOrSlabbed, ')
          ..write('gradingCompany: $gradingCompany, ')
          ..write('graderNotes: $graderNotes, ')
          ..write('signedBy: $signedBy, ')
          ..write('labelType: $labelType, ')
          ..write('customLabel: $customLabel, ')
          ..write('pageQuality: $pageQuality, ')
          ..write('certificationNumber: $certificationNumber, ')
          ..write('keyComic: $keyComic, ')
          ..write('keyReason: $keyReason, ')
          ..write('keyCategory: $keyCategory, ')
          ..write('keySeverity: $keySeverity, ')
          ..write('rating: $rating, ')
          ..write('readStatus: $readStatus, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('tags: $tags, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('soldAt: $soldAt, ')
          ..write('sellPriceCents: $sellPriceCents, ')
          ..write('soldTo: $soldTo, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('ownerLabel: $ownerLabel, ')
          ..write('locationId: $locationId, ')
          ..write('features: $features, ')
          ..write('hdrFormatsJson: $hdrFormatsJson, ')
          ..write('purchaseStore: $purchaseStore, ')
          ..write('boxSetId: $boxSetId, ')
          ..write('boxSetName: $boxSetName, ')
          ..write('storageDevice: $storageDevice, ')
          ..write('storageSlot: $storageSlot, ')
          ..write('region: $region, ')
          ..write('packaging: $packaging, ')
          ..write('distributor: $distributor, ')
          ..write('collectionStatus: $collectionStatus, ')
          ..write('lastBagBoardDate: $lastBagBoardDate, ')
          ..write('marketValueCents: $marketValueCents, ')
          ..write('gameCompleteness: $gameCompleteness, ')
          ..write('gameHasBox: $gameHasBox, ')
          ..write('gameHasManual: $gameHasManual, ')
          ..write('gamePriceChartingId: $gamePriceChartingId, ')
          ..write('gameCoreRegion: $gameCoreRegion, ')
          ..write('gameValueIsLocked: $gameValueIsLocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        itemId,
        createdAt,
        isDigital,
        anchorType,
        editionId,
        variantId,
        bundleReleaseId,
        condition,
        grade,
        purchaseDate,
        pricePaidCents,
        currency,
        personalNotes,
        quantity,
        indexNumber,
        coverPriceCents,
        rawOrSlabbed,
        gradingCompany,
        graderNotes,
        signedBy,
        labelType,
        customLabel,
        pageQuality,
        certificationNumber,
        keyComic,
        keyReason,
        keyCategory,
        keySeverity,
        rating,
        readStatus,
        startedAt,
        finishedAt,
        tags,
        updatedAt,
        deletedAt,
        soldAt,
        sellPriceCents,
        soldTo,
        ownerUserId,
        ownerLabel,
        locationId,
        features,
        hdrFormatsJson,
        purchaseStore,
        boxSetId,
        boxSetName,
        storageDevice,
        storageSlot,
        region,
        packaging,
        distributor,
        collectionStatus,
        lastBagBoardDate,
        marketValueCents,
        gameCompleteness,
        gameHasBox,
        gameHasManual,
        gamePriceChartingId,
        gameCoreRegion,
        gameValueIsLocked
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OwnedItemsCacheData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.createdAt == this.createdAt &&
          other.isDigital == this.isDigital &&
          other.anchorType == this.anchorType &&
          other.editionId == this.editionId &&
          other.variantId == this.variantId &&
          other.bundleReleaseId == this.bundleReleaseId &&
          other.condition == this.condition &&
          other.grade == this.grade &&
          other.purchaseDate == this.purchaseDate &&
          other.pricePaidCents == this.pricePaidCents &&
          other.currency == this.currency &&
          other.personalNotes == this.personalNotes &&
          other.quantity == this.quantity &&
          other.indexNumber == this.indexNumber &&
          other.coverPriceCents == this.coverPriceCents &&
          other.rawOrSlabbed == this.rawOrSlabbed &&
          other.gradingCompany == this.gradingCompany &&
          other.graderNotes == this.graderNotes &&
          other.signedBy == this.signedBy &&
          other.labelType == this.labelType &&
          other.customLabel == this.customLabel &&
          other.pageQuality == this.pageQuality &&
          other.certificationNumber == this.certificationNumber &&
          other.keyComic == this.keyComic &&
          other.keyReason == this.keyReason &&
          other.keyCategory == this.keyCategory &&
          other.keySeverity == this.keySeverity &&
          other.rating == this.rating &&
          other.readStatus == this.readStatus &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.tags == this.tags &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.soldAt == this.soldAt &&
          other.sellPriceCents == this.sellPriceCents &&
          other.soldTo == this.soldTo &&
          other.ownerUserId == this.ownerUserId &&
          other.ownerLabel == this.ownerLabel &&
          other.locationId == this.locationId &&
          other.features == this.features &&
          other.hdrFormatsJson == this.hdrFormatsJson &&
          other.purchaseStore == this.purchaseStore &&
          other.boxSetId == this.boxSetId &&
          other.boxSetName == this.boxSetName &&
          other.storageDevice == this.storageDevice &&
          other.storageSlot == this.storageSlot &&
          other.region == this.region &&
          other.packaging == this.packaging &&
          other.distributor == this.distributor &&
          other.collectionStatus == this.collectionStatus &&
          other.lastBagBoardDate == this.lastBagBoardDate &&
          other.marketValueCents == this.marketValueCents &&
          other.gameCompleteness == this.gameCompleteness &&
          other.gameHasBox == this.gameHasBox &&
          other.gameHasManual == this.gameHasManual &&
          other.gamePriceChartingId == this.gamePriceChartingId &&
          other.gameCoreRegion == this.gameCoreRegion &&
          other.gameValueIsLocked == this.gameValueIsLocked);
}

class OwnedItemsCacheCompanion extends UpdateCompanion<OwnedItemsCacheData> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<DateTime?> createdAt;
  final Value<bool?> isDigital;
  final Value<String?> anchorType;
  final Value<String?> editionId;
  final Value<String?> variantId;
  final Value<String?> bundleReleaseId;
  final Value<String?> condition;
  final Value<String?> grade;
  final Value<DateTime?> purchaseDate;
  final Value<int?> pricePaidCents;
  final Value<String?> currency;
  final Value<String?> personalNotes;
  final Value<int> quantity;
  final Value<int?> indexNumber;
  final Value<int?> coverPriceCents;
  final Value<String?> rawOrSlabbed;
  final Value<String?> gradingCompany;
  final Value<String?> graderNotes;
  final Value<String?> signedBy;
  final Value<String?> labelType;
  final Value<String?> customLabel;
  final Value<String?> pageQuality;
  final Value<String?> certificationNumber;
  final Value<bool> keyComic;
  final Value<String?> keyReason;
  final Value<String?> keyCategory;
  final Value<String?> keySeverity;
  final Value<int?> rating;
  final Value<String?> readStatus;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<String?> tags;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> soldAt;
  final Value<int?> sellPriceCents;
  final Value<String?> soldTo;
  final Value<String?> ownerUserId;
  final Value<String?> ownerLabel;
  final Value<String?> locationId;
  final Value<String?> features;
  final Value<String?> hdrFormatsJson;
  final Value<String?> purchaseStore;
  final Value<String?> boxSetId;
  final Value<String?> boxSetName;
  final Value<String?> storageDevice;
  final Value<String?> storageSlot;
  final Value<String?> region;
  final Value<String?> packaging;
  final Value<String?> distributor;
  final Value<String?> collectionStatus;
  final Value<DateTime?> lastBagBoardDate;
  final Value<int?> marketValueCents;
  final Value<String?> gameCompleteness;
  final Value<bool?> gameHasBox;
  final Value<bool?> gameHasManual;
  final Value<String?> gamePriceChartingId;
  final Value<String?> gameCoreRegion;
  final Value<bool?> gameValueIsLocked;
  final Value<int> rowid;
  const OwnedItemsCacheCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isDigital = const Value.absent(),
    this.anchorType = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.bundleReleaseId = const Value.absent(),
    this.condition = const Value.absent(),
    this.grade = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.pricePaidCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.personalNotes = const Value.absent(),
    this.quantity = const Value.absent(),
    this.indexNumber = const Value.absent(),
    this.coverPriceCents = const Value.absent(),
    this.rawOrSlabbed = const Value.absent(),
    this.gradingCompany = const Value.absent(),
    this.graderNotes = const Value.absent(),
    this.signedBy = const Value.absent(),
    this.labelType = const Value.absent(),
    this.customLabel = const Value.absent(),
    this.pageQuality = const Value.absent(),
    this.certificationNumber = const Value.absent(),
    this.keyComic = const Value.absent(),
    this.keyReason = const Value.absent(),
    this.keyCategory = const Value.absent(),
    this.keySeverity = const Value.absent(),
    this.rating = const Value.absent(),
    this.readStatus = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.tags = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.soldAt = const Value.absent(),
    this.sellPriceCents = const Value.absent(),
    this.soldTo = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.ownerLabel = const Value.absent(),
    this.locationId = const Value.absent(),
    this.features = const Value.absent(),
    this.hdrFormatsJson = const Value.absent(),
    this.purchaseStore = const Value.absent(),
    this.boxSetId = const Value.absent(),
    this.boxSetName = const Value.absent(),
    this.storageDevice = const Value.absent(),
    this.storageSlot = const Value.absent(),
    this.region = const Value.absent(),
    this.packaging = const Value.absent(),
    this.distributor = const Value.absent(),
    this.collectionStatus = const Value.absent(),
    this.lastBagBoardDate = const Value.absent(),
    this.marketValueCents = const Value.absent(),
    this.gameCompleteness = const Value.absent(),
    this.gameHasBox = const Value.absent(),
    this.gameHasManual = const Value.absent(),
    this.gamePriceChartingId = const Value.absent(),
    this.gameCoreRegion = const Value.absent(),
    this.gameValueIsLocked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OwnedItemsCacheCompanion.insert({
    required String id,
    required String itemId,
    this.createdAt = const Value.absent(),
    this.isDigital = const Value.absent(),
    this.anchorType = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.bundleReleaseId = const Value.absent(),
    this.condition = const Value.absent(),
    this.grade = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.pricePaidCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.personalNotes = const Value.absent(),
    this.quantity = const Value.absent(),
    this.indexNumber = const Value.absent(),
    this.coverPriceCents = const Value.absent(),
    this.rawOrSlabbed = const Value.absent(),
    this.gradingCompany = const Value.absent(),
    this.graderNotes = const Value.absent(),
    this.signedBy = const Value.absent(),
    this.labelType = const Value.absent(),
    this.customLabel = const Value.absent(),
    this.pageQuality = const Value.absent(),
    this.certificationNumber = const Value.absent(),
    this.keyComic = const Value.absent(),
    this.keyReason = const Value.absent(),
    this.keyCategory = const Value.absent(),
    this.keySeverity = const Value.absent(),
    this.rating = const Value.absent(),
    this.readStatus = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.tags = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.soldAt = const Value.absent(),
    this.sellPriceCents = const Value.absent(),
    this.soldTo = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.ownerLabel = const Value.absent(),
    this.locationId = const Value.absent(),
    this.features = const Value.absent(),
    this.hdrFormatsJson = const Value.absent(),
    this.purchaseStore = const Value.absent(),
    this.boxSetId = const Value.absent(),
    this.boxSetName = const Value.absent(),
    this.storageDevice = const Value.absent(),
    this.storageSlot = const Value.absent(),
    this.region = const Value.absent(),
    this.packaging = const Value.absent(),
    this.distributor = const Value.absent(),
    this.collectionStatus = const Value.absent(),
    this.lastBagBoardDate = const Value.absent(),
    this.marketValueCents = const Value.absent(),
    this.gameCompleteness = const Value.absent(),
    this.gameHasBox = const Value.absent(),
    this.gameHasManual = const Value.absent(),
    this.gamePriceChartingId = const Value.absent(),
    this.gameCoreRegion = const Value.absent(),
    this.gameValueIsLocked = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        updatedAt = Value(updatedAt);
  static Insertable<OwnedItemsCacheData> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<DateTime>? createdAt,
    Expression<bool>? isDigital,
    Expression<String>? anchorType,
    Expression<String>? editionId,
    Expression<String>? variantId,
    Expression<String>? bundleReleaseId,
    Expression<String>? condition,
    Expression<String>? grade,
    Expression<DateTime>? purchaseDate,
    Expression<int>? pricePaidCents,
    Expression<String>? currency,
    Expression<String>? personalNotes,
    Expression<int>? quantity,
    Expression<int>? indexNumber,
    Expression<int>? coverPriceCents,
    Expression<String>? rawOrSlabbed,
    Expression<String>? gradingCompany,
    Expression<String>? graderNotes,
    Expression<String>? signedBy,
    Expression<String>? labelType,
    Expression<String>? customLabel,
    Expression<String>? pageQuality,
    Expression<String>? certificationNumber,
    Expression<bool>? keyComic,
    Expression<String>? keyReason,
    Expression<String>? keyCategory,
    Expression<String>? keySeverity,
    Expression<int>? rating,
    Expression<String>? readStatus,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<String>? tags,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? soldAt,
    Expression<int>? sellPriceCents,
    Expression<String>? soldTo,
    Expression<String>? ownerUserId,
    Expression<String>? ownerLabel,
    Expression<String>? locationId,
    Expression<String>? features,
    Expression<String>? hdrFormatsJson,
    Expression<String>? purchaseStore,
    Expression<String>? boxSetId,
    Expression<String>? boxSetName,
    Expression<String>? storageDevice,
    Expression<String>? storageSlot,
    Expression<String>? region,
    Expression<String>? packaging,
    Expression<String>? distributor,
    Expression<String>? collectionStatus,
    Expression<DateTime>? lastBagBoardDate,
    Expression<int>? marketValueCents,
    Expression<String>? gameCompleteness,
    Expression<bool>? gameHasBox,
    Expression<bool>? gameHasManual,
    Expression<String>? gamePriceChartingId,
    Expression<String>? gameCoreRegion,
    Expression<bool>? gameValueIsLocked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (createdAt != null) 'created_at': createdAt,
      if (isDigital != null) 'is_digital': isDigital,
      if (anchorType != null) 'anchor_type': anchorType,
      if (editionId != null) 'edition_id': editionId,
      if (variantId != null) 'variant_id': variantId,
      if (bundleReleaseId != null) 'bundle_release_id': bundleReleaseId,
      if (condition != null) 'condition': condition,
      if (grade != null) 'grade': grade,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (pricePaidCents != null) 'price_paid_cents': pricePaidCents,
      if (currency != null) 'currency': currency,
      if (personalNotes != null) 'personal_notes': personalNotes,
      if (quantity != null) 'quantity': quantity,
      if (indexNumber != null) 'index_number': indexNumber,
      if (coverPriceCents != null) 'cover_price_cents': coverPriceCents,
      if (rawOrSlabbed != null) 'raw_or_slabbed': rawOrSlabbed,
      if (gradingCompany != null) 'grading_company': gradingCompany,
      if (graderNotes != null) 'grader_notes': graderNotes,
      if (signedBy != null) 'signed_by': signedBy,
      if (labelType != null) 'label_type': labelType,
      if (customLabel != null) 'custom_label': customLabel,
      if (pageQuality != null) 'page_quality': pageQuality,
      if (certificationNumber != null)
        'certification_number': certificationNumber,
      if (keyComic != null) 'key_comic': keyComic,
      if (keyReason != null) 'key_reason': keyReason,
      if (keyCategory != null) 'key_category': keyCategory,
      if (keySeverity != null) 'key_severity': keySeverity,
      if (rating != null) 'rating': rating,
      if (readStatus != null) 'read_status': readStatus,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (tags != null) 'tags': tags,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (soldAt != null) 'sold_at': soldAt,
      if (sellPriceCents != null) 'sell_price_cents': sellPriceCents,
      if (soldTo != null) 'sold_to': soldTo,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (ownerLabel != null) 'owner_label': ownerLabel,
      if (locationId != null) 'location_id': locationId,
      if (features != null) 'features': features,
      if (hdrFormatsJson != null) 'hdr_formats_json': hdrFormatsJson,
      if (purchaseStore != null) 'purchase_store': purchaseStore,
      if (boxSetId != null) 'box_set_id': boxSetId,
      if (boxSetName != null) 'box_set_name': boxSetName,
      if (storageDevice != null) 'storage_device': storageDevice,
      if (storageSlot != null) 'storage_slot': storageSlot,
      if (region != null) 'region': region,
      if (packaging != null) 'packaging': packaging,
      if (distributor != null) 'distributor': distributor,
      if (collectionStatus != null) 'collection_status': collectionStatus,
      if (lastBagBoardDate != null) 'last_bag_board_date': lastBagBoardDate,
      if (marketValueCents != null) 'market_value_cents': marketValueCents,
      if (gameCompleteness != null) 'game_completeness': gameCompleteness,
      if (gameHasBox != null) 'game_has_box': gameHasBox,
      if (gameHasManual != null) 'game_has_manual': gameHasManual,
      if (gamePriceChartingId != null)
        'game_price_charting_id': gamePriceChartingId,
      if (gameCoreRegion != null) 'game_core_region': gameCoreRegion,
      if (gameValueIsLocked != null) 'game_value_is_locked': gameValueIsLocked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OwnedItemsCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<DateTime?>? createdAt,
      Value<bool?>? isDigital,
      Value<String?>? anchorType,
      Value<String?>? editionId,
      Value<String?>? variantId,
      Value<String?>? bundleReleaseId,
      Value<String?>? condition,
      Value<String?>? grade,
      Value<DateTime?>? purchaseDate,
      Value<int?>? pricePaidCents,
      Value<String?>? currency,
      Value<String?>? personalNotes,
      Value<int>? quantity,
      Value<int?>? indexNumber,
      Value<int?>? coverPriceCents,
      Value<String?>? rawOrSlabbed,
      Value<String?>? gradingCompany,
      Value<String?>? graderNotes,
      Value<String?>? signedBy,
      Value<String?>? labelType,
      Value<String?>? customLabel,
      Value<String?>? pageQuality,
      Value<String?>? certificationNumber,
      Value<bool>? keyComic,
      Value<String?>? keyReason,
      Value<String?>? keyCategory,
      Value<String?>? keySeverity,
      Value<int?>? rating,
      Value<String?>? readStatus,
      Value<DateTime?>? startedAt,
      Value<DateTime?>? finishedAt,
      Value<String?>? tags,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<DateTime?>? soldAt,
      Value<int?>? sellPriceCents,
      Value<String?>? soldTo,
      Value<String?>? ownerUserId,
      Value<String?>? ownerLabel,
      Value<String?>? locationId,
      Value<String?>? features,
      Value<String?>? hdrFormatsJson,
      Value<String?>? purchaseStore,
      Value<String?>? boxSetId,
      Value<String?>? boxSetName,
      Value<String?>? storageDevice,
      Value<String?>? storageSlot,
      Value<String?>? region,
      Value<String?>? packaging,
      Value<String?>? distributor,
      Value<String?>? collectionStatus,
      Value<DateTime?>? lastBagBoardDate,
      Value<int?>? marketValueCents,
      Value<String?>? gameCompleteness,
      Value<bool?>? gameHasBox,
      Value<bool?>? gameHasManual,
      Value<String?>? gamePriceChartingId,
      Value<String?>? gameCoreRegion,
      Value<bool?>? gameValueIsLocked,
      Value<int>? rowid}) {
    return OwnedItemsCacheCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      createdAt: createdAt ?? this.createdAt,
      isDigital: isDigital ?? this.isDigital,
      anchorType: anchorType ?? this.anchorType,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
      condition: condition ?? this.condition,
      grade: grade ?? this.grade,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      pricePaidCents: pricePaidCents ?? this.pricePaidCents,
      currency: currency ?? this.currency,
      personalNotes: personalNotes ?? this.personalNotes,
      quantity: quantity ?? this.quantity,
      indexNumber: indexNumber ?? this.indexNumber,
      coverPriceCents: coverPriceCents ?? this.coverPriceCents,
      rawOrSlabbed: rawOrSlabbed ?? this.rawOrSlabbed,
      gradingCompany: gradingCompany ?? this.gradingCompany,
      graderNotes: graderNotes ?? this.graderNotes,
      signedBy: signedBy ?? this.signedBy,
      labelType: labelType ?? this.labelType,
      customLabel: customLabel ?? this.customLabel,
      pageQuality: pageQuality ?? this.pageQuality,
      certificationNumber: certificationNumber ?? this.certificationNumber,
      keyComic: keyComic ?? this.keyComic,
      keyReason: keyReason ?? this.keyReason,
      keyCategory: keyCategory ?? this.keyCategory,
      keySeverity: keySeverity ?? this.keySeverity,
      rating: rating ?? this.rating,
      readStatus: readStatus ?? this.readStatus,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      tags: tags ?? this.tags,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      soldAt: soldAt ?? this.soldAt,
      sellPriceCents: sellPriceCents ?? this.sellPriceCents,
      soldTo: soldTo ?? this.soldTo,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      ownerLabel: ownerLabel ?? this.ownerLabel,
      locationId: locationId ?? this.locationId,
      features: features ?? this.features,
      hdrFormatsJson: hdrFormatsJson ?? this.hdrFormatsJson,
      purchaseStore: purchaseStore ?? this.purchaseStore,
      boxSetId: boxSetId ?? this.boxSetId,
      boxSetName: boxSetName ?? this.boxSetName,
      storageDevice: storageDevice ?? this.storageDevice,
      storageSlot: storageSlot ?? this.storageSlot,
      region: region ?? this.region,
      packaging: packaging ?? this.packaging,
      distributor: distributor ?? this.distributor,
      collectionStatus: collectionStatus ?? this.collectionStatus,
      lastBagBoardDate: lastBagBoardDate ?? this.lastBagBoardDate,
      marketValueCents: marketValueCents ?? this.marketValueCents,
      gameCompleteness: gameCompleteness ?? this.gameCompleteness,
      gameHasBox: gameHasBox ?? this.gameHasBox,
      gameHasManual: gameHasManual ?? this.gameHasManual,
      gamePriceChartingId: gamePriceChartingId ?? this.gamePriceChartingId,
      gameCoreRegion: gameCoreRegion ?? this.gameCoreRegion,
      gameValueIsLocked: gameValueIsLocked ?? this.gameValueIsLocked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isDigital.present) {
      map['is_digital'] = Variable<bool>(isDigital.value);
    }
    if (anchorType.present) {
      map['anchor_type'] = Variable<String>(anchorType.value);
    }
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (bundleReleaseId.present) {
      map['bundle_release_id'] = Variable<String>(bundleReleaseId.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (pricePaidCents.present) {
      map['price_paid_cents'] = Variable<int>(pricePaidCents.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (personalNotes.present) {
      map['personal_notes'] = Variable<String>(personalNotes.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (indexNumber.present) {
      map['index_number'] = Variable<int>(indexNumber.value);
    }
    if (coverPriceCents.present) {
      map['cover_price_cents'] = Variable<int>(coverPriceCents.value);
    }
    if (rawOrSlabbed.present) {
      map['raw_or_slabbed'] = Variable<String>(rawOrSlabbed.value);
    }
    if (gradingCompany.present) {
      map['grading_company'] = Variable<String>(gradingCompany.value);
    }
    if (graderNotes.present) {
      map['grader_notes'] = Variable<String>(graderNotes.value);
    }
    if (signedBy.present) {
      map['signed_by'] = Variable<String>(signedBy.value);
    }
    if (labelType.present) {
      map['label_type'] = Variable<String>(labelType.value);
    }
    if (customLabel.present) {
      map['custom_label'] = Variable<String>(customLabel.value);
    }
    if (pageQuality.present) {
      map['page_quality'] = Variable<String>(pageQuality.value);
    }
    if (certificationNumber.present) {
      map['certification_number'] = Variable<String>(certificationNumber.value);
    }
    if (keyComic.present) {
      map['key_comic'] = Variable<bool>(keyComic.value);
    }
    if (keyReason.present) {
      map['key_reason'] = Variable<String>(keyReason.value);
    }
    if (keyCategory.present) {
      map['key_category'] = Variable<String>(keyCategory.value);
    }
    if (keySeverity.present) {
      map['key_severity'] = Variable<String>(keySeverity.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (readStatus.present) {
      map['read_status'] = Variable<String>(readStatus.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (soldAt.present) {
      map['sold_at'] = Variable<DateTime>(soldAt.value);
    }
    if (sellPriceCents.present) {
      map['sell_price_cents'] = Variable<int>(sellPriceCents.value);
    }
    if (soldTo.present) {
      map['sold_to'] = Variable<String>(soldTo.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<String>(ownerUserId.value);
    }
    if (ownerLabel.present) {
      map['owner_label'] = Variable<String>(ownerLabel.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (features.present) {
      map['features'] = Variable<String>(features.value);
    }
    if (hdrFormatsJson.present) {
      map['hdr_formats_json'] = Variable<String>(hdrFormatsJson.value);
    }
    if (purchaseStore.present) {
      map['purchase_store'] = Variable<String>(purchaseStore.value);
    }
    if (boxSetId.present) {
      map['box_set_id'] = Variable<String>(boxSetId.value);
    }
    if (boxSetName.present) {
      map['box_set_name'] = Variable<String>(boxSetName.value);
    }
    if (storageDevice.present) {
      map['storage_device'] = Variable<String>(storageDevice.value);
    }
    if (storageSlot.present) {
      map['storage_slot'] = Variable<String>(storageSlot.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (packaging.present) {
      map['packaging'] = Variable<String>(packaging.value);
    }
    if (distributor.present) {
      map['distributor'] = Variable<String>(distributor.value);
    }
    if (collectionStatus.present) {
      map['collection_status'] = Variable<String>(collectionStatus.value);
    }
    if (lastBagBoardDate.present) {
      map['last_bag_board_date'] = Variable<DateTime>(lastBagBoardDate.value);
    }
    if (marketValueCents.present) {
      map['market_value_cents'] = Variable<int>(marketValueCents.value);
    }
    if (gameCompleteness.present) {
      map['game_completeness'] = Variable<String>(gameCompleteness.value);
    }
    if (gameHasBox.present) {
      map['game_has_box'] = Variable<bool>(gameHasBox.value);
    }
    if (gameHasManual.present) {
      map['game_has_manual'] = Variable<bool>(gameHasManual.value);
    }
    if (gamePriceChartingId.present) {
      map['game_price_charting_id'] =
          Variable<String>(gamePriceChartingId.value);
    }
    if (gameCoreRegion.present) {
      map['game_core_region'] = Variable<String>(gameCoreRegion.value);
    }
    if (gameValueIsLocked.present) {
      map['game_value_is_locked'] = Variable<bool>(gameValueIsLocked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OwnedItemsCacheCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDigital: $isDigital, ')
          ..write('anchorType: $anchorType, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('bundleReleaseId: $bundleReleaseId, ')
          ..write('condition: $condition, ')
          ..write('grade: $grade, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('pricePaidCents: $pricePaidCents, ')
          ..write('currency: $currency, ')
          ..write('personalNotes: $personalNotes, ')
          ..write('quantity: $quantity, ')
          ..write('indexNumber: $indexNumber, ')
          ..write('coverPriceCents: $coverPriceCents, ')
          ..write('rawOrSlabbed: $rawOrSlabbed, ')
          ..write('gradingCompany: $gradingCompany, ')
          ..write('graderNotes: $graderNotes, ')
          ..write('signedBy: $signedBy, ')
          ..write('labelType: $labelType, ')
          ..write('customLabel: $customLabel, ')
          ..write('pageQuality: $pageQuality, ')
          ..write('certificationNumber: $certificationNumber, ')
          ..write('keyComic: $keyComic, ')
          ..write('keyReason: $keyReason, ')
          ..write('keyCategory: $keyCategory, ')
          ..write('keySeverity: $keySeverity, ')
          ..write('rating: $rating, ')
          ..write('readStatus: $readStatus, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('tags: $tags, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('soldAt: $soldAt, ')
          ..write('sellPriceCents: $sellPriceCents, ')
          ..write('soldTo: $soldTo, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('ownerLabel: $ownerLabel, ')
          ..write('locationId: $locationId, ')
          ..write('features: $features, ')
          ..write('hdrFormatsJson: $hdrFormatsJson, ')
          ..write('purchaseStore: $purchaseStore, ')
          ..write('boxSetId: $boxSetId, ')
          ..write('boxSetName: $boxSetName, ')
          ..write('storageDevice: $storageDevice, ')
          ..write('storageSlot: $storageSlot, ')
          ..write('region: $region, ')
          ..write('packaging: $packaging, ')
          ..write('distributor: $distributor, ')
          ..write('collectionStatus: $collectionStatus, ')
          ..write('lastBagBoardDate: $lastBagBoardDate, ')
          ..write('marketValueCents: $marketValueCents, ')
          ..write('gameCompleteness: $gameCompleteness, ')
          ..write('gameHasBox: $gameHasBox, ')
          ..write('gameHasManual: $gameHasManual, ')
          ..write('gamePriceChartingId: $gamePriceChartingId, ')
          ..write('gameCoreRegion: $gameCoreRegion, ')
          ..write('gameValueIsLocked: $gameValueIsLocked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WishlistItemsCacheTable extends WishlistItemsCache
    with TableInfo<$WishlistItemsCacheTable, WishlistItemsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WishlistItemsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _anchorTypeMeta =
      const VerificationMeta('anchorType');
  @override
  late final GeneratedColumn<String> anchorType = GeneratedColumn<String>(
      'anchor_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editionIdMeta =
      const VerificationMeta('editionId');
  @override
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
      'edition_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bundleReleaseIdMeta =
      const VerificationMeta('bundleReleaseId');
  @override
  late final GeneratedColumn<String> bundleReleaseId = GeneratedColumn<String>(
      'bundle_release_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _targetPriceCentsMeta =
      const VerificationMeta('targetPriceCents');
  @override
  late final GeneratedColumn<int> targetPriceCents = GeneratedColumn<int>(
      'target_price_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemId,
        anchorType,
        editionId,
        variantId,
        bundleReleaseId,
        targetPriceCents,
        currency,
        notes,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wishlist_items_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<WishlistItemsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('anchor_type')) {
      context.handle(
          _anchorTypeMeta,
          anchorType.isAcceptableOrUnknown(
              data['anchor_type']!, _anchorTypeMeta));
    }
    if (data.containsKey('edition_id')) {
      context.handle(_editionIdMeta,
          editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta));
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    }
    if (data.containsKey('bundle_release_id')) {
      context.handle(
          _bundleReleaseIdMeta,
          bundleReleaseId.isAcceptableOrUnknown(
              data['bundle_release_id']!, _bundleReleaseIdMeta));
    }
    if (data.containsKey('target_price_cents')) {
      context.handle(
          _targetPriceCentsMeta,
          targetPriceCents.isAcceptableOrUnknown(
              data['target_price_cents']!, _targetPriceCentsMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WishlistItemsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WishlistItemsCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      anchorType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}anchor_type']),
      editionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edition_id']),
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
      bundleReleaseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}bundle_release_id']),
      targetPriceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_price_cents']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $WishlistItemsCacheTable createAlias(String alias) {
    return $WishlistItemsCacheTable(attachedDatabase, alias);
  }
}

class WishlistItemsCacheData extends DataClass
    implements Insertable<WishlistItemsCacheData> {
  final String id;
  final String itemId;
  final String? anchorType;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
  final int? targetPriceCents;
  final String? currency;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const WishlistItemsCacheData(
      {required this.id,
      required this.itemId,
      this.anchorType,
      this.editionId,
      this.variantId,
      this.bundleReleaseId,
      this.targetPriceCents,
      this.currency,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || anchorType != null) {
      map['anchor_type'] = Variable<String>(anchorType);
    }
    if (!nullToAbsent || editionId != null) {
      map['edition_id'] = Variable<String>(editionId);
    }
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    if (!nullToAbsent || bundleReleaseId != null) {
      map['bundle_release_id'] = Variable<String>(bundleReleaseId);
    }
    if (!nullToAbsent || targetPriceCents != null) {
      map['target_price_cents'] = Variable<int>(targetPriceCents);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  WishlistItemsCacheCompanion toCompanion(bool nullToAbsent) {
    return WishlistItemsCacheCompanion(
      id: Value(id),
      itemId: Value(itemId),
      anchorType: anchorType == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorType),
      editionId: editionId == null && nullToAbsent
          ? const Value.absent()
          : Value(editionId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      bundleReleaseId: bundleReleaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(bundleReleaseId),
      targetPriceCents: targetPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(targetPriceCents),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory WishlistItemsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WishlistItemsCacheData(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      anchorType: serializer.fromJson<String?>(json['anchorType']),
      editionId: serializer.fromJson<String?>(json['editionId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      bundleReleaseId: serializer.fromJson<String?>(json['bundleReleaseId']),
      targetPriceCents: serializer.fromJson<int?>(json['targetPriceCents']),
      currency: serializer.fromJson<String?>(json['currency']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'anchorType': serializer.toJson<String?>(anchorType),
      'editionId': serializer.toJson<String?>(editionId),
      'variantId': serializer.toJson<String?>(variantId),
      'bundleReleaseId': serializer.toJson<String?>(bundleReleaseId),
      'targetPriceCents': serializer.toJson<int?>(targetPriceCents),
      'currency': serializer.toJson<String?>(currency),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  WishlistItemsCacheData copyWith(
          {String? id,
          String? itemId,
          Value<String?> anchorType = const Value.absent(),
          Value<String?> editionId = const Value.absent(),
          Value<String?> variantId = const Value.absent(),
          Value<String?> bundleReleaseId = const Value.absent(),
          Value<int?> targetPriceCents = const Value.absent(),
          Value<String?> currency = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      WishlistItemsCacheData(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        anchorType: anchorType.present ? anchorType.value : this.anchorType,
        editionId: editionId.present ? editionId.value : this.editionId,
        variantId: variantId.present ? variantId.value : this.variantId,
        bundleReleaseId: bundleReleaseId.present
            ? bundleReleaseId.value
            : this.bundleReleaseId,
        targetPriceCents: targetPriceCents.present
            ? targetPriceCents.value
            : this.targetPriceCents,
        currency: currency.present ? currency.value : this.currency,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  WishlistItemsCacheData copyWithCompanion(WishlistItemsCacheCompanion data) {
    return WishlistItemsCacheData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      anchorType:
          data.anchorType.present ? data.anchorType.value : this.anchorType,
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      bundleReleaseId: data.bundleReleaseId.present
          ? data.bundleReleaseId.value
          : this.bundleReleaseId,
      targetPriceCents: data.targetPriceCents.present
          ? data.targetPriceCents.value
          : this.targetPriceCents,
      currency: data.currency.present ? data.currency.value : this.currency,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WishlistItemsCacheData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('anchorType: $anchorType, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('bundleReleaseId: $bundleReleaseId, ')
          ..write('targetPriceCents: $targetPriceCents, ')
          ..write('currency: $currency, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      itemId,
      anchorType,
      editionId,
      variantId,
      bundleReleaseId,
      targetPriceCents,
      currency,
      notes,
      createdAt,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WishlistItemsCacheData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.anchorType == this.anchorType &&
          other.editionId == this.editionId &&
          other.variantId == this.variantId &&
          other.bundleReleaseId == this.bundleReleaseId &&
          other.targetPriceCents == this.targetPriceCents &&
          other.currency == this.currency &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class WishlistItemsCacheCompanion
    extends UpdateCompanion<WishlistItemsCacheData> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> anchorType;
  final Value<String?> editionId;
  final Value<String?> variantId;
  final Value<String?> bundleReleaseId;
  final Value<int?> targetPriceCents;
  final Value<String?> currency;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const WishlistItemsCacheCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.anchorType = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.bundleReleaseId = const Value.absent(),
    this.targetPriceCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WishlistItemsCacheCompanion.insert({
    required String id,
    required String itemId,
    this.anchorType = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.bundleReleaseId = const Value.absent(),
    this.targetPriceCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<WishlistItemsCacheData> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? anchorType,
    Expression<String>? editionId,
    Expression<String>? variantId,
    Expression<String>? bundleReleaseId,
    Expression<int>? targetPriceCents,
    Expression<String>? currency,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (anchorType != null) 'anchor_type': anchorType,
      if (editionId != null) 'edition_id': editionId,
      if (variantId != null) 'variant_id': variantId,
      if (bundleReleaseId != null) 'bundle_release_id': bundleReleaseId,
      if (targetPriceCents != null) 'target_price_cents': targetPriceCents,
      if (currency != null) 'currency': currency,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WishlistItemsCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String?>? anchorType,
      Value<String?>? editionId,
      Value<String?>? variantId,
      Value<String?>? bundleReleaseId,
      Value<int?>? targetPriceCents,
      Value<String?>? currency,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return WishlistItemsCacheCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      anchorType: anchorType ?? this.anchorType,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
      targetPriceCents: targetPriceCents ?? this.targetPriceCents,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (anchorType.present) {
      map['anchor_type'] = Variable<String>(anchorType.value);
    }
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (bundleReleaseId.present) {
      map['bundle_release_id'] = Variable<String>(bundleReleaseId.value);
    }
    if (targetPriceCents.present) {
      map['target_price_cents'] = Variable<int>(targetPriceCents.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WishlistItemsCacheCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('anchorType: $anchorType, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('bundleReleaseId: $bundleReleaseId, ')
          ..write('targetPriceCents: $targetPriceCents, ')
          ..write('currency: $currency, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackingEntriesCacheTable extends TrackingEntriesCache
    with TableInfo<$TrackingEntriesCacheTable, TrackingEntriesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackingEntriesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownedItemIdMeta =
      const VerificationMeta('ownedItemId');
  @override
  late final GeneratedColumn<String> ownedItemId = GeneratedColumn<String>(
      'owned_item_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editionIdMeta =
      const VerificationMeta('editionId');
  @override
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
      'edition_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bundleReleaseIdMeta =
      const VerificationMeta('bundleReleaseId');
  @override
  late final GeneratedColumn<String> bundleReleaseId = GeneratedColumn<String>(
      'bundle_release_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _finishedAtMeta =
      const VerificationMeta('finishedAt');
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
      'finished_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _progressCurrentMeta =
      const VerificationMeta('progressCurrent');
  @override
  late final GeneratedColumn<int> progressCurrent = GeneratedColumn<int>(
      'progress_current', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _progressTotalMeta =
      const VerificationMeta('progressTotal');
  @override
  late final GeneratedColumn<int> progressTotal = GeneratedColumn<int>(
      'progress_total', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _timesCompletedMeta =
      const VerificationMeta('timesCompleted');
  @override
  late final GeneratedColumn<int> timesCompleted = GeneratedColumn<int>(
      'times_completed', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seasonNumberMeta =
      const VerificationMeta('seasonNumber');
  @override
  late final GeneratedColumn<int> seasonNumber = GeneratedColumn<int>(
      'season_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _episodeNumberMeta =
      const VerificationMeta('episodeNumber');
  @override
  late final GeneratedColumn<int> episodeNumber = GeneratedColumn<int>(
      'episode_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _episodeRatingsMeta =
      const VerificationMeta('episodeRatings');
  @override
  late final GeneratedColumn<String> episodeRatings = GeneratedColumn<String>(
      'episode_ratings', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemId,
        ownedItemId,
        editionId,
        variantId,
        bundleReleaseId,
        sourceType,
        status,
        rating,
        startedAt,
        finishedAt,
        progressCurrent,
        progressTotal,
        timesCompleted,
        notes,
        seasonNumber,
        episodeNumber,
        episodeRatings,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracking_entries_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<TrackingEntriesCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('owned_item_id')) {
      context.handle(
          _ownedItemIdMeta,
          ownedItemId.isAcceptableOrUnknown(
              data['owned_item_id']!, _ownedItemIdMeta));
    }
    if (data.containsKey('edition_id')) {
      context.handle(_editionIdMeta,
          editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta));
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    }
    if (data.containsKey('bundle_release_id')) {
      context.handle(
          _bundleReleaseIdMeta,
          bundleReleaseId.isAcceptableOrUnknown(
              data['bundle_release_id']!, _bundleReleaseIdMeta));
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('finished_at')) {
      context.handle(
          _finishedAtMeta,
          finishedAt.isAcceptableOrUnknown(
              data['finished_at']!, _finishedAtMeta));
    }
    if (data.containsKey('progress_current')) {
      context.handle(
          _progressCurrentMeta,
          progressCurrent.isAcceptableOrUnknown(
              data['progress_current']!, _progressCurrentMeta));
    }
    if (data.containsKey('progress_total')) {
      context.handle(
          _progressTotalMeta,
          progressTotal.isAcceptableOrUnknown(
              data['progress_total']!, _progressTotalMeta));
    }
    if (data.containsKey('times_completed')) {
      context.handle(
          _timesCompletedMeta,
          timesCompleted.isAcceptableOrUnknown(
              data['times_completed']!, _timesCompletedMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('season_number')) {
      context.handle(
          _seasonNumberMeta,
          seasonNumber.isAcceptableOrUnknown(
              data['season_number']!, _seasonNumberMeta));
    }
    if (data.containsKey('episode_number')) {
      context.handle(
          _episodeNumberMeta,
          episodeNumber.isAcceptableOrUnknown(
              data['episode_number']!, _episodeNumberMeta));
    }
    if (data.containsKey('episode_ratings')) {
      context.handle(
          _episodeRatingsMeta,
          episodeRatings.isAcceptableOrUnknown(
              data['episode_ratings']!, _episodeRatingsMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackingEntriesCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackingEntriesCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      ownedItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owned_item_id']),
      editionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edition_id']),
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
      bundleReleaseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}bundle_release_id']),
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status']),
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      finishedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}finished_at']),
      progressCurrent: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}progress_current']),
      progressTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}progress_total']),
      timesCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}times_completed']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      seasonNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}season_number']),
      episodeNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}episode_number']),
      episodeRatings: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}episode_ratings']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TrackingEntriesCacheTable createAlias(String alias) {
    return $TrackingEntriesCacheTable(attachedDatabase, alias);
  }
}

class TrackingEntriesCacheData extends DataClass
    implements Insertable<TrackingEntriesCacheData> {
  final String id;
  final String itemId;
  final String? ownedItemId;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
  final String? sourceType;
  final String? status;
  final int? rating;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;
  final String? notes;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? episodeRatings;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TrackingEntriesCacheData(
      {required this.id,
      required this.itemId,
      this.ownedItemId,
      this.editionId,
      this.variantId,
      this.bundleReleaseId,
      this.sourceType,
      this.status,
      this.rating,
      this.startedAt,
      this.finishedAt,
      this.progressCurrent,
      this.progressTotal,
      this.timesCompleted,
      this.notes,
      this.seasonNumber,
      this.episodeNumber,
      this.episodeRatings,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || ownedItemId != null) {
      map['owned_item_id'] = Variable<String>(ownedItemId);
    }
    if (!nullToAbsent || editionId != null) {
      map['edition_id'] = Variable<String>(editionId);
    }
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    if (!nullToAbsent || bundleReleaseId != null) {
      map['bundle_release_id'] = Variable<String>(bundleReleaseId);
    }
    if (!nullToAbsent || sourceType != null) {
      map['source_type'] = Variable<String>(sourceType);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || progressCurrent != null) {
      map['progress_current'] = Variable<int>(progressCurrent);
    }
    if (!nullToAbsent || progressTotal != null) {
      map['progress_total'] = Variable<int>(progressTotal);
    }
    if (!nullToAbsent || timesCompleted != null) {
      map['times_completed'] = Variable<int>(timesCompleted);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || seasonNumber != null) {
      map['season_number'] = Variable<int>(seasonNumber);
    }
    if (!nullToAbsent || episodeNumber != null) {
      map['episode_number'] = Variable<int>(episodeNumber);
    }
    if (!nullToAbsent || episodeRatings != null) {
      map['episode_ratings'] = Variable<String>(episodeRatings);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TrackingEntriesCacheCompanion toCompanion(bool nullToAbsent) {
    return TrackingEntriesCacheCompanion(
      id: Value(id),
      itemId: Value(itemId),
      ownedItemId: ownedItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownedItemId),
      editionId: editionId == null && nullToAbsent
          ? const Value.absent()
          : Value(editionId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      bundleReleaseId: bundleReleaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(bundleReleaseId),
      sourceType: sourceType == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceType),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      progressCurrent: progressCurrent == null && nullToAbsent
          ? const Value.absent()
          : Value(progressCurrent),
      progressTotal: progressTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(progressTotal),
      timesCompleted: timesCompleted == null && nullToAbsent
          ? const Value.absent()
          : Value(timesCompleted),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      seasonNumber: seasonNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonNumber),
      episodeNumber: episodeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(episodeNumber),
      episodeRatings: episodeRatings == null && nullToAbsent
          ? const Value.absent()
          : Value(episodeRatings),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TrackingEntriesCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackingEntriesCacheData(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      ownedItemId: serializer.fromJson<String?>(json['ownedItemId']),
      editionId: serializer.fromJson<String?>(json['editionId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      bundleReleaseId: serializer.fromJson<String?>(json['bundleReleaseId']),
      sourceType: serializer.fromJson<String?>(json['sourceType']),
      status: serializer.fromJson<String?>(json['status']),
      rating: serializer.fromJson<int?>(json['rating']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      progressCurrent: serializer.fromJson<int?>(json['progressCurrent']),
      progressTotal: serializer.fromJson<int?>(json['progressTotal']),
      timesCompleted: serializer.fromJson<int?>(json['timesCompleted']),
      notes: serializer.fromJson<String?>(json['notes']),
      seasonNumber: serializer.fromJson<int?>(json['seasonNumber']),
      episodeNumber: serializer.fromJson<int?>(json['episodeNumber']),
      episodeRatings: serializer.fromJson<String?>(json['episodeRatings']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'ownedItemId': serializer.toJson<String?>(ownedItemId),
      'editionId': serializer.toJson<String?>(editionId),
      'variantId': serializer.toJson<String?>(variantId),
      'bundleReleaseId': serializer.toJson<String?>(bundleReleaseId),
      'sourceType': serializer.toJson<String?>(sourceType),
      'status': serializer.toJson<String?>(status),
      'rating': serializer.toJson<int?>(rating),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'progressCurrent': serializer.toJson<int?>(progressCurrent),
      'progressTotal': serializer.toJson<int?>(progressTotal),
      'timesCompleted': serializer.toJson<int?>(timesCompleted),
      'notes': serializer.toJson<String?>(notes),
      'seasonNumber': serializer.toJson<int?>(seasonNumber),
      'episodeNumber': serializer.toJson<int?>(episodeNumber),
      'episodeRatings': serializer.toJson<String?>(episodeRatings),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TrackingEntriesCacheData copyWith(
          {String? id,
          String? itemId,
          Value<String?> ownedItemId = const Value.absent(),
          Value<String?> editionId = const Value.absent(),
          Value<String?> variantId = const Value.absent(),
          Value<String?> bundleReleaseId = const Value.absent(),
          Value<String?> sourceType = const Value.absent(),
          Value<String?> status = const Value.absent(),
          Value<int?> rating = const Value.absent(),
          Value<DateTime?> startedAt = const Value.absent(),
          Value<DateTime?> finishedAt = const Value.absent(),
          Value<int?> progressCurrent = const Value.absent(),
          Value<int?> progressTotal = const Value.absent(),
          Value<int?> timesCompleted = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<int?> seasonNumber = const Value.absent(),
          Value<int?> episodeNumber = const Value.absent(),
          Value<String?> episodeRatings = const Value.absent(),
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      TrackingEntriesCacheData(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        ownedItemId: ownedItemId.present ? ownedItemId.value : this.ownedItemId,
        editionId: editionId.present ? editionId.value : this.editionId,
        variantId: variantId.present ? variantId.value : this.variantId,
        bundleReleaseId: bundleReleaseId.present
            ? bundleReleaseId.value
            : this.bundleReleaseId,
        sourceType: sourceType.present ? sourceType.value : this.sourceType,
        status: status.present ? status.value : this.status,
        rating: rating.present ? rating.value : this.rating,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
        progressCurrent: progressCurrent.present
            ? progressCurrent.value
            : this.progressCurrent,
        progressTotal:
            progressTotal.present ? progressTotal.value : this.progressTotal,
        timesCompleted:
            timesCompleted.present ? timesCompleted.value : this.timesCompleted,
        notes: notes.present ? notes.value : this.notes,
        seasonNumber:
            seasonNumber.present ? seasonNumber.value : this.seasonNumber,
        episodeNumber:
            episodeNumber.present ? episodeNumber.value : this.episodeNumber,
        episodeRatings:
            episodeRatings.present ? episodeRatings.value : this.episodeRatings,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  TrackingEntriesCacheData copyWithCompanion(
      TrackingEntriesCacheCompanion data) {
    return TrackingEntriesCacheData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      ownedItemId:
          data.ownedItemId.present ? data.ownedItemId.value : this.ownedItemId,
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      bundleReleaseId: data.bundleReleaseId.present
          ? data.bundleReleaseId.value
          : this.bundleReleaseId,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      status: data.status.present ? data.status.value : this.status,
      rating: data.rating.present ? data.rating.value : this.rating,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt:
          data.finishedAt.present ? data.finishedAt.value : this.finishedAt,
      progressCurrent: data.progressCurrent.present
          ? data.progressCurrent.value
          : this.progressCurrent,
      progressTotal: data.progressTotal.present
          ? data.progressTotal.value
          : this.progressTotal,
      timesCompleted: data.timesCompleted.present
          ? data.timesCompleted.value
          : this.timesCompleted,
      notes: data.notes.present ? data.notes.value : this.notes,
      seasonNumber: data.seasonNumber.present
          ? data.seasonNumber.value
          : this.seasonNumber,
      episodeNumber: data.episodeNumber.present
          ? data.episodeNumber.value
          : this.episodeNumber,
      episodeRatings: data.episodeRatings.present
          ? data.episodeRatings.value
          : this.episodeRatings,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackingEntriesCacheData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('bundleReleaseId: $bundleReleaseId, ')
          ..write('sourceType: $sourceType, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('progressCurrent: $progressCurrent, ')
          ..write('progressTotal: $progressTotal, ')
          ..write('timesCompleted: $timesCompleted, ')
          ..write('notes: $notes, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('episodeRatings: $episodeRatings, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      itemId,
      ownedItemId,
      editionId,
      variantId,
      bundleReleaseId,
      sourceType,
      status,
      rating,
      startedAt,
      finishedAt,
      progressCurrent,
      progressTotal,
      timesCompleted,
      notes,
      seasonNumber,
      episodeNumber,
      episodeRatings,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackingEntriesCacheData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.ownedItemId == this.ownedItemId &&
          other.editionId == this.editionId &&
          other.variantId == this.variantId &&
          other.bundleReleaseId == this.bundleReleaseId &&
          other.sourceType == this.sourceType &&
          other.status == this.status &&
          other.rating == this.rating &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.progressCurrent == this.progressCurrent &&
          other.progressTotal == this.progressTotal &&
          other.timesCompleted == this.timesCompleted &&
          other.notes == this.notes &&
          other.seasonNumber == this.seasonNumber &&
          other.episodeNumber == this.episodeNumber &&
          other.episodeRatings == this.episodeRatings &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TrackingEntriesCacheCompanion
    extends UpdateCompanion<TrackingEntriesCacheData> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> ownedItemId;
  final Value<String?> editionId;
  final Value<String?> variantId;
  final Value<String?> bundleReleaseId;
  final Value<String?> sourceType;
  final Value<String?> status;
  final Value<int?> rating;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int?> progressCurrent;
  final Value<int?> progressTotal;
  final Value<int?> timesCompleted;
  final Value<String?> notes;
  final Value<int?> seasonNumber;
  final Value<int?> episodeNumber;
  final Value<String?> episodeRatings;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TrackingEntriesCacheCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.ownedItemId = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.bundleReleaseId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.status = const Value.absent(),
    this.rating = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.progressCurrent = const Value.absent(),
    this.progressTotal = const Value.absent(),
    this.timesCompleted = const Value.absent(),
    this.notes = const Value.absent(),
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.episodeRatings = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackingEntriesCacheCompanion.insert({
    required String id,
    required String itemId,
    this.ownedItemId = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.bundleReleaseId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.status = const Value.absent(),
    this.rating = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.progressCurrent = const Value.absent(),
    this.progressTotal = const Value.absent(),
    this.timesCompleted = const Value.absent(),
    this.notes = const Value.absent(),
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.episodeRatings = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        updatedAt = Value(updatedAt);
  static Insertable<TrackingEntriesCacheData> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? ownedItemId,
    Expression<String>? editionId,
    Expression<String>? variantId,
    Expression<String>? bundleReleaseId,
    Expression<String>? sourceType,
    Expression<String>? status,
    Expression<int>? rating,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? progressCurrent,
    Expression<int>? progressTotal,
    Expression<int>? timesCompleted,
    Expression<String>? notes,
    Expression<int>? seasonNumber,
    Expression<int>? episodeNumber,
    Expression<String>? episodeRatings,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (ownedItemId != null) 'owned_item_id': ownedItemId,
      if (editionId != null) 'edition_id': editionId,
      if (variantId != null) 'variant_id': variantId,
      if (bundleReleaseId != null) 'bundle_release_id': bundleReleaseId,
      if (sourceType != null) 'source_type': sourceType,
      if (status != null) 'status': status,
      if (rating != null) 'rating': rating,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (progressCurrent != null) 'progress_current': progressCurrent,
      if (progressTotal != null) 'progress_total': progressTotal,
      if (timesCompleted != null) 'times_completed': timesCompleted,
      if (notes != null) 'notes': notes,
      if (seasonNumber != null) 'season_number': seasonNumber,
      if (episodeNumber != null) 'episode_number': episodeNumber,
      if (episodeRatings != null) 'episode_ratings': episodeRatings,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackingEntriesCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String?>? ownedItemId,
      Value<String?>? editionId,
      Value<String?>? variantId,
      Value<String?>? bundleReleaseId,
      Value<String?>? sourceType,
      Value<String?>? status,
      Value<int?>? rating,
      Value<DateTime?>? startedAt,
      Value<DateTime?>? finishedAt,
      Value<int?>? progressCurrent,
      Value<int?>? progressTotal,
      Value<int?>? timesCompleted,
      Value<String?>? notes,
      Value<int?>? seasonNumber,
      Value<int?>? episodeNumber,
      Value<String?>? episodeRatings,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return TrackingEntriesCacheCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
      sourceType: sourceType ?? this.sourceType,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      progressCurrent: progressCurrent ?? this.progressCurrent,
      progressTotal: progressTotal ?? this.progressTotal,
      timesCompleted: timesCompleted ?? this.timesCompleted,
      notes: notes ?? this.notes,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      episodeRatings: episodeRatings ?? this.episodeRatings,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (ownedItemId.present) {
      map['owned_item_id'] = Variable<String>(ownedItemId.value);
    }
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (bundleReleaseId.present) {
      map['bundle_release_id'] = Variable<String>(bundleReleaseId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (progressCurrent.present) {
      map['progress_current'] = Variable<int>(progressCurrent.value);
    }
    if (progressTotal.present) {
      map['progress_total'] = Variable<int>(progressTotal.value);
    }
    if (timesCompleted.present) {
      map['times_completed'] = Variable<int>(timesCompleted.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (seasonNumber.present) {
      map['season_number'] = Variable<int>(seasonNumber.value);
    }
    if (episodeNumber.present) {
      map['episode_number'] = Variable<int>(episodeNumber.value);
    }
    if (episodeRatings.present) {
      map['episode_ratings'] = Variable<String>(episodeRatings.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackingEntriesCacheCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('bundleReleaseId: $bundleReleaseId, ')
          ..write('sourceType: $sourceType, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('progressCurrent: $progressCurrent, ')
          ..write('progressTotal: $progressTotal, ')
          ..write('timesCompleted: $timesCompleted, ')
          ..write('notes: $notes, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('episodeRatings: $episodeRatings, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackingUnitsCacheTable extends TrackingUnitsCache
    with TableInfo<$TrackingUnitsCacheTable, TrackingUnitsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackingUnitsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _trackingEntryIdMeta =
      const VerificationMeta('trackingEntryId');
  @override
  late final GeneratedColumn<String> trackingEntryId = GeneratedColumn<String>(
      'tracking_entry_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownedItemIdMeta =
      const VerificationMeta('ownedItemId');
  @override
  late final GeneratedColumn<String> ownedItemId = GeneratedColumn<String>(
      'owned_item_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editionIdMeta =
      const VerificationMeta('editionId');
  @override
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
      'edition_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bundleReleaseIdMeta =
      const VerificationMeta('bundleReleaseId');
  @override
  late final GeneratedColumn<String> bundleReleaseId = GeneratedColumn<String>(
      'bundle_release_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _unitTypeMeta =
      const VerificationMeta('unitType');
  @override
  late final GeneratedColumn<String> unitType = GeneratedColumn<String>(
      'unit_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _seasonNumberMeta =
      const VerificationMeta('seasonNumber');
  @override
  late final GeneratedColumn<int> seasonNumber = GeneratedColumn<int>(
      'season_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _episodeNumberMeta =
      const VerificationMeta('episodeNumber');
  @override
  late final GeneratedColumn<int> episodeNumber = GeneratedColumn<int>(
      'episode_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _volumeNumberMeta =
      const VerificationMeta('volumeNumber');
  @override
  late final GeneratedColumn<int> volumeNumber = GeneratedColumn<int>(
      'volume_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _chapterNumberMeta =
      const VerificationMeta('chapterNumber');
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
      'chapter_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _issueNumberMeta =
      const VerificationMeta('issueNumber');
  @override
  late final GeneratedColumn<String> issueNumber = GeneratedColumn<String>(
      'issue_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemId,
        trackingEntryId,
        ownedItemId,
        editionId,
        variantId,
        bundleReleaseId,
        unitType,
        seasonNumber,
        episodeNumber,
        volumeNumber,
        chapterNumber,
        issueNumber,
        completedAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracking_units_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<TrackingUnitsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('tracking_entry_id')) {
      context.handle(
          _trackingEntryIdMeta,
          trackingEntryId.isAcceptableOrUnknown(
              data['tracking_entry_id']!, _trackingEntryIdMeta));
    }
    if (data.containsKey('owned_item_id')) {
      context.handle(
          _ownedItemIdMeta,
          ownedItemId.isAcceptableOrUnknown(
              data['owned_item_id']!, _ownedItemIdMeta));
    }
    if (data.containsKey('edition_id')) {
      context.handle(_editionIdMeta,
          editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta));
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    }
    if (data.containsKey('bundle_release_id')) {
      context.handle(
          _bundleReleaseIdMeta,
          bundleReleaseId.isAcceptableOrUnknown(
              data['bundle_release_id']!, _bundleReleaseIdMeta));
    }
    if (data.containsKey('unit_type')) {
      context.handle(_unitTypeMeta,
          unitType.isAcceptableOrUnknown(data['unit_type']!, _unitTypeMeta));
    } else if (isInserting) {
      context.missing(_unitTypeMeta);
    }
    if (data.containsKey('season_number')) {
      context.handle(
          _seasonNumberMeta,
          seasonNumber.isAcceptableOrUnknown(
              data['season_number']!, _seasonNumberMeta));
    }
    if (data.containsKey('episode_number')) {
      context.handle(
          _episodeNumberMeta,
          episodeNumber.isAcceptableOrUnknown(
              data['episode_number']!, _episodeNumberMeta));
    }
    if (data.containsKey('volume_number')) {
      context.handle(
          _volumeNumberMeta,
          volumeNumber.isAcceptableOrUnknown(
              data['volume_number']!, _volumeNumberMeta));
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
          _chapterNumberMeta,
          chapterNumber.isAcceptableOrUnknown(
              data['chapter_number']!, _chapterNumberMeta));
    }
    if (data.containsKey('issue_number')) {
      context.handle(
          _issueNumberMeta,
          issueNumber.isAcceptableOrUnknown(
              data['issue_number']!, _issueNumberMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackingUnitsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackingUnitsCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      trackingEntryId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}tracking_entry_id']),
      ownedItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owned_item_id']),
      editionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edition_id']),
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
      bundleReleaseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}bundle_release_id']),
      unitType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_type'])!,
      seasonNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}season_number']),
      episodeNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}episode_number']),
      volumeNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}volume_number']),
      chapterNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_number']),
      issueNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}issue_number']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TrackingUnitsCacheTable createAlias(String alias) {
    return $TrackingUnitsCacheTable(attachedDatabase, alias);
  }
}

class TrackingUnitsCacheData extends DataClass
    implements Insertable<TrackingUnitsCacheData> {
  final String id;
  final String itemId;
  final String? trackingEntryId;
  final String? ownedItemId;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
  final String unitType;
  final int? seasonNumber;
  final int? episodeNumber;
  final int? volumeNumber;
  final int? chapterNumber;
  final String? issueNumber;
  final DateTime completedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TrackingUnitsCacheData(
      {required this.id,
      required this.itemId,
      this.trackingEntryId,
      this.ownedItemId,
      this.editionId,
      this.variantId,
      this.bundleReleaseId,
      required this.unitType,
      this.seasonNumber,
      this.episodeNumber,
      this.volumeNumber,
      this.chapterNumber,
      this.issueNumber,
      required this.completedAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || trackingEntryId != null) {
      map['tracking_entry_id'] = Variable<String>(trackingEntryId);
    }
    if (!nullToAbsent || ownedItemId != null) {
      map['owned_item_id'] = Variable<String>(ownedItemId);
    }
    if (!nullToAbsent || editionId != null) {
      map['edition_id'] = Variable<String>(editionId);
    }
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    if (!nullToAbsent || bundleReleaseId != null) {
      map['bundle_release_id'] = Variable<String>(bundleReleaseId);
    }
    map['unit_type'] = Variable<String>(unitType);
    if (!nullToAbsent || seasonNumber != null) {
      map['season_number'] = Variable<int>(seasonNumber);
    }
    if (!nullToAbsent || episodeNumber != null) {
      map['episode_number'] = Variable<int>(episodeNumber);
    }
    if (!nullToAbsent || volumeNumber != null) {
      map['volume_number'] = Variable<int>(volumeNumber);
    }
    if (!nullToAbsent || chapterNumber != null) {
      map['chapter_number'] = Variable<int>(chapterNumber);
    }
    if (!nullToAbsent || issueNumber != null) {
      map['issue_number'] = Variable<String>(issueNumber);
    }
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TrackingUnitsCacheCompanion toCompanion(bool nullToAbsent) {
    return TrackingUnitsCacheCompanion(
      id: Value(id),
      itemId: Value(itemId),
      trackingEntryId: trackingEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(trackingEntryId),
      ownedItemId: ownedItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownedItemId),
      editionId: editionId == null && nullToAbsent
          ? const Value.absent()
          : Value(editionId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      bundleReleaseId: bundleReleaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(bundleReleaseId),
      unitType: Value(unitType),
      seasonNumber: seasonNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonNumber),
      episodeNumber: episodeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(episodeNumber),
      volumeNumber: volumeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(volumeNumber),
      chapterNumber: chapterNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterNumber),
      issueNumber: issueNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(issueNumber),
      completedAt: Value(completedAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TrackingUnitsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackingUnitsCacheData(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      trackingEntryId: serializer.fromJson<String?>(json['trackingEntryId']),
      ownedItemId: serializer.fromJson<String?>(json['ownedItemId']),
      editionId: serializer.fromJson<String?>(json['editionId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      bundleReleaseId: serializer.fromJson<String?>(json['bundleReleaseId']),
      unitType: serializer.fromJson<String>(json['unitType']),
      seasonNumber: serializer.fromJson<int?>(json['seasonNumber']),
      episodeNumber: serializer.fromJson<int?>(json['episodeNumber']),
      volumeNumber: serializer.fromJson<int?>(json['volumeNumber']),
      chapterNumber: serializer.fromJson<int?>(json['chapterNumber']),
      issueNumber: serializer.fromJson<String?>(json['issueNumber']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'trackingEntryId': serializer.toJson<String?>(trackingEntryId),
      'ownedItemId': serializer.toJson<String?>(ownedItemId),
      'editionId': serializer.toJson<String?>(editionId),
      'variantId': serializer.toJson<String?>(variantId),
      'bundleReleaseId': serializer.toJson<String?>(bundleReleaseId),
      'unitType': serializer.toJson<String>(unitType),
      'seasonNumber': serializer.toJson<int?>(seasonNumber),
      'episodeNumber': serializer.toJson<int?>(episodeNumber),
      'volumeNumber': serializer.toJson<int?>(volumeNumber),
      'chapterNumber': serializer.toJson<int?>(chapterNumber),
      'issueNumber': serializer.toJson<String?>(issueNumber),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TrackingUnitsCacheData copyWith(
          {String? id,
          String? itemId,
          Value<String?> trackingEntryId = const Value.absent(),
          Value<String?> ownedItemId = const Value.absent(),
          Value<String?> editionId = const Value.absent(),
          Value<String?> variantId = const Value.absent(),
          Value<String?> bundleReleaseId = const Value.absent(),
          String? unitType,
          Value<int?> seasonNumber = const Value.absent(),
          Value<int?> episodeNumber = const Value.absent(),
          Value<int?> volumeNumber = const Value.absent(),
          Value<int?> chapterNumber = const Value.absent(),
          Value<String?> issueNumber = const Value.absent(),
          DateTime? completedAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      TrackingUnitsCacheData(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        trackingEntryId: trackingEntryId.present
            ? trackingEntryId.value
            : this.trackingEntryId,
        ownedItemId: ownedItemId.present ? ownedItemId.value : this.ownedItemId,
        editionId: editionId.present ? editionId.value : this.editionId,
        variantId: variantId.present ? variantId.value : this.variantId,
        bundleReleaseId: bundleReleaseId.present
            ? bundleReleaseId.value
            : this.bundleReleaseId,
        unitType: unitType ?? this.unitType,
        seasonNumber:
            seasonNumber.present ? seasonNumber.value : this.seasonNumber,
        episodeNumber:
            episodeNumber.present ? episodeNumber.value : this.episodeNumber,
        volumeNumber:
            volumeNumber.present ? volumeNumber.value : this.volumeNumber,
        chapterNumber:
            chapterNumber.present ? chapterNumber.value : this.chapterNumber,
        issueNumber: issueNumber.present ? issueNumber.value : this.issueNumber,
        completedAt: completedAt ?? this.completedAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  TrackingUnitsCacheData copyWithCompanion(TrackingUnitsCacheCompanion data) {
    return TrackingUnitsCacheData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      trackingEntryId: data.trackingEntryId.present
          ? data.trackingEntryId.value
          : this.trackingEntryId,
      ownedItemId:
          data.ownedItemId.present ? data.ownedItemId.value : this.ownedItemId,
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      bundleReleaseId: data.bundleReleaseId.present
          ? data.bundleReleaseId.value
          : this.bundleReleaseId,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      seasonNumber: data.seasonNumber.present
          ? data.seasonNumber.value
          : this.seasonNumber,
      episodeNumber: data.episodeNumber.present
          ? data.episodeNumber.value
          : this.episodeNumber,
      volumeNumber: data.volumeNumber.present
          ? data.volumeNumber.value
          : this.volumeNumber,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      issueNumber:
          data.issueNumber.present ? data.issueNumber.value : this.issueNumber,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackingUnitsCacheData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('trackingEntryId: $trackingEntryId, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('bundleReleaseId: $bundleReleaseId, ')
          ..write('unitType: $unitType, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('volumeNumber: $volumeNumber, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('issueNumber: $issueNumber, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      itemId,
      trackingEntryId,
      ownedItemId,
      editionId,
      variantId,
      bundleReleaseId,
      unitType,
      seasonNumber,
      episodeNumber,
      volumeNumber,
      chapterNumber,
      issueNumber,
      completedAt,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackingUnitsCacheData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.trackingEntryId == this.trackingEntryId &&
          other.ownedItemId == this.ownedItemId &&
          other.editionId == this.editionId &&
          other.variantId == this.variantId &&
          other.bundleReleaseId == this.bundleReleaseId &&
          other.unitType == this.unitType &&
          other.seasonNumber == this.seasonNumber &&
          other.episodeNumber == this.episodeNumber &&
          other.volumeNumber == this.volumeNumber &&
          other.chapterNumber == this.chapterNumber &&
          other.issueNumber == this.issueNumber &&
          other.completedAt == this.completedAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TrackingUnitsCacheCompanion
    extends UpdateCompanion<TrackingUnitsCacheData> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> trackingEntryId;
  final Value<String?> ownedItemId;
  final Value<String?> editionId;
  final Value<String?> variantId;
  final Value<String?> bundleReleaseId;
  final Value<String> unitType;
  final Value<int?> seasonNumber;
  final Value<int?> episodeNumber;
  final Value<int?> volumeNumber;
  final Value<int?> chapterNumber;
  final Value<String?> issueNumber;
  final Value<DateTime> completedAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TrackingUnitsCacheCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.trackingEntryId = const Value.absent(),
    this.ownedItemId = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.bundleReleaseId = const Value.absent(),
    this.unitType = const Value.absent(),
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.volumeNumber = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.issueNumber = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackingUnitsCacheCompanion.insert({
    required String id,
    required String itemId,
    this.trackingEntryId = const Value.absent(),
    this.ownedItemId = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.bundleReleaseId = const Value.absent(),
    required String unitType,
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.volumeNumber = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.issueNumber = const Value.absent(),
    required DateTime completedAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        unitType = Value(unitType),
        completedAt = Value(completedAt),
        updatedAt = Value(updatedAt);
  static Insertable<TrackingUnitsCacheData> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? trackingEntryId,
    Expression<String>? ownedItemId,
    Expression<String>? editionId,
    Expression<String>? variantId,
    Expression<String>? bundleReleaseId,
    Expression<String>? unitType,
    Expression<int>? seasonNumber,
    Expression<int>? episodeNumber,
    Expression<int>? volumeNumber,
    Expression<int>? chapterNumber,
    Expression<String>? issueNumber,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (trackingEntryId != null) 'tracking_entry_id': trackingEntryId,
      if (ownedItemId != null) 'owned_item_id': ownedItemId,
      if (editionId != null) 'edition_id': editionId,
      if (variantId != null) 'variant_id': variantId,
      if (bundleReleaseId != null) 'bundle_release_id': bundleReleaseId,
      if (unitType != null) 'unit_type': unitType,
      if (seasonNumber != null) 'season_number': seasonNumber,
      if (episodeNumber != null) 'episode_number': episodeNumber,
      if (volumeNumber != null) 'volume_number': volumeNumber,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (issueNumber != null) 'issue_number': issueNumber,
      if (completedAt != null) 'completed_at': completedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackingUnitsCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String?>? trackingEntryId,
      Value<String?>? ownedItemId,
      Value<String?>? editionId,
      Value<String?>? variantId,
      Value<String?>? bundleReleaseId,
      Value<String>? unitType,
      Value<int?>? seasonNumber,
      Value<int?>? episodeNumber,
      Value<int?>? volumeNumber,
      Value<int?>? chapterNumber,
      Value<String?>? issueNumber,
      Value<DateTime>? completedAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return TrackingUnitsCacheCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
      unitType: unitType ?? this.unitType,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      volumeNumber: volumeNumber ?? this.volumeNumber,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      issueNumber: issueNumber ?? this.issueNumber,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (trackingEntryId.present) {
      map['tracking_entry_id'] = Variable<String>(trackingEntryId.value);
    }
    if (ownedItemId.present) {
      map['owned_item_id'] = Variable<String>(ownedItemId.value);
    }
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (bundleReleaseId.present) {
      map['bundle_release_id'] = Variable<String>(bundleReleaseId.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(unitType.value);
    }
    if (seasonNumber.present) {
      map['season_number'] = Variable<int>(seasonNumber.value);
    }
    if (episodeNumber.present) {
      map['episode_number'] = Variable<int>(episodeNumber.value);
    }
    if (volumeNumber.present) {
      map['volume_number'] = Variable<int>(volumeNumber.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (issueNumber.present) {
      map['issue_number'] = Variable<String>(issueNumber.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackingUnitsCacheCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('trackingEntryId: $trackingEntryId, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('bundleReleaseId: $bundleReleaseId, ')
          ..write('unitType: $unitType, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('volumeNumber: $volumeNumber, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('issueNumber: $issueNumber, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchSessionsCacheTable extends WatchSessionsCache
    with TableInfo<$WatchSessionsCacheTable, WatchSessionsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchSessionsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetRefJsonMeta =
      const VerificationMeta('targetRefJson');
  @override
  late final GeneratedColumn<String> targetRefJson = GeneratedColumn<String>(
      'target_ref_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _trackingEntryIdMeta =
      const VerificationMeta('trackingEntryId');
  @override
  late final GeneratedColumn<String> trackingEntryId = GeneratedColumn<String>(
      'tracking_entry_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seasonNumberMeta =
      const VerificationMeta('seasonNumber');
  @override
  late final GeneratedColumn<int> seasonNumber = GeneratedColumn<int>(
      'season_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _episodeNumberMeta =
      const VerificationMeta('episodeNumber');
  @override
  late final GeneratedColumn<int> episodeNumber = GeneratedColumn<int>(
      'episode_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seenWhereMeta =
      const VerificationMeta('seenWhere');
  @override
  late final GeneratedColumn<String> seenWhere = GeneratedColumn<String>(
      'seen_where', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _watchedAtMeta =
      const VerificationMeta('watchedAt');
  @override
  late final GeneratedColumn<DateTime> watchedAt = GeneratedColumn<DateTime>(
      'watched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemId,
        targetRefJson,
        trackingEntryId,
        seasonNumber,
        episodeNumber,
        sourceType,
        seenWhere,
        watchedAt,
        rating,
        notes,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_sessions_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<WatchSessionsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('target_ref_json')) {
      context.handle(
          _targetRefJsonMeta,
          targetRefJson.isAcceptableOrUnknown(
              data['target_ref_json']!, _targetRefJsonMeta));
    }
    if (data.containsKey('tracking_entry_id')) {
      context.handle(
          _trackingEntryIdMeta,
          trackingEntryId.isAcceptableOrUnknown(
              data['tracking_entry_id']!, _trackingEntryIdMeta));
    }
    if (data.containsKey('season_number')) {
      context.handle(
          _seasonNumberMeta,
          seasonNumber.isAcceptableOrUnknown(
              data['season_number']!, _seasonNumberMeta));
    }
    if (data.containsKey('episode_number')) {
      context.handle(
          _episodeNumberMeta,
          episodeNumber.isAcceptableOrUnknown(
              data['episode_number']!, _episodeNumberMeta));
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    }
    if (data.containsKey('seen_where')) {
      context.handle(_seenWhereMeta,
          seenWhere.isAcceptableOrUnknown(data['seen_where']!, _seenWhereMeta));
    }
    if (data.containsKey('watched_at')) {
      context.handle(_watchedAtMeta,
          watchedAt.isAcceptableOrUnknown(data['watched_at']!, _watchedAtMeta));
    } else if (isInserting) {
      context.missing(_watchedAtMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchSessionsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchSessionsCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      targetRefJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_ref_json']),
      trackingEntryId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}tracking_entry_id']),
      seasonNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}season_number']),
      episodeNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}episode_number']),
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type']),
      seenWhere: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seen_where']),
      watchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}watched_at'])!,
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $WatchSessionsCacheTable createAlias(String alias) {
    return $WatchSessionsCacheTable(attachedDatabase, alias);
  }
}

class WatchSessionsCacheData extends DataClass
    implements Insertable<WatchSessionsCacheData> {
  final String id;
  final String itemId;
  final String? targetRefJson;
  final String? trackingEntryId;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? sourceType;
  final String? seenWhere;
  final DateTime watchedAt;
  final int? rating;
  final String? notes;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const WatchSessionsCacheData(
      {required this.id,
      required this.itemId,
      this.targetRefJson,
      this.trackingEntryId,
      this.seasonNumber,
      this.episodeNumber,
      this.sourceType,
      this.seenWhere,
      required this.watchedAt,
      this.rating,
      this.notes,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || targetRefJson != null) {
      map['target_ref_json'] = Variable<String>(targetRefJson);
    }
    if (!nullToAbsent || trackingEntryId != null) {
      map['tracking_entry_id'] = Variable<String>(trackingEntryId);
    }
    if (!nullToAbsent || seasonNumber != null) {
      map['season_number'] = Variable<int>(seasonNumber);
    }
    if (!nullToAbsent || episodeNumber != null) {
      map['episode_number'] = Variable<int>(episodeNumber);
    }
    if (!nullToAbsent || sourceType != null) {
      map['source_type'] = Variable<String>(sourceType);
    }
    if (!nullToAbsent || seenWhere != null) {
      map['seen_where'] = Variable<String>(seenWhere);
    }
    map['watched_at'] = Variable<DateTime>(watchedAt);
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  WatchSessionsCacheCompanion toCompanion(bool nullToAbsent) {
    return WatchSessionsCacheCompanion(
      id: Value(id),
      itemId: Value(itemId),
      targetRefJson: targetRefJson == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRefJson),
      trackingEntryId: trackingEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(trackingEntryId),
      seasonNumber: seasonNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonNumber),
      episodeNumber: episodeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(episodeNumber),
      sourceType: sourceType == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceType),
      seenWhere: seenWhere == null && nullToAbsent
          ? const Value.absent()
          : Value(seenWhere),
      watchedAt: Value(watchedAt),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory WatchSessionsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchSessionsCacheData(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      targetRefJson: serializer.fromJson<String?>(json['targetRefJson']),
      trackingEntryId: serializer.fromJson<String?>(json['trackingEntryId']),
      seasonNumber: serializer.fromJson<int?>(json['seasonNumber']),
      episodeNumber: serializer.fromJson<int?>(json['episodeNumber']),
      sourceType: serializer.fromJson<String?>(json['sourceType']),
      seenWhere: serializer.fromJson<String?>(json['seenWhere']),
      watchedAt: serializer.fromJson<DateTime>(json['watchedAt']),
      rating: serializer.fromJson<int?>(json['rating']),
      notes: serializer.fromJson<String?>(json['notes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'targetRefJson': serializer.toJson<String?>(targetRefJson),
      'trackingEntryId': serializer.toJson<String?>(trackingEntryId),
      'seasonNumber': serializer.toJson<int?>(seasonNumber),
      'episodeNumber': serializer.toJson<int?>(episodeNumber),
      'sourceType': serializer.toJson<String?>(sourceType),
      'seenWhere': serializer.toJson<String?>(seenWhere),
      'watchedAt': serializer.toJson<DateTime>(watchedAt),
      'rating': serializer.toJson<int?>(rating),
      'notes': serializer.toJson<String?>(notes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  WatchSessionsCacheData copyWith(
          {String? id,
          String? itemId,
          Value<String?> targetRefJson = const Value.absent(),
          Value<String?> trackingEntryId = const Value.absent(),
          Value<int?> seasonNumber = const Value.absent(),
          Value<int?> episodeNumber = const Value.absent(),
          Value<String?> sourceType = const Value.absent(),
          Value<String?> seenWhere = const Value.absent(),
          DateTime? watchedAt,
          Value<int?> rating = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      WatchSessionsCacheData(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        targetRefJson:
            targetRefJson.present ? targetRefJson.value : this.targetRefJson,
        trackingEntryId: trackingEntryId.present
            ? trackingEntryId.value
            : this.trackingEntryId,
        seasonNumber:
            seasonNumber.present ? seasonNumber.value : this.seasonNumber,
        episodeNumber:
            episodeNumber.present ? episodeNumber.value : this.episodeNumber,
        sourceType: sourceType.present ? sourceType.value : this.sourceType,
        seenWhere: seenWhere.present ? seenWhere.value : this.seenWhere,
        watchedAt: watchedAt ?? this.watchedAt,
        rating: rating.present ? rating.value : this.rating,
        notes: notes.present ? notes.value : this.notes,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  WatchSessionsCacheData copyWithCompanion(WatchSessionsCacheCompanion data) {
    return WatchSessionsCacheData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      targetRefJson: data.targetRefJson.present
          ? data.targetRefJson.value
          : this.targetRefJson,
      trackingEntryId: data.trackingEntryId.present
          ? data.trackingEntryId.value
          : this.trackingEntryId,
      seasonNumber: data.seasonNumber.present
          ? data.seasonNumber.value
          : this.seasonNumber,
      episodeNumber: data.episodeNumber.present
          ? data.episodeNumber.value
          : this.episodeNumber,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      seenWhere: data.seenWhere.present ? data.seenWhere.value : this.seenWhere,
      watchedAt: data.watchedAt.present ? data.watchedAt.value : this.watchedAt,
      rating: data.rating.present ? data.rating.value : this.rating,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchSessionsCacheData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('targetRefJson: $targetRefJson, ')
          ..write('trackingEntryId: $trackingEntryId, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('sourceType: $sourceType, ')
          ..write('seenWhere: $seenWhere, ')
          ..write('watchedAt: $watchedAt, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      itemId,
      targetRefJson,
      trackingEntryId,
      seasonNumber,
      episodeNumber,
      sourceType,
      seenWhere,
      watchedAt,
      rating,
      notes,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchSessionsCacheData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.targetRefJson == this.targetRefJson &&
          other.trackingEntryId == this.trackingEntryId &&
          other.seasonNumber == this.seasonNumber &&
          other.episodeNumber == this.episodeNumber &&
          other.sourceType == this.sourceType &&
          other.seenWhere == this.seenWhere &&
          other.watchedAt == this.watchedAt &&
          other.rating == this.rating &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class WatchSessionsCacheCompanion
    extends UpdateCompanion<WatchSessionsCacheData> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> targetRefJson;
  final Value<String?> trackingEntryId;
  final Value<int?> seasonNumber;
  final Value<int?> episodeNumber;
  final Value<String?> sourceType;
  final Value<String?> seenWhere;
  final Value<DateTime> watchedAt;
  final Value<int?> rating;
  final Value<String?> notes;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const WatchSessionsCacheCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.targetRefJson = const Value.absent(),
    this.trackingEntryId = const Value.absent(),
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.seenWhere = const Value.absent(),
    this.watchedAt = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchSessionsCacheCompanion.insert({
    required String id,
    required String itemId,
    this.targetRefJson = const Value.absent(),
    this.trackingEntryId = const Value.absent(),
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.seenWhere = const Value.absent(),
    required DateTime watchedAt,
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        watchedAt = Value(watchedAt),
        updatedAt = Value(updatedAt);
  static Insertable<WatchSessionsCacheData> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? targetRefJson,
    Expression<String>? trackingEntryId,
    Expression<int>? seasonNumber,
    Expression<int>? episodeNumber,
    Expression<String>? sourceType,
    Expression<String>? seenWhere,
    Expression<DateTime>? watchedAt,
    Expression<int>? rating,
    Expression<String>? notes,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (targetRefJson != null) 'target_ref_json': targetRefJson,
      if (trackingEntryId != null) 'tracking_entry_id': trackingEntryId,
      if (seasonNumber != null) 'season_number': seasonNumber,
      if (episodeNumber != null) 'episode_number': episodeNumber,
      if (sourceType != null) 'source_type': sourceType,
      if (seenWhere != null) 'seen_where': seenWhere,
      if (watchedAt != null) 'watched_at': watchedAt,
      if (rating != null) 'rating': rating,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchSessionsCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String?>? targetRefJson,
      Value<String?>? trackingEntryId,
      Value<int?>? seasonNumber,
      Value<int?>? episodeNumber,
      Value<String?>? sourceType,
      Value<String?>? seenWhere,
      Value<DateTime>? watchedAt,
      Value<int?>? rating,
      Value<String?>? notes,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return WatchSessionsCacheCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      targetRefJson: targetRefJson ?? this.targetRefJson,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      sourceType: sourceType ?? this.sourceType,
      seenWhere: seenWhere ?? this.seenWhere,
      watchedAt: watchedAt ?? this.watchedAt,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (targetRefJson.present) {
      map['target_ref_json'] = Variable<String>(targetRefJson.value);
    }
    if (trackingEntryId.present) {
      map['tracking_entry_id'] = Variable<String>(trackingEntryId.value);
    }
    if (seasonNumber.present) {
      map['season_number'] = Variable<int>(seasonNumber.value);
    }
    if (episodeNumber.present) {
      map['episode_number'] = Variable<int>(episodeNumber.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (seenWhere.present) {
      map['seen_where'] = Variable<String>(seenWhere.value);
    }
    if (watchedAt.present) {
      map['watched_at'] = Variable<DateTime>(watchedAt.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchSessionsCacheCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('targetRefJson: $targetRefJson, ')
          ..write('trackingEntryId: $trackingEntryId, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('sourceType: $sourceType, ')
          ..write('seenWhere: $seenWhere, ')
          ..write('watchedAt: $watchedAt, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientChangedAtMeta =
      const VerificationMeta('clientChangedAt');
  @override
  late final GeneratedColumn<DateTime> clientChangedAt =
      GeneratedColumn<DateTime>('client_changed_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, entityType, entityId, action, payloadJson, clientChangedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('client_changed_at')) {
      context.handle(
          _clientChangedAtMeta,
          clientChangedAt.isAcceptableOrUnknown(
              data['client_changed_at']!, _clientChangedAtMeta));
    } else if (isInserting) {
      context.missing(_clientChangedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType, entityId};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      clientChangedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}client_changed_at'])!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final String id;
  final String entityType;
  final String entityId;
  final String action;
  final String payloadJson;
  final DateTime clientChangedAt;
  const SyncQueueData(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.action,
      required this.payloadJson,
      required this.clientChangedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    map['payload_json'] = Variable<String>(payloadJson);
    map['client_changed_at'] = Variable<DateTime>(clientChangedAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      payloadJson: Value(payloadJson),
      clientChangedAt: Value(clientChangedAt),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      clientChangedAt: serializer.fromJson<DateTime>(json['clientChangedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'clientChangedAt': serializer.toJson<DateTime>(clientChangedAt),
    };
  }

  SyncQueueData copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          String? action,
          String? payloadJson,
          DateTime? clientChangedAt}) =>
      SyncQueueData(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        action: action ?? this.action,
        payloadJson: payloadJson ?? this.payloadJson,
        clientChangedAt: clientChangedAt ?? this.clientChangedAt,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      clientChangedAt: data.clientChangedAt.present
          ? data.clientChangedAt.value
          : this.clientChangedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('clientChangedAt: $clientChangedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entityType, entityId, action, payloadJson, clientChangedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.payloadJson == this.payloadJson &&
          other.clientChangedAt == this.clientChangedAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String> payloadJson;
  final Value<DateTime> clientChangedAt;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.clientChangedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String action,
    required String payloadJson,
    required DateTime clientChangedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        action = Value(action),
        payloadJson = Value(payloadJson),
        clientChangedAt = Value(clientChangedAt);
  static Insertable<SyncQueueData> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? payloadJson,
    Expression<DateTime>? clientChangedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (clientChangedAt != null) 'client_changed_at': clientChangedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? action,
      Value<String>? payloadJson,
      Value<DateTime>? clientChangedAt,
      Value<int>? rowid}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      payloadJson: payloadJson ?? this.payloadJson,
      clientChangedAt: clientChangedAt ?? this.clientChangedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (clientChangedAt.present) {
      map['client_changed_at'] = Variable<DateTime>(clientChangedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('clientChangedAt: $clientChangedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserMetadataOverridesCacheTable extends UserMetadataOverridesCache
    with
        TableInfo<$UserMetadataOverridesCacheTable,
            UserMetadataOverridesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserMetadataOverridesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _editionIdMeta =
      const VerificationMeta('editionId');
  @override
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
      'edition_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fieldPathMeta =
      const VerificationMeta('fieldPath');
  @override
  late final GeneratedColumn<String> fieldPath = GeneratedColumn<String>(
      'field_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originalValueMeta =
      const VerificationMeta('originalValue');
  @override
  late final GeneratedColumn<String> originalValue = GeneratedColumn<String>(
      'original_value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _overrideValueMeta =
      const VerificationMeta('overrideValue');
  @override
  late final GeneratedColumn<String> overrideValue = GeneratedColumn<String>(
      'override_value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemId,
        editionId,
        variantId,
        fieldPath,
        originalValue,
        overrideValue,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_metadata_overrides_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<UserMetadataOverridesCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('edition_id')) {
      context.handle(_editionIdMeta,
          editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta));
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    }
    if (data.containsKey('field_path')) {
      context.handle(_fieldPathMeta,
          fieldPath.isAcceptableOrUnknown(data['field_path']!, _fieldPathMeta));
    } else if (isInserting) {
      context.missing(_fieldPathMeta);
    }
    if (data.containsKey('original_value')) {
      context.handle(
          _originalValueMeta,
          originalValue.isAcceptableOrUnknown(
              data['original_value']!, _originalValueMeta));
    }
    if (data.containsKey('override_value')) {
      context.handle(
          _overrideValueMeta,
          overrideValue.isAcceptableOrUnknown(
              data['override_value']!, _overrideValueMeta));
    } else if (isInserting) {
      context.missing(_overrideValueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserMetadataOverridesCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserMetadataOverridesCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      editionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edition_id']),
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
      fieldPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field_path'])!,
      originalValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_value']),
      overrideValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}override_value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $UserMetadataOverridesCacheTable createAlias(String alias) {
    return $UserMetadataOverridesCacheTable(attachedDatabase, alias);
  }
}

class UserMetadataOverridesCacheData extends DataClass
    implements Insertable<UserMetadataOverridesCacheData> {
  final String id;
  final String itemId;
  final String? editionId;
  final String? variantId;
  final String fieldPath;
  final String? originalValue;
  final String overrideValue;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const UserMetadataOverridesCacheData(
      {required this.id,
      required this.itemId,
      this.editionId,
      this.variantId,
      required this.fieldPath,
      this.originalValue,
      required this.overrideValue,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || editionId != null) {
      map['edition_id'] = Variable<String>(editionId);
    }
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    map['field_path'] = Variable<String>(fieldPath);
    if (!nullToAbsent || originalValue != null) {
      map['original_value'] = Variable<String>(originalValue);
    }
    map['override_value'] = Variable<String>(overrideValue);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  UserMetadataOverridesCacheCompanion toCompanion(bool nullToAbsent) {
    return UserMetadataOverridesCacheCompanion(
      id: Value(id),
      itemId: Value(itemId),
      editionId: editionId == null && nullToAbsent
          ? const Value.absent()
          : Value(editionId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      fieldPath: Value(fieldPath),
      originalValue: originalValue == null && nullToAbsent
          ? const Value.absent()
          : Value(originalValue),
      overrideValue: Value(overrideValue),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory UserMetadataOverridesCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserMetadataOverridesCacheData(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      editionId: serializer.fromJson<String?>(json['editionId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      fieldPath: serializer.fromJson<String>(json['fieldPath']),
      originalValue: serializer.fromJson<String?>(json['originalValue']),
      overrideValue: serializer.fromJson<String>(json['overrideValue']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'editionId': serializer.toJson<String?>(editionId),
      'variantId': serializer.toJson<String?>(variantId),
      'fieldPath': serializer.toJson<String>(fieldPath),
      'originalValue': serializer.toJson<String?>(originalValue),
      'overrideValue': serializer.toJson<String>(overrideValue),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  UserMetadataOverridesCacheData copyWith(
          {String? id,
          String? itemId,
          Value<String?> editionId = const Value.absent(),
          Value<String?> variantId = const Value.absent(),
          String? fieldPath,
          Value<String?> originalValue = const Value.absent(),
          String? overrideValue,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      UserMetadataOverridesCacheData(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        editionId: editionId.present ? editionId.value : this.editionId,
        variantId: variantId.present ? variantId.value : this.variantId,
        fieldPath: fieldPath ?? this.fieldPath,
        originalValue:
            originalValue.present ? originalValue.value : this.originalValue,
        overrideValue: overrideValue ?? this.overrideValue,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  UserMetadataOverridesCacheData copyWithCompanion(
      UserMetadataOverridesCacheCompanion data) {
    return UserMetadataOverridesCacheData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      fieldPath: data.fieldPath.present ? data.fieldPath.value : this.fieldPath,
      originalValue: data.originalValue.present
          ? data.originalValue.value
          : this.originalValue,
      overrideValue: data.overrideValue.present
          ? data.overrideValue.value
          : this.overrideValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserMetadataOverridesCacheData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('fieldPath: $fieldPath, ')
          ..write('originalValue: $originalValue, ')
          ..write('overrideValue: $overrideValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, itemId, editionId, variantId, fieldPath,
      originalValue, overrideValue, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserMetadataOverridesCacheData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.editionId == this.editionId &&
          other.variantId == this.variantId &&
          other.fieldPath == this.fieldPath &&
          other.originalValue == this.originalValue &&
          other.overrideValue == this.overrideValue &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class UserMetadataOverridesCacheCompanion
    extends UpdateCompanion<UserMetadataOverridesCacheData> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> editionId;
  final Value<String?> variantId;
  final Value<String> fieldPath;
  final Value<String?> originalValue;
  final Value<String> overrideValue;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const UserMetadataOverridesCacheCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.fieldPath = const Value.absent(),
    this.originalValue = const Value.absent(),
    this.overrideValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserMetadataOverridesCacheCompanion.insert({
    required String id,
    required String itemId,
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    required String fieldPath,
    this.originalValue = const Value.absent(),
    required String overrideValue,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        fieldPath = Value(fieldPath),
        overrideValue = Value(overrideValue),
        updatedAt = Value(updatedAt);
  static Insertable<UserMetadataOverridesCacheData> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? editionId,
    Expression<String>? variantId,
    Expression<String>? fieldPath,
    Expression<String>? originalValue,
    Expression<String>? overrideValue,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (editionId != null) 'edition_id': editionId,
      if (variantId != null) 'variant_id': variantId,
      if (fieldPath != null) 'field_path': fieldPath,
      if (originalValue != null) 'original_value': originalValue,
      if (overrideValue != null) 'override_value': overrideValue,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserMetadataOverridesCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String?>? editionId,
      Value<String?>? variantId,
      Value<String>? fieldPath,
      Value<String?>? originalValue,
      Value<String>? overrideValue,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return UserMetadataOverridesCacheCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      fieldPath: fieldPath ?? this.fieldPath,
      originalValue: originalValue ?? this.originalValue,
      overrideValue: overrideValue ?? this.overrideValue,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (fieldPath.present) {
      map['field_path'] = Variable<String>(fieldPath.value);
    }
    if (originalValue.present) {
      map['original_value'] = Variable<String>(originalValue.value);
    }
    if (overrideValue.present) {
      map['override_value'] = Variable<String>(overrideValue.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserMetadataOverridesCacheCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('fieldPath: $fieldPath, ')
          ..write('originalValue: $originalValue, ')
          ..write('overrideValue: $overrideValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomEpisodesCacheTable extends CustomEpisodesCache
    with TableInfo<$CustomEpisodesCacheTable, CustomEpisodesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomEpisodesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _seasonNumberMeta =
      const VerificationMeta('seasonNumber');
  @override
  late final GeneratedColumn<int> seasonNumber = GeneratedColumn<int>(
      'season_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _episodeNumberMeta =
      const VerificationMeta('episodeNumber');
  @override
  late final GeneratedColumn<int> episodeNumber = GeneratedColumn<int>(
      'episode_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _overviewMeta =
      const VerificationMeta('overview');
  @override
  late final GeneratedColumn<String> overview = GeneratedColumn<String>(
      'overview', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _airDateMeta =
      const VerificationMeta('airDate');
  @override
  late final GeneratedColumn<String> airDate = GeneratedColumn<String>(
      'air_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _runtimeMinutesMeta =
      const VerificationMeta('runtimeMinutes');
  @override
  late final GeneratedColumn<int> runtimeMinutes = GeneratedColumn<int>(
      'runtime_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _stillImageUrlMeta =
      const VerificationMeta('stillImageUrl');
  @override
  late final GeneratedColumn<String> stillImageUrl = GeneratedColumn<String>(
      'still_image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localImagePathMeta =
      const VerificationMeta('localImagePath');
  @override
  late final GeneratedColumn<String> localImagePath = GeneratedColumn<String>(
      'local_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailImageUrlMeta =
      const VerificationMeta('thumbnailImageUrl');
  @override
  late final GeneratedColumn<String> thumbnailImageUrl =
      GeneratedColumn<String>('thumbnail_image_url', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemId,
        seasonNumber,
        episodeNumber,
        title,
        overview,
        airDate,
        runtimeMinutes,
        stillImageUrl,
        localImagePath,
        thumbnailImageUrl,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_episodes_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<CustomEpisodesCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('season_number')) {
      context.handle(
          _seasonNumberMeta,
          seasonNumber.isAcceptableOrUnknown(
              data['season_number']!, _seasonNumberMeta));
    } else if (isInserting) {
      context.missing(_seasonNumberMeta);
    }
    if (data.containsKey('episode_number')) {
      context.handle(
          _episodeNumberMeta,
          episodeNumber.isAcceptableOrUnknown(
              data['episode_number']!, _episodeNumberMeta));
    } else if (isInserting) {
      context.missing(_episodeNumberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('overview')) {
      context.handle(_overviewMeta,
          overview.isAcceptableOrUnknown(data['overview']!, _overviewMeta));
    }
    if (data.containsKey('air_date')) {
      context.handle(_airDateMeta,
          airDate.isAcceptableOrUnknown(data['air_date']!, _airDateMeta));
    }
    if (data.containsKey('runtime_minutes')) {
      context.handle(
          _runtimeMinutesMeta,
          runtimeMinutes.isAcceptableOrUnknown(
              data['runtime_minutes']!, _runtimeMinutesMeta));
    }
    if (data.containsKey('still_image_url')) {
      context.handle(
          _stillImageUrlMeta,
          stillImageUrl.isAcceptableOrUnknown(
              data['still_image_url']!, _stillImageUrlMeta));
    }
    if (data.containsKey('local_image_path')) {
      context.handle(
          _localImagePathMeta,
          localImagePath.isAcceptableOrUnknown(
              data['local_image_path']!, _localImagePathMeta));
    }
    if (data.containsKey('thumbnail_image_url')) {
      context.handle(
          _thumbnailImageUrlMeta,
          thumbnailImageUrl.isAcceptableOrUnknown(
              data['thumbnail_image_url']!, _thumbnailImageUrlMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomEpisodesCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomEpisodesCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      seasonNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}season_number'])!,
      episodeNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}episode_number'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      overview: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}overview']),
      airDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}air_date']),
      runtimeMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}runtime_minutes']),
      stillImageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}still_image_url']),
      localImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_image_path']),
      thumbnailImageUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}thumbnail_image_url']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $CustomEpisodesCacheTable createAlias(String alias) {
    return $CustomEpisodesCacheTable(attachedDatabase, alias);
  }
}

class CustomEpisodesCacheData extends DataClass
    implements Insertable<CustomEpisodesCacheData> {
  final String id;
  final String itemId;
  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final String? overview;
  final String? airDate;
  final int? runtimeMinutes;
  final String? stillImageUrl;
  final String? localImagePath;
  final String? thumbnailImageUrl;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const CustomEpisodesCacheData(
      {required this.id,
      required this.itemId,
      required this.seasonNumber,
      required this.episodeNumber,
      required this.title,
      this.overview,
      this.airDate,
      this.runtimeMinutes,
      this.stillImageUrl,
      this.localImagePath,
      this.thumbnailImageUrl,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['season_number'] = Variable<int>(seasonNumber);
    map['episode_number'] = Variable<int>(episodeNumber);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || overview != null) {
      map['overview'] = Variable<String>(overview);
    }
    if (!nullToAbsent || airDate != null) {
      map['air_date'] = Variable<String>(airDate);
    }
    if (!nullToAbsent || runtimeMinutes != null) {
      map['runtime_minutes'] = Variable<int>(runtimeMinutes);
    }
    if (!nullToAbsent || stillImageUrl != null) {
      map['still_image_url'] = Variable<String>(stillImageUrl);
    }
    if (!nullToAbsent || localImagePath != null) {
      map['local_image_path'] = Variable<String>(localImagePath);
    }
    if (!nullToAbsent || thumbnailImageUrl != null) {
      map['thumbnail_image_url'] = Variable<String>(thumbnailImageUrl);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CustomEpisodesCacheCompanion toCompanion(bool nullToAbsent) {
    return CustomEpisodesCacheCompanion(
      id: Value(id),
      itemId: Value(itemId),
      seasonNumber: Value(seasonNumber),
      episodeNumber: Value(episodeNumber),
      title: Value(title),
      overview: overview == null && nullToAbsent
          ? const Value.absent()
          : Value(overview),
      airDate: airDate == null && nullToAbsent
          ? const Value.absent()
          : Value(airDate),
      runtimeMinutes: runtimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(runtimeMinutes),
      stillImageUrl: stillImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(stillImageUrl),
      localImagePath: localImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localImagePath),
      thumbnailImageUrl: thumbnailImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailImageUrl),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CustomEpisodesCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomEpisodesCacheData(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      seasonNumber: serializer.fromJson<int>(json['seasonNumber']),
      episodeNumber: serializer.fromJson<int>(json['episodeNumber']),
      title: serializer.fromJson<String>(json['title']),
      overview: serializer.fromJson<String?>(json['overview']),
      airDate: serializer.fromJson<String?>(json['airDate']),
      runtimeMinutes: serializer.fromJson<int?>(json['runtimeMinutes']),
      stillImageUrl: serializer.fromJson<String?>(json['stillImageUrl']),
      localImagePath: serializer.fromJson<String?>(json['localImagePath']),
      thumbnailImageUrl:
          serializer.fromJson<String?>(json['thumbnailImageUrl']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'seasonNumber': serializer.toJson<int>(seasonNumber),
      'episodeNumber': serializer.toJson<int>(episodeNumber),
      'title': serializer.toJson<String>(title),
      'overview': serializer.toJson<String?>(overview),
      'airDate': serializer.toJson<String?>(airDate),
      'runtimeMinutes': serializer.toJson<int?>(runtimeMinutes),
      'stillImageUrl': serializer.toJson<String?>(stillImageUrl),
      'localImagePath': serializer.toJson<String?>(localImagePath),
      'thumbnailImageUrl': serializer.toJson<String?>(thumbnailImageUrl),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CustomEpisodesCacheData copyWith(
          {String? id,
          String? itemId,
          int? seasonNumber,
          int? episodeNumber,
          String? title,
          Value<String?> overview = const Value.absent(),
          Value<String?> airDate = const Value.absent(),
          Value<int?> runtimeMinutes = const Value.absent(),
          Value<String?> stillImageUrl = const Value.absent(),
          Value<String?> localImagePath = const Value.absent(),
          Value<String?> thumbnailImageUrl = const Value.absent(),
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      CustomEpisodesCacheData(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        seasonNumber: seasonNumber ?? this.seasonNumber,
        episodeNumber: episodeNumber ?? this.episodeNumber,
        title: title ?? this.title,
        overview: overview.present ? overview.value : this.overview,
        airDate: airDate.present ? airDate.value : this.airDate,
        runtimeMinutes:
            runtimeMinutes.present ? runtimeMinutes.value : this.runtimeMinutes,
        stillImageUrl:
            stillImageUrl.present ? stillImageUrl.value : this.stillImageUrl,
        localImagePath:
            localImagePath.present ? localImagePath.value : this.localImagePath,
        thumbnailImageUrl: thumbnailImageUrl.present
            ? thumbnailImageUrl.value
            : this.thumbnailImageUrl,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  CustomEpisodesCacheData copyWithCompanion(CustomEpisodesCacheCompanion data) {
    return CustomEpisodesCacheData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      seasonNumber: data.seasonNumber.present
          ? data.seasonNumber.value
          : this.seasonNumber,
      episodeNumber: data.episodeNumber.present
          ? data.episodeNumber.value
          : this.episodeNumber,
      title: data.title.present ? data.title.value : this.title,
      overview: data.overview.present ? data.overview.value : this.overview,
      airDate: data.airDate.present ? data.airDate.value : this.airDate,
      runtimeMinutes: data.runtimeMinutes.present
          ? data.runtimeMinutes.value
          : this.runtimeMinutes,
      stillImageUrl: data.stillImageUrl.present
          ? data.stillImageUrl.value
          : this.stillImageUrl,
      localImagePath: data.localImagePath.present
          ? data.localImagePath.value
          : this.localImagePath,
      thumbnailImageUrl: data.thumbnailImageUrl.present
          ? data.thumbnailImageUrl.value
          : this.thumbnailImageUrl,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomEpisodesCacheData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('title: $title, ')
          ..write('overview: $overview, ')
          ..write('airDate: $airDate, ')
          ..write('runtimeMinutes: $runtimeMinutes, ')
          ..write('stillImageUrl: $stillImageUrl, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('thumbnailImageUrl: $thumbnailImageUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      itemId,
      seasonNumber,
      episodeNumber,
      title,
      overview,
      airDate,
      runtimeMinutes,
      stillImageUrl,
      localImagePath,
      thumbnailImageUrl,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomEpisodesCacheData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.seasonNumber == this.seasonNumber &&
          other.episodeNumber == this.episodeNumber &&
          other.title == this.title &&
          other.overview == this.overview &&
          other.airDate == this.airDate &&
          other.runtimeMinutes == this.runtimeMinutes &&
          other.stillImageUrl == this.stillImageUrl &&
          other.localImagePath == this.localImagePath &&
          other.thumbnailImageUrl == this.thumbnailImageUrl &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CustomEpisodesCacheCompanion
    extends UpdateCompanion<CustomEpisodesCacheData> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<int> seasonNumber;
  final Value<int> episodeNumber;
  final Value<String> title;
  final Value<String?> overview;
  final Value<String?> airDate;
  final Value<int?> runtimeMinutes;
  final Value<String?> stillImageUrl;
  final Value<String?> localImagePath;
  final Value<String?> thumbnailImageUrl;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CustomEpisodesCacheCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.overview = const Value.absent(),
    this.airDate = const Value.absent(),
    this.runtimeMinutes = const Value.absent(),
    this.stillImageUrl = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.thumbnailImageUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomEpisodesCacheCompanion.insert({
    required String id,
    required String itemId,
    required int seasonNumber,
    required int episodeNumber,
    required String title,
    this.overview = const Value.absent(),
    this.airDate = const Value.absent(),
    this.runtimeMinutes = const Value.absent(),
    this.stillImageUrl = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.thumbnailImageUrl = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        seasonNumber = Value(seasonNumber),
        episodeNumber = Value(episodeNumber),
        title = Value(title),
        updatedAt = Value(updatedAt);
  static Insertable<CustomEpisodesCacheData> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<int>? seasonNumber,
    Expression<int>? episodeNumber,
    Expression<String>? title,
    Expression<String>? overview,
    Expression<String>? airDate,
    Expression<int>? runtimeMinutes,
    Expression<String>? stillImageUrl,
    Expression<String>? localImagePath,
    Expression<String>? thumbnailImageUrl,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (seasonNumber != null) 'season_number': seasonNumber,
      if (episodeNumber != null) 'episode_number': episodeNumber,
      if (title != null) 'title': title,
      if (overview != null) 'overview': overview,
      if (airDate != null) 'air_date': airDate,
      if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
      if (stillImageUrl != null) 'still_image_url': stillImageUrl,
      if (localImagePath != null) 'local_image_path': localImagePath,
      if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomEpisodesCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<int>? seasonNumber,
      Value<int>? episodeNumber,
      Value<String>? title,
      Value<String?>? overview,
      Value<String?>? airDate,
      Value<int?>? runtimeMinutes,
      Value<String?>? stillImageUrl,
      Value<String?>? localImagePath,
      Value<String?>? thumbnailImageUrl,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return CustomEpisodesCacheCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      airDate: airDate ?? this.airDate,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      stillImageUrl: stillImageUrl ?? this.stillImageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (seasonNumber.present) {
      map['season_number'] = Variable<int>(seasonNumber.value);
    }
    if (episodeNumber.present) {
      map['episode_number'] = Variable<int>(episodeNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (overview.present) {
      map['overview'] = Variable<String>(overview.value);
    }
    if (airDate.present) {
      map['air_date'] = Variable<String>(airDate.value);
    }
    if (runtimeMinutes.present) {
      map['runtime_minutes'] = Variable<int>(runtimeMinutes.value);
    }
    if (stillImageUrl.present) {
      map['still_image_url'] = Variable<String>(stillImageUrl.value);
    }
    if (localImagePath.present) {
      map['local_image_path'] = Variable<String>(localImagePath.value);
    }
    if (thumbnailImageUrl.present) {
      map['thumbnail_image_url'] = Variable<String>(thumbnailImageUrl.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomEpisodesCacheCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('title: $title, ')
          ..write('overview: $overview, ')
          ..write('airDate: $airDate, ')
          ..write('runtimeMinutes: $runtimeMinutes, ')
          ..write('stillImageUrl: $stillImageUrl, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('thumbnailImageUrl: $thumbnailImageUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserExternalLinksCacheTable extends UserExternalLinksCache
    with TableInfo<$UserExternalLinksCacheTable, UserExternalLinksCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserExternalLinksCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _editionIdMeta =
      const VerificationMeta('editionId');
  @override
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
      'edition_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemId,
        editionId,
        variantId,
        label,
        url,
        kind,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_external_links_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<UserExternalLinksCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('edition_id')) {
      context.handle(_editionIdMeta,
          editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta));
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserExternalLinksCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserExternalLinksCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      editionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edition_id']),
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserExternalLinksCacheTable createAlias(String alias) {
    return $UserExternalLinksCacheTable(attachedDatabase, alias);
  }
}

class UserExternalLinksCacheData extends DataClass
    implements Insertable<UserExternalLinksCacheData> {
  final String id;
  final String itemId;
  final String? editionId;
  final String? variantId;
  final String label;
  final String url;
  final String kind;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserExternalLinksCacheData(
      {required this.id,
      required this.itemId,
      this.editionId,
      this.variantId,
      required this.label,
      required this.url,
      required this.kind,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || editionId != null) {
      map['edition_id'] = Variable<String>(editionId);
    }
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    map['label'] = Variable<String>(label);
    map['url'] = Variable<String>(url);
    map['kind'] = Variable<String>(kind);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserExternalLinksCacheCompanion toCompanion(bool nullToAbsent) {
    return UserExternalLinksCacheCompanion(
      id: Value(id),
      itemId: Value(itemId),
      editionId: editionId == null && nullToAbsent
          ? const Value.absent()
          : Value(editionId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      label: Value(label),
      url: Value(url),
      kind: Value(kind),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserExternalLinksCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserExternalLinksCacheData(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      editionId: serializer.fromJson<String?>(json['editionId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      label: serializer.fromJson<String>(json['label']),
      url: serializer.fromJson<String>(json['url']),
      kind: serializer.fromJson<String>(json['kind']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'editionId': serializer.toJson<String?>(editionId),
      'variantId': serializer.toJson<String?>(variantId),
      'label': serializer.toJson<String>(label),
      'url': serializer.toJson<String>(url),
      'kind': serializer.toJson<String>(kind),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserExternalLinksCacheData copyWith(
          {String? id,
          String? itemId,
          Value<String?> editionId = const Value.absent(),
          Value<String?> variantId = const Value.absent(),
          String? label,
          String? url,
          String? kind,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      UserExternalLinksCacheData(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        editionId: editionId.present ? editionId.value : this.editionId,
        variantId: variantId.present ? variantId.value : this.variantId,
        label: label ?? this.label,
        url: url ?? this.url,
        kind: kind ?? this.kind,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserExternalLinksCacheData copyWithCompanion(
      UserExternalLinksCacheCompanion data) {
    return UserExternalLinksCacheData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      label: data.label.present ? data.label.value : this.label,
      url: data.url.present ? data.url.value : this.url,
      kind: data.kind.present ? data.kind.value : this.kind,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserExternalLinksCacheData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('label: $label, ')
          ..write('url: $url, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, itemId, editionId, variantId, label, url, kind, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserExternalLinksCacheData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.editionId == this.editionId &&
          other.variantId == this.variantId &&
          other.label == this.label &&
          other.url == this.url &&
          other.kind == this.kind &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserExternalLinksCacheCompanion
    extends UpdateCompanion<UserExternalLinksCacheData> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> editionId;
  final Value<String?> variantId;
  final Value<String> label;
  final Value<String> url;
  final Value<String> kind;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserExternalLinksCacheCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.label = const Value.absent(),
    this.url = const Value.absent(),
    this.kind = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserExternalLinksCacheCompanion.insert({
    required String id,
    required String itemId,
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    required String label,
    required String url,
    required String kind,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        label = Value(label),
        url = Value(url),
        kind = Value(kind),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<UserExternalLinksCacheData> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? editionId,
    Expression<String>? variantId,
    Expression<String>? label,
    Expression<String>? url,
    Expression<String>? kind,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (editionId != null) 'edition_id': editionId,
      if (variantId != null) 'variant_id': variantId,
      if (label != null) 'label': label,
      if (url != null) 'url': url,
      if (kind != null) 'kind': kind,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserExternalLinksCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String?>? editionId,
      Value<String?>? variantId,
      Value<String>? label,
      Value<String>? url,
      Value<String>? kind,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return UserExternalLinksCacheCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      label: label ?? this.label,
      url: url ?? this.url,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserExternalLinksCacheCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('label: $label, ')
          ..write('url: $url, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomFieldDefinitionsCacheTable extends CustomFieldDefinitionsCache
    with
        TableInfo<$CustomFieldDefinitionsCacheTable,
            CustomFieldDefinitionsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomFieldDefinitionsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fieldTypeMeta =
      const VerificationMeta('fieldType');
  @override
  late final GeneratedColumn<String> fieldType = GeneratedColumn<String>(
      'field_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mediaKindMeta =
      const VerificationMeta('mediaKind');
  @override
  late final GeneratedColumn<String> mediaKind = GeneratedColumn<String>(
      'media_kind', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editScopeMeta =
      const VerificationMeta('editScope');
  @override
  late final GeneratedColumn<String> editScope = GeneratedColumn<String>(
      'edit_scope', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _optionsMeta =
      const VerificationMeta('options');
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
      'options', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        fieldType,
        mediaKind,
        editScope,
        sortOrder,
        options,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_field_definitions_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<CustomFieldDefinitionsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('field_type')) {
      context.handle(_fieldTypeMeta,
          fieldType.isAcceptableOrUnknown(data['field_type']!, _fieldTypeMeta));
    } else if (isInserting) {
      context.missing(_fieldTypeMeta);
    }
    if (data.containsKey('media_kind')) {
      context.handle(_mediaKindMeta,
          mediaKind.isAcceptableOrUnknown(data['media_kind']!, _mediaKindMeta));
    }
    if (data.containsKey('edit_scope')) {
      context.handle(_editScopeMeta,
          editScope.isAcceptableOrUnknown(data['edit_scope']!, _editScopeMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('options')) {
      context.handle(_optionsMeta,
          options.isAcceptableOrUnknown(data['options']!, _optionsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomFieldDefinitionsCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomFieldDefinitionsCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      fieldType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field_type'])!,
      mediaKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_kind']),
      editScope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edit_scope']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      options: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}options']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CustomFieldDefinitionsCacheTable createAlias(String alias) {
    return $CustomFieldDefinitionsCacheTable(attachedDatabase, alias);
  }
}

class CustomFieldDefinitionsCacheData extends DataClass
    implements Insertable<CustomFieldDefinitionsCacheData> {
  final String id;
  final String name;
  final String fieldType;
  final String? mediaKind;
  final String? editScope;
  final int sortOrder;
  final String? options;
  final DateTime createdAt;
  const CustomFieldDefinitionsCacheData(
      {required this.id,
      required this.name,
      required this.fieldType,
      this.mediaKind,
      this.editScope,
      required this.sortOrder,
      this.options,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['field_type'] = Variable<String>(fieldType);
    if (!nullToAbsent || mediaKind != null) {
      map['media_kind'] = Variable<String>(mediaKind);
    }
    if (!nullToAbsent || editScope != null) {
      map['edit_scope'] = Variable<String>(editScope);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || options != null) {
      map['options'] = Variable<String>(options);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomFieldDefinitionsCacheCompanion toCompanion(bool nullToAbsent) {
    return CustomFieldDefinitionsCacheCompanion(
      id: Value(id),
      name: Value(name),
      fieldType: Value(fieldType),
      mediaKind: mediaKind == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaKind),
      editScope: editScope == null && nullToAbsent
          ? const Value.absent()
          : Value(editScope),
      sortOrder: Value(sortOrder),
      options: options == null && nullToAbsent
          ? const Value.absent()
          : Value(options),
      createdAt: Value(createdAt),
    );
  }

  factory CustomFieldDefinitionsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomFieldDefinitionsCacheData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fieldType: serializer.fromJson<String>(json['fieldType']),
      mediaKind: serializer.fromJson<String?>(json['mediaKind']),
      editScope: serializer.fromJson<String?>(json['editScope']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      options: serializer.fromJson<String?>(json['options']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'fieldType': serializer.toJson<String>(fieldType),
      'mediaKind': serializer.toJson<String?>(mediaKind),
      'editScope': serializer.toJson<String?>(editScope),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'options': serializer.toJson<String?>(options),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomFieldDefinitionsCacheData copyWith(
          {String? id,
          String? name,
          String? fieldType,
          Value<String?> mediaKind = const Value.absent(),
          Value<String?> editScope = const Value.absent(),
          int? sortOrder,
          Value<String?> options = const Value.absent(),
          DateTime? createdAt}) =>
      CustomFieldDefinitionsCacheData(
        id: id ?? this.id,
        name: name ?? this.name,
        fieldType: fieldType ?? this.fieldType,
        mediaKind: mediaKind.present ? mediaKind.value : this.mediaKind,
        editScope: editScope.present ? editScope.value : this.editScope,
        sortOrder: sortOrder ?? this.sortOrder,
        options: options.present ? options.value : this.options,
        createdAt: createdAt ?? this.createdAt,
      );
  CustomFieldDefinitionsCacheData copyWithCompanion(
      CustomFieldDefinitionsCacheCompanion data) {
    return CustomFieldDefinitionsCacheData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fieldType: data.fieldType.present ? data.fieldType.value : this.fieldType,
      mediaKind: data.mediaKind.present ? data.mediaKind.value : this.mediaKind,
      editScope: data.editScope.present ? data.editScope.value : this.editScope,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      options: data.options.present ? data.options.value : this.options,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldDefinitionsCacheData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fieldType: $fieldType, ')
          ..write('mediaKind: $mediaKind, ')
          ..write('editScope: $editScope, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('options: $options, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, fieldType, mediaKind, editScope, sortOrder, options, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomFieldDefinitionsCacheData &&
          other.id == this.id &&
          other.name == this.name &&
          other.fieldType == this.fieldType &&
          other.mediaKind == this.mediaKind &&
          other.editScope == this.editScope &&
          other.sortOrder == this.sortOrder &&
          other.options == this.options &&
          other.createdAt == this.createdAt);
}

class CustomFieldDefinitionsCacheCompanion
    extends UpdateCompanion<CustomFieldDefinitionsCacheData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> fieldType;
  final Value<String?> mediaKind;
  final Value<String?> editScope;
  final Value<int> sortOrder;
  final Value<String?> options;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomFieldDefinitionsCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fieldType = const Value.absent(),
    this.mediaKind = const Value.absent(),
    this.editScope = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.options = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomFieldDefinitionsCacheCompanion.insert({
    required String id,
    required String name,
    required String fieldType,
    this.mediaKind = const Value.absent(),
    this.editScope = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.options = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        fieldType = Value(fieldType),
        createdAt = Value(createdAt);
  static Insertable<CustomFieldDefinitionsCacheData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? fieldType,
    Expression<String>? mediaKind,
    Expression<String>? editScope,
    Expression<int>? sortOrder,
    Expression<String>? options,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fieldType != null) 'field_type': fieldType,
      if (mediaKind != null) 'media_kind': mediaKind,
      if (editScope != null) 'edit_scope': editScope,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (options != null) 'options': options,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomFieldDefinitionsCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? fieldType,
      Value<String?>? mediaKind,
      Value<String?>? editScope,
      Value<int>? sortOrder,
      Value<String?>? options,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CustomFieldDefinitionsCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fieldType: fieldType ?? this.fieldType,
      mediaKind: mediaKind ?? this.mediaKind,
      editScope: editScope ?? this.editScope,
      sortOrder: sortOrder ?? this.sortOrder,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fieldType.present) {
      map['field_type'] = Variable<String>(fieldType.value);
    }
    if (mediaKind.present) {
      map['media_kind'] = Variable<String>(mediaKind.value);
    }
    if (editScope.present) {
      map['edit_scope'] = Variable<String>(editScope.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldDefinitionsCacheCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fieldType: $fieldType, ')
          ..write('mediaKind: $mediaKind, ')
          ..write('editScope: $editScope, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('options: $options, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomFieldValuesCacheTable extends CustomFieldValuesCache
    with TableInfo<$CustomFieldValuesCacheTable, CustomFieldValuesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomFieldValuesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetIdMeta =
      const VerificationMeta('targetId');
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
      'target_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetScopeMeta =
      const VerificationMeta('targetScope');
  @override
  late final GeneratedColumn<String> targetScope = GeneratedColumn<String>(
      'target_scope', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _catalogRefJsonMeta =
      const VerificationMeta('catalogRefJson');
  @override
  late final GeneratedColumn<String> catalogRefJson = GeneratedColumn<String>(
      'catalog_ref_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fieldDefinitionIdMeta =
      const VerificationMeta('fieldDefinitionId');
  @override
  late final GeneratedColumn<String> fieldDefinitionId =
      GeneratedColumn<String>('field_definition_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        targetId,
        targetScope,
        catalogRefJson,
        fieldDefinitionId,
        value,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_field_values_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<CustomFieldValuesCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(_targetIdMeta,
          targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta));
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('target_scope')) {
      context.handle(
          _targetScopeMeta,
          targetScope.isAcceptableOrUnknown(
              data['target_scope']!, _targetScopeMeta));
    } else if (isInserting) {
      context.missing(_targetScopeMeta);
    }
    if (data.containsKey('catalog_ref_json')) {
      context.handle(
          _catalogRefJsonMeta,
          catalogRefJson.isAcceptableOrUnknown(
              data['catalog_ref_json']!, _catalogRefJsonMeta));
    }
    if (data.containsKey('field_definition_id')) {
      context.handle(
          _fieldDefinitionIdMeta,
          fieldDefinitionId.isAcceptableOrUnknown(
              data['field_definition_id']!, _fieldDefinitionIdMeta));
    } else if (isInserting) {
      context.missing(_fieldDefinitionIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomFieldValuesCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomFieldValuesCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      targetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_id'])!,
      targetScope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_scope'])!,
      catalogRefJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}catalog_ref_json']),
      fieldDefinitionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}field_definition_id'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CustomFieldValuesCacheTable createAlias(String alias) {
    return $CustomFieldValuesCacheTable(attachedDatabase, alias);
  }
}

class CustomFieldValuesCacheData extends DataClass
    implements Insertable<CustomFieldValuesCacheData> {
  final String id;
  final String targetId;
  final String targetScope;
  final String? catalogRefJson;
  final String fieldDefinitionId;
  final String? value;
  final DateTime updatedAt;
  const CustomFieldValuesCacheData(
      {required this.id,
      required this.targetId,
      required this.targetScope,
      this.catalogRefJson,
      required this.fieldDefinitionId,
      this.value,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['target_id'] = Variable<String>(targetId);
    map['target_scope'] = Variable<String>(targetScope);
    if (!nullToAbsent || catalogRefJson != null) {
      map['catalog_ref_json'] = Variable<String>(catalogRefJson);
    }
    map['field_definition_id'] = Variable<String>(fieldDefinitionId);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomFieldValuesCacheCompanion toCompanion(bool nullToAbsent) {
    return CustomFieldValuesCacheCompanion(
      id: Value(id),
      targetId: Value(targetId),
      targetScope: Value(targetScope),
      catalogRefJson: catalogRefJson == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogRefJson),
      fieldDefinitionId: Value(fieldDefinitionId),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomFieldValuesCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomFieldValuesCacheData(
      id: serializer.fromJson<String>(json['id']),
      targetId: serializer.fromJson<String>(json['targetId']),
      targetScope: serializer.fromJson<String>(json['targetScope']),
      catalogRefJson: serializer.fromJson<String?>(json['catalogRefJson']),
      fieldDefinitionId: serializer.fromJson<String>(json['fieldDefinitionId']),
      value: serializer.fromJson<String?>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'targetId': serializer.toJson<String>(targetId),
      'targetScope': serializer.toJson<String>(targetScope),
      'catalogRefJson': serializer.toJson<String?>(catalogRefJson),
      'fieldDefinitionId': serializer.toJson<String>(fieldDefinitionId),
      'value': serializer.toJson<String?>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CustomFieldValuesCacheData copyWith(
          {String? id,
          String? targetId,
          String? targetScope,
          Value<String?> catalogRefJson = const Value.absent(),
          String? fieldDefinitionId,
          Value<String?> value = const Value.absent(),
          DateTime? updatedAt}) =>
      CustomFieldValuesCacheData(
        id: id ?? this.id,
        targetId: targetId ?? this.targetId,
        targetScope: targetScope ?? this.targetScope,
        catalogRefJson:
            catalogRefJson.present ? catalogRefJson.value : this.catalogRefJson,
        fieldDefinitionId: fieldDefinitionId ?? this.fieldDefinitionId,
        value: value.present ? value.value : this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CustomFieldValuesCacheData copyWithCompanion(
      CustomFieldValuesCacheCompanion data) {
    return CustomFieldValuesCacheData(
      id: data.id.present ? data.id.value : this.id,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      targetScope:
          data.targetScope.present ? data.targetScope.value : this.targetScope,
      catalogRefJson: data.catalogRefJson.present
          ? data.catalogRefJson.value
          : this.catalogRefJson,
      fieldDefinitionId: data.fieldDefinitionId.present
          ? data.fieldDefinitionId.value
          : this.fieldDefinitionId,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldValuesCacheData(')
          ..write('id: $id, ')
          ..write('targetId: $targetId, ')
          ..write('targetScope: $targetScope, ')
          ..write('catalogRefJson: $catalogRefJson, ')
          ..write('fieldDefinitionId: $fieldDefinitionId, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, targetId, targetScope, catalogRefJson,
      fieldDefinitionId, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomFieldValuesCacheData &&
          other.id == this.id &&
          other.targetId == this.targetId &&
          other.targetScope == this.targetScope &&
          other.catalogRefJson == this.catalogRefJson &&
          other.fieldDefinitionId == this.fieldDefinitionId &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class CustomFieldValuesCacheCompanion
    extends UpdateCompanion<CustomFieldValuesCacheData> {
  final Value<String> id;
  final Value<String> targetId;
  final Value<String> targetScope;
  final Value<String?> catalogRefJson;
  final Value<String> fieldDefinitionId;
  final Value<String?> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CustomFieldValuesCacheCompanion({
    this.id = const Value.absent(),
    this.targetId = const Value.absent(),
    this.targetScope = const Value.absent(),
    this.catalogRefJson = const Value.absent(),
    this.fieldDefinitionId = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomFieldValuesCacheCompanion.insert({
    required String id,
    required String targetId,
    required String targetScope,
    this.catalogRefJson = const Value.absent(),
    required String fieldDefinitionId,
    this.value = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        targetId = Value(targetId),
        targetScope = Value(targetScope),
        fieldDefinitionId = Value(fieldDefinitionId),
        updatedAt = Value(updatedAt);
  static Insertable<CustomFieldValuesCacheData> custom({
    Expression<String>? id,
    Expression<String>? targetId,
    Expression<String>? targetScope,
    Expression<String>? catalogRefJson,
    Expression<String>? fieldDefinitionId,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetId != null) 'target_id': targetId,
      if (targetScope != null) 'target_scope': targetScope,
      if (catalogRefJson != null) 'catalog_ref_json': catalogRefJson,
      if (fieldDefinitionId != null) 'field_definition_id': fieldDefinitionId,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomFieldValuesCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? targetId,
      Value<String>? targetScope,
      Value<String?>? catalogRefJson,
      Value<String>? fieldDefinitionId,
      Value<String?>? value,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CustomFieldValuesCacheCompanion(
      id: id ?? this.id,
      targetId: targetId ?? this.targetId,
      targetScope: targetScope ?? this.targetScope,
      catalogRefJson: catalogRefJson ?? this.catalogRefJson,
      fieldDefinitionId: fieldDefinitionId ?? this.fieldDefinitionId,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (targetScope.present) {
      map['target_scope'] = Variable<String>(targetScope.value);
    }
    if (catalogRefJson.present) {
      map['catalog_ref_json'] = Variable<String>(catalogRefJson.value);
    }
    if (fieldDefinitionId.present) {
      map['field_definition_id'] = Variable<String>(fieldDefinitionId.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldValuesCacheCompanion(')
          ..write('id: $id, ')
          ..write('targetId: $targetId, ')
          ..write('targetScope: $targetScope, ')
          ..write('catalogRefJson: $catalogRefJson, ')
          ..write('fieldDefinitionId: $fieldDefinitionId, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemImagesCacheTable extends ItemImagesCache
    with TableInfo<$ItemImagesCacheTable, ItemImagesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemImagesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownedItemIdMeta =
      const VerificationMeta('ownedItemId');
  @override
  late final GeneratedColumn<String> ownedItemId = GeneratedColumn<String>(
      'owned_item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageTypeMeta =
      const VerificationMeta('imageType');
  @override
  late final GeneratedColumn<String> imageType = GeneratedColumn<String>(
      'image_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('front_cover'));
  static const VerificationMeta _imageDataMeta =
      const VerificationMeta('imageData');
  @override
  late final GeneratedColumn<Uint8List> imageData = GeneratedColumn<Uint8List>(
      'image_data', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _captionMeta =
      const VerificationMeta('caption');
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
      'caption', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ownedItemId, imageType, imageData, caption, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_images_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<ItemImagesCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owned_item_id')) {
      context.handle(
          _ownedItemIdMeta,
          ownedItemId.isAcceptableOrUnknown(
              data['owned_item_id']!, _ownedItemIdMeta));
    } else if (isInserting) {
      context.missing(_ownedItemIdMeta);
    }
    if (data.containsKey('image_type')) {
      context.handle(_imageTypeMeta,
          imageType.isAcceptableOrUnknown(data['image_type']!, _imageTypeMeta));
    }
    if (data.containsKey('image_data')) {
      context.handle(_imageDataMeta,
          imageData.isAcceptableOrUnknown(data['image_data']!, _imageDataMeta));
    } else if (isInserting) {
      context.missing(_imageDataMeta);
    }
    if (data.containsKey('caption')) {
      context.handle(_captionMeta,
          caption.isAcceptableOrUnknown(data['caption']!, _captionMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemImagesCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemImagesCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ownedItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owned_item_id'])!,
      imageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_type'])!,
      imageData: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}image_data'])!,
      caption: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}caption']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ItemImagesCacheTable createAlias(String alias) {
    return $ItemImagesCacheTable(attachedDatabase, alias);
  }
}

class ItemImagesCacheData extends DataClass
    implements Insertable<ItemImagesCacheData> {
  final String id;
  final String ownedItemId;
  final String imageType;
  final Uint8List imageData;
  final String? caption;
  final int sortOrder;
  final DateTime createdAt;
  const ItemImagesCacheData(
      {required this.id,
      required this.ownedItemId,
      required this.imageType,
      required this.imageData,
      this.caption,
      required this.sortOrder,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owned_item_id'] = Variable<String>(ownedItemId);
    map['image_type'] = Variable<String>(imageType);
    map['image_data'] = Variable<Uint8List>(imageData);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ItemImagesCacheCompanion toCompanion(bool nullToAbsent) {
    return ItemImagesCacheCompanion(
      id: Value(id),
      ownedItemId: Value(ownedItemId),
      imageType: Value(imageType),
      imageData: Value(imageData),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory ItemImagesCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemImagesCacheData(
      id: serializer.fromJson<String>(json['id']),
      ownedItemId: serializer.fromJson<String>(json['ownedItemId']),
      imageType: serializer.fromJson<String>(json['imageType']),
      imageData: serializer.fromJson<Uint8List>(json['imageData']),
      caption: serializer.fromJson<String?>(json['caption']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownedItemId': serializer.toJson<String>(ownedItemId),
      'imageType': serializer.toJson<String>(imageType),
      'imageData': serializer.toJson<Uint8List>(imageData),
      'caption': serializer.toJson<String?>(caption),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ItemImagesCacheData copyWith(
          {String? id,
          String? ownedItemId,
          String? imageType,
          Uint8List? imageData,
          Value<String?> caption = const Value.absent(),
          int? sortOrder,
          DateTime? createdAt}) =>
      ItemImagesCacheData(
        id: id ?? this.id,
        ownedItemId: ownedItemId ?? this.ownedItemId,
        imageType: imageType ?? this.imageType,
        imageData: imageData ?? this.imageData,
        caption: caption.present ? caption.value : this.caption,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );
  ItemImagesCacheData copyWithCompanion(ItemImagesCacheCompanion data) {
    return ItemImagesCacheData(
      id: data.id.present ? data.id.value : this.id,
      ownedItemId:
          data.ownedItemId.present ? data.ownedItemId.value : this.ownedItemId,
      imageType: data.imageType.present ? data.imageType.value : this.imageType,
      imageData: data.imageData.present ? data.imageData.value : this.imageData,
      caption: data.caption.present ? data.caption.value : this.caption,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemImagesCacheData(')
          ..write('id: $id, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('imageType: $imageType, ')
          ..write('imageData: $imageData, ')
          ..write('caption: $caption, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ownedItemId, imageType,
      $driftBlobEquality.hash(imageData), caption, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemImagesCacheData &&
          other.id == this.id &&
          other.ownedItemId == this.ownedItemId &&
          other.imageType == this.imageType &&
          $driftBlobEquality.equals(other.imageData, this.imageData) &&
          other.caption == this.caption &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class ItemImagesCacheCompanion extends UpdateCompanion<ItemImagesCacheData> {
  final Value<String> id;
  final Value<String> ownedItemId;
  final Value<String> imageType;
  final Value<Uint8List> imageData;
  final Value<String?> caption;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ItemImagesCacheCompanion({
    this.id = const Value.absent(),
    this.ownedItemId = const Value.absent(),
    this.imageType = const Value.absent(),
    this.imageData = const Value.absent(),
    this.caption = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemImagesCacheCompanion.insert({
    required String id,
    required String ownedItemId,
    this.imageType = const Value.absent(),
    required Uint8List imageData,
    this.caption = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ownedItemId = Value(ownedItemId),
        imageData = Value(imageData),
        createdAt = Value(createdAt);
  static Insertable<ItemImagesCacheData> custom({
    Expression<String>? id,
    Expression<String>? ownedItemId,
    Expression<String>? imageType,
    Expression<Uint8List>? imageData,
    Expression<String>? caption,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownedItemId != null) 'owned_item_id': ownedItemId,
      if (imageType != null) 'image_type': imageType,
      if (imageData != null) 'image_data': imageData,
      if (caption != null) 'caption': caption,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemImagesCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? ownedItemId,
      Value<String>? imageType,
      Value<Uint8List>? imageData,
      Value<String?>? caption,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ItemImagesCacheCompanion(
      id: id ?? this.id,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      imageType: imageType ?? this.imageType,
      imageData: imageData ?? this.imageData,
      caption: caption ?? this.caption,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownedItemId.present) {
      map['owned_item_id'] = Variable<String>(ownedItemId.value);
    }
    if (imageType.present) {
      map['image_type'] = Variable<String>(imageType.value);
    }
    if (imageData.present) {
      map['image_data'] = Variable<Uint8List>(imageData.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemImagesCacheCompanion(')
          ..write('id: $id, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('imageType: $imageType, ')
          ..write('imageData: $imageData, ')
          ..write('caption: $caption, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoansCacheTable extends LoansCache
    with TableInfo<$LoansCacheTable, LoansCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownedItemIdMeta =
      const VerificationMeta('ownedItemId');
  @override
  late final GeneratedColumn<String> ownedItemId = GeneratedColumn<String>(
      'owned_item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _borrowerNameMeta =
      const VerificationMeta('borrowerName');
  @override
  late final GeneratedColumn<String> borrowerName = GeneratedColumn<String>(
      'borrower_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lentDateMeta =
      const VerificationMeta('lentDate');
  @override
  late final GeneratedColumn<DateTime> lentDate = GeneratedColumn<DateTime>(
      'lent_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _returnedDateMeta =
      const VerificationMeta('returnedDate');
  @override
  late final GeneratedColumn<DateTime> returnedDate = GeneratedColumn<DateTime>(
      'returned_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ownedItemId, borrowerName, lentDate, dueDate, returnedDate, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans_cache';
  @override
  VerificationContext validateIntegrity(Insertable<LoansCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owned_item_id')) {
      context.handle(
          _ownedItemIdMeta,
          ownedItemId.isAcceptableOrUnknown(
              data['owned_item_id']!, _ownedItemIdMeta));
    } else if (isInserting) {
      context.missing(_ownedItemIdMeta);
    }
    if (data.containsKey('borrower_name')) {
      context.handle(
          _borrowerNameMeta,
          borrowerName.isAcceptableOrUnknown(
              data['borrower_name']!, _borrowerNameMeta));
    } else if (isInserting) {
      context.missing(_borrowerNameMeta);
    }
    if (data.containsKey('lent_date')) {
      context.handle(_lentDateMeta,
          lentDate.isAcceptableOrUnknown(data['lent_date']!, _lentDateMeta));
    } else if (isInserting) {
      context.missing(_lentDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('returned_date')) {
      context.handle(
          _returnedDateMeta,
          returnedDate.isAcceptableOrUnknown(
              data['returned_date']!, _returnedDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoansCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoansCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ownedItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owned_item_id'])!,
      borrowerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}borrower_name'])!,
      lentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}lent_date'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      returnedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}returned_date']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $LoansCacheTable createAlias(String alias) {
    return $LoansCacheTable(attachedDatabase, alias);
  }
}

class LoansCacheData extends DataClass implements Insertable<LoansCacheData> {
  final String id;
  final String ownedItemId;
  final String borrowerName;
  final DateTime lentDate;
  final DateTime? dueDate;
  final DateTime? returnedDate;
  final String? notes;
  const LoansCacheData(
      {required this.id,
      required this.ownedItemId,
      required this.borrowerName,
      required this.lentDate,
      this.dueDate,
      this.returnedDate,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owned_item_id'] = Variable<String>(ownedItemId);
    map['borrower_name'] = Variable<String>(borrowerName);
    map['lent_date'] = Variable<DateTime>(lentDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || returnedDate != null) {
      map['returned_date'] = Variable<DateTime>(returnedDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LoansCacheCompanion toCompanion(bool nullToAbsent) {
    return LoansCacheCompanion(
      id: Value(id),
      ownedItemId: Value(ownedItemId),
      borrowerName: Value(borrowerName),
      lentDate: Value(lentDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      returnedDate: returnedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(returnedDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory LoansCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoansCacheData(
      id: serializer.fromJson<String>(json['id']),
      ownedItemId: serializer.fromJson<String>(json['ownedItemId']),
      borrowerName: serializer.fromJson<String>(json['borrowerName']),
      lentDate: serializer.fromJson<DateTime>(json['lentDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      returnedDate: serializer.fromJson<DateTime?>(json['returnedDate']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownedItemId': serializer.toJson<String>(ownedItemId),
      'borrowerName': serializer.toJson<String>(borrowerName),
      'lentDate': serializer.toJson<DateTime>(lentDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'returnedDate': serializer.toJson<DateTime?>(returnedDate),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LoansCacheData copyWith(
          {String? id,
          String? ownedItemId,
          String? borrowerName,
          DateTime? lentDate,
          Value<DateTime?> dueDate = const Value.absent(),
          Value<DateTime?> returnedDate = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      LoansCacheData(
        id: id ?? this.id,
        ownedItemId: ownedItemId ?? this.ownedItemId,
        borrowerName: borrowerName ?? this.borrowerName,
        lentDate: lentDate ?? this.lentDate,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        returnedDate:
            returnedDate.present ? returnedDate.value : this.returnedDate,
        notes: notes.present ? notes.value : this.notes,
      );
  LoansCacheData copyWithCompanion(LoansCacheCompanion data) {
    return LoansCacheData(
      id: data.id.present ? data.id.value : this.id,
      ownedItemId:
          data.ownedItemId.present ? data.ownedItemId.value : this.ownedItemId,
      borrowerName: data.borrowerName.present
          ? data.borrowerName.value
          : this.borrowerName,
      lentDate: data.lentDate.present ? data.lentDate.value : this.lentDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      returnedDate: data.returnedDate.present
          ? data.returnedDate.value
          : this.returnedDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoansCacheData(')
          ..write('id: $id, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('borrowerName: $borrowerName, ')
          ..write('lentDate: $lentDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('returnedDate: $returnedDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, ownedItemId, borrowerName, lentDate, dueDate, returnedDate, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoansCacheData &&
          other.id == this.id &&
          other.ownedItemId == this.ownedItemId &&
          other.borrowerName == this.borrowerName &&
          other.lentDate == this.lentDate &&
          other.dueDate == this.dueDate &&
          other.returnedDate == this.returnedDate &&
          other.notes == this.notes);
}

class LoansCacheCompanion extends UpdateCompanion<LoansCacheData> {
  final Value<String> id;
  final Value<String> ownedItemId;
  final Value<String> borrowerName;
  final Value<DateTime> lentDate;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> returnedDate;
  final Value<String?> notes;
  final Value<int> rowid;
  const LoansCacheCompanion({
    this.id = const Value.absent(),
    this.ownedItemId = const Value.absent(),
    this.borrowerName = const Value.absent(),
    this.lentDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.returnedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoansCacheCompanion.insert({
    required String id,
    required String ownedItemId,
    required String borrowerName,
    required DateTime lentDate,
    this.dueDate = const Value.absent(),
    this.returnedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ownedItemId = Value(ownedItemId),
        borrowerName = Value(borrowerName),
        lentDate = Value(lentDate);
  static Insertable<LoansCacheData> custom({
    Expression<String>? id,
    Expression<String>? ownedItemId,
    Expression<String>? borrowerName,
    Expression<DateTime>? lentDate,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? returnedDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownedItemId != null) 'owned_item_id': ownedItemId,
      if (borrowerName != null) 'borrower_name': borrowerName,
      if (lentDate != null) 'lent_date': lentDate,
      if (dueDate != null) 'due_date': dueDate,
      if (returnedDate != null) 'returned_date': returnedDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoansCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? ownedItemId,
      Value<String>? borrowerName,
      Value<DateTime>? lentDate,
      Value<DateTime?>? dueDate,
      Value<DateTime?>? returnedDate,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return LoansCacheCompanion(
      id: id ?? this.id,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      borrowerName: borrowerName ?? this.borrowerName,
      lentDate: lentDate ?? this.lentDate,
      dueDate: dueDate ?? this.dueDate,
      returnedDate: returnedDate ?? this.returnedDate,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownedItemId.present) {
      map['owned_item_id'] = Variable<String>(ownedItemId.value);
    }
    if (borrowerName.present) {
      map['borrower_name'] = Variable<String>(borrowerName.value);
    }
    if (lentDate.present) {
      map['lent_date'] = Variable<DateTime>(lentDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (returnedDate.present) {
      map['returned_date'] = Variable<DateTime>(returnedDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoansCacheCompanion(')
          ..write('id: $id, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('borrowerName: $borrowerName, ')
          ..write('lentDate: $lentDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('returnedDate: $returnedDate, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationsCacheTable extends LocationsCache
    with TableInfo<$LocationsCacheTable, LocationsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, parentId, description, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations_cache';
  @override
  VerificationContext validateIntegrity(Insertable<LocationsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationsCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $LocationsCacheTable createAlias(String alias) {
    return $LocationsCacheTable(attachedDatabase, alias);
  }
}

class LocationsCacheData extends DataClass
    implements Insertable<LocationsCacheData> {
  final String id;
  final String name;
  final String? parentId;
  final String? description;
  final int sortOrder;
  const LocationsCacheData(
      {required this.id,
      required this.name,
      this.parentId,
      this.description,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LocationsCacheCompanion toCompanion(bool nullToAbsent) {
    return LocationsCacheCompanion(
      id: Value(id),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sortOrder: Value(sortOrder),
    );
  }

  factory LocationsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationsCacheData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      description: serializer.fromJson<String?>(json['description']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
      'description': serializer.toJson<String?>(description),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LocationsCacheData copyWith(
          {String? id,
          String? name,
          Value<String?> parentId = const Value.absent(),
          Value<String?> description = const Value.absent(),
          int? sortOrder}) =>
      LocationsCacheData(
        id: id ?? this.id,
        name: name ?? this.name,
        parentId: parentId.present ? parentId.value : this.parentId,
        description: description.present ? description.value : this.description,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  LocationsCacheData copyWithCompanion(LocationsCacheCompanion data) {
    return LocationsCacheData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      description:
          data.description.present ? data.description.value : this.description,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationsCacheData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, parentId, description, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationsCacheData &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId &&
          other.description == this.description &&
          other.sortOrder == this.sortOrder);
}

class LocationsCacheCompanion extends UpdateCompanion<LocationsCacheData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<String?> description;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LocationsCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationsCacheCompanion.insert({
    required String id,
    required String name,
    this.parentId = const Value.absent(),
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<LocationsCacheData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<String>? description,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (description != null) 'description': description,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationsCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? parentId,
      Value<String?>? description,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return LocationsCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationsCacheCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SmartListsCacheTable extends SmartListsCache
    with TableInfo<$SmartListsCacheTable, SmartListsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmartListsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mediaKindMeta =
      const VerificationMeta('mediaKind');
  @override
  late final GeneratedColumn<String> mediaKind = GeneratedColumn<String>(
      'media_kind', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _criteriaJsonMeta =
      const VerificationMeta('criteriaJson');
  @override
  late final GeneratedColumn<String> criteriaJson = GeneratedColumn<String>(
      'criteria_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, mediaKind, criteriaJson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'smart_lists_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<SmartListsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('media_kind')) {
      context.handle(_mediaKindMeta,
          mediaKind.isAcceptableOrUnknown(data['media_kind']!, _mediaKindMeta));
    }
    if (data.containsKey('criteria_json')) {
      context.handle(
          _criteriaJsonMeta,
          criteriaJson.isAcceptableOrUnknown(
              data['criteria_json']!, _criteriaJsonMeta));
    } else if (isInserting) {
      context.missing(_criteriaJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmartListsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmartListsCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      mediaKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_kind']),
      criteriaJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}criteria_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SmartListsCacheTable createAlias(String alias) {
    return $SmartListsCacheTable(attachedDatabase, alias);
  }
}

class SmartListsCacheData extends DataClass
    implements Insertable<SmartListsCacheData> {
  final String id;
  final String name;
  final String? mediaKind;
  final String criteriaJson;
  final DateTime createdAt;
  const SmartListsCacheData(
      {required this.id,
      required this.name,
      this.mediaKind,
      required this.criteriaJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || mediaKind != null) {
      map['media_kind'] = Variable<String>(mediaKind);
    }
    map['criteria_json'] = Variable<String>(criteriaJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SmartListsCacheCompanion toCompanion(bool nullToAbsent) {
    return SmartListsCacheCompanion(
      id: Value(id),
      name: Value(name),
      mediaKind: mediaKind == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaKind),
      criteriaJson: Value(criteriaJson),
      createdAt: Value(createdAt),
    );
  }

  factory SmartListsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmartListsCacheData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      mediaKind: serializer.fromJson<String?>(json['mediaKind']),
      criteriaJson: serializer.fromJson<String>(json['criteriaJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'mediaKind': serializer.toJson<String?>(mediaKind),
      'criteriaJson': serializer.toJson<String>(criteriaJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SmartListsCacheData copyWith(
          {String? id,
          String? name,
          Value<String?> mediaKind = const Value.absent(),
          String? criteriaJson,
          DateTime? createdAt}) =>
      SmartListsCacheData(
        id: id ?? this.id,
        name: name ?? this.name,
        mediaKind: mediaKind.present ? mediaKind.value : this.mediaKind,
        criteriaJson: criteriaJson ?? this.criteriaJson,
        createdAt: createdAt ?? this.createdAt,
      );
  SmartListsCacheData copyWithCompanion(SmartListsCacheCompanion data) {
    return SmartListsCacheData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      mediaKind: data.mediaKind.present ? data.mediaKind.value : this.mediaKind,
      criteriaJson: data.criteriaJson.present
          ? data.criteriaJson.value
          : this.criteriaJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmartListsCacheData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mediaKind: $mediaKind, ')
          ..write('criteriaJson: $criteriaJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, mediaKind, criteriaJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmartListsCacheData &&
          other.id == this.id &&
          other.name == this.name &&
          other.mediaKind == this.mediaKind &&
          other.criteriaJson == this.criteriaJson &&
          other.createdAt == this.createdAt);
}

class SmartListsCacheCompanion extends UpdateCompanion<SmartListsCacheData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> mediaKind;
  final Value<String> criteriaJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SmartListsCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.mediaKind = const Value.absent(),
    this.criteriaJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SmartListsCacheCompanion.insert({
    required String id,
    required String name,
    this.mediaKind = const Value.absent(),
    required String criteriaJson,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        criteriaJson = Value(criteriaJson),
        createdAt = Value(createdAt);
  static Insertable<SmartListsCacheData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? mediaKind,
    Expression<String>? criteriaJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mediaKind != null) 'media_kind': mediaKind,
      if (criteriaJson != null) 'criteria_json': criteriaJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SmartListsCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? mediaKind,
      Value<String>? criteriaJson,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SmartListsCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      mediaKind: mediaKind ?? this.mediaKind,
      criteriaJson: criteriaJson ?? this.criteriaJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mediaKind.present) {
      map['media_kind'] = Variable<String>(mediaKind.value);
    }
    if (criteriaJson.present) {
      map['criteria_json'] = Variable<String>(criteriaJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmartListsCacheCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mediaKind: $mediaKind, ')
          ..write('criteriaJson: $criteriaJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserFoldersCacheTable extends UserFoldersCache
    with TableInfo<$UserFoldersCacheTable, UserFoldersCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserFoldersCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, parentId, iconName, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_folders_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<UserFoldersCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserFoldersCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserFoldersCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $UserFoldersCacheTable createAlias(String alias) {
    return $UserFoldersCacheTable(attachedDatabase, alias);
  }
}

class UserFoldersCacheData extends DataClass
    implements Insertable<UserFoldersCacheData> {
  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final String? iconName;
  final int sortOrder;
  const UserFoldersCacheData(
      {required this.id,
      required this.name,
      this.description,
      this.parentId,
      this.iconName,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  UserFoldersCacheCompanion toCompanion(bool nullToAbsent) {
    return UserFoldersCacheCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      sortOrder: Value(sortOrder),
    );
  }

  factory UserFoldersCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserFoldersCacheData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'parentId': serializer.toJson<String?>(parentId),
      'iconName': serializer.toJson<String?>(iconName),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  UserFoldersCacheData copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> parentId = const Value.absent(),
          Value<String?> iconName = const Value.absent(),
          int? sortOrder}) =>
      UserFoldersCacheData(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        parentId: parentId.present ? parentId.value : this.parentId,
        iconName: iconName.present ? iconName.value : this.iconName,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  UserFoldersCacheData copyWithCompanion(UserFoldersCacheCompanion data) {
    return UserFoldersCacheData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserFoldersCacheData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('parentId: $parentId, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, parentId, iconName, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserFoldersCacheData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.parentId == this.parentId &&
          other.iconName == this.iconName &&
          other.sortOrder == this.sortOrder);
}

class UserFoldersCacheCompanion extends UpdateCompanion<UserFoldersCacheData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> parentId;
  final Value<String?> iconName;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const UserFoldersCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.parentId = const Value.absent(),
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserFoldersCacheCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.parentId = const Value.absent(),
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<UserFoldersCacheData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? parentId,
    Expression<String>? iconName,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (parentId != null) 'parent_id': parentId,
      if (iconName != null) 'icon_name': iconName,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserFoldersCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? parentId,
      Value<String?>? iconName,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return UserFoldersCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserFoldersCacheCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('parentId: $parentId, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserFolderItemsCacheTable extends UserFolderItemsCache
    with TableInfo<$UserFolderItemsCacheTable, UserFolderItemsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserFolderItemsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _folderIdMeta =
      const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
      'folder_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownedItemIdMeta =
      const VerificationMeta('ownedItemId');
  @override
  late final GeneratedColumn<String> ownedItemId = GeneratedColumn<String>(
      'owned_item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [folderId, ownedItemId, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_folder_items_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<UserFolderItemsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('folder_id')) {
      context.handle(_folderIdMeta,
          folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta));
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('owned_item_id')) {
      context.handle(
          _ownedItemIdMeta,
          ownedItemId.isAcceptableOrUnknown(
              data['owned_item_id']!, _ownedItemIdMeta));
    } else if (isInserting) {
      context.missing(_ownedItemIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {folderId, ownedItemId};
  @override
  UserFolderItemsCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserFolderItemsCacheData(
      folderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}folder_id'])!,
      ownedItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owned_item_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $UserFolderItemsCacheTable createAlias(String alias) {
    return $UserFolderItemsCacheTable(attachedDatabase, alias);
  }
}

class UserFolderItemsCacheData extends DataClass
    implements Insertable<UserFolderItemsCacheData> {
  final String folderId;
  final String ownedItemId;
  final int sortOrder;
  const UserFolderItemsCacheData(
      {required this.folderId,
      required this.ownedItemId,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['folder_id'] = Variable<String>(folderId);
    map['owned_item_id'] = Variable<String>(ownedItemId);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  UserFolderItemsCacheCompanion toCompanion(bool nullToAbsent) {
    return UserFolderItemsCacheCompanion(
      folderId: Value(folderId),
      ownedItemId: Value(ownedItemId),
      sortOrder: Value(sortOrder),
    );
  }

  factory UserFolderItemsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserFolderItemsCacheData(
      folderId: serializer.fromJson<String>(json['folderId']),
      ownedItemId: serializer.fromJson<String>(json['ownedItemId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'folderId': serializer.toJson<String>(folderId),
      'ownedItemId': serializer.toJson<String>(ownedItemId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  UserFolderItemsCacheData copyWith(
          {String? folderId, String? ownedItemId, int? sortOrder}) =>
      UserFolderItemsCacheData(
        folderId: folderId ?? this.folderId,
        ownedItemId: ownedItemId ?? this.ownedItemId,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  UserFolderItemsCacheData copyWithCompanion(
      UserFolderItemsCacheCompanion data) {
    return UserFolderItemsCacheData(
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      ownedItemId:
          data.ownedItemId.present ? data.ownedItemId.value : this.ownedItemId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserFolderItemsCacheData(')
          ..write('folderId: $folderId, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(folderId, ownedItemId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserFolderItemsCacheData &&
          other.folderId == this.folderId &&
          other.ownedItemId == this.ownedItemId &&
          other.sortOrder == this.sortOrder);
}

class UserFolderItemsCacheCompanion
    extends UpdateCompanion<UserFolderItemsCacheData> {
  final Value<String> folderId;
  final Value<String> ownedItemId;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const UserFolderItemsCacheCompanion({
    this.folderId = const Value.absent(),
    this.ownedItemId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserFolderItemsCacheCompanion.insert({
    required String folderId,
    required String ownedItemId,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : folderId = Value(folderId),
        ownedItemId = Value(ownedItemId);
  static Insertable<UserFolderItemsCacheData> custom({
    Expression<String>? folderId,
    Expression<String>? ownedItemId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (folderId != null) 'folder_id': folderId,
      if (ownedItemId != null) 'owned_item_id': ownedItemId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserFolderItemsCacheCompanion copyWith(
      {Value<String>? folderId,
      Value<String>? ownedItemId,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return UserFolderItemsCacheCompanion(
      folderId: folderId ?? this.folderId,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (ownedItemId.present) {
      map['owned_item_id'] = Variable<String>(ownedItemId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserFolderItemsCacheCompanion(')
          ..write('folderId: $folderId, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingQueueCacheTable extends ReadingQueueCache
    with TableInfo<$ReadingQueueCacheTable, ReadingQueueCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingQueueCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownedItemIdMeta =
      const VerificationMeta('ownedItemId');
  @override
  late final GeneratedColumn<String> ownedItemId = GeneratedColumn<String>(
      'owned_item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [ownedItemId, position, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_queue_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReadingQueueCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owned_item_id')) {
      context.handle(
          _ownedItemIdMeta,
          ownedItemId.isAcceptableOrUnknown(
              data['owned_item_id']!, _ownedItemIdMeta));
    } else if (isInserting) {
      context.missing(_ownedItemIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownedItemId};
  @override
  ReadingQueueCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingQueueCacheData(
      ownedItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owned_item_id'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $ReadingQueueCacheTable createAlias(String alias) {
    return $ReadingQueueCacheTable(attachedDatabase, alias);
  }
}

class ReadingQueueCacheData extends DataClass
    implements Insertable<ReadingQueueCacheData> {
  final String ownedItemId;
  final int position;
  final DateTime addedAt;
  const ReadingQueueCacheData(
      {required this.ownedItemId,
      required this.position,
      required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owned_item_id'] = Variable<String>(ownedItemId);
    map['position'] = Variable<int>(position);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  ReadingQueueCacheCompanion toCompanion(bool nullToAbsent) {
    return ReadingQueueCacheCompanion(
      ownedItemId: Value(ownedItemId),
      position: Value(position),
      addedAt: Value(addedAt),
    );
  }

  factory ReadingQueueCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingQueueCacheData(
      ownedItemId: serializer.fromJson<String>(json['ownedItemId']),
      position: serializer.fromJson<int>(json['position']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownedItemId': serializer.toJson<String>(ownedItemId),
      'position': serializer.toJson<int>(position),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  ReadingQueueCacheData copyWith(
          {String? ownedItemId, int? position, DateTime? addedAt}) =>
      ReadingQueueCacheData(
        ownedItemId: ownedItemId ?? this.ownedItemId,
        position: position ?? this.position,
        addedAt: addedAt ?? this.addedAt,
      );
  ReadingQueueCacheData copyWithCompanion(ReadingQueueCacheCompanion data) {
    return ReadingQueueCacheData(
      ownedItemId:
          data.ownedItemId.present ? data.ownedItemId.value : this.ownedItemId,
      position: data.position.present ? data.position.value : this.position,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingQueueCacheData(')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ownedItemId, position, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingQueueCacheData &&
          other.ownedItemId == this.ownedItemId &&
          other.position == this.position &&
          other.addedAt == this.addedAt);
}

class ReadingQueueCacheCompanion
    extends UpdateCompanion<ReadingQueueCacheData> {
  final Value<String> ownedItemId;
  final Value<int> position;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const ReadingQueueCacheCompanion({
    this.ownedItemId = const Value.absent(),
    this.position = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingQueueCacheCompanion.insert({
    required String ownedItemId,
    required int position,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  })  : ownedItemId = Value(ownedItemId),
        position = Value(position),
        addedAt = Value(addedAt);
  static Insertable<ReadingQueueCacheData> custom({
    Expression<String>? ownedItemId,
    Expression<int>? position,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownedItemId != null) 'owned_item_id': ownedItemId,
      if (position != null) 'position': position,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingQueueCacheCompanion copyWith(
      {Value<String>? ownedItemId,
      Value<int>? position,
      Value<DateTime>? addedAt,
      Value<int>? rowid}) {
    return ReadingQueueCacheCompanion(
      ownedItemId: ownedItemId ?? this.ownedItemId,
      position: position ?? this.position,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownedItemId.present) {
      map['owned_item_id'] = Variable<String>(ownedItemId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingQueueCacheCompanion(')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PickListValuesCacheTable extends PickListValuesCache
    with TableInfo<$PickListValuesCacheTable, PickListValuesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PickListValuesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _listNameMeta =
      const VerificationMeta('listName');
  @override
  late final GeneratedColumn<String> listName = GeneratedColumn<String>(
      'list_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mediaKindMeta =
      const VerificationMeta('mediaKind');
  @override
  late final GeneratedColumn<String> mediaKind = GeneratedColumn<String>(
      'media_kind', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, listName, mediaKind, value, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pick_list_values_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<PickListValuesCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('list_name')) {
      context.handle(_listNameMeta,
          listName.isAcceptableOrUnknown(data['list_name']!, _listNameMeta));
    } else if (isInserting) {
      context.missing(_listNameMeta);
    }
    if (data.containsKey('media_kind')) {
      context.handle(_mediaKindMeta,
          mediaKind.isAcceptableOrUnknown(data['media_kind']!, _mediaKindMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PickListValuesCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PickListValuesCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      listName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}list_name'])!,
      mediaKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_kind']),
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $PickListValuesCacheTable createAlias(String alias) {
    return $PickListValuesCacheTable(attachedDatabase, alias);
  }
}

class PickListValuesCacheData extends DataClass
    implements Insertable<PickListValuesCacheData> {
  final String id;
  final String listName;
  final String? mediaKind;
  final String value;
  final int sortOrder;
  const PickListValuesCacheData(
      {required this.id,
      required this.listName,
      this.mediaKind,
      required this.value,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['list_name'] = Variable<String>(listName);
    if (!nullToAbsent || mediaKind != null) {
      map['media_kind'] = Variable<String>(mediaKind);
    }
    map['value'] = Variable<String>(value);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PickListValuesCacheCompanion toCompanion(bool nullToAbsent) {
    return PickListValuesCacheCompanion(
      id: Value(id),
      listName: Value(listName),
      mediaKind: mediaKind == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaKind),
      value: Value(value),
      sortOrder: Value(sortOrder),
    );
  }

  factory PickListValuesCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PickListValuesCacheData(
      id: serializer.fromJson<String>(json['id']),
      listName: serializer.fromJson<String>(json['listName']),
      mediaKind: serializer.fromJson<String?>(json['mediaKind']),
      value: serializer.fromJson<String>(json['value']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'listName': serializer.toJson<String>(listName),
      'mediaKind': serializer.toJson<String?>(mediaKind),
      'value': serializer.toJson<String>(value),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  PickListValuesCacheData copyWith(
          {String? id,
          String? listName,
          Value<String?> mediaKind = const Value.absent(),
          String? value,
          int? sortOrder}) =>
      PickListValuesCacheData(
        id: id ?? this.id,
        listName: listName ?? this.listName,
        mediaKind: mediaKind.present ? mediaKind.value : this.mediaKind,
        value: value ?? this.value,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  PickListValuesCacheData copyWithCompanion(PickListValuesCacheCompanion data) {
    return PickListValuesCacheData(
      id: data.id.present ? data.id.value : this.id,
      listName: data.listName.present ? data.listName.value : this.listName,
      mediaKind: data.mediaKind.present ? data.mediaKind.value : this.mediaKind,
      value: data.value.present ? data.value.value : this.value,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PickListValuesCacheData(')
          ..write('id: $id, ')
          ..write('listName: $listName, ')
          ..write('mediaKind: $mediaKind, ')
          ..write('value: $value, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listName, mediaKind, value, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PickListValuesCacheData &&
          other.id == this.id &&
          other.listName == this.listName &&
          other.mediaKind == this.mediaKind &&
          other.value == this.value &&
          other.sortOrder == this.sortOrder);
}

class PickListValuesCacheCompanion
    extends UpdateCompanion<PickListValuesCacheData> {
  final Value<String> id;
  final Value<String> listName;
  final Value<String?> mediaKind;
  final Value<String> value;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const PickListValuesCacheCompanion({
    this.id = const Value.absent(),
    this.listName = const Value.absent(),
    this.mediaKind = const Value.absent(),
    this.value = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PickListValuesCacheCompanion.insert({
    required String id,
    required String listName,
    this.mediaKind = const Value.absent(),
    required String value,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        listName = Value(listName),
        value = Value(value);
  static Insertable<PickListValuesCacheData> custom({
    Expression<String>? id,
    Expression<String>? listName,
    Expression<String>? mediaKind,
    Expression<String>? value,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listName != null) 'list_name': listName,
      if (mediaKind != null) 'media_kind': mediaKind,
      if (value != null) 'value': value,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PickListValuesCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? listName,
      Value<String?>? mediaKind,
      Value<String>? value,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return PickListValuesCacheCompanion(
      id: id ?? this.id,
      listName: listName ?? this.listName,
      mediaKind: mediaKind ?? this.mediaKind,
      value: value ?? this.value,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (listName.present) {
      map['list_name'] = Variable<String>(listName.value);
    }
    if (mediaKind.present) {
      map['media_kind'] = Variable<String>(mediaKind.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PickListValuesCacheCompanion(')
          ..write('id: $id, ')
          ..write('listName: $listName, ')
          ..write('mediaKind: $mediaKind, ')
          ..write('value: $value, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SerialAuthorityCacheTable extends SerialAuthorityCache
    with TableInfo<$SerialAuthorityCacheTable, SerialAuthorityCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SerialAuthorityCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mediaKindMeta =
      const VerificationMeta('mediaKind');
  @override
  late final GeneratedColumn<String> mediaKind = GeneratedColumn<String>(
      'media_kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _normalizedTitleMeta =
      const VerificationMeta('normalizedTitle');
  @override
  late final GeneratedColumn<String> normalizedTitle = GeneratedColumn<String>(
      'normalized_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortTitleMeta =
      const VerificationMeta('sortTitle');
  @override
  late final GeneratedColumn<String> sortTitle = GeneratedColumn<String>(
      'sort_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _normalizedSortTitleMeta =
      const VerificationMeta('normalizedSortTitle');
  @override
  late final GeneratedColumn<String> normalizedSortTitle =
      GeneratedColumn<String>('normalized_sort_title', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coreSeriesIdMeta =
      const VerificationMeta('coreSeriesId');
  @override
  late final GeneratedColumn<String> coreSeriesId = GeneratedColumn<String>(
      'core_series_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        mediaKind,
        title,
        normalizedTitle,
        sortTitle,
        normalizedSortTitle,
        coreSeriesId,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'serial_authority_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<SerialAuthorityCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('media_kind')) {
      context.handle(_mediaKindMeta,
          mediaKind.isAcceptableOrUnknown(data['media_kind']!, _mediaKindMeta));
    } else if (isInserting) {
      context.missing(_mediaKindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('normalized_title')) {
      context.handle(
          _normalizedTitleMeta,
          normalizedTitle.isAcceptableOrUnknown(
              data['normalized_title']!, _normalizedTitleMeta));
    } else if (isInserting) {
      context.missing(_normalizedTitleMeta);
    }
    if (data.containsKey('sort_title')) {
      context.handle(_sortTitleMeta,
          sortTitle.isAcceptableOrUnknown(data['sort_title']!, _sortTitleMeta));
    }
    if (data.containsKey('normalized_sort_title')) {
      context.handle(
          _normalizedSortTitleMeta,
          normalizedSortTitle.isAcceptableOrUnknown(
              data['normalized_sort_title']!, _normalizedSortTitleMeta));
    }
    if (data.containsKey('core_series_id')) {
      context.handle(
          _coreSeriesIdMeta,
          coreSeriesId.isAcceptableOrUnknown(
              data['core_series_id']!, _coreSeriesIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SerialAuthorityCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SerialAuthorityCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      mediaKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_kind'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      normalizedTitle: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}normalized_title'])!,
      sortTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sort_title']),
      normalizedSortTitle: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}normalized_sort_title']),
      coreSeriesId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}core_series_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SerialAuthorityCacheTable createAlias(String alias) {
    return $SerialAuthorityCacheTable(attachedDatabase, alias);
  }
}

class SerialAuthorityCacheData extends DataClass
    implements Insertable<SerialAuthorityCacheData> {
  final String id;
  final String mediaKind;
  final String title;
  final String normalizedTitle;
  final String? sortTitle;
  final String? normalizedSortTitle;
  final String? coreSeriesId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SerialAuthorityCacheData(
      {required this.id,
      required this.mediaKind,
      required this.title,
      required this.normalizedTitle,
      this.sortTitle,
      this.normalizedSortTitle,
      this.coreSeriesId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['media_kind'] = Variable<String>(mediaKind);
    map['title'] = Variable<String>(title);
    map['normalized_title'] = Variable<String>(normalizedTitle);
    if (!nullToAbsent || sortTitle != null) {
      map['sort_title'] = Variable<String>(sortTitle);
    }
    if (!nullToAbsent || normalizedSortTitle != null) {
      map['normalized_sort_title'] = Variable<String>(normalizedSortTitle);
    }
    if (!nullToAbsent || coreSeriesId != null) {
      map['core_series_id'] = Variable<String>(coreSeriesId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SerialAuthorityCacheCompanion toCompanion(bool nullToAbsent) {
    return SerialAuthorityCacheCompanion(
      id: Value(id),
      mediaKind: Value(mediaKind),
      title: Value(title),
      normalizedTitle: Value(normalizedTitle),
      sortTitle: sortTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(sortTitle),
      normalizedSortTitle: normalizedSortTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedSortTitle),
      coreSeriesId: coreSeriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(coreSeriesId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SerialAuthorityCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SerialAuthorityCacheData(
      id: serializer.fromJson<String>(json['id']),
      mediaKind: serializer.fromJson<String>(json['mediaKind']),
      title: serializer.fromJson<String>(json['title']),
      normalizedTitle: serializer.fromJson<String>(json['normalizedTitle']),
      sortTitle: serializer.fromJson<String?>(json['sortTitle']),
      normalizedSortTitle:
          serializer.fromJson<String?>(json['normalizedSortTitle']),
      coreSeriesId: serializer.fromJson<String?>(json['coreSeriesId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaKind': serializer.toJson<String>(mediaKind),
      'title': serializer.toJson<String>(title),
      'normalizedTitle': serializer.toJson<String>(normalizedTitle),
      'sortTitle': serializer.toJson<String?>(sortTitle),
      'normalizedSortTitle': serializer.toJson<String?>(normalizedSortTitle),
      'coreSeriesId': serializer.toJson<String?>(coreSeriesId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SerialAuthorityCacheData copyWith(
          {String? id,
          String? mediaKind,
          String? title,
          String? normalizedTitle,
          Value<String?> sortTitle = const Value.absent(),
          Value<String?> normalizedSortTitle = const Value.absent(),
          Value<String?> coreSeriesId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SerialAuthorityCacheData(
        id: id ?? this.id,
        mediaKind: mediaKind ?? this.mediaKind,
        title: title ?? this.title,
        normalizedTitle: normalizedTitle ?? this.normalizedTitle,
        sortTitle: sortTitle.present ? sortTitle.value : this.sortTitle,
        normalizedSortTitle: normalizedSortTitle.present
            ? normalizedSortTitle.value
            : this.normalizedSortTitle,
        coreSeriesId:
            coreSeriesId.present ? coreSeriesId.value : this.coreSeriesId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SerialAuthorityCacheData copyWithCompanion(
      SerialAuthorityCacheCompanion data) {
    return SerialAuthorityCacheData(
      id: data.id.present ? data.id.value : this.id,
      mediaKind: data.mediaKind.present ? data.mediaKind.value : this.mediaKind,
      title: data.title.present ? data.title.value : this.title,
      normalizedTitle: data.normalizedTitle.present
          ? data.normalizedTitle.value
          : this.normalizedTitle,
      sortTitle: data.sortTitle.present ? data.sortTitle.value : this.sortTitle,
      normalizedSortTitle: data.normalizedSortTitle.present
          ? data.normalizedSortTitle.value
          : this.normalizedSortTitle,
      coreSeriesId: data.coreSeriesId.present
          ? data.coreSeriesId.value
          : this.coreSeriesId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SerialAuthorityCacheData(')
          ..write('id: $id, ')
          ..write('mediaKind: $mediaKind, ')
          ..write('title: $title, ')
          ..write('normalizedTitle: $normalizedTitle, ')
          ..write('sortTitle: $sortTitle, ')
          ..write('normalizedSortTitle: $normalizedSortTitle, ')
          ..write('coreSeriesId: $coreSeriesId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mediaKind, title, normalizedTitle,
      sortTitle, normalizedSortTitle, coreSeriesId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SerialAuthorityCacheData &&
          other.id == this.id &&
          other.mediaKind == this.mediaKind &&
          other.title == this.title &&
          other.normalizedTitle == this.normalizedTitle &&
          other.sortTitle == this.sortTitle &&
          other.normalizedSortTitle == this.normalizedSortTitle &&
          other.coreSeriesId == this.coreSeriesId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SerialAuthorityCacheCompanion
    extends UpdateCompanion<SerialAuthorityCacheData> {
  final Value<String> id;
  final Value<String> mediaKind;
  final Value<String> title;
  final Value<String> normalizedTitle;
  final Value<String?> sortTitle;
  final Value<String?> normalizedSortTitle;
  final Value<String?> coreSeriesId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SerialAuthorityCacheCompanion({
    this.id = const Value.absent(),
    this.mediaKind = const Value.absent(),
    this.title = const Value.absent(),
    this.normalizedTitle = const Value.absent(),
    this.sortTitle = const Value.absent(),
    this.normalizedSortTitle = const Value.absent(),
    this.coreSeriesId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SerialAuthorityCacheCompanion.insert({
    required String id,
    required String mediaKind,
    required String title,
    required String normalizedTitle,
    this.sortTitle = const Value.absent(),
    this.normalizedSortTitle = const Value.absent(),
    this.coreSeriesId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        mediaKind = Value(mediaKind),
        title = Value(title),
        normalizedTitle = Value(normalizedTitle),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SerialAuthorityCacheData> custom({
    Expression<String>? id,
    Expression<String>? mediaKind,
    Expression<String>? title,
    Expression<String>? normalizedTitle,
    Expression<String>? sortTitle,
    Expression<String>? normalizedSortTitle,
    Expression<String>? coreSeriesId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaKind != null) 'media_kind': mediaKind,
      if (title != null) 'title': title,
      if (normalizedTitle != null) 'normalized_title': normalizedTitle,
      if (sortTitle != null) 'sort_title': sortTitle,
      if (normalizedSortTitle != null)
        'normalized_sort_title': normalizedSortTitle,
      if (coreSeriesId != null) 'core_series_id': coreSeriesId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SerialAuthorityCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? mediaKind,
      Value<String>? title,
      Value<String>? normalizedTitle,
      Value<String?>? sortTitle,
      Value<String?>? normalizedSortTitle,
      Value<String?>? coreSeriesId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SerialAuthorityCacheCompanion(
      id: id ?? this.id,
      mediaKind: mediaKind ?? this.mediaKind,
      title: title ?? this.title,
      normalizedTitle: normalizedTitle ?? this.normalizedTitle,
      sortTitle: sortTitle ?? this.sortTitle,
      normalizedSortTitle: normalizedSortTitle ?? this.normalizedSortTitle,
      coreSeriesId: coreSeriesId ?? this.coreSeriesId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mediaKind.present) {
      map['media_kind'] = Variable<String>(mediaKind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (normalizedTitle.present) {
      map['normalized_title'] = Variable<String>(normalizedTitle.value);
    }
    if (sortTitle.present) {
      map['sort_title'] = Variable<String>(sortTitle.value);
    }
    if (normalizedSortTitle.present) {
      map['normalized_sort_title'] =
          Variable<String>(normalizedSortTitle.value);
    }
    if (coreSeriesId.present) {
      map['core_series_id'] = Variable<String>(coreSeriesId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SerialAuthorityCacheCompanion(')
          ..write('id: $id, ')
          ..write('mediaKind: $mediaKind, ')
          ..write('title: $title, ')
          ..write('normalizedTitle: $normalizedTitle, ')
          ..write('sortTitle: $sortTitle, ')
          ..write('normalizedSortTitle: $normalizedSortTitle, ')
          ..write('coreSeriesId: $coreSeriesId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProviderAccountsCacheTable extends ProviderAccountsCache
    with TableInfo<$ProviderAccountsCacheTable, ProviderAccountsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProviderAccountsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authTypeMeta =
      const VerificationMeta('authType');
  @override
  late final GeneratedColumn<String> authType = GeneratedColumn<String>(
      'auth_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteAccountIdMeta =
      const VerificationMeta('remoteAccountId');
  @override
  late final GeneratedColumn<String> remoteAccountId = GeneratedColumn<String>(
      'remote_account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remoteHandleMeta =
      const VerificationMeta('remoteHandle');
  @override
  late final GeneratedColumn<String> remoteHandle = GeneratedColumn<String>(
      'remote_handle', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _connectedAtMeta =
      const VerificationMeta('connectedAt');
  @override
  late final GeneratedColumn<DateTime> connectedAt = GeneratedColumn<DateTime>(
      'connected_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncAtMeta =
      const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
      'last_sync_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _enabledCapabilitiesJsonMeta =
      const VerificationMeta('enabledCapabilitiesJson');
  @override
  late final GeneratedColumn<String> enabledCapabilitiesJson =
      GeneratedColumn<String>('enabled_capabilities_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncPolicyJsonMeta =
      const VerificationMeta('syncPolicyJson');
  @override
  late final GeneratedColumn<String> syncPolicyJson = GeneratedColumn<String>(
      'sync_policy_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        provider,
        displayName,
        authType,
        remoteAccountId,
        remoteHandle,
        username,
        avatarUrl,
        connectedAt,
        lastSyncAt,
        enabledCapabilitiesJson,
        syncPolicyJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provider_accounts_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<ProviderAccountsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('auth_type')) {
      context.handle(_authTypeMeta,
          authType.isAcceptableOrUnknown(data['auth_type']!, _authTypeMeta));
    } else if (isInserting) {
      context.missing(_authTypeMeta);
    }
    if (data.containsKey('remote_account_id')) {
      context.handle(
          _remoteAccountIdMeta,
          remoteAccountId.isAcceptableOrUnknown(
              data['remote_account_id']!, _remoteAccountIdMeta));
    }
    if (data.containsKey('remote_handle')) {
      context.handle(
          _remoteHandleMeta,
          remoteHandle.isAcceptableOrUnknown(
              data['remote_handle']!, _remoteHandleMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('connected_at')) {
      context.handle(
          _connectedAtMeta,
          connectedAt.isAcceptableOrUnknown(
              data['connected_at']!, _connectedAtMeta));
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
          _lastSyncAtMeta,
          lastSyncAt.isAcceptableOrUnknown(
              data['last_sync_at']!, _lastSyncAtMeta));
    }
    if (data.containsKey('enabled_capabilities_json')) {
      context.handle(
          _enabledCapabilitiesJsonMeta,
          enabledCapabilitiesJson.isAcceptableOrUnknown(
              data['enabled_capabilities_json']!,
              _enabledCapabilitiesJsonMeta));
    } else if (isInserting) {
      context.missing(_enabledCapabilitiesJsonMeta);
    }
    if (data.containsKey('sync_policy_json')) {
      context.handle(
          _syncPolicyJsonMeta,
          syncPolicyJson.isAcceptableOrUnknown(
              data['sync_policy_json']!, _syncPolicyJsonMeta));
    } else if (isInserting) {
      context.missing(_syncPolicyJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProviderAccountsCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderAccountsCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      authType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}auth_type'])!,
      remoteAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}remote_account_id']),
      remoteHandle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_handle']),
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username']),
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      connectedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}connected_at']),
      lastSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync_at']),
      enabledCapabilitiesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}enabled_capabilities_json'])!,
      syncPolicyJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}sync_policy_json'])!,
    );
  }

  @override
  $ProviderAccountsCacheTable createAlias(String alias) {
    return $ProviderAccountsCacheTable(attachedDatabase, alias);
  }
}

class ProviderAccountsCacheData extends DataClass
    implements Insertable<ProviderAccountsCacheData> {
  final String id;
  final String provider;
  final String displayName;
  final String authType;
  final String? remoteAccountId;
  final String? remoteHandle;
  final String? username;
  final String? avatarUrl;
  final DateTime? connectedAt;
  final DateTime? lastSyncAt;
  final String enabledCapabilitiesJson;
  final String syncPolicyJson;
  const ProviderAccountsCacheData(
      {required this.id,
      required this.provider,
      required this.displayName,
      required this.authType,
      this.remoteAccountId,
      this.remoteHandle,
      this.username,
      this.avatarUrl,
      this.connectedAt,
      this.lastSyncAt,
      required this.enabledCapabilitiesJson,
      required this.syncPolicyJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider'] = Variable<String>(provider);
    map['display_name'] = Variable<String>(displayName);
    map['auth_type'] = Variable<String>(authType);
    if (!nullToAbsent || remoteAccountId != null) {
      map['remote_account_id'] = Variable<String>(remoteAccountId);
    }
    if (!nullToAbsent || remoteHandle != null) {
      map['remote_handle'] = Variable<String>(remoteHandle);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || connectedAt != null) {
      map['connected_at'] = Variable<DateTime>(connectedAt);
    }
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    map['enabled_capabilities_json'] =
        Variable<String>(enabledCapabilitiesJson);
    map['sync_policy_json'] = Variable<String>(syncPolicyJson);
    return map;
  }

  ProviderAccountsCacheCompanion toCompanion(bool nullToAbsent) {
    return ProviderAccountsCacheCompanion(
      id: Value(id),
      provider: Value(provider),
      displayName: Value(displayName),
      authType: Value(authType),
      remoteAccountId: remoteAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteAccountId),
      remoteHandle: remoteHandle == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteHandle),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      connectedAt: connectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(connectedAt),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      enabledCapabilitiesJson: Value(enabledCapabilitiesJson),
      syncPolicyJson: Value(syncPolicyJson),
    );
  }

  factory ProviderAccountsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderAccountsCacheData(
      id: serializer.fromJson<String>(json['id']),
      provider: serializer.fromJson<String>(json['provider']),
      displayName: serializer.fromJson<String>(json['displayName']),
      authType: serializer.fromJson<String>(json['authType']),
      remoteAccountId: serializer.fromJson<String?>(json['remoteAccountId']),
      remoteHandle: serializer.fromJson<String?>(json['remoteHandle']),
      username: serializer.fromJson<String?>(json['username']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      connectedAt: serializer.fromJson<DateTime?>(json['connectedAt']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      enabledCapabilitiesJson:
          serializer.fromJson<String>(json['enabledCapabilitiesJson']),
      syncPolicyJson: serializer.fromJson<String>(json['syncPolicyJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'provider': serializer.toJson<String>(provider),
      'displayName': serializer.toJson<String>(displayName),
      'authType': serializer.toJson<String>(authType),
      'remoteAccountId': serializer.toJson<String?>(remoteAccountId),
      'remoteHandle': serializer.toJson<String?>(remoteHandle),
      'username': serializer.toJson<String?>(username),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'connectedAt': serializer.toJson<DateTime?>(connectedAt),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'enabledCapabilitiesJson':
          serializer.toJson<String>(enabledCapabilitiesJson),
      'syncPolicyJson': serializer.toJson<String>(syncPolicyJson),
    };
  }

  ProviderAccountsCacheData copyWith(
          {String? id,
          String? provider,
          String? displayName,
          String? authType,
          Value<String?> remoteAccountId = const Value.absent(),
          Value<String?> remoteHandle = const Value.absent(),
          Value<String?> username = const Value.absent(),
          Value<String?> avatarUrl = const Value.absent(),
          Value<DateTime?> connectedAt = const Value.absent(),
          Value<DateTime?> lastSyncAt = const Value.absent(),
          String? enabledCapabilitiesJson,
          String? syncPolicyJson}) =>
      ProviderAccountsCacheData(
        id: id ?? this.id,
        provider: provider ?? this.provider,
        displayName: displayName ?? this.displayName,
        authType: authType ?? this.authType,
        remoteAccountId: remoteAccountId.present
            ? remoteAccountId.value
            : this.remoteAccountId,
        remoteHandle:
            remoteHandle.present ? remoteHandle.value : this.remoteHandle,
        username: username.present ? username.value : this.username,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        connectedAt: connectedAt.present ? connectedAt.value : this.connectedAt,
        lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
        enabledCapabilitiesJson:
            enabledCapabilitiesJson ?? this.enabledCapabilitiesJson,
        syncPolicyJson: syncPolicyJson ?? this.syncPolicyJson,
      );
  ProviderAccountsCacheData copyWithCompanion(
      ProviderAccountsCacheCompanion data) {
    return ProviderAccountsCacheData(
      id: data.id.present ? data.id.value : this.id,
      provider: data.provider.present ? data.provider.value : this.provider,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      authType: data.authType.present ? data.authType.value : this.authType,
      remoteAccountId: data.remoteAccountId.present
          ? data.remoteAccountId.value
          : this.remoteAccountId,
      remoteHandle: data.remoteHandle.present
          ? data.remoteHandle.value
          : this.remoteHandle,
      username: data.username.present ? data.username.value : this.username,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      connectedAt:
          data.connectedAt.present ? data.connectedAt.value : this.connectedAt,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
      enabledCapabilitiesJson: data.enabledCapabilitiesJson.present
          ? data.enabledCapabilitiesJson.value
          : this.enabledCapabilitiesJson,
      syncPolicyJson: data.syncPolicyJson.present
          ? data.syncPolicyJson.value
          : this.syncPolicyJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProviderAccountsCacheData(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('displayName: $displayName, ')
          ..write('authType: $authType, ')
          ..write('remoteAccountId: $remoteAccountId, ')
          ..write('remoteHandle: $remoteHandle, ')
          ..write('username: $username, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('connectedAt: $connectedAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('enabledCapabilitiesJson: $enabledCapabilitiesJson, ')
          ..write('syncPolicyJson: $syncPolicyJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      provider,
      displayName,
      authType,
      remoteAccountId,
      remoteHandle,
      username,
      avatarUrl,
      connectedAt,
      lastSyncAt,
      enabledCapabilitiesJson,
      syncPolicyJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderAccountsCacheData &&
          other.id == this.id &&
          other.provider == this.provider &&
          other.displayName == this.displayName &&
          other.authType == this.authType &&
          other.remoteAccountId == this.remoteAccountId &&
          other.remoteHandle == this.remoteHandle &&
          other.username == this.username &&
          other.avatarUrl == this.avatarUrl &&
          other.connectedAt == this.connectedAt &&
          other.lastSyncAt == this.lastSyncAt &&
          other.enabledCapabilitiesJson == this.enabledCapabilitiesJson &&
          other.syncPolicyJson == this.syncPolicyJson);
}

class ProviderAccountsCacheCompanion
    extends UpdateCompanion<ProviderAccountsCacheData> {
  final Value<String> id;
  final Value<String> provider;
  final Value<String> displayName;
  final Value<String> authType;
  final Value<String?> remoteAccountId;
  final Value<String?> remoteHandle;
  final Value<String?> username;
  final Value<String?> avatarUrl;
  final Value<DateTime?> connectedAt;
  final Value<DateTime?> lastSyncAt;
  final Value<String> enabledCapabilitiesJson;
  final Value<String> syncPolicyJson;
  final Value<int> rowid;
  const ProviderAccountsCacheCompanion({
    this.id = const Value.absent(),
    this.provider = const Value.absent(),
    this.displayName = const Value.absent(),
    this.authType = const Value.absent(),
    this.remoteAccountId = const Value.absent(),
    this.remoteHandle = const Value.absent(),
    this.username = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.connectedAt = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.enabledCapabilitiesJson = const Value.absent(),
    this.syncPolicyJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProviderAccountsCacheCompanion.insert({
    required String id,
    required String provider,
    required String displayName,
    required String authType,
    this.remoteAccountId = const Value.absent(),
    this.remoteHandle = const Value.absent(),
    this.username = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.connectedAt = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    required String enabledCapabilitiesJson,
    required String syncPolicyJson,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        provider = Value(provider),
        displayName = Value(displayName),
        authType = Value(authType),
        enabledCapabilitiesJson = Value(enabledCapabilitiesJson),
        syncPolicyJson = Value(syncPolicyJson);
  static Insertable<ProviderAccountsCacheData> custom({
    Expression<String>? id,
    Expression<String>? provider,
    Expression<String>? displayName,
    Expression<String>? authType,
    Expression<String>? remoteAccountId,
    Expression<String>? remoteHandle,
    Expression<String>? username,
    Expression<String>? avatarUrl,
    Expression<DateTime>? connectedAt,
    Expression<DateTime>? lastSyncAt,
    Expression<String>? enabledCapabilitiesJson,
    Expression<String>? syncPolicyJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (provider != null) 'provider': provider,
      if (displayName != null) 'display_name': displayName,
      if (authType != null) 'auth_type': authType,
      if (remoteAccountId != null) 'remote_account_id': remoteAccountId,
      if (remoteHandle != null) 'remote_handle': remoteHandle,
      if (username != null) 'username': username,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (connectedAt != null) 'connected_at': connectedAt,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (enabledCapabilitiesJson != null)
        'enabled_capabilities_json': enabledCapabilitiesJson,
      if (syncPolicyJson != null) 'sync_policy_json': syncPolicyJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProviderAccountsCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? provider,
      Value<String>? displayName,
      Value<String>? authType,
      Value<String?>? remoteAccountId,
      Value<String?>? remoteHandle,
      Value<String?>? username,
      Value<String?>? avatarUrl,
      Value<DateTime?>? connectedAt,
      Value<DateTime?>? lastSyncAt,
      Value<String>? enabledCapabilitiesJson,
      Value<String>? syncPolicyJson,
      Value<int>? rowid}) {
    return ProviderAccountsCacheCompanion(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      displayName: displayName ?? this.displayName,
      authType: authType ?? this.authType,
      remoteAccountId: remoteAccountId ?? this.remoteAccountId,
      remoteHandle: remoteHandle ?? this.remoteHandle,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      connectedAt: connectedAt ?? this.connectedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      enabledCapabilitiesJson:
          enabledCapabilitiesJson ?? this.enabledCapabilitiesJson,
      syncPolicyJson: syncPolicyJson ?? this.syncPolicyJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (authType.present) {
      map['auth_type'] = Variable<String>(authType.value);
    }
    if (remoteAccountId.present) {
      map['remote_account_id'] = Variable<String>(remoteAccountId.value);
    }
    if (remoteHandle.present) {
      map['remote_handle'] = Variable<String>(remoteHandle.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (connectedAt.present) {
      map['connected_at'] = Variable<DateTime>(connectedAt.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (enabledCapabilitiesJson.present) {
      map['enabled_capabilities_json'] =
          Variable<String>(enabledCapabilitiesJson.value);
    }
    if (syncPolicyJson.present) {
      map['sync_policy_json'] = Variable<String>(syncPolicyJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProviderAccountsCacheCompanion(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('displayName: $displayName, ')
          ..write('authType: $authType, ')
          ..write('remoteAccountId: $remoteAccountId, ')
          ..write('remoteHandle: $remoteHandle, ')
          ..write('username: $username, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('connectedAt: $connectedAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('enabledCapabilitiesJson: $enabledCapabilitiesJson, ')
          ..write('syncPolicyJson: $syncPolicyJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProviderItemLinksCacheTable extends ProviderItemLinksCache
    with TableInfo<$ProviderItemLinksCacheTable, ProviderItemLinksCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProviderItemLinksCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteItemIdMeta =
      const VerificationMeta('remoteItemId');
  @override
  late final GeneratedColumn<String> remoteItemId = GeneratedColumn<String>(
      'remote_item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteEntryIdMeta =
      const VerificationMeta('remoteEntryId');
  @override
  late final GeneratedColumn<String> remoteEntryId = GeneratedColumn<String>(
      'remote_entry_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localEntityRefJsonMeta =
      const VerificationMeta('localEntityRefJson');
  @override
  late final GeneratedColumn<String> localEntityRefJson =
      GeneratedColumn<String>('local_entity_ref_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _baseSnapshotJsonMeta =
      const VerificationMeta('baseSnapshotJson');
  @override
  late final GeneratedColumn<String> baseSnapshotJson = GeneratedColumn<String>(
      'base_snapshot_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastPulledAtMeta =
      const VerificationMeta('lastPulledAt');
  @override
  late final GeneratedColumn<DateTime> lastPulledAt = GeneratedColumn<DateTime>(
      'last_pulled_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastPushedAtMeta =
      const VerificationMeta('lastPushedAt');
  @override
  late final GeneratedColumn<DateTime> lastPushedAt = GeneratedColumn<DateTime>(
      'last_pushed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _remoteRevisionMeta =
      const VerificationMeta('remoteRevision');
  @override
  late final GeneratedColumn<String> remoteRevision = GeneratedColumn<String>(
      'remote_revision', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        accountId,
        provider,
        remoteItemId,
        remoteEntryId,
        localEntityRefJson,
        baseSnapshotJson,
        lastPulledAt,
        lastPushedAt,
        remoteRevision,
        metadataJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provider_item_links_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<ProviderItemLinksCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('remote_item_id')) {
      context.handle(
          _remoteItemIdMeta,
          remoteItemId.isAcceptableOrUnknown(
              data['remote_item_id']!, _remoteItemIdMeta));
    } else if (isInserting) {
      context.missing(_remoteItemIdMeta);
    }
    if (data.containsKey('remote_entry_id')) {
      context.handle(
          _remoteEntryIdMeta,
          remoteEntryId.isAcceptableOrUnknown(
              data['remote_entry_id']!, _remoteEntryIdMeta));
    }
    if (data.containsKey('local_entity_ref_json')) {
      context.handle(
          _localEntityRefJsonMeta,
          localEntityRefJson.isAcceptableOrUnknown(
              data['local_entity_ref_json']!, _localEntityRefJsonMeta));
    } else if (isInserting) {
      context.missing(_localEntityRefJsonMeta);
    }
    if (data.containsKey('base_snapshot_json')) {
      context.handle(
          _baseSnapshotJsonMeta,
          baseSnapshotJson.isAcceptableOrUnknown(
              data['base_snapshot_json']!, _baseSnapshotJsonMeta));
    }
    if (data.containsKey('last_pulled_at')) {
      context.handle(
          _lastPulledAtMeta,
          lastPulledAt.isAcceptableOrUnknown(
              data['last_pulled_at']!, _lastPulledAtMeta));
    }
    if (data.containsKey('last_pushed_at')) {
      context.handle(
          _lastPushedAtMeta,
          lastPushedAt.isAcceptableOrUnknown(
              data['last_pushed_at']!, _lastPushedAtMeta));
    }
    if (data.containsKey('remote_revision')) {
      context.handle(
          _remoteRevisionMeta,
          remoteRevision.isAcceptableOrUnknown(
              data['remote_revision']!, _remoteRevisionMeta));
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    } else if (isInserting) {
      context.missing(_metadataJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, remoteItemId};
  @override
  ProviderItemLinksCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderItemLinksCacheData(
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider'])!,
      remoteItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_item_id'])!,
      remoteEntryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_entry_id']),
      localEntityRefJson: attachedDatabase.typeMapping.read(DriftSqlType.string,
          data['${effectivePrefix}local_entity_ref_json'])!,
      baseSnapshotJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}base_snapshot_json']),
      lastPulledAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_pulled_at']),
      lastPushedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_pushed_at']),
      remoteRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_revision']),
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
    );
  }

  @override
  $ProviderItemLinksCacheTable createAlias(String alias) {
    return $ProviderItemLinksCacheTable(attachedDatabase, alias);
  }
}

class ProviderItemLinksCacheData extends DataClass
    implements Insertable<ProviderItemLinksCacheData> {
  final String accountId;
  final String provider;
  final String remoteItemId;
  final String? remoteEntryId;
  final String localEntityRefJson;
  final String? baseSnapshotJson;
  final DateTime? lastPulledAt;
  final DateTime? lastPushedAt;
  final String? remoteRevision;
  final String metadataJson;
  const ProviderItemLinksCacheData(
      {required this.accountId,
      required this.provider,
      required this.remoteItemId,
      this.remoteEntryId,
      required this.localEntityRefJson,
      this.baseSnapshotJson,
      this.lastPulledAt,
      this.lastPushedAt,
      this.remoteRevision,
      required this.metadataJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['provider'] = Variable<String>(provider);
    map['remote_item_id'] = Variable<String>(remoteItemId);
    if (!nullToAbsent || remoteEntryId != null) {
      map['remote_entry_id'] = Variable<String>(remoteEntryId);
    }
    map['local_entity_ref_json'] = Variable<String>(localEntityRefJson);
    if (!nullToAbsent || baseSnapshotJson != null) {
      map['base_snapshot_json'] = Variable<String>(baseSnapshotJson);
    }
    if (!nullToAbsent || lastPulledAt != null) {
      map['last_pulled_at'] = Variable<DateTime>(lastPulledAt);
    }
    if (!nullToAbsent || lastPushedAt != null) {
      map['last_pushed_at'] = Variable<DateTime>(lastPushedAt);
    }
    if (!nullToAbsent || remoteRevision != null) {
      map['remote_revision'] = Variable<String>(remoteRevision);
    }
    map['metadata_json'] = Variable<String>(metadataJson);
    return map;
  }

  ProviderItemLinksCacheCompanion toCompanion(bool nullToAbsent) {
    return ProviderItemLinksCacheCompanion(
      accountId: Value(accountId),
      provider: Value(provider),
      remoteItemId: Value(remoteItemId),
      remoteEntryId: remoteEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteEntryId),
      localEntityRefJson: Value(localEntityRefJson),
      baseSnapshotJson: baseSnapshotJson == null && nullToAbsent
          ? const Value.absent()
          : Value(baseSnapshotJson),
      lastPulledAt: lastPulledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPulledAt),
      lastPushedAt: lastPushedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPushedAt),
      remoteRevision: remoteRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteRevision),
      metadataJson: Value(metadataJson),
    );
  }

  factory ProviderItemLinksCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderItemLinksCacheData(
      accountId: serializer.fromJson<String>(json['accountId']),
      provider: serializer.fromJson<String>(json['provider']),
      remoteItemId: serializer.fromJson<String>(json['remoteItemId']),
      remoteEntryId: serializer.fromJson<String?>(json['remoteEntryId']),
      localEntityRefJson:
          serializer.fromJson<String>(json['localEntityRefJson']),
      baseSnapshotJson: serializer.fromJson<String?>(json['baseSnapshotJson']),
      lastPulledAt: serializer.fromJson<DateTime?>(json['lastPulledAt']),
      lastPushedAt: serializer.fromJson<DateTime?>(json['lastPushedAt']),
      remoteRevision: serializer.fromJson<String?>(json['remoteRevision']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'provider': serializer.toJson<String>(provider),
      'remoteItemId': serializer.toJson<String>(remoteItemId),
      'remoteEntryId': serializer.toJson<String?>(remoteEntryId),
      'localEntityRefJson': serializer.toJson<String>(localEntityRefJson),
      'baseSnapshotJson': serializer.toJson<String?>(baseSnapshotJson),
      'lastPulledAt': serializer.toJson<DateTime?>(lastPulledAt),
      'lastPushedAt': serializer.toJson<DateTime?>(lastPushedAt),
      'remoteRevision': serializer.toJson<String?>(remoteRevision),
      'metadataJson': serializer.toJson<String>(metadataJson),
    };
  }

  ProviderItemLinksCacheData copyWith(
          {String? accountId,
          String? provider,
          String? remoteItemId,
          Value<String?> remoteEntryId = const Value.absent(),
          String? localEntityRefJson,
          Value<String?> baseSnapshotJson = const Value.absent(),
          Value<DateTime?> lastPulledAt = const Value.absent(),
          Value<DateTime?> lastPushedAt = const Value.absent(),
          Value<String?> remoteRevision = const Value.absent(),
          String? metadataJson}) =>
      ProviderItemLinksCacheData(
        accountId: accountId ?? this.accountId,
        provider: provider ?? this.provider,
        remoteItemId: remoteItemId ?? this.remoteItemId,
        remoteEntryId:
            remoteEntryId.present ? remoteEntryId.value : this.remoteEntryId,
        localEntityRefJson: localEntityRefJson ?? this.localEntityRefJson,
        baseSnapshotJson: baseSnapshotJson.present
            ? baseSnapshotJson.value
            : this.baseSnapshotJson,
        lastPulledAt:
            lastPulledAt.present ? lastPulledAt.value : this.lastPulledAt,
        lastPushedAt:
            lastPushedAt.present ? lastPushedAt.value : this.lastPushedAt,
        remoteRevision:
            remoteRevision.present ? remoteRevision.value : this.remoteRevision,
        metadataJson: metadataJson ?? this.metadataJson,
      );
  ProviderItemLinksCacheData copyWithCompanion(
      ProviderItemLinksCacheCompanion data) {
    return ProviderItemLinksCacheData(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      provider: data.provider.present ? data.provider.value : this.provider,
      remoteItemId: data.remoteItemId.present
          ? data.remoteItemId.value
          : this.remoteItemId,
      remoteEntryId: data.remoteEntryId.present
          ? data.remoteEntryId.value
          : this.remoteEntryId,
      localEntityRefJson: data.localEntityRefJson.present
          ? data.localEntityRefJson.value
          : this.localEntityRefJson,
      baseSnapshotJson: data.baseSnapshotJson.present
          ? data.baseSnapshotJson.value
          : this.baseSnapshotJson,
      lastPulledAt: data.lastPulledAt.present
          ? data.lastPulledAt.value
          : this.lastPulledAt,
      lastPushedAt: data.lastPushedAt.present
          ? data.lastPushedAt.value
          : this.lastPushedAt,
      remoteRevision: data.remoteRevision.present
          ? data.remoteRevision.value
          : this.remoteRevision,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProviderItemLinksCacheData(')
          ..write('accountId: $accountId, ')
          ..write('provider: $provider, ')
          ..write('remoteItemId: $remoteItemId, ')
          ..write('remoteEntryId: $remoteEntryId, ')
          ..write('localEntityRefJson: $localEntityRefJson, ')
          ..write('baseSnapshotJson: $baseSnapshotJson, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('lastPushedAt: $lastPushedAt, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      accountId,
      provider,
      remoteItemId,
      remoteEntryId,
      localEntityRefJson,
      baseSnapshotJson,
      lastPulledAt,
      lastPushedAt,
      remoteRevision,
      metadataJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderItemLinksCacheData &&
          other.accountId == this.accountId &&
          other.provider == this.provider &&
          other.remoteItemId == this.remoteItemId &&
          other.remoteEntryId == this.remoteEntryId &&
          other.localEntityRefJson == this.localEntityRefJson &&
          other.baseSnapshotJson == this.baseSnapshotJson &&
          other.lastPulledAt == this.lastPulledAt &&
          other.lastPushedAt == this.lastPushedAt &&
          other.remoteRevision == this.remoteRevision &&
          other.metadataJson == this.metadataJson);
}

class ProviderItemLinksCacheCompanion
    extends UpdateCompanion<ProviderItemLinksCacheData> {
  final Value<String> accountId;
  final Value<String> provider;
  final Value<String> remoteItemId;
  final Value<String?> remoteEntryId;
  final Value<String> localEntityRefJson;
  final Value<String?> baseSnapshotJson;
  final Value<DateTime?> lastPulledAt;
  final Value<DateTime?> lastPushedAt;
  final Value<String?> remoteRevision;
  final Value<String> metadataJson;
  final Value<int> rowid;
  const ProviderItemLinksCacheCompanion({
    this.accountId = const Value.absent(),
    this.provider = const Value.absent(),
    this.remoteItemId = const Value.absent(),
    this.remoteEntryId = const Value.absent(),
    this.localEntityRefJson = const Value.absent(),
    this.baseSnapshotJson = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.lastPushedAt = const Value.absent(),
    this.remoteRevision = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProviderItemLinksCacheCompanion.insert({
    required String accountId,
    required String provider,
    required String remoteItemId,
    this.remoteEntryId = const Value.absent(),
    required String localEntityRefJson,
    this.baseSnapshotJson = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.lastPushedAt = const Value.absent(),
    this.remoteRevision = const Value.absent(),
    required String metadataJson,
    this.rowid = const Value.absent(),
  })  : accountId = Value(accountId),
        provider = Value(provider),
        remoteItemId = Value(remoteItemId),
        localEntityRefJson = Value(localEntityRefJson),
        metadataJson = Value(metadataJson);
  static Insertable<ProviderItemLinksCacheData> custom({
    Expression<String>? accountId,
    Expression<String>? provider,
    Expression<String>? remoteItemId,
    Expression<String>? remoteEntryId,
    Expression<String>? localEntityRefJson,
    Expression<String>? baseSnapshotJson,
    Expression<DateTime>? lastPulledAt,
    Expression<DateTime>? lastPushedAt,
    Expression<String>? remoteRevision,
    Expression<String>? metadataJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (provider != null) 'provider': provider,
      if (remoteItemId != null) 'remote_item_id': remoteItemId,
      if (remoteEntryId != null) 'remote_entry_id': remoteEntryId,
      if (localEntityRefJson != null)
        'local_entity_ref_json': localEntityRefJson,
      if (baseSnapshotJson != null) 'base_snapshot_json': baseSnapshotJson,
      if (lastPulledAt != null) 'last_pulled_at': lastPulledAt,
      if (lastPushedAt != null) 'last_pushed_at': lastPushedAt,
      if (remoteRevision != null) 'remote_revision': remoteRevision,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProviderItemLinksCacheCompanion copyWith(
      {Value<String>? accountId,
      Value<String>? provider,
      Value<String>? remoteItemId,
      Value<String?>? remoteEntryId,
      Value<String>? localEntityRefJson,
      Value<String?>? baseSnapshotJson,
      Value<DateTime?>? lastPulledAt,
      Value<DateTime?>? lastPushedAt,
      Value<String?>? remoteRevision,
      Value<String>? metadataJson,
      Value<int>? rowid}) {
    return ProviderItemLinksCacheCompanion(
      accountId: accountId ?? this.accountId,
      provider: provider ?? this.provider,
      remoteItemId: remoteItemId ?? this.remoteItemId,
      remoteEntryId: remoteEntryId ?? this.remoteEntryId,
      localEntityRefJson: localEntityRefJson ?? this.localEntityRefJson,
      baseSnapshotJson: baseSnapshotJson ?? this.baseSnapshotJson,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      lastPushedAt: lastPushedAt ?? this.lastPushedAt,
      remoteRevision: remoteRevision ?? this.remoteRevision,
      metadataJson: metadataJson ?? this.metadataJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (remoteItemId.present) {
      map['remote_item_id'] = Variable<String>(remoteItemId.value);
    }
    if (remoteEntryId.present) {
      map['remote_entry_id'] = Variable<String>(remoteEntryId.value);
    }
    if (localEntityRefJson.present) {
      map['local_entity_ref_json'] = Variable<String>(localEntityRefJson.value);
    }
    if (baseSnapshotJson.present) {
      map['base_snapshot_json'] = Variable<String>(baseSnapshotJson.value);
    }
    if (lastPulledAt.present) {
      map['last_pulled_at'] = Variable<DateTime>(lastPulledAt.value);
    }
    if (lastPushedAt.present) {
      map['last_pushed_at'] = Variable<DateTime>(lastPushedAt.value);
    }
    if (remoteRevision.present) {
      map['remote_revision'] = Variable<String>(remoteRevision.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProviderItemLinksCacheCompanion(')
          ..write('accountId: $accountId, ')
          ..write('provider: $provider, ')
          ..write('remoteItemId: $remoteItemId, ')
          ..write('remoteEntryId: $remoteEntryId, ')
          ..write('localEntityRefJson: $localEntityRefJson, ')
          ..write('baseSnapshotJson: $baseSnapshotJson, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('lastPushedAt: $lastPushedAt, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ComicMediaRowsTable extends ComicMediaRows
    with TableInfo<$ComicMediaRowsTable, ComicMediaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComicMediaRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortTitleMeta =
      const VerificationMeta('sortTitle');
  @override
  late final GeneratedColumn<String> sortTitle = GeneratedColumn<String>(
      'sort_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seriesTitleMeta =
      const VerificationMeta('seriesTitle');
  @override
  late final GeneratedColumn<String> seriesTitle = GeneratedColumn<String>(
      'series_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _issueNumberMeta =
      const VerificationMeta('issueNumber');
  @override
  late final GeneratedColumn<String> issueNumber = GeneratedColumn<String>(
      'issue_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _publisherMeta =
      const VerificationMeta('publisher');
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
      'publisher', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imprintMeta =
      const VerificationMeta('imprint');
  @override
  late final GeneratedColumn<String> imprint = GeneratedColumn<String>(
      'imprint', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _releaseDateMeta =
      const VerificationMeta('releaseDate');
  @override
  late final GeneratedColumn<DateTime> releaseDate = GeneratedColumn<DateTime>(
      'release_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _coverDateMeta =
      const VerificationMeta('coverDate');
  @override
  late final GeneratedColumn<DateTime> coverDate = GeneratedColumn<DateTime>(
      'cover_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _pageCountMeta =
      const VerificationMeta('pageCount');
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
      'page_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _countryMeta =
      const VerificationMeta('country');
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
      'country', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('US'));
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  static const VerificationMeta _ageRatingMeta =
      const VerificationMeta('ageRating');
  @override
  late final GeneratedColumn<String> ageRating = GeneratedColumn<String>(
      'age_rating', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _crossoverMeta =
      const VerificationMeta('crossover');
  @override
  late final GeneratedColumn<String> crossover = GeneratedColumn<String>(
      'crossover', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _synopsisMeta =
      const VerificationMeta('synopsis');
  @override
  late final GeneratedColumn<String> synopsis = GeneratedColumn<String>(
      'synopsis', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _genresJsonMeta =
      const VerificationMeta('genresJson');
  @override
  late final GeneratedColumn<String> genresJson = GeneratedColumn<String>(
      'genres_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _searchAliasesJsonMeta =
      const VerificationMeta('searchAliasesJson');
  @override
  late final GeneratedColumn<String> searchAliasesJson =
      GeneratedColumn<String>('search_aliases_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _writersJsonMeta =
      const VerificationMeta('writersJson');
  @override
  late final GeneratedColumn<String> writersJson = GeneratedColumn<String>(
      'writers_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _artistsJsonMeta =
      const VerificationMeta('artistsJson');
  @override
  late final GeneratedColumn<String> artistsJson = GeneratedColumn<String>(
      'artists_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _inkersJsonMeta =
      const VerificationMeta('inkersJson');
  @override
  late final GeneratedColumn<String> inkersJson = GeneratedColumn<String>(
      'inkers_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _coloristsJsonMeta =
      const VerificationMeta('coloristsJson');
  @override
  late final GeneratedColumn<String> coloristsJson = GeneratedColumn<String>(
      'colorists_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _letterersJsonMeta =
      const VerificationMeta('letterersJson');
  @override
  late final GeneratedColumn<String> letterersJson = GeneratedColumn<String>(
      'letterers_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _editorsJsonMeta =
      const VerificationMeta('editorsJson');
  @override
  late final GeneratedColumn<String> editorsJson = GeneratedColumn<String>(
      'editors_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _coverArtistsJsonMeta =
      const VerificationMeta('coverArtistsJson');
  @override
  late final GeneratedColumn<String> coverArtistsJson = GeneratedColumn<String>(
      'cover_artists_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _creatorCreditsJsonMeta =
      const VerificationMeta('creatorCreditsJson');
  @override
  late final GeneratedColumn<String> creatorCreditsJson =
      GeneratedColumn<String>('creator_credits_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _charactersJsonMeta =
      const VerificationMeta('charactersJson');
  @override
  late final GeneratedColumn<String> charactersJson = GeneratedColumn<String>(
      'characters_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _characterDetailsJsonMeta =
      const VerificationMeta('characterDetailsJson');
  @override
  late final GeneratedColumn<String> characterDetailsJson =
      GeneratedColumn<String>('character_details_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _creatorsJsonMeta =
      const VerificationMeta('creatorsJson');
  @override
  late final GeneratedColumn<String> creatorsJson = GeneratedColumn<String>(
      'creators_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _storyArcsJsonMeta =
      const VerificationMeta('storyArcsJson');
  @override
  late final GeneratedColumn<String> storyArcsJson = GeneratedColumn<String>(
      'story_arcs_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _keyEventsJsonMeta =
      const VerificationMeta('keyEventsJson');
  @override
  late final GeneratedColumn<String> keyEventsJson = GeneratedColumn<String>(
      'key_events_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _isKeyComicMeta =
      const VerificationMeta('isKeyComic');
  @override
  late final GeneratedColumn<bool> isKeyComic = GeneratedColumn<bool>(
      'is_key_comic', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_key_comic" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _keyReasonMeta =
      const VerificationMeta('keyReason');
  @override
  late final GeneratedColumn<String> keyReason = GeneratedColumn<String>(
      'key_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantMeta =
      const VerificationMeta('variant');
  @override
  late final GeneratedColumn<String> variant = GeneratedColumn<String>(
      'variant', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantDescriptionMeta =
      const VerificationMeta('variantDescription');
  @override
  late final GeneratedColumn<String> variantDescription =
      GeneratedColumn<String>('variant_description', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seriesJsonMeta =
      const VerificationMeta('seriesJson');
  @override
  late final GeneratedColumn<String> seriesJson = GeneratedColumn<String>(
      'series_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _publishingJsonMeta =
      const VerificationMeta('publishingJson');
  @override
  late final GeneratedColumn<String> publishingJson = GeneratedColumn<String>(
      'publishing_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editionTitleMeta =
      const VerificationMeta('editionTitle');
  @override
  late final GeneratedColumn<String> editionTitle = GeneratedColumn<String>(
      'edition_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleExtensionMeta =
      const VerificationMeta('titleExtension');
  @override
  late final GeneratedColumn<String> titleExtension = GeneratedColumn<String>(
      'title_extension', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _physicalFormatMeta =
      const VerificationMeta('physicalFormat');
  @override
  late final GeneratedColumn<String> physicalFormat = GeneratedColumn<String>(
      'physical_format', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _physicalFormatLabelMeta =
      const VerificationMeta('physicalFormatLabel');
  @override
  late final GeneratedColumn<String> physicalFormatLabel =
      GeneratedColumn<String>('physical_format_label', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _linksJsonMeta =
      const VerificationMeta('linksJson');
  @override
  late final GeneratedColumn<String> linksJson = GeneratedColumn<String>(
      'links_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _rawPayloadJsonMeta =
      const VerificationMeta('rawPayloadJson');
  @override
  late final GeneratedColumn<String> rawPayloadJson = GeneratedColumn<String>(
      'raw_payload_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        sortTitle,
        seriesTitle,
        issueNumber,
        publisher,
        imprint,
        releaseDate,
        coverDate,
        pageCount,
        country,
        language,
        ageRating,
        crossover,
        synopsis,
        genresJson,
        searchAliasesJson,
        writersJson,
        artistsJson,
        inkersJson,
        coloristsJson,
        letterersJson,
        editorsJson,
        coverArtistsJson,
        creatorCreditsJson,
        charactersJson,
        characterDetailsJson,
        creatorsJson,
        storyArcsJson,
        keyEventsJson,
        isKeyComic,
        keyReason,
        variant,
        variantDescription,
        barcode,
        seriesJson,
        publishingJson,
        editionTitle,
        titleExtension,
        physicalFormat,
        physicalFormatLabel,
        linksJson,
        rawPayloadJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comic_media_rows';
  @override
  VerificationContext validateIntegrity(Insertable<ComicMediaRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('sort_title')) {
      context.handle(_sortTitleMeta,
          sortTitle.isAcceptableOrUnknown(data['sort_title']!, _sortTitleMeta));
    }
    if (data.containsKey('series_title')) {
      context.handle(
          _seriesTitleMeta,
          seriesTitle.isAcceptableOrUnknown(
              data['series_title']!, _seriesTitleMeta));
    }
    if (data.containsKey('issue_number')) {
      context.handle(
          _issueNumberMeta,
          issueNumber.isAcceptableOrUnknown(
              data['issue_number']!, _issueNumberMeta));
    }
    if (data.containsKey('publisher')) {
      context.handle(_publisherMeta,
          publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta));
    }
    if (data.containsKey('imprint')) {
      context.handle(_imprintMeta,
          imprint.isAcceptableOrUnknown(data['imprint']!, _imprintMeta));
    }
    if (data.containsKey('release_date')) {
      context.handle(
          _releaseDateMeta,
          releaseDate.isAcceptableOrUnknown(
              data['release_date']!, _releaseDateMeta));
    }
    if (data.containsKey('cover_date')) {
      context.handle(_coverDateMeta,
          coverDate.isAcceptableOrUnknown(data['cover_date']!, _coverDateMeta));
    }
    if (data.containsKey('page_count')) {
      context.handle(_pageCountMeta,
          pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta));
    }
    if (data.containsKey('country')) {
      context.handle(_countryMeta,
          country.isAcceptableOrUnknown(data['country']!, _countryMeta));
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('age_rating')) {
      context.handle(_ageRatingMeta,
          ageRating.isAcceptableOrUnknown(data['age_rating']!, _ageRatingMeta));
    }
    if (data.containsKey('crossover')) {
      context.handle(_crossoverMeta,
          crossover.isAcceptableOrUnknown(data['crossover']!, _crossoverMeta));
    }
    if (data.containsKey('synopsis')) {
      context.handle(_synopsisMeta,
          synopsis.isAcceptableOrUnknown(data['synopsis']!, _synopsisMeta));
    }
    if (data.containsKey('genres_json')) {
      context.handle(
          _genresJsonMeta,
          genresJson.isAcceptableOrUnknown(
              data['genres_json']!, _genresJsonMeta));
    }
    if (data.containsKey('search_aliases_json')) {
      context.handle(
          _searchAliasesJsonMeta,
          searchAliasesJson.isAcceptableOrUnknown(
              data['search_aliases_json']!, _searchAliasesJsonMeta));
    }
    if (data.containsKey('writers_json')) {
      context.handle(
          _writersJsonMeta,
          writersJson.isAcceptableOrUnknown(
              data['writers_json']!, _writersJsonMeta));
    }
    if (data.containsKey('artists_json')) {
      context.handle(
          _artistsJsonMeta,
          artistsJson.isAcceptableOrUnknown(
              data['artists_json']!, _artistsJsonMeta));
    }
    if (data.containsKey('inkers_json')) {
      context.handle(
          _inkersJsonMeta,
          inkersJson.isAcceptableOrUnknown(
              data['inkers_json']!, _inkersJsonMeta));
    }
    if (data.containsKey('colorists_json')) {
      context.handle(
          _coloristsJsonMeta,
          coloristsJson.isAcceptableOrUnknown(
              data['colorists_json']!, _coloristsJsonMeta));
    }
    if (data.containsKey('letterers_json')) {
      context.handle(
          _letterersJsonMeta,
          letterersJson.isAcceptableOrUnknown(
              data['letterers_json']!, _letterersJsonMeta));
    }
    if (data.containsKey('editors_json')) {
      context.handle(
          _editorsJsonMeta,
          editorsJson.isAcceptableOrUnknown(
              data['editors_json']!, _editorsJsonMeta));
    }
    if (data.containsKey('cover_artists_json')) {
      context.handle(
          _coverArtistsJsonMeta,
          coverArtistsJson.isAcceptableOrUnknown(
              data['cover_artists_json']!, _coverArtistsJsonMeta));
    }
    if (data.containsKey('creator_credits_json')) {
      context.handle(
          _creatorCreditsJsonMeta,
          creatorCreditsJson.isAcceptableOrUnknown(
              data['creator_credits_json']!, _creatorCreditsJsonMeta));
    }
    if (data.containsKey('characters_json')) {
      context.handle(
          _charactersJsonMeta,
          charactersJson.isAcceptableOrUnknown(
              data['characters_json']!, _charactersJsonMeta));
    }
    if (data.containsKey('character_details_json')) {
      context.handle(
          _characterDetailsJsonMeta,
          characterDetailsJson.isAcceptableOrUnknown(
              data['character_details_json']!, _characterDetailsJsonMeta));
    }
    if (data.containsKey('creators_json')) {
      context.handle(
          _creatorsJsonMeta,
          creatorsJson.isAcceptableOrUnknown(
              data['creators_json']!, _creatorsJsonMeta));
    }
    if (data.containsKey('story_arcs_json')) {
      context.handle(
          _storyArcsJsonMeta,
          storyArcsJson.isAcceptableOrUnknown(
              data['story_arcs_json']!, _storyArcsJsonMeta));
    }
    if (data.containsKey('key_events_json')) {
      context.handle(
          _keyEventsJsonMeta,
          keyEventsJson.isAcceptableOrUnknown(
              data['key_events_json']!, _keyEventsJsonMeta));
    }
    if (data.containsKey('is_key_comic')) {
      context.handle(
          _isKeyComicMeta,
          isKeyComic.isAcceptableOrUnknown(
              data['is_key_comic']!, _isKeyComicMeta));
    }
    if (data.containsKey('key_reason')) {
      context.handle(_keyReasonMeta,
          keyReason.isAcceptableOrUnknown(data['key_reason']!, _keyReasonMeta));
    }
    if (data.containsKey('variant')) {
      context.handle(_variantMeta,
          variant.isAcceptableOrUnknown(data['variant']!, _variantMeta));
    }
    if (data.containsKey('variant_description')) {
      context.handle(
          _variantDescriptionMeta,
          variantDescription.isAcceptableOrUnknown(
              data['variant_description']!, _variantDescriptionMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('series_json')) {
      context.handle(
          _seriesJsonMeta,
          seriesJson.isAcceptableOrUnknown(
              data['series_json']!, _seriesJsonMeta));
    }
    if (data.containsKey('publishing_json')) {
      context.handle(
          _publishingJsonMeta,
          publishingJson.isAcceptableOrUnknown(
              data['publishing_json']!, _publishingJsonMeta));
    }
    if (data.containsKey('edition_title')) {
      context.handle(
          _editionTitleMeta,
          editionTitle.isAcceptableOrUnknown(
              data['edition_title']!, _editionTitleMeta));
    }
    if (data.containsKey('title_extension')) {
      context.handle(
          _titleExtensionMeta,
          titleExtension.isAcceptableOrUnknown(
              data['title_extension']!, _titleExtensionMeta));
    }
    if (data.containsKey('physical_format')) {
      context.handle(
          _physicalFormatMeta,
          physicalFormat.isAcceptableOrUnknown(
              data['physical_format']!, _physicalFormatMeta));
    }
    if (data.containsKey('physical_format_label')) {
      context.handle(
          _physicalFormatLabelMeta,
          physicalFormatLabel.isAcceptableOrUnknown(
              data['physical_format_label']!, _physicalFormatLabelMeta));
    }
    if (data.containsKey('links_json')) {
      context.handle(_linksJsonMeta,
          linksJson.isAcceptableOrUnknown(data['links_json']!, _linksJsonMeta));
    }
    if (data.containsKey('raw_payload_json')) {
      context.handle(
          _rawPayloadJsonMeta,
          rawPayloadJson.isAcceptableOrUnknown(
              data['raw_payload_json']!, _rawPayloadJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ComicMediaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ComicMediaRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      sortTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sort_title']),
      seriesTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}series_title']),
      issueNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}issue_number']),
      publisher: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}publisher']),
      imprint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imprint']),
      releaseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}release_date']),
      coverDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cover_date']),
      pageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_count']),
      country: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      ageRating: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}age_rating']),
      crossover: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crossover']),
      synopsis: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}synopsis']),
      genresJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}genres_json'])!,
      searchAliasesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}search_aliases_json'])!,
      writersJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}writers_json'])!,
      artistsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artists_json'])!,
      inkersJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}inkers_json'])!,
      coloristsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}colorists_json'])!,
      letterersJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}letterers_json'])!,
      editorsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}editors_json'])!,
      coverArtistsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}cover_artists_json'])!,
      creatorCreditsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}creator_credits_json'])!,
      charactersJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}characters_json'])!,
      characterDetailsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}character_details_json'])!,
      creatorsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}creators_json'])!,
      storyArcsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}story_arcs_json'])!,
      keyEventsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}key_events_json'])!,
      isKeyComic: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_key_comic'])!,
      keyReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key_reason']),
      variant: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant']),
      variantDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}variant_description']),
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      seriesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}series_json']),
      publishingJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}publishing_json']),
      editionTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edition_title']),
      titleExtension: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title_extension']),
      physicalFormat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}physical_format']),
      physicalFormatLabel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}physical_format_label']),
      linksJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}links_json'])!,
      rawPayloadJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}raw_payload_json'])!,
    );
  }

  @override
  $ComicMediaRowsTable createAlias(String alias) {
    return $ComicMediaRowsTable(attachedDatabase, alias);
  }
}

class ComicMediaRow extends DataClass implements Insertable<ComicMediaRow> {
  final String id;
  final String title;
  final String? sortTitle;
  final String? seriesTitle;
  final String? issueNumber;
  final String? publisher;
  final String? imprint;
  final DateTime? releaseDate;
  final DateTime? coverDate;
  final int? pageCount;
  final String country;
  final String language;
  final String? ageRating;
  final String? crossover;
  final String? synopsis;
  final String genresJson;
  final String searchAliasesJson;
  final String writersJson;
  final String artistsJson;
  final String inkersJson;
  final String coloristsJson;
  final String letterersJson;
  final String editorsJson;
  final String coverArtistsJson;
  final String creatorCreditsJson;
  final String charactersJson;
  final String characterDetailsJson;
  final String creatorsJson;
  final String storyArcsJson;
  final String keyEventsJson;
  final bool isKeyComic;
  final String? keyReason;
  final String? variant;
  final String? variantDescription;
  final String? barcode;
  final String? seriesJson;
  final String? publishingJson;
  final String? editionTitle;
  final String? titleExtension;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String linksJson;
  final String rawPayloadJson;
  const ComicMediaRow(
      {required this.id,
      required this.title,
      this.sortTitle,
      this.seriesTitle,
      this.issueNumber,
      this.publisher,
      this.imprint,
      this.releaseDate,
      this.coverDate,
      this.pageCount,
      required this.country,
      required this.language,
      this.ageRating,
      this.crossover,
      this.synopsis,
      required this.genresJson,
      required this.searchAliasesJson,
      required this.writersJson,
      required this.artistsJson,
      required this.inkersJson,
      required this.coloristsJson,
      required this.letterersJson,
      required this.editorsJson,
      required this.coverArtistsJson,
      required this.creatorCreditsJson,
      required this.charactersJson,
      required this.characterDetailsJson,
      required this.creatorsJson,
      required this.storyArcsJson,
      required this.keyEventsJson,
      required this.isKeyComic,
      this.keyReason,
      this.variant,
      this.variantDescription,
      this.barcode,
      this.seriesJson,
      this.publishingJson,
      this.editionTitle,
      this.titleExtension,
      this.physicalFormat,
      this.physicalFormatLabel,
      required this.linksJson,
      required this.rawPayloadJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || sortTitle != null) {
      map['sort_title'] = Variable<String>(sortTitle);
    }
    if (!nullToAbsent || seriesTitle != null) {
      map['series_title'] = Variable<String>(seriesTitle);
    }
    if (!nullToAbsent || issueNumber != null) {
      map['issue_number'] = Variable<String>(issueNumber);
    }
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || imprint != null) {
      map['imprint'] = Variable<String>(imprint);
    }
    if (!nullToAbsent || releaseDate != null) {
      map['release_date'] = Variable<DateTime>(releaseDate);
    }
    if (!nullToAbsent || coverDate != null) {
      map['cover_date'] = Variable<DateTime>(coverDate);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    map['country'] = Variable<String>(country);
    map['language'] = Variable<String>(language);
    if (!nullToAbsent || ageRating != null) {
      map['age_rating'] = Variable<String>(ageRating);
    }
    if (!nullToAbsent || crossover != null) {
      map['crossover'] = Variable<String>(crossover);
    }
    if (!nullToAbsent || synopsis != null) {
      map['synopsis'] = Variable<String>(synopsis);
    }
    map['genres_json'] = Variable<String>(genresJson);
    map['search_aliases_json'] = Variable<String>(searchAliasesJson);
    map['writers_json'] = Variable<String>(writersJson);
    map['artists_json'] = Variable<String>(artistsJson);
    map['inkers_json'] = Variable<String>(inkersJson);
    map['colorists_json'] = Variable<String>(coloristsJson);
    map['letterers_json'] = Variable<String>(letterersJson);
    map['editors_json'] = Variable<String>(editorsJson);
    map['cover_artists_json'] = Variable<String>(coverArtistsJson);
    map['creator_credits_json'] = Variable<String>(creatorCreditsJson);
    map['characters_json'] = Variable<String>(charactersJson);
    map['character_details_json'] = Variable<String>(characterDetailsJson);
    map['creators_json'] = Variable<String>(creatorsJson);
    map['story_arcs_json'] = Variable<String>(storyArcsJson);
    map['key_events_json'] = Variable<String>(keyEventsJson);
    map['is_key_comic'] = Variable<bool>(isKeyComic);
    if (!nullToAbsent || keyReason != null) {
      map['key_reason'] = Variable<String>(keyReason);
    }
    if (!nullToAbsent || variant != null) {
      map['variant'] = Variable<String>(variant);
    }
    if (!nullToAbsent || variantDescription != null) {
      map['variant_description'] = Variable<String>(variantDescription);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || seriesJson != null) {
      map['series_json'] = Variable<String>(seriesJson);
    }
    if (!nullToAbsent || publishingJson != null) {
      map['publishing_json'] = Variable<String>(publishingJson);
    }
    if (!nullToAbsent || editionTitle != null) {
      map['edition_title'] = Variable<String>(editionTitle);
    }
    if (!nullToAbsent || titleExtension != null) {
      map['title_extension'] = Variable<String>(titleExtension);
    }
    if (!nullToAbsent || physicalFormat != null) {
      map['physical_format'] = Variable<String>(physicalFormat);
    }
    if (!nullToAbsent || physicalFormatLabel != null) {
      map['physical_format_label'] = Variable<String>(physicalFormatLabel);
    }
    map['links_json'] = Variable<String>(linksJson);
    map['raw_payload_json'] = Variable<String>(rawPayloadJson);
    return map;
  }

  ComicMediaRowsCompanion toCompanion(bool nullToAbsent) {
    return ComicMediaRowsCompanion(
      id: Value(id),
      title: Value(title),
      sortTitle: sortTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(sortTitle),
      seriesTitle: seriesTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesTitle),
      issueNumber: issueNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(issueNumber),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      imprint: imprint == null && nullToAbsent
          ? const Value.absent()
          : Value(imprint),
      releaseDate: releaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseDate),
      coverDate: coverDate == null && nullToAbsent
          ? const Value.absent()
          : Value(coverDate),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      country: Value(country),
      language: Value(language),
      ageRating: ageRating == null && nullToAbsent
          ? const Value.absent()
          : Value(ageRating),
      crossover: crossover == null && nullToAbsent
          ? const Value.absent()
          : Value(crossover),
      synopsis: synopsis == null && nullToAbsent
          ? const Value.absent()
          : Value(synopsis),
      genresJson: Value(genresJson),
      searchAliasesJson: Value(searchAliasesJson),
      writersJson: Value(writersJson),
      artistsJson: Value(artistsJson),
      inkersJson: Value(inkersJson),
      coloristsJson: Value(coloristsJson),
      letterersJson: Value(letterersJson),
      editorsJson: Value(editorsJson),
      coverArtistsJson: Value(coverArtistsJson),
      creatorCreditsJson: Value(creatorCreditsJson),
      charactersJson: Value(charactersJson),
      characterDetailsJson: Value(characterDetailsJson),
      creatorsJson: Value(creatorsJson),
      storyArcsJson: Value(storyArcsJson),
      keyEventsJson: Value(keyEventsJson),
      isKeyComic: Value(isKeyComic),
      keyReason: keyReason == null && nullToAbsent
          ? const Value.absent()
          : Value(keyReason),
      variant: variant == null && nullToAbsent
          ? const Value.absent()
          : Value(variant),
      variantDescription: variantDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(variantDescription),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      seriesJson: seriesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesJson),
      publishingJson: publishingJson == null && nullToAbsent
          ? const Value.absent()
          : Value(publishingJson),
      editionTitle: editionTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(editionTitle),
      titleExtension: titleExtension == null && nullToAbsent
          ? const Value.absent()
          : Value(titleExtension),
      physicalFormat: physicalFormat == null && nullToAbsent
          ? const Value.absent()
          : Value(physicalFormat),
      physicalFormatLabel: physicalFormatLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(physicalFormatLabel),
      linksJson: Value(linksJson),
      rawPayloadJson: Value(rawPayloadJson),
    );
  }

  factory ComicMediaRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ComicMediaRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      sortTitle: serializer.fromJson<String?>(json['sortTitle']),
      seriesTitle: serializer.fromJson<String?>(json['seriesTitle']),
      issueNumber: serializer.fromJson<String?>(json['issueNumber']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      imprint: serializer.fromJson<String?>(json['imprint']),
      releaseDate: serializer.fromJson<DateTime?>(json['releaseDate']),
      coverDate: serializer.fromJson<DateTime?>(json['coverDate']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      country: serializer.fromJson<String>(json['country']),
      language: serializer.fromJson<String>(json['language']),
      ageRating: serializer.fromJson<String?>(json['ageRating']),
      crossover: serializer.fromJson<String?>(json['crossover']),
      synopsis: serializer.fromJson<String?>(json['synopsis']),
      genresJson: serializer.fromJson<String>(json['genresJson']),
      searchAliasesJson: serializer.fromJson<String>(json['searchAliasesJson']),
      writersJson: serializer.fromJson<String>(json['writersJson']),
      artistsJson: serializer.fromJson<String>(json['artistsJson']),
      inkersJson: serializer.fromJson<String>(json['inkersJson']),
      coloristsJson: serializer.fromJson<String>(json['coloristsJson']),
      letterersJson: serializer.fromJson<String>(json['letterersJson']),
      editorsJson: serializer.fromJson<String>(json['editorsJson']),
      coverArtistsJson: serializer.fromJson<String>(json['coverArtistsJson']),
      creatorCreditsJson:
          serializer.fromJson<String>(json['creatorCreditsJson']),
      charactersJson: serializer.fromJson<String>(json['charactersJson']),
      characterDetailsJson:
          serializer.fromJson<String>(json['characterDetailsJson']),
      creatorsJson: serializer.fromJson<String>(json['creatorsJson']),
      storyArcsJson: serializer.fromJson<String>(json['storyArcsJson']),
      keyEventsJson: serializer.fromJson<String>(json['keyEventsJson']),
      isKeyComic: serializer.fromJson<bool>(json['isKeyComic']),
      keyReason: serializer.fromJson<String?>(json['keyReason']),
      variant: serializer.fromJson<String?>(json['variant']),
      variantDescription:
          serializer.fromJson<String?>(json['variantDescription']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      seriesJson: serializer.fromJson<String?>(json['seriesJson']),
      publishingJson: serializer.fromJson<String?>(json['publishingJson']),
      editionTitle: serializer.fromJson<String?>(json['editionTitle']),
      titleExtension: serializer.fromJson<String?>(json['titleExtension']),
      physicalFormat: serializer.fromJson<String?>(json['physicalFormat']),
      physicalFormatLabel:
          serializer.fromJson<String?>(json['physicalFormatLabel']),
      linksJson: serializer.fromJson<String>(json['linksJson']),
      rawPayloadJson: serializer.fromJson<String>(json['rawPayloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'sortTitle': serializer.toJson<String?>(sortTitle),
      'seriesTitle': serializer.toJson<String?>(seriesTitle),
      'issueNumber': serializer.toJson<String?>(issueNumber),
      'publisher': serializer.toJson<String?>(publisher),
      'imprint': serializer.toJson<String?>(imprint),
      'releaseDate': serializer.toJson<DateTime?>(releaseDate),
      'coverDate': serializer.toJson<DateTime?>(coverDate),
      'pageCount': serializer.toJson<int?>(pageCount),
      'country': serializer.toJson<String>(country),
      'language': serializer.toJson<String>(language),
      'ageRating': serializer.toJson<String?>(ageRating),
      'crossover': serializer.toJson<String?>(crossover),
      'synopsis': serializer.toJson<String?>(synopsis),
      'genresJson': serializer.toJson<String>(genresJson),
      'searchAliasesJson': serializer.toJson<String>(searchAliasesJson),
      'writersJson': serializer.toJson<String>(writersJson),
      'artistsJson': serializer.toJson<String>(artistsJson),
      'inkersJson': serializer.toJson<String>(inkersJson),
      'coloristsJson': serializer.toJson<String>(coloristsJson),
      'letterersJson': serializer.toJson<String>(letterersJson),
      'editorsJson': serializer.toJson<String>(editorsJson),
      'coverArtistsJson': serializer.toJson<String>(coverArtistsJson),
      'creatorCreditsJson': serializer.toJson<String>(creatorCreditsJson),
      'charactersJson': serializer.toJson<String>(charactersJson),
      'characterDetailsJson': serializer.toJson<String>(characterDetailsJson),
      'creatorsJson': serializer.toJson<String>(creatorsJson),
      'storyArcsJson': serializer.toJson<String>(storyArcsJson),
      'keyEventsJson': serializer.toJson<String>(keyEventsJson),
      'isKeyComic': serializer.toJson<bool>(isKeyComic),
      'keyReason': serializer.toJson<String?>(keyReason),
      'variant': serializer.toJson<String?>(variant),
      'variantDescription': serializer.toJson<String?>(variantDescription),
      'barcode': serializer.toJson<String?>(barcode),
      'seriesJson': serializer.toJson<String?>(seriesJson),
      'publishingJson': serializer.toJson<String?>(publishingJson),
      'editionTitle': serializer.toJson<String?>(editionTitle),
      'titleExtension': serializer.toJson<String?>(titleExtension),
      'physicalFormat': serializer.toJson<String?>(physicalFormat),
      'physicalFormatLabel': serializer.toJson<String?>(physicalFormatLabel),
      'linksJson': serializer.toJson<String>(linksJson),
      'rawPayloadJson': serializer.toJson<String>(rawPayloadJson),
    };
  }

  ComicMediaRow copyWith(
          {String? id,
          String? title,
          Value<String?> sortTitle = const Value.absent(),
          Value<String?> seriesTitle = const Value.absent(),
          Value<String?> issueNumber = const Value.absent(),
          Value<String?> publisher = const Value.absent(),
          Value<String?> imprint = const Value.absent(),
          Value<DateTime?> releaseDate = const Value.absent(),
          Value<DateTime?> coverDate = const Value.absent(),
          Value<int?> pageCount = const Value.absent(),
          String? country,
          String? language,
          Value<String?> ageRating = const Value.absent(),
          Value<String?> crossover = const Value.absent(),
          Value<String?> synopsis = const Value.absent(),
          String? genresJson,
          String? searchAliasesJson,
          String? writersJson,
          String? artistsJson,
          String? inkersJson,
          String? coloristsJson,
          String? letterersJson,
          String? editorsJson,
          String? coverArtistsJson,
          String? creatorCreditsJson,
          String? charactersJson,
          String? characterDetailsJson,
          String? creatorsJson,
          String? storyArcsJson,
          String? keyEventsJson,
          bool? isKeyComic,
          Value<String?> keyReason = const Value.absent(),
          Value<String?> variant = const Value.absent(),
          Value<String?> variantDescription = const Value.absent(),
          Value<String?> barcode = const Value.absent(),
          Value<String?> seriesJson = const Value.absent(),
          Value<String?> publishingJson = const Value.absent(),
          Value<String?> editionTitle = const Value.absent(),
          Value<String?> titleExtension = const Value.absent(),
          Value<String?> physicalFormat = const Value.absent(),
          Value<String?> physicalFormatLabel = const Value.absent(),
          String? linksJson,
          String? rawPayloadJson}) =>
      ComicMediaRow(
        id: id ?? this.id,
        title: title ?? this.title,
        sortTitle: sortTitle.present ? sortTitle.value : this.sortTitle,
        seriesTitle: seriesTitle.present ? seriesTitle.value : this.seriesTitle,
        issueNumber: issueNumber.present ? issueNumber.value : this.issueNumber,
        publisher: publisher.present ? publisher.value : this.publisher,
        imprint: imprint.present ? imprint.value : this.imprint,
        releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
        coverDate: coverDate.present ? coverDate.value : this.coverDate,
        pageCount: pageCount.present ? pageCount.value : this.pageCount,
        country: country ?? this.country,
        language: language ?? this.language,
        ageRating: ageRating.present ? ageRating.value : this.ageRating,
        crossover: crossover.present ? crossover.value : this.crossover,
        synopsis: synopsis.present ? synopsis.value : this.synopsis,
        genresJson: genresJson ?? this.genresJson,
        searchAliasesJson: searchAliasesJson ?? this.searchAliasesJson,
        writersJson: writersJson ?? this.writersJson,
        artistsJson: artistsJson ?? this.artistsJson,
        inkersJson: inkersJson ?? this.inkersJson,
        coloristsJson: coloristsJson ?? this.coloristsJson,
        letterersJson: letterersJson ?? this.letterersJson,
        editorsJson: editorsJson ?? this.editorsJson,
        coverArtistsJson: coverArtistsJson ?? this.coverArtistsJson,
        creatorCreditsJson: creatorCreditsJson ?? this.creatorCreditsJson,
        charactersJson: charactersJson ?? this.charactersJson,
        characterDetailsJson: characterDetailsJson ?? this.characterDetailsJson,
        creatorsJson: creatorsJson ?? this.creatorsJson,
        storyArcsJson: storyArcsJson ?? this.storyArcsJson,
        keyEventsJson: keyEventsJson ?? this.keyEventsJson,
        isKeyComic: isKeyComic ?? this.isKeyComic,
        keyReason: keyReason.present ? keyReason.value : this.keyReason,
        variant: variant.present ? variant.value : this.variant,
        variantDescription: variantDescription.present
            ? variantDescription.value
            : this.variantDescription,
        barcode: barcode.present ? barcode.value : this.barcode,
        seriesJson: seriesJson.present ? seriesJson.value : this.seriesJson,
        publishingJson:
            publishingJson.present ? publishingJson.value : this.publishingJson,
        editionTitle:
            editionTitle.present ? editionTitle.value : this.editionTitle,
        titleExtension:
            titleExtension.present ? titleExtension.value : this.titleExtension,
        physicalFormat:
            physicalFormat.present ? physicalFormat.value : this.physicalFormat,
        physicalFormatLabel: physicalFormatLabel.present
            ? physicalFormatLabel.value
            : this.physicalFormatLabel,
        linksJson: linksJson ?? this.linksJson,
        rawPayloadJson: rawPayloadJson ?? this.rawPayloadJson,
      );
  ComicMediaRow copyWithCompanion(ComicMediaRowsCompanion data) {
    return ComicMediaRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      sortTitle: data.sortTitle.present ? data.sortTitle.value : this.sortTitle,
      seriesTitle:
          data.seriesTitle.present ? data.seriesTitle.value : this.seriesTitle,
      issueNumber:
          data.issueNumber.present ? data.issueNumber.value : this.issueNumber,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      imprint: data.imprint.present ? data.imprint.value : this.imprint,
      releaseDate:
          data.releaseDate.present ? data.releaseDate.value : this.releaseDate,
      coverDate: data.coverDate.present ? data.coverDate.value : this.coverDate,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      country: data.country.present ? data.country.value : this.country,
      language: data.language.present ? data.language.value : this.language,
      ageRating: data.ageRating.present ? data.ageRating.value : this.ageRating,
      crossover: data.crossover.present ? data.crossover.value : this.crossover,
      synopsis: data.synopsis.present ? data.synopsis.value : this.synopsis,
      genresJson:
          data.genresJson.present ? data.genresJson.value : this.genresJson,
      searchAliasesJson: data.searchAliasesJson.present
          ? data.searchAliasesJson.value
          : this.searchAliasesJson,
      writersJson:
          data.writersJson.present ? data.writersJson.value : this.writersJson,
      artistsJson:
          data.artistsJson.present ? data.artistsJson.value : this.artistsJson,
      inkersJson:
          data.inkersJson.present ? data.inkersJson.value : this.inkersJson,
      coloristsJson: data.coloristsJson.present
          ? data.coloristsJson.value
          : this.coloristsJson,
      letterersJson: data.letterersJson.present
          ? data.letterersJson.value
          : this.letterersJson,
      editorsJson:
          data.editorsJson.present ? data.editorsJson.value : this.editorsJson,
      coverArtistsJson: data.coverArtistsJson.present
          ? data.coverArtistsJson.value
          : this.coverArtistsJson,
      creatorCreditsJson: data.creatorCreditsJson.present
          ? data.creatorCreditsJson.value
          : this.creatorCreditsJson,
      charactersJson: data.charactersJson.present
          ? data.charactersJson.value
          : this.charactersJson,
      characterDetailsJson: data.characterDetailsJson.present
          ? data.characterDetailsJson.value
          : this.characterDetailsJson,
      creatorsJson: data.creatorsJson.present
          ? data.creatorsJson.value
          : this.creatorsJson,
      storyArcsJson: data.storyArcsJson.present
          ? data.storyArcsJson.value
          : this.storyArcsJson,
      keyEventsJson: data.keyEventsJson.present
          ? data.keyEventsJson.value
          : this.keyEventsJson,
      isKeyComic:
          data.isKeyComic.present ? data.isKeyComic.value : this.isKeyComic,
      keyReason: data.keyReason.present ? data.keyReason.value : this.keyReason,
      variant: data.variant.present ? data.variant.value : this.variant,
      variantDescription: data.variantDescription.present
          ? data.variantDescription.value
          : this.variantDescription,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      seriesJson:
          data.seriesJson.present ? data.seriesJson.value : this.seriesJson,
      publishingJson: data.publishingJson.present
          ? data.publishingJson.value
          : this.publishingJson,
      editionTitle: data.editionTitle.present
          ? data.editionTitle.value
          : this.editionTitle,
      titleExtension: data.titleExtension.present
          ? data.titleExtension.value
          : this.titleExtension,
      physicalFormat: data.physicalFormat.present
          ? data.physicalFormat.value
          : this.physicalFormat,
      physicalFormatLabel: data.physicalFormatLabel.present
          ? data.physicalFormatLabel.value
          : this.physicalFormatLabel,
      linksJson: data.linksJson.present ? data.linksJson.value : this.linksJson,
      rawPayloadJson: data.rawPayloadJson.present
          ? data.rawPayloadJson.value
          : this.rawPayloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ComicMediaRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sortTitle: $sortTitle, ')
          ..write('seriesTitle: $seriesTitle, ')
          ..write('issueNumber: $issueNumber, ')
          ..write('publisher: $publisher, ')
          ..write('imprint: $imprint, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('coverDate: $coverDate, ')
          ..write('pageCount: $pageCount, ')
          ..write('country: $country, ')
          ..write('language: $language, ')
          ..write('ageRating: $ageRating, ')
          ..write('crossover: $crossover, ')
          ..write('synopsis: $synopsis, ')
          ..write('genresJson: $genresJson, ')
          ..write('searchAliasesJson: $searchAliasesJson, ')
          ..write('writersJson: $writersJson, ')
          ..write('artistsJson: $artistsJson, ')
          ..write('inkersJson: $inkersJson, ')
          ..write('coloristsJson: $coloristsJson, ')
          ..write('letterersJson: $letterersJson, ')
          ..write('editorsJson: $editorsJson, ')
          ..write('coverArtistsJson: $coverArtistsJson, ')
          ..write('creatorCreditsJson: $creatorCreditsJson, ')
          ..write('charactersJson: $charactersJson, ')
          ..write('characterDetailsJson: $characterDetailsJson, ')
          ..write('creatorsJson: $creatorsJson, ')
          ..write('storyArcsJson: $storyArcsJson, ')
          ..write('keyEventsJson: $keyEventsJson, ')
          ..write('isKeyComic: $isKeyComic, ')
          ..write('keyReason: $keyReason, ')
          ..write('variant: $variant, ')
          ..write('variantDescription: $variantDescription, ')
          ..write('barcode: $barcode, ')
          ..write('seriesJson: $seriesJson, ')
          ..write('publishingJson: $publishingJson, ')
          ..write('editionTitle: $editionTitle, ')
          ..write('titleExtension: $titleExtension, ')
          ..write('physicalFormat: $physicalFormat, ')
          ..write('physicalFormatLabel: $physicalFormatLabel, ')
          ..write('linksJson: $linksJson, ')
          ..write('rawPayloadJson: $rawPayloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        title,
        sortTitle,
        seriesTitle,
        issueNumber,
        publisher,
        imprint,
        releaseDate,
        coverDate,
        pageCount,
        country,
        language,
        ageRating,
        crossover,
        synopsis,
        genresJson,
        searchAliasesJson,
        writersJson,
        artistsJson,
        inkersJson,
        coloristsJson,
        letterersJson,
        editorsJson,
        coverArtistsJson,
        creatorCreditsJson,
        charactersJson,
        characterDetailsJson,
        creatorsJson,
        storyArcsJson,
        keyEventsJson,
        isKeyComic,
        keyReason,
        variant,
        variantDescription,
        barcode,
        seriesJson,
        publishingJson,
        editionTitle,
        titleExtension,
        physicalFormat,
        physicalFormatLabel,
        linksJson,
        rawPayloadJson
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComicMediaRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.sortTitle == this.sortTitle &&
          other.seriesTitle == this.seriesTitle &&
          other.issueNumber == this.issueNumber &&
          other.publisher == this.publisher &&
          other.imprint == this.imprint &&
          other.releaseDate == this.releaseDate &&
          other.coverDate == this.coverDate &&
          other.pageCount == this.pageCount &&
          other.country == this.country &&
          other.language == this.language &&
          other.ageRating == this.ageRating &&
          other.crossover == this.crossover &&
          other.synopsis == this.synopsis &&
          other.genresJson == this.genresJson &&
          other.searchAliasesJson == this.searchAliasesJson &&
          other.writersJson == this.writersJson &&
          other.artistsJson == this.artistsJson &&
          other.inkersJson == this.inkersJson &&
          other.coloristsJson == this.coloristsJson &&
          other.letterersJson == this.letterersJson &&
          other.editorsJson == this.editorsJson &&
          other.coverArtistsJson == this.coverArtistsJson &&
          other.creatorCreditsJson == this.creatorCreditsJson &&
          other.charactersJson == this.charactersJson &&
          other.characterDetailsJson == this.characterDetailsJson &&
          other.creatorsJson == this.creatorsJson &&
          other.storyArcsJson == this.storyArcsJson &&
          other.keyEventsJson == this.keyEventsJson &&
          other.isKeyComic == this.isKeyComic &&
          other.keyReason == this.keyReason &&
          other.variant == this.variant &&
          other.variantDescription == this.variantDescription &&
          other.barcode == this.barcode &&
          other.seriesJson == this.seriesJson &&
          other.publishingJson == this.publishingJson &&
          other.editionTitle == this.editionTitle &&
          other.titleExtension == this.titleExtension &&
          other.physicalFormat == this.physicalFormat &&
          other.physicalFormatLabel == this.physicalFormatLabel &&
          other.linksJson == this.linksJson &&
          other.rawPayloadJson == this.rawPayloadJson);
}

class ComicMediaRowsCompanion extends UpdateCompanion<ComicMediaRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> sortTitle;
  final Value<String?> seriesTitle;
  final Value<String?> issueNumber;
  final Value<String?> publisher;
  final Value<String?> imprint;
  final Value<DateTime?> releaseDate;
  final Value<DateTime?> coverDate;
  final Value<int?> pageCount;
  final Value<String> country;
  final Value<String> language;
  final Value<String?> ageRating;
  final Value<String?> crossover;
  final Value<String?> synopsis;
  final Value<String> genresJson;
  final Value<String> searchAliasesJson;
  final Value<String> writersJson;
  final Value<String> artistsJson;
  final Value<String> inkersJson;
  final Value<String> coloristsJson;
  final Value<String> letterersJson;
  final Value<String> editorsJson;
  final Value<String> coverArtistsJson;
  final Value<String> creatorCreditsJson;
  final Value<String> charactersJson;
  final Value<String> characterDetailsJson;
  final Value<String> creatorsJson;
  final Value<String> storyArcsJson;
  final Value<String> keyEventsJson;
  final Value<bool> isKeyComic;
  final Value<String?> keyReason;
  final Value<String?> variant;
  final Value<String?> variantDescription;
  final Value<String?> barcode;
  final Value<String?> seriesJson;
  final Value<String?> publishingJson;
  final Value<String?> editionTitle;
  final Value<String?> titleExtension;
  final Value<String?> physicalFormat;
  final Value<String?> physicalFormatLabel;
  final Value<String> linksJson;
  final Value<String> rawPayloadJson;
  final Value<int> rowid;
  const ComicMediaRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.sortTitle = const Value.absent(),
    this.seriesTitle = const Value.absent(),
    this.issueNumber = const Value.absent(),
    this.publisher = const Value.absent(),
    this.imprint = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.coverDate = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.country = const Value.absent(),
    this.language = const Value.absent(),
    this.ageRating = const Value.absent(),
    this.crossover = const Value.absent(),
    this.synopsis = const Value.absent(),
    this.genresJson = const Value.absent(),
    this.searchAliasesJson = const Value.absent(),
    this.writersJson = const Value.absent(),
    this.artistsJson = const Value.absent(),
    this.inkersJson = const Value.absent(),
    this.coloristsJson = const Value.absent(),
    this.letterersJson = const Value.absent(),
    this.editorsJson = const Value.absent(),
    this.coverArtistsJson = const Value.absent(),
    this.creatorCreditsJson = const Value.absent(),
    this.charactersJson = const Value.absent(),
    this.characterDetailsJson = const Value.absent(),
    this.creatorsJson = const Value.absent(),
    this.storyArcsJson = const Value.absent(),
    this.keyEventsJson = const Value.absent(),
    this.isKeyComic = const Value.absent(),
    this.keyReason = const Value.absent(),
    this.variant = const Value.absent(),
    this.variantDescription = const Value.absent(),
    this.barcode = const Value.absent(),
    this.seriesJson = const Value.absent(),
    this.publishingJson = const Value.absent(),
    this.editionTitle = const Value.absent(),
    this.titleExtension = const Value.absent(),
    this.physicalFormat = const Value.absent(),
    this.physicalFormatLabel = const Value.absent(),
    this.linksJson = const Value.absent(),
    this.rawPayloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ComicMediaRowsCompanion.insert({
    required String id,
    required String title,
    this.sortTitle = const Value.absent(),
    this.seriesTitle = const Value.absent(),
    this.issueNumber = const Value.absent(),
    this.publisher = const Value.absent(),
    this.imprint = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.coverDate = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.country = const Value.absent(),
    this.language = const Value.absent(),
    this.ageRating = const Value.absent(),
    this.crossover = const Value.absent(),
    this.synopsis = const Value.absent(),
    this.genresJson = const Value.absent(),
    this.searchAliasesJson = const Value.absent(),
    this.writersJson = const Value.absent(),
    this.artistsJson = const Value.absent(),
    this.inkersJson = const Value.absent(),
    this.coloristsJson = const Value.absent(),
    this.letterersJson = const Value.absent(),
    this.editorsJson = const Value.absent(),
    this.coverArtistsJson = const Value.absent(),
    this.creatorCreditsJson = const Value.absent(),
    this.charactersJson = const Value.absent(),
    this.characterDetailsJson = const Value.absent(),
    this.creatorsJson = const Value.absent(),
    this.storyArcsJson = const Value.absent(),
    this.keyEventsJson = const Value.absent(),
    this.isKeyComic = const Value.absent(),
    this.keyReason = const Value.absent(),
    this.variant = const Value.absent(),
    this.variantDescription = const Value.absent(),
    this.barcode = const Value.absent(),
    this.seriesJson = const Value.absent(),
    this.publishingJson = const Value.absent(),
    this.editionTitle = const Value.absent(),
    this.titleExtension = const Value.absent(),
    this.physicalFormat = const Value.absent(),
    this.physicalFormatLabel = const Value.absent(),
    this.linksJson = const Value.absent(),
    this.rawPayloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title);
  static Insertable<ComicMediaRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? sortTitle,
    Expression<String>? seriesTitle,
    Expression<String>? issueNumber,
    Expression<String>? publisher,
    Expression<String>? imprint,
    Expression<DateTime>? releaseDate,
    Expression<DateTime>? coverDate,
    Expression<int>? pageCount,
    Expression<String>? country,
    Expression<String>? language,
    Expression<String>? ageRating,
    Expression<String>? crossover,
    Expression<String>? synopsis,
    Expression<String>? genresJson,
    Expression<String>? searchAliasesJson,
    Expression<String>? writersJson,
    Expression<String>? artistsJson,
    Expression<String>? inkersJson,
    Expression<String>? coloristsJson,
    Expression<String>? letterersJson,
    Expression<String>? editorsJson,
    Expression<String>? coverArtistsJson,
    Expression<String>? creatorCreditsJson,
    Expression<String>? charactersJson,
    Expression<String>? characterDetailsJson,
    Expression<String>? creatorsJson,
    Expression<String>? storyArcsJson,
    Expression<String>? keyEventsJson,
    Expression<bool>? isKeyComic,
    Expression<String>? keyReason,
    Expression<String>? variant,
    Expression<String>? variantDescription,
    Expression<String>? barcode,
    Expression<String>? seriesJson,
    Expression<String>? publishingJson,
    Expression<String>? editionTitle,
    Expression<String>? titleExtension,
    Expression<String>? physicalFormat,
    Expression<String>? physicalFormatLabel,
    Expression<String>? linksJson,
    Expression<String>? rawPayloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (sortTitle != null) 'sort_title': sortTitle,
      if (seriesTitle != null) 'series_title': seriesTitle,
      if (issueNumber != null) 'issue_number': issueNumber,
      if (publisher != null) 'publisher': publisher,
      if (imprint != null) 'imprint': imprint,
      if (releaseDate != null) 'release_date': releaseDate,
      if (coverDate != null) 'cover_date': coverDate,
      if (pageCount != null) 'page_count': pageCount,
      if (country != null) 'country': country,
      if (language != null) 'language': language,
      if (ageRating != null) 'age_rating': ageRating,
      if (crossover != null) 'crossover': crossover,
      if (synopsis != null) 'synopsis': synopsis,
      if (genresJson != null) 'genres_json': genresJson,
      if (searchAliasesJson != null) 'search_aliases_json': searchAliasesJson,
      if (writersJson != null) 'writers_json': writersJson,
      if (artistsJson != null) 'artists_json': artistsJson,
      if (inkersJson != null) 'inkers_json': inkersJson,
      if (coloristsJson != null) 'colorists_json': coloristsJson,
      if (letterersJson != null) 'letterers_json': letterersJson,
      if (editorsJson != null) 'editors_json': editorsJson,
      if (coverArtistsJson != null) 'cover_artists_json': coverArtistsJson,
      if (creatorCreditsJson != null)
        'creator_credits_json': creatorCreditsJson,
      if (charactersJson != null) 'characters_json': charactersJson,
      if (characterDetailsJson != null)
        'character_details_json': characterDetailsJson,
      if (creatorsJson != null) 'creators_json': creatorsJson,
      if (storyArcsJson != null) 'story_arcs_json': storyArcsJson,
      if (keyEventsJson != null) 'key_events_json': keyEventsJson,
      if (isKeyComic != null) 'is_key_comic': isKeyComic,
      if (keyReason != null) 'key_reason': keyReason,
      if (variant != null) 'variant': variant,
      if (variantDescription != null) 'variant_description': variantDescription,
      if (barcode != null) 'barcode': barcode,
      if (seriesJson != null) 'series_json': seriesJson,
      if (publishingJson != null) 'publishing_json': publishingJson,
      if (editionTitle != null) 'edition_title': editionTitle,
      if (titleExtension != null) 'title_extension': titleExtension,
      if (physicalFormat != null) 'physical_format': physicalFormat,
      if (physicalFormatLabel != null)
        'physical_format_label': physicalFormatLabel,
      if (linksJson != null) 'links_json': linksJson,
      if (rawPayloadJson != null) 'raw_payload_json': rawPayloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ComicMediaRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? sortTitle,
      Value<String?>? seriesTitle,
      Value<String?>? issueNumber,
      Value<String?>? publisher,
      Value<String?>? imprint,
      Value<DateTime?>? releaseDate,
      Value<DateTime?>? coverDate,
      Value<int?>? pageCount,
      Value<String>? country,
      Value<String>? language,
      Value<String?>? ageRating,
      Value<String?>? crossover,
      Value<String?>? synopsis,
      Value<String>? genresJson,
      Value<String>? searchAliasesJson,
      Value<String>? writersJson,
      Value<String>? artistsJson,
      Value<String>? inkersJson,
      Value<String>? coloristsJson,
      Value<String>? letterersJson,
      Value<String>? editorsJson,
      Value<String>? coverArtistsJson,
      Value<String>? creatorCreditsJson,
      Value<String>? charactersJson,
      Value<String>? characterDetailsJson,
      Value<String>? creatorsJson,
      Value<String>? storyArcsJson,
      Value<String>? keyEventsJson,
      Value<bool>? isKeyComic,
      Value<String?>? keyReason,
      Value<String?>? variant,
      Value<String?>? variantDescription,
      Value<String?>? barcode,
      Value<String?>? seriesJson,
      Value<String?>? publishingJson,
      Value<String?>? editionTitle,
      Value<String?>? titleExtension,
      Value<String?>? physicalFormat,
      Value<String?>? physicalFormatLabel,
      Value<String>? linksJson,
      Value<String>? rawPayloadJson,
      Value<int>? rowid}) {
    return ComicMediaRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      sortTitle: sortTitle ?? this.sortTitle,
      seriesTitle: seriesTitle ?? this.seriesTitle,
      issueNumber: issueNumber ?? this.issueNumber,
      publisher: publisher ?? this.publisher,
      imprint: imprint ?? this.imprint,
      releaseDate: releaseDate ?? this.releaseDate,
      coverDate: coverDate ?? this.coverDate,
      pageCount: pageCount ?? this.pageCount,
      country: country ?? this.country,
      language: language ?? this.language,
      ageRating: ageRating ?? this.ageRating,
      crossover: crossover ?? this.crossover,
      synopsis: synopsis ?? this.synopsis,
      genresJson: genresJson ?? this.genresJson,
      searchAliasesJson: searchAliasesJson ?? this.searchAliasesJson,
      writersJson: writersJson ?? this.writersJson,
      artistsJson: artistsJson ?? this.artistsJson,
      inkersJson: inkersJson ?? this.inkersJson,
      coloristsJson: coloristsJson ?? this.coloristsJson,
      letterersJson: letterersJson ?? this.letterersJson,
      editorsJson: editorsJson ?? this.editorsJson,
      coverArtistsJson: coverArtistsJson ?? this.coverArtistsJson,
      creatorCreditsJson: creatorCreditsJson ?? this.creatorCreditsJson,
      charactersJson: charactersJson ?? this.charactersJson,
      characterDetailsJson: characterDetailsJson ?? this.characterDetailsJson,
      creatorsJson: creatorsJson ?? this.creatorsJson,
      storyArcsJson: storyArcsJson ?? this.storyArcsJson,
      keyEventsJson: keyEventsJson ?? this.keyEventsJson,
      isKeyComic: isKeyComic ?? this.isKeyComic,
      keyReason: keyReason ?? this.keyReason,
      variant: variant ?? this.variant,
      variantDescription: variantDescription ?? this.variantDescription,
      barcode: barcode ?? this.barcode,
      seriesJson: seriesJson ?? this.seriesJson,
      publishingJson: publishingJson ?? this.publishingJson,
      editionTitle: editionTitle ?? this.editionTitle,
      titleExtension: titleExtension ?? this.titleExtension,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      physicalFormatLabel: physicalFormatLabel ?? this.physicalFormatLabel,
      linksJson: linksJson ?? this.linksJson,
      rawPayloadJson: rawPayloadJson ?? this.rawPayloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sortTitle.present) {
      map['sort_title'] = Variable<String>(sortTitle.value);
    }
    if (seriesTitle.present) {
      map['series_title'] = Variable<String>(seriesTitle.value);
    }
    if (issueNumber.present) {
      map['issue_number'] = Variable<String>(issueNumber.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (imprint.present) {
      map['imprint'] = Variable<String>(imprint.value);
    }
    if (releaseDate.present) {
      map['release_date'] = Variable<DateTime>(releaseDate.value);
    }
    if (coverDate.present) {
      map['cover_date'] = Variable<DateTime>(coverDate.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (ageRating.present) {
      map['age_rating'] = Variable<String>(ageRating.value);
    }
    if (crossover.present) {
      map['crossover'] = Variable<String>(crossover.value);
    }
    if (synopsis.present) {
      map['synopsis'] = Variable<String>(synopsis.value);
    }
    if (genresJson.present) {
      map['genres_json'] = Variable<String>(genresJson.value);
    }
    if (searchAliasesJson.present) {
      map['search_aliases_json'] = Variable<String>(searchAliasesJson.value);
    }
    if (writersJson.present) {
      map['writers_json'] = Variable<String>(writersJson.value);
    }
    if (artistsJson.present) {
      map['artists_json'] = Variable<String>(artistsJson.value);
    }
    if (inkersJson.present) {
      map['inkers_json'] = Variable<String>(inkersJson.value);
    }
    if (coloristsJson.present) {
      map['colorists_json'] = Variable<String>(coloristsJson.value);
    }
    if (letterersJson.present) {
      map['letterers_json'] = Variable<String>(letterersJson.value);
    }
    if (editorsJson.present) {
      map['editors_json'] = Variable<String>(editorsJson.value);
    }
    if (coverArtistsJson.present) {
      map['cover_artists_json'] = Variable<String>(coverArtistsJson.value);
    }
    if (creatorCreditsJson.present) {
      map['creator_credits_json'] = Variable<String>(creatorCreditsJson.value);
    }
    if (charactersJson.present) {
      map['characters_json'] = Variable<String>(charactersJson.value);
    }
    if (characterDetailsJson.present) {
      map['character_details_json'] =
          Variable<String>(characterDetailsJson.value);
    }
    if (creatorsJson.present) {
      map['creators_json'] = Variable<String>(creatorsJson.value);
    }
    if (storyArcsJson.present) {
      map['story_arcs_json'] = Variable<String>(storyArcsJson.value);
    }
    if (keyEventsJson.present) {
      map['key_events_json'] = Variable<String>(keyEventsJson.value);
    }
    if (isKeyComic.present) {
      map['is_key_comic'] = Variable<bool>(isKeyComic.value);
    }
    if (keyReason.present) {
      map['key_reason'] = Variable<String>(keyReason.value);
    }
    if (variant.present) {
      map['variant'] = Variable<String>(variant.value);
    }
    if (variantDescription.present) {
      map['variant_description'] = Variable<String>(variantDescription.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (seriesJson.present) {
      map['series_json'] = Variable<String>(seriesJson.value);
    }
    if (publishingJson.present) {
      map['publishing_json'] = Variable<String>(publishingJson.value);
    }
    if (editionTitle.present) {
      map['edition_title'] = Variable<String>(editionTitle.value);
    }
    if (titleExtension.present) {
      map['title_extension'] = Variable<String>(titleExtension.value);
    }
    if (physicalFormat.present) {
      map['physical_format'] = Variable<String>(physicalFormat.value);
    }
    if (physicalFormatLabel.present) {
      map['physical_format_label'] =
          Variable<String>(physicalFormatLabel.value);
    }
    if (linksJson.present) {
      map['links_json'] = Variable<String>(linksJson.value);
    }
    if (rawPayloadJson.present) {
      map['raw_payload_json'] = Variable<String>(rawPayloadJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComicMediaRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sortTitle: $sortTitle, ')
          ..write('seriesTitle: $seriesTitle, ')
          ..write('issueNumber: $issueNumber, ')
          ..write('publisher: $publisher, ')
          ..write('imprint: $imprint, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('coverDate: $coverDate, ')
          ..write('pageCount: $pageCount, ')
          ..write('country: $country, ')
          ..write('language: $language, ')
          ..write('ageRating: $ageRating, ')
          ..write('crossover: $crossover, ')
          ..write('synopsis: $synopsis, ')
          ..write('genresJson: $genresJson, ')
          ..write('searchAliasesJson: $searchAliasesJson, ')
          ..write('writersJson: $writersJson, ')
          ..write('artistsJson: $artistsJson, ')
          ..write('inkersJson: $inkersJson, ')
          ..write('coloristsJson: $coloristsJson, ')
          ..write('letterersJson: $letterersJson, ')
          ..write('editorsJson: $editorsJson, ')
          ..write('coverArtistsJson: $coverArtistsJson, ')
          ..write('creatorCreditsJson: $creatorCreditsJson, ')
          ..write('charactersJson: $charactersJson, ')
          ..write('characterDetailsJson: $characterDetailsJson, ')
          ..write('creatorsJson: $creatorsJson, ')
          ..write('storyArcsJson: $storyArcsJson, ')
          ..write('keyEventsJson: $keyEventsJson, ')
          ..write('isKeyComic: $isKeyComic, ')
          ..write('keyReason: $keyReason, ')
          ..write('variant: $variant, ')
          ..write('variantDescription: $variantDescription, ')
          ..write('barcode: $barcode, ')
          ..write('seriesJson: $seriesJson, ')
          ..write('publishingJson: $publishingJson, ')
          ..write('editionTitle: $editionTitle, ')
          ..write('titleExtension: $titleExtension, ')
          ..write('physicalFormat: $physicalFormat, ')
          ..write('physicalFormatLabel: $physicalFormatLabel, ')
          ..write('linksJson: $linksJson, ')
          ..write('rawPayloadJson: $rawPayloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ComicReleaseRowsTable extends ComicReleaseRows
    with TableInfo<$ComicReleaseRowsTable, ComicReleaseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComicReleaseRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mediaIdMeta =
      const VerificationMeta('mediaId');
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
      'media_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _publisherMeta =
      const VerificationMeta('publisher');
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
      'publisher', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imprintMeta =
      const VerificationMeta('imprint');
  @override
  late final GeneratedColumn<String> imprint = GeneratedColumn<String>(
      'imprint', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isbnMeta = const VerificationMeta('isbn');
  @override
  late final GeneratedColumn<String> isbn = GeneratedColumn<String>(
      'isbn', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _upcMeta = const VerificationMeta('upc');
  @override
  late final GeneratedColumn<String> upc = GeneratedColumn<String>(
      'upc', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _releaseDateMeta =
      const VerificationMeta('releaseDate');
  @override
  late final GeneratedColumn<DateTime> releaseDate = GeneratedColumn<DateTime>(
      'release_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _coverImageUrlMeta =
      const VerificationMeta('coverImageUrl');
  @override
  late final GeneratedColumn<String> coverImageUrl = GeneratedColumn<String>(
      'cover_image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantsJsonMeta =
      const VerificationMeta('variantsJson');
  @override
  late final GeneratedColumn<String> variantsJson = GeneratedColumn<String>(
      'variants_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  @override
  List<GeneratedColumn> get $columns => [
        mediaId,
        id,
        title,
        publisher,
        imprint,
        isbn,
        upc,
        releaseDate,
        coverImageUrl,
        variantsJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comic_release_rows';
  @override
  VerificationContext validateIntegrity(Insertable<ComicReleaseRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('media_id')) {
      context.handle(_mediaIdMeta,
          mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta));
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('publisher')) {
      context.handle(_publisherMeta,
          publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta));
    }
    if (data.containsKey('imprint')) {
      context.handle(_imprintMeta,
          imprint.isAcceptableOrUnknown(data['imprint']!, _imprintMeta));
    }
    if (data.containsKey('isbn')) {
      context.handle(
          _isbnMeta, isbn.isAcceptableOrUnknown(data['isbn']!, _isbnMeta));
    }
    if (data.containsKey('upc')) {
      context.handle(
          _upcMeta, upc.isAcceptableOrUnknown(data['upc']!, _upcMeta));
    }
    if (data.containsKey('release_date')) {
      context.handle(
          _releaseDateMeta,
          releaseDate.isAcceptableOrUnknown(
              data['release_date']!, _releaseDateMeta));
    }
    if (data.containsKey('cover_image_url')) {
      context.handle(
          _coverImageUrlMeta,
          coverImageUrl.isAcceptableOrUnknown(
              data['cover_image_url']!, _coverImageUrlMeta));
    }
    if (data.containsKey('variants_json')) {
      context.handle(
          _variantsJsonMeta,
          variantsJson.isAcceptableOrUnknown(
              data['variants_json']!, _variantsJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaId, id};
  @override
  ComicReleaseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ComicReleaseRow(
      mediaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_id'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      publisher: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}publisher']),
      imprint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imprint']),
      isbn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}isbn']),
      upc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}upc']),
      releaseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}release_date']),
      coverImageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_image_url']),
      variantsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variants_json'])!,
    );
  }

  @override
  $ComicReleaseRowsTable createAlias(String alias) {
    return $ComicReleaseRowsTable(attachedDatabase, alias);
  }
}

class ComicReleaseRow extends DataClass implements Insertable<ComicReleaseRow> {
  final String mediaId;
  final String id;
  final String title;
  final String? publisher;
  final String? imprint;
  final String? isbn;
  final String? upc;
  final DateTime? releaseDate;
  final String? coverImageUrl;
  final String variantsJson;
  const ComicReleaseRow(
      {required this.mediaId,
      required this.id,
      required this.title,
      this.publisher,
      this.imprint,
      this.isbn,
      this.upc,
      this.releaseDate,
      this.coverImageUrl,
      required this.variantsJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || imprint != null) {
      map['imprint'] = Variable<String>(imprint);
    }
    if (!nullToAbsent || isbn != null) {
      map['isbn'] = Variable<String>(isbn);
    }
    if (!nullToAbsent || upc != null) {
      map['upc'] = Variable<String>(upc);
    }
    if (!nullToAbsent || releaseDate != null) {
      map['release_date'] = Variable<DateTime>(releaseDate);
    }
    if (!nullToAbsent || coverImageUrl != null) {
      map['cover_image_url'] = Variable<String>(coverImageUrl);
    }
    map['variants_json'] = Variable<String>(variantsJson);
    return map;
  }

  ComicReleaseRowsCompanion toCompanion(bool nullToAbsent) {
    return ComicReleaseRowsCompanion(
      mediaId: Value(mediaId),
      id: Value(id),
      title: Value(title),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      imprint: imprint == null && nullToAbsent
          ? const Value.absent()
          : Value(imprint),
      isbn: isbn == null && nullToAbsent ? const Value.absent() : Value(isbn),
      upc: upc == null && nullToAbsent ? const Value.absent() : Value(upc),
      releaseDate: releaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseDate),
      coverImageUrl: coverImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImageUrl),
      variantsJson: Value(variantsJson),
    );
  }

  factory ComicReleaseRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ComicReleaseRow(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      imprint: serializer.fromJson<String?>(json['imprint']),
      isbn: serializer.fromJson<String?>(json['isbn']),
      upc: serializer.fromJson<String?>(json['upc']),
      releaseDate: serializer.fromJson<DateTime?>(json['releaseDate']),
      coverImageUrl: serializer.fromJson<String?>(json['coverImageUrl']),
      variantsJson: serializer.fromJson<String>(json['variantsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'publisher': serializer.toJson<String?>(publisher),
      'imprint': serializer.toJson<String?>(imprint),
      'isbn': serializer.toJson<String?>(isbn),
      'upc': serializer.toJson<String?>(upc),
      'releaseDate': serializer.toJson<DateTime?>(releaseDate),
      'coverImageUrl': serializer.toJson<String?>(coverImageUrl),
      'variantsJson': serializer.toJson<String>(variantsJson),
    };
  }

  ComicReleaseRow copyWith(
          {String? mediaId,
          String? id,
          String? title,
          Value<String?> publisher = const Value.absent(),
          Value<String?> imprint = const Value.absent(),
          Value<String?> isbn = const Value.absent(),
          Value<String?> upc = const Value.absent(),
          Value<DateTime?> releaseDate = const Value.absent(),
          Value<String?> coverImageUrl = const Value.absent(),
          String? variantsJson}) =>
      ComicReleaseRow(
        mediaId: mediaId ?? this.mediaId,
        id: id ?? this.id,
        title: title ?? this.title,
        publisher: publisher.present ? publisher.value : this.publisher,
        imprint: imprint.present ? imprint.value : this.imprint,
        isbn: isbn.present ? isbn.value : this.isbn,
        upc: upc.present ? upc.value : this.upc,
        releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
        coverImageUrl:
            coverImageUrl.present ? coverImageUrl.value : this.coverImageUrl,
        variantsJson: variantsJson ?? this.variantsJson,
      );
  ComicReleaseRow copyWithCompanion(ComicReleaseRowsCompanion data) {
    return ComicReleaseRow(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      imprint: data.imprint.present ? data.imprint.value : this.imprint,
      isbn: data.isbn.present ? data.isbn.value : this.isbn,
      upc: data.upc.present ? data.upc.value : this.upc,
      releaseDate:
          data.releaseDate.present ? data.releaseDate.value : this.releaseDate,
      coverImageUrl: data.coverImageUrl.present
          ? data.coverImageUrl.value
          : this.coverImageUrl,
      variantsJson: data.variantsJson.present
          ? data.variantsJson.value
          : this.variantsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ComicReleaseRow(')
          ..write('mediaId: $mediaId, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('publisher: $publisher, ')
          ..write('imprint: $imprint, ')
          ..write('isbn: $isbn, ')
          ..write('upc: $upc, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('variantsJson: $variantsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(mediaId, id, title, publisher, imprint, isbn,
      upc, releaseDate, coverImageUrl, variantsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComicReleaseRow &&
          other.mediaId == this.mediaId &&
          other.id == this.id &&
          other.title == this.title &&
          other.publisher == this.publisher &&
          other.imprint == this.imprint &&
          other.isbn == this.isbn &&
          other.upc == this.upc &&
          other.releaseDate == this.releaseDate &&
          other.coverImageUrl == this.coverImageUrl &&
          other.variantsJson == this.variantsJson);
}

class ComicReleaseRowsCompanion extends UpdateCompanion<ComicReleaseRow> {
  final Value<String> mediaId;
  final Value<String> id;
  final Value<String> title;
  final Value<String?> publisher;
  final Value<String?> imprint;
  final Value<String?> isbn;
  final Value<String?> upc;
  final Value<DateTime?> releaseDate;
  final Value<String?> coverImageUrl;
  final Value<String> variantsJson;
  final Value<int> rowid;
  const ComicReleaseRowsCompanion({
    this.mediaId = const Value.absent(),
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.publisher = const Value.absent(),
    this.imprint = const Value.absent(),
    this.isbn = const Value.absent(),
    this.upc = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.variantsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ComicReleaseRowsCompanion.insert({
    required String mediaId,
    required String id,
    required String title,
    this.publisher = const Value.absent(),
    this.imprint = const Value.absent(),
    this.isbn = const Value.absent(),
    this.upc = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.variantsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : mediaId = Value(mediaId),
        id = Value(id),
        title = Value(title);
  static Insertable<ComicReleaseRow> custom({
    Expression<String>? mediaId,
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? publisher,
    Expression<String>? imprint,
    Expression<String>? isbn,
    Expression<String>? upc,
    Expression<DateTime>? releaseDate,
    Expression<String>? coverImageUrl,
    Expression<String>? variantsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (publisher != null) 'publisher': publisher,
      if (imprint != null) 'imprint': imprint,
      if (isbn != null) 'isbn': isbn,
      if (upc != null) 'upc': upc,
      if (releaseDate != null) 'release_date': releaseDate,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (variantsJson != null) 'variants_json': variantsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ComicReleaseRowsCompanion copyWith(
      {Value<String>? mediaId,
      Value<String>? id,
      Value<String>? title,
      Value<String?>? publisher,
      Value<String?>? imprint,
      Value<String?>? isbn,
      Value<String?>? upc,
      Value<DateTime?>? releaseDate,
      Value<String?>? coverImageUrl,
      Value<String>? variantsJson,
      Value<int>? rowid}) {
    return ComicReleaseRowsCompanion(
      mediaId: mediaId ?? this.mediaId,
      id: id ?? this.id,
      title: title ?? this.title,
      publisher: publisher ?? this.publisher,
      imprint: imprint ?? this.imprint,
      isbn: isbn ?? this.isbn,
      upc: upc ?? this.upc,
      releaseDate: releaseDate ?? this.releaseDate,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      variantsJson: variantsJson ?? this.variantsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (imprint.present) {
      map['imprint'] = Variable<String>(imprint.value);
    }
    if (isbn.present) {
      map['isbn'] = Variable<String>(isbn.value);
    }
    if (upc.present) {
      map['upc'] = Variable<String>(upc.value);
    }
    if (releaseDate.present) {
      map['release_date'] = Variable<DateTime>(releaseDate.value);
    }
    if (coverImageUrl.present) {
      map['cover_image_url'] = Variable<String>(coverImageUrl.value);
    }
    if (variantsJson.present) {
      map['variants_json'] = Variable<String>(variantsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComicReleaseRowsCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('publisher: $publisher, ')
          ..write('imprint: $imprint, ')
          ..write('isbn: $isbn, ')
          ..write('upc: $upc, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('variantsJson: $variantsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $CatalogCacheTable catalogCache = $CatalogCacheTable(this);
  late final $OwnedItemsCacheTable ownedItemsCache =
      $OwnedItemsCacheTable(this);
  late final $WishlistItemsCacheTable wishlistItemsCache =
      $WishlistItemsCacheTable(this);
  late final $TrackingEntriesCacheTable trackingEntriesCache =
      $TrackingEntriesCacheTable(this);
  late final $TrackingUnitsCacheTable trackingUnitsCache =
      $TrackingUnitsCacheTable(this);
  late final $WatchSessionsCacheTable watchSessionsCache =
      $WatchSessionsCacheTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $UserMetadataOverridesCacheTable userMetadataOverridesCache =
      $UserMetadataOverridesCacheTable(this);
  late final $CustomEpisodesCacheTable customEpisodesCache =
      $CustomEpisodesCacheTable(this);
  late final $UserExternalLinksCacheTable userExternalLinksCache =
      $UserExternalLinksCacheTable(this);
  late final $CustomFieldDefinitionsCacheTable customFieldDefinitionsCache =
      $CustomFieldDefinitionsCacheTable(this);
  late final $CustomFieldValuesCacheTable customFieldValuesCache =
      $CustomFieldValuesCacheTable(this);
  late final $ItemImagesCacheTable itemImagesCache =
      $ItemImagesCacheTable(this);
  late final $LoansCacheTable loansCache = $LoansCacheTable(this);
  late final $LocationsCacheTable locationsCache = $LocationsCacheTable(this);
  late final $SmartListsCacheTable smartListsCache =
      $SmartListsCacheTable(this);
  late final $UserFoldersCacheTable userFoldersCache =
      $UserFoldersCacheTable(this);
  late final $UserFolderItemsCacheTable userFolderItemsCache =
      $UserFolderItemsCacheTable(this);
  late final $ReadingQueueCacheTable readingQueueCache =
      $ReadingQueueCacheTable(this);
  late final $PickListValuesCacheTable pickListValuesCache =
      $PickListValuesCacheTable(this);
  late final $SerialAuthorityCacheTable serialAuthorityCache =
      $SerialAuthorityCacheTable(this);
  late final $ProviderAccountsCacheTable providerAccountsCache =
      $ProviderAccountsCacheTable(this);
  late final $ProviderItemLinksCacheTable providerItemLinksCache =
      $ProviderItemLinksCacheTable(this);
  late final $ComicMediaRowsTable comicMediaRows = $ComicMediaRowsTable(this);
  late final $ComicReleaseRowsTable comicReleaseRows =
      $ComicReleaseRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        catalogCache,
        ownedItemsCache,
        wishlistItemsCache,
        trackingEntriesCache,
        trackingUnitsCache,
        watchSessionsCache,
        syncQueue,
        userMetadataOverridesCache,
        customEpisodesCache,
        userExternalLinksCache,
        customFieldDefinitionsCache,
        customFieldValuesCache,
        itemImagesCache,
        loansCache,
        locationsCache,
        smartListsCache,
        userFoldersCache,
        userFolderItemsCache,
        readingQueueCache,
        pickListValuesCache,
        serialAuthorityCache,
        providerAccountsCache,
        providerItemLinksCache,
        comicMediaRows,
        comicReleaseRows
      ];
}

typedef $$CatalogCacheTableCreateCompanionBuilder = CatalogCacheCompanion
    Function({
  required String id,
  required String kind,
  required String payloadJson,
  required DateTime cachedAt,
  Value<int> rowid,
});
typedef $$CatalogCacheTableUpdateCompanionBuilder = CatalogCacheCompanion
    Function({
  Value<String> id,
  Value<String> kind,
  Value<String> payloadJson,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$CatalogCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $CatalogCacheTable> {
  $$CatalogCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CatalogCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $CatalogCacheTable> {
  $$CatalogCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CatalogCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CatalogCacheTable> {
  $$CatalogCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CatalogCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $CatalogCacheTable,
    CatalogCacheData,
    $$CatalogCacheTableFilterComposer,
    $$CatalogCacheTableOrderingComposer,
    $$CatalogCacheTableAnnotationComposer,
    $$CatalogCacheTableCreateCompanionBuilder,
    $$CatalogCacheTableUpdateCompanionBuilder,
    (
      CatalogCacheData,
      BaseReferences<_$LocalDatabase, $CatalogCacheTable, CatalogCacheData>
    ),
    CatalogCacheData,
    PrefetchHooks Function()> {
  $$CatalogCacheTableTableManager(_$LocalDatabase db, $CatalogCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogCacheCompanion(
            id: id,
            kind: kind,
            payloadJson: payloadJson,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String kind,
            required String payloadJson,
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogCacheCompanion.insert(
            id: id,
            kind: kind,
            payloadJson: payloadJson,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CatalogCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $CatalogCacheTable,
    CatalogCacheData,
    $$CatalogCacheTableFilterComposer,
    $$CatalogCacheTableOrderingComposer,
    $$CatalogCacheTableAnnotationComposer,
    $$CatalogCacheTableCreateCompanionBuilder,
    $$CatalogCacheTableUpdateCompanionBuilder,
    (
      CatalogCacheData,
      BaseReferences<_$LocalDatabase, $CatalogCacheTable, CatalogCacheData>
    ),
    CatalogCacheData,
    PrefetchHooks Function()>;
typedef $$OwnedItemsCacheTableCreateCompanionBuilder = OwnedItemsCacheCompanion
    Function({
  required String id,
  required String itemId,
  Value<DateTime?> createdAt,
  Value<bool?> isDigital,
  Value<String?> anchorType,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> bundleReleaseId,
  Value<String?> condition,
  Value<String?> grade,
  Value<DateTime?> purchaseDate,
  Value<int?> pricePaidCents,
  Value<String?> currency,
  Value<String?> personalNotes,
  Value<int> quantity,
  Value<int?> indexNumber,
  Value<int?> coverPriceCents,
  Value<String?> rawOrSlabbed,
  Value<String?> gradingCompany,
  Value<String?> graderNotes,
  Value<String?> signedBy,
  Value<String?> labelType,
  Value<String?> customLabel,
  Value<String?> pageQuality,
  Value<String?> certificationNumber,
  Value<bool> keyComic,
  Value<String?> keyReason,
  Value<String?> keyCategory,
  Value<String?> keySeverity,
  Value<int?> rating,
  Value<String?> readStatus,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<String?> tags,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> soldAt,
  Value<int?> sellPriceCents,
  Value<String?> soldTo,
  Value<String?> ownerUserId,
  Value<String?> ownerLabel,
  Value<String?> locationId,
  Value<String?> features,
  Value<String?> hdrFormatsJson,
  Value<String?> purchaseStore,
  Value<String?> boxSetId,
  Value<String?> boxSetName,
  Value<String?> storageDevice,
  Value<String?> storageSlot,
  Value<String?> region,
  Value<String?> packaging,
  Value<String?> distributor,
  Value<String?> collectionStatus,
  Value<DateTime?> lastBagBoardDate,
  Value<int?> marketValueCents,
  Value<String?> gameCompleteness,
  Value<bool?> gameHasBox,
  Value<bool?> gameHasManual,
  Value<String?> gamePriceChartingId,
  Value<String?> gameCoreRegion,
  Value<bool?> gameValueIsLocked,
  Value<int> rowid,
});
typedef $$OwnedItemsCacheTableUpdateCompanionBuilder = OwnedItemsCacheCompanion
    Function({
  Value<String> id,
  Value<String> itemId,
  Value<DateTime?> createdAt,
  Value<bool?> isDigital,
  Value<String?> anchorType,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> bundleReleaseId,
  Value<String?> condition,
  Value<String?> grade,
  Value<DateTime?> purchaseDate,
  Value<int?> pricePaidCents,
  Value<String?> currency,
  Value<String?> personalNotes,
  Value<int> quantity,
  Value<int?> indexNumber,
  Value<int?> coverPriceCents,
  Value<String?> rawOrSlabbed,
  Value<String?> gradingCompany,
  Value<String?> graderNotes,
  Value<String?> signedBy,
  Value<String?> labelType,
  Value<String?> customLabel,
  Value<String?> pageQuality,
  Value<String?> certificationNumber,
  Value<bool> keyComic,
  Value<String?> keyReason,
  Value<String?> keyCategory,
  Value<String?> keySeverity,
  Value<int?> rating,
  Value<String?> readStatus,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<String?> tags,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> soldAt,
  Value<int?> sellPriceCents,
  Value<String?> soldTo,
  Value<String?> ownerUserId,
  Value<String?> ownerLabel,
  Value<String?> locationId,
  Value<String?> features,
  Value<String?> hdrFormatsJson,
  Value<String?> purchaseStore,
  Value<String?> boxSetId,
  Value<String?> boxSetName,
  Value<String?> storageDevice,
  Value<String?> storageSlot,
  Value<String?> region,
  Value<String?> packaging,
  Value<String?> distributor,
  Value<String?> collectionStatus,
  Value<DateTime?> lastBagBoardDate,
  Value<int?> marketValueCents,
  Value<String?> gameCompleteness,
  Value<bool?> gameHasBox,
  Value<bool?> gameHasManual,
  Value<String?> gamePriceChartingId,
  Value<String?> gameCoreRegion,
  Value<bool?> gameValueIsLocked,
  Value<int> rowid,
});

class $$OwnedItemsCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $OwnedItemsCacheTable> {
  $$OwnedItemsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDigital => $composableBuilder(
      column: $table.isDigital, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get anchorType => $composableBuilder(
      column: $table.anchorType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pricePaidCents => $composableBuilder(
      column: $table.pricePaidCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personalNotes => $composableBuilder(
      column: $table.personalNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get indexNumber => $composableBuilder(
      column: $table.indexNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get coverPriceCents => $composableBuilder(
      column: $table.coverPriceCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawOrSlabbed => $composableBuilder(
      column: $table.rawOrSlabbed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gradingCompany => $composableBuilder(
      column: $table.gradingCompany,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get graderNotes => $composableBuilder(
      column: $table.graderNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get signedBy => $composableBuilder(
      column: $table.signedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get labelType => $composableBuilder(
      column: $table.labelType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customLabel => $composableBuilder(
      column: $table.customLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pageQuality => $composableBuilder(
      column: $table.pageQuality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get certificationNumber => $composableBuilder(
      column: $table.certificationNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get keyComic => $composableBuilder(
      column: $table.keyComic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get keyReason => $composableBuilder(
      column: $table.keyReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get keyCategory => $composableBuilder(
      column: $table.keyCategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get keySeverity => $composableBuilder(
      column: $table.keySeverity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get readStatus => $composableBuilder(
      column: $table.readStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get soldAt => $composableBuilder(
      column: $table.soldAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sellPriceCents => $composableBuilder(
      column: $table.sellPriceCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get soldTo => $composableBuilder(
      column: $table.soldTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerLabel => $composableBuilder(
      column: $table.ownerLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get features => $composableBuilder(
      column: $table.features, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hdrFormatsJson => $composableBuilder(
      column: $table.hdrFormatsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchaseStore => $composableBuilder(
      column: $table.purchaseStore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boxSetId => $composableBuilder(
      column: $table.boxSetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boxSetName => $composableBuilder(
      column: $table.boxSetName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storageDevice => $composableBuilder(
      column: $table.storageDevice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storageSlot => $composableBuilder(
      column: $table.storageSlot, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get region => $composableBuilder(
      column: $table.region, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get packaging => $composableBuilder(
      column: $table.packaging, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get distributor => $composableBuilder(
      column: $table.distributor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectionStatus => $composableBuilder(
      column: $table.collectionStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastBagBoardDate => $composableBuilder(
      column: $table.lastBagBoardDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get marketValueCents => $composableBuilder(
      column: $table.marketValueCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gameCompleteness => $composableBuilder(
      column: $table.gameCompleteness,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get gameHasBox => $composableBuilder(
      column: $table.gameHasBox, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get gameHasManual => $composableBuilder(
      column: $table.gameHasManual, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gamePriceChartingId => $composableBuilder(
      column: $table.gamePriceChartingId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gameCoreRegion => $composableBuilder(
      column: $table.gameCoreRegion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get gameValueIsLocked => $composableBuilder(
      column: $table.gameValueIsLocked,
      builder: (column) => ColumnFilters(column));
}

class $$OwnedItemsCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $OwnedItemsCacheTable> {
  $$OwnedItemsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDigital => $composableBuilder(
      column: $table.isDigital, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get anchorType => $composableBuilder(
      column: $table.anchorType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pricePaidCents => $composableBuilder(
      column: $table.pricePaidCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personalNotes => $composableBuilder(
      column: $table.personalNotes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get indexNumber => $composableBuilder(
      column: $table.indexNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get coverPriceCents => $composableBuilder(
      column: $table.coverPriceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawOrSlabbed => $composableBuilder(
      column: $table.rawOrSlabbed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gradingCompany => $composableBuilder(
      column: $table.gradingCompany,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get graderNotes => $composableBuilder(
      column: $table.graderNotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get signedBy => $composableBuilder(
      column: $table.signedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get labelType => $composableBuilder(
      column: $table.labelType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customLabel => $composableBuilder(
      column: $table.customLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pageQuality => $composableBuilder(
      column: $table.pageQuality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get certificationNumber => $composableBuilder(
      column: $table.certificationNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get keyComic => $composableBuilder(
      column: $table.keyComic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get keyReason => $composableBuilder(
      column: $table.keyReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get keyCategory => $composableBuilder(
      column: $table.keyCategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get keySeverity => $composableBuilder(
      column: $table.keySeverity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get readStatus => $composableBuilder(
      column: $table.readStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get soldAt => $composableBuilder(
      column: $table.soldAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sellPriceCents => $composableBuilder(
      column: $table.sellPriceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get soldTo => $composableBuilder(
      column: $table.soldTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerLabel => $composableBuilder(
      column: $table.ownerLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get features => $composableBuilder(
      column: $table.features, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hdrFormatsJson => $composableBuilder(
      column: $table.hdrFormatsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseStore => $composableBuilder(
      column: $table.purchaseStore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boxSetId => $composableBuilder(
      column: $table.boxSetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boxSetName => $composableBuilder(
      column: $table.boxSetName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storageDevice => $composableBuilder(
      column: $table.storageDevice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storageSlot => $composableBuilder(
      column: $table.storageSlot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get region => $composableBuilder(
      column: $table.region, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get packaging => $composableBuilder(
      column: $table.packaging, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get distributor => $composableBuilder(
      column: $table.distributor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectionStatus => $composableBuilder(
      column: $table.collectionStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastBagBoardDate => $composableBuilder(
      column: $table.lastBagBoardDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get marketValueCents => $composableBuilder(
      column: $table.marketValueCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gameCompleteness => $composableBuilder(
      column: $table.gameCompleteness,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get gameHasBox => $composableBuilder(
      column: $table.gameHasBox, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get gameHasManual => $composableBuilder(
      column: $table.gameHasManual,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gamePriceChartingId => $composableBuilder(
      column: $table.gamePriceChartingId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gameCoreRegion => $composableBuilder(
      column: $table.gameCoreRegion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get gameValueIsLocked => $composableBuilder(
      column: $table.gameValueIsLocked,
      builder: (column) => ColumnOrderings(column));
}

class $$OwnedItemsCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $OwnedItemsCacheTable> {
  $$OwnedItemsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isDigital =>
      $composableBuilder(column: $table.isDigital, builder: (column) => column);

  GeneratedColumn<String> get anchorType => $composableBuilder(
      column: $table.anchorType, builder: (column) => column);

  GeneratedColumn<String> get editionId =>
      $composableBuilder(column: $table.editionId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId, builder: (column) => column);

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => column);

  GeneratedColumn<int> get pricePaidCents => $composableBuilder(
      column: $table.pricePaidCents, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get personalNotes => $composableBuilder(
      column: $table.personalNotes, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get indexNumber => $composableBuilder(
      column: $table.indexNumber, builder: (column) => column);

  GeneratedColumn<int> get coverPriceCents => $composableBuilder(
      column: $table.coverPriceCents, builder: (column) => column);

  GeneratedColumn<String> get rawOrSlabbed => $composableBuilder(
      column: $table.rawOrSlabbed, builder: (column) => column);

  GeneratedColumn<String> get gradingCompany => $composableBuilder(
      column: $table.gradingCompany, builder: (column) => column);

  GeneratedColumn<String> get graderNotes => $composableBuilder(
      column: $table.graderNotes, builder: (column) => column);

  GeneratedColumn<String> get signedBy =>
      $composableBuilder(column: $table.signedBy, builder: (column) => column);

  GeneratedColumn<String> get labelType =>
      $composableBuilder(column: $table.labelType, builder: (column) => column);

  GeneratedColumn<String> get customLabel => $composableBuilder(
      column: $table.customLabel, builder: (column) => column);

  GeneratedColumn<String> get pageQuality => $composableBuilder(
      column: $table.pageQuality, builder: (column) => column);

  GeneratedColumn<String> get certificationNumber => $composableBuilder(
      column: $table.certificationNumber, builder: (column) => column);

  GeneratedColumn<bool> get keyComic =>
      $composableBuilder(column: $table.keyComic, builder: (column) => column);

  GeneratedColumn<String> get keyReason =>
      $composableBuilder(column: $table.keyReason, builder: (column) => column);

  GeneratedColumn<String> get keyCategory => $composableBuilder(
      column: $table.keyCategory, builder: (column) => column);

  GeneratedColumn<String> get keySeverity => $composableBuilder(
      column: $table.keySeverity, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get readStatus => $composableBuilder(
      column: $table.readStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get soldAt =>
      $composableBuilder(column: $table.soldAt, builder: (column) => column);

  GeneratedColumn<int> get sellPriceCents => $composableBuilder(
      column: $table.sellPriceCents, builder: (column) => column);

  GeneratedColumn<String> get soldTo =>
      $composableBuilder(column: $table.soldTo, builder: (column) => column);

  GeneratedColumn<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => column);

  GeneratedColumn<String> get ownerLabel => $composableBuilder(
      column: $table.ownerLabel, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => column);

  GeneratedColumn<String> get features =>
      $composableBuilder(column: $table.features, builder: (column) => column);

  GeneratedColumn<String> get hdrFormatsJson => $composableBuilder(
      column: $table.hdrFormatsJson, builder: (column) => column);

  GeneratedColumn<String> get purchaseStore => $composableBuilder(
      column: $table.purchaseStore, builder: (column) => column);

  GeneratedColumn<String> get boxSetId =>
      $composableBuilder(column: $table.boxSetId, builder: (column) => column);

  GeneratedColumn<String> get boxSetName => $composableBuilder(
      column: $table.boxSetName, builder: (column) => column);

  GeneratedColumn<String> get storageDevice => $composableBuilder(
      column: $table.storageDevice, builder: (column) => column);

  GeneratedColumn<String> get storageSlot => $composableBuilder(
      column: $table.storageSlot, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get packaging =>
      $composableBuilder(column: $table.packaging, builder: (column) => column);

  GeneratedColumn<String> get distributor => $composableBuilder(
      column: $table.distributor, builder: (column) => column);

  GeneratedColumn<String> get collectionStatus => $composableBuilder(
      column: $table.collectionStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastBagBoardDate => $composableBuilder(
      column: $table.lastBagBoardDate, builder: (column) => column);

  GeneratedColumn<int> get marketValueCents => $composableBuilder(
      column: $table.marketValueCents, builder: (column) => column);

  GeneratedColumn<String> get gameCompleteness => $composableBuilder(
      column: $table.gameCompleteness, builder: (column) => column);

  GeneratedColumn<bool> get gameHasBox => $composableBuilder(
      column: $table.gameHasBox, builder: (column) => column);

  GeneratedColumn<bool> get gameHasManual => $composableBuilder(
      column: $table.gameHasManual, builder: (column) => column);

  GeneratedColumn<String> get gamePriceChartingId => $composableBuilder(
      column: $table.gamePriceChartingId, builder: (column) => column);

  GeneratedColumn<String> get gameCoreRegion => $composableBuilder(
      column: $table.gameCoreRegion, builder: (column) => column);

  GeneratedColumn<bool> get gameValueIsLocked => $composableBuilder(
      column: $table.gameValueIsLocked, builder: (column) => column);
}

class $$OwnedItemsCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $OwnedItemsCacheTable,
    OwnedItemsCacheData,
    $$OwnedItemsCacheTableFilterComposer,
    $$OwnedItemsCacheTableOrderingComposer,
    $$OwnedItemsCacheTableAnnotationComposer,
    $$OwnedItemsCacheTableCreateCompanionBuilder,
    $$OwnedItemsCacheTableUpdateCompanionBuilder,
    (
      OwnedItemsCacheData,
      BaseReferences<_$LocalDatabase, $OwnedItemsCacheTable,
          OwnedItemsCacheData>
    ),
    OwnedItemsCacheData,
    PrefetchHooks Function()> {
  $$OwnedItemsCacheTableTableManager(
      _$LocalDatabase db, $OwnedItemsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OwnedItemsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OwnedItemsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OwnedItemsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool?> isDigital = const Value.absent(),
            Value<String?> anchorType = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> bundleReleaseId = const Value.absent(),
            Value<String?> condition = const Value.absent(),
            Value<String?> grade = const Value.absent(),
            Value<DateTime?> purchaseDate = const Value.absent(),
            Value<int?> pricePaidCents = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<String?> personalNotes = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int?> indexNumber = const Value.absent(),
            Value<int?> coverPriceCents = const Value.absent(),
            Value<String?> rawOrSlabbed = const Value.absent(),
            Value<String?> gradingCompany = const Value.absent(),
            Value<String?> graderNotes = const Value.absent(),
            Value<String?> signedBy = const Value.absent(),
            Value<String?> labelType = const Value.absent(),
            Value<String?> customLabel = const Value.absent(),
            Value<String?> pageQuality = const Value.absent(),
            Value<String?> certificationNumber = const Value.absent(),
            Value<bool> keyComic = const Value.absent(),
            Value<String?> keyReason = const Value.absent(),
            Value<String?> keyCategory = const Value.absent(),
            Value<String?> keySeverity = const Value.absent(),
            Value<int?> rating = const Value.absent(),
            Value<String?> readStatus = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime?> soldAt = const Value.absent(),
            Value<int?> sellPriceCents = const Value.absent(),
            Value<String?> soldTo = const Value.absent(),
            Value<String?> ownerUserId = const Value.absent(),
            Value<String?> ownerLabel = const Value.absent(),
            Value<String?> locationId = const Value.absent(),
            Value<String?> features = const Value.absent(),
            Value<String?> hdrFormatsJson = const Value.absent(),
            Value<String?> purchaseStore = const Value.absent(),
            Value<String?> boxSetId = const Value.absent(),
            Value<String?> boxSetName = const Value.absent(),
            Value<String?> storageDevice = const Value.absent(),
            Value<String?> storageSlot = const Value.absent(),
            Value<String?> region = const Value.absent(),
            Value<String?> packaging = const Value.absent(),
            Value<String?> distributor = const Value.absent(),
            Value<String?> collectionStatus = const Value.absent(),
            Value<DateTime?> lastBagBoardDate = const Value.absent(),
            Value<int?> marketValueCents = const Value.absent(),
            Value<String?> gameCompleteness = const Value.absent(),
            Value<bool?> gameHasBox = const Value.absent(),
            Value<bool?> gameHasManual = const Value.absent(),
            Value<String?> gamePriceChartingId = const Value.absent(),
            Value<String?> gameCoreRegion = const Value.absent(),
            Value<bool?> gameValueIsLocked = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OwnedItemsCacheCompanion(
            id: id,
            itemId: itemId,
            createdAt: createdAt,
            isDigital: isDigital,
            anchorType: anchorType,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
            condition: condition,
            grade: grade,
            purchaseDate: purchaseDate,
            pricePaidCents: pricePaidCents,
            currency: currency,
            personalNotes: personalNotes,
            quantity: quantity,
            indexNumber: indexNumber,
            coverPriceCents: coverPriceCents,
            rawOrSlabbed: rawOrSlabbed,
            gradingCompany: gradingCompany,
            graderNotes: graderNotes,
            signedBy: signedBy,
            labelType: labelType,
            customLabel: customLabel,
            pageQuality: pageQuality,
            certificationNumber: certificationNumber,
            keyComic: keyComic,
            keyReason: keyReason,
            keyCategory: keyCategory,
            keySeverity: keySeverity,
            rating: rating,
            readStatus: readStatus,
            startedAt: startedAt,
            finishedAt: finishedAt,
            tags: tags,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            soldAt: soldAt,
            sellPriceCents: sellPriceCents,
            soldTo: soldTo,
            ownerUserId: ownerUserId,
            ownerLabel: ownerLabel,
            locationId: locationId,
            features: features,
            hdrFormatsJson: hdrFormatsJson,
            purchaseStore: purchaseStore,
            boxSetId: boxSetId,
            boxSetName: boxSetName,
            storageDevice: storageDevice,
            storageSlot: storageSlot,
            region: region,
            packaging: packaging,
            distributor: distributor,
            collectionStatus: collectionStatus,
            lastBagBoardDate: lastBagBoardDate,
            marketValueCents: marketValueCents,
            gameCompleteness: gameCompleteness,
            gameHasBox: gameHasBox,
            gameHasManual: gameHasManual,
            gamePriceChartingId: gamePriceChartingId,
            gameCoreRegion: gameCoreRegion,
            gameValueIsLocked: gameValueIsLocked,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool?> isDigital = const Value.absent(),
            Value<String?> anchorType = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> bundleReleaseId = const Value.absent(),
            Value<String?> condition = const Value.absent(),
            Value<String?> grade = const Value.absent(),
            Value<DateTime?> purchaseDate = const Value.absent(),
            Value<int?> pricePaidCents = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<String?> personalNotes = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int?> indexNumber = const Value.absent(),
            Value<int?> coverPriceCents = const Value.absent(),
            Value<String?> rawOrSlabbed = const Value.absent(),
            Value<String?> gradingCompany = const Value.absent(),
            Value<String?> graderNotes = const Value.absent(),
            Value<String?> signedBy = const Value.absent(),
            Value<String?> labelType = const Value.absent(),
            Value<String?> customLabel = const Value.absent(),
            Value<String?> pageQuality = const Value.absent(),
            Value<String?> certificationNumber = const Value.absent(),
            Value<bool> keyComic = const Value.absent(),
            Value<String?> keyReason = const Value.absent(),
            Value<String?> keyCategory = const Value.absent(),
            Value<String?> keySeverity = const Value.absent(),
            Value<int?> rating = const Value.absent(),
            Value<String?> readStatus = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime?> soldAt = const Value.absent(),
            Value<int?> sellPriceCents = const Value.absent(),
            Value<String?> soldTo = const Value.absent(),
            Value<String?> ownerUserId = const Value.absent(),
            Value<String?> ownerLabel = const Value.absent(),
            Value<String?> locationId = const Value.absent(),
            Value<String?> features = const Value.absent(),
            Value<String?> hdrFormatsJson = const Value.absent(),
            Value<String?> purchaseStore = const Value.absent(),
            Value<String?> boxSetId = const Value.absent(),
            Value<String?> boxSetName = const Value.absent(),
            Value<String?> storageDevice = const Value.absent(),
            Value<String?> storageSlot = const Value.absent(),
            Value<String?> region = const Value.absent(),
            Value<String?> packaging = const Value.absent(),
            Value<String?> distributor = const Value.absent(),
            Value<String?> collectionStatus = const Value.absent(),
            Value<DateTime?> lastBagBoardDate = const Value.absent(),
            Value<int?> marketValueCents = const Value.absent(),
            Value<String?> gameCompleteness = const Value.absent(),
            Value<bool?> gameHasBox = const Value.absent(),
            Value<bool?> gameHasManual = const Value.absent(),
            Value<String?> gamePriceChartingId = const Value.absent(),
            Value<String?> gameCoreRegion = const Value.absent(),
            Value<bool?> gameValueIsLocked = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OwnedItemsCacheCompanion.insert(
            id: id,
            itemId: itemId,
            createdAt: createdAt,
            isDigital: isDigital,
            anchorType: anchorType,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
            condition: condition,
            grade: grade,
            purchaseDate: purchaseDate,
            pricePaidCents: pricePaidCents,
            currency: currency,
            personalNotes: personalNotes,
            quantity: quantity,
            indexNumber: indexNumber,
            coverPriceCents: coverPriceCents,
            rawOrSlabbed: rawOrSlabbed,
            gradingCompany: gradingCompany,
            graderNotes: graderNotes,
            signedBy: signedBy,
            labelType: labelType,
            customLabel: customLabel,
            pageQuality: pageQuality,
            certificationNumber: certificationNumber,
            keyComic: keyComic,
            keyReason: keyReason,
            keyCategory: keyCategory,
            keySeverity: keySeverity,
            rating: rating,
            readStatus: readStatus,
            startedAt: startedAt,
            finishedAt: finishedAt,
            tags: tags,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            soldAt: soldAt,
            sellPriceCents: sellPriceCents,
            soldTo: soldTo,
            ownerUserId: ownerUserId,
            ownerLabel: ownerLabel,
            locationId: locationId,
            features: features,
            hdrFormatsJson: hdrFormatsJson,
            purchaseStore: purchaseStore,
            boxSetId: boxSetId,
            boxSetName: boxSetName,
            storageDevice: storageDevice,
            storageSlot: storageSlot,
            region: region,
            packaging: packaging,
            distributor: distributor,
            collectionStatus: collectionStatus,
            lastBagBoardDate: lastBagBoardDate,
            marketValueCents: marketValueCents,
            gameCompleteness: gameCompleteness,
            gameHasBox: gameHasBox,
            gameHasManual: gameHasManual,
            gamePriceChartingId: gamePriceChartingId,
            gameCoreRegion: gameCoreRegion,
            gameValueIsLocked: gameValueIsLocked,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OwnedItemsCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $OwnedItemsCacheTable,
    OwnedItemsCacheData,
    $$OwnedItemsCacheTableFilterComposer,
    $$OwnedItemsCacheTableOrderingComposer,
    $$OwnedItemsCacheTableAnnotationComposer,
    $$OwnedItemsCacheTableCreateCompanionBuilder,
    $$OwnedItemsCacheTableUpdateCompanionBuilder,
    (
      OwnedItemsCacheData,
      BaseReferences<_$LocalDatabase, $OwnedItemsCacheTable,
          OwnedItemsCacheData>
    ),
    OwnedItemsCacheData,
    PrefetchHooks Function()>;
typedef $$WishlistItemsCacheTableCreateCompanionBuilder
    = WishlistItemsCacheCompanion Function({
  required String id,
  required String itemId,
  Value<String?> anchorType,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> bundleReleaseId,
  Value<int?> targetPriceCents,
  Value<String?> currency,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$WishlistItemsCacheTableUpdateCompanionBuilder
    = WishlistItemsCacheCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String?> anchorType,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> bundleReleaseId,
  Value<int?> targetPriceCents,
  Value<String?> currency,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$WishlistItemsCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $WishlistItemsCacheTable> {
  $$WishlistItemsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get anchorType => $composableBuilder(
      column: $table.anchorType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetPriceCents => $composableBuilder(
      column: $table.targetPriceCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$WishlistItemsCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $WishlistItemsCacheTable> {
  $$WishlistItemsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get anchorType => $composableBuilder(
      column: $table.anchorType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetPriceCents => $composableBuilder(
      column: $table.targetPriceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$WishlistItemsCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $WishlistItemsCacheTable> {
  $$WishlistItemsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get anchorType => $composableBuilder(
      column: $table.anchorType, builder: (column) => column);

  GeneratedColumn<String> get editionId =>
      $composableBuilder(column: $table.editionId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId, builder: (column) => column);

  GeneratedColumn<int> get targetPriceCents => $composableBuilder(
      column: $table.targetPriceCents, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$WishlistItemsCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $WishlistItemsCacheTable,
    WishlistItemsCacheData,
    $$WishlistItemsCacheTableFilterComposer,
    $$WishlistItemsCacheTableOrderingComposer,
    $$WishlistItemsCacheTableAnnotationComposer,
    $$WishlistItemsCacheTableCreateCompanionBuilder,
    $$WishlistItemsCacheTableUpdateCompanionBuilder,
    (
      WishlistItemsCacheData,
      BaseReferences<_$LocalDatabase, $WishlistItemsCacheTable,
          WishlistItemsCacheData>
    ),
    WishlistItemsCacheData,
    PrefetchHooks Function()> {
  $$WishlistItemsCacheTableTableManager(
      _$LocalDatabase db, $WishlistItemsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WishlistItemsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WishlistItemsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WishlistItemsCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String?> anchorType = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> bundleReleaseId = const Value.absent(),
            Value<int?> targetPriceCents = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WishlistItemsCacheCompanion(
            id: id,
            itemId: itemId,
            anchorType: anchorType,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
            targetPriceCents: targetPriceCents,
            currency: currency,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            Value<String?> anchorType = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> bundleReleaseId = const Value.absent(),
            Value<int?> targetPriceCents = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WishlistItemsCacheCompanion.insert(
            id: id,
            itemId: itemId,
            anchorType: anchorType,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
            targetPriceCents: targetPriceCents,
            currency: currency,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WishlistItemsCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $WishlistItemsCacheTable,
    WishlistItemsCacheData,
    $$WishlistItemsCacheTableFilterComposer,
    $$WishlistItemsCacheTableOrderingComposer,
    $$WishlistItemsCacheTableAnnotationComposer,
    $$WishlistItemsCacheTableCreateCompanionBuilder,
    $$WishlistItemsCacheTableUpdateCompanionBuilder,
    (
      WishlistItemsCacheData,
      BaseReferences<_$LocalDatabase, $WishlistItemsCacheTable,
          WishlistItemsCacheData>
    ),
    WishlistItemsCacheData,
    PrefetchHooks Function()>;
typedef $$TrackingEntriesCacheTableCreateCompanionBuilder
    = TrackingEntriesCacheCompanion Function({
  required String id,
  required String itemId,
  Value<String?> ownedItemId,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> bundleReleaseId,
  Value<String?> sourceType,
  Value<String?> status,
  Value<int?> rating,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<int?> progressCurrent,
  Value<int?> progressTotal,
  Value<int?> timesCompleted,
  Value<String?> notes,
  Value<int?> seasonNumber,
  Value<int?> episodeNumber,
  Value<String?> episodeRatings,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$TrackingEntriesCacheTableUpdateCompanionBuilder
    = TrackingEntriesCacheCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String?> ownedItemId,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> bundleReleaseId,
  Value<String?> sourceType,
  Value<String?> status,
  Value<int?> rating,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<int?> progressCurrent,
  Value<int?> progressTotal,
  Value<int?> timesCompleted,
  Value<String?> notes,
  Value<int?> seasonNumber,
  Value<int?> episodeNumber,
  Value<String?> episodeRatings,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$TrackingEntriesCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $TrackingEntriesCacheTable> {
  $$TrackingEntriesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get progressCurrent => $composableBuilder(
      column: $table.progressCurrent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get progressTotal => $composableBuilder(
      column: $table.progressTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timesCompleted => $composableBuilder(
      column: $table.timesCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get episodeRatings => $composableBuilder(
      column: $table.episodeRatings,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$TrackingEntriesCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $TrackingEntriesCacheTable> {
  $$TrackingEntriesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get progressCurrent => $composableBuilder(
      column: $table.progressCurrent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get progressTotal => $composableBuilder(
      column: $table.progressTotal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timesCompleted => $composableBuilder(
      column: $table.timesCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get episodeRatings => $composableBuilder(
      column: $table.episodeRatings,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$TrackingEntriesCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $TrackingEntriesCacheTable> {
  $$TrackingEntriesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => column);

  GeneratedColumn<String> get editionId =>
      $composableBuilder(column: $table.editionId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => column);

  GeneratedColumn<int> get progressCurrent => $composableBuilder(
      column: $table.progressCurrent, builder: (column) => column);

  GeneratedColumn<int> get progressTotal => $composableBuilder(
      column: $table.progressTotal, builder: (column) => column);

  GeneratedColumn<int> get timesCompleted => $composableBuilder(
      column: $table.timesCompleted, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => column);

  GeneratedColumn<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => column);

  GeneratedColumn<String> get episodeRatings => $composableBuilder(
      column: $table.episodeRatings, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TrackingEntriesCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $TrackingEntriesCacheTable,
    TrackingEntriesCacheData,
    $$TrackingEntriesCacheTableFilterComposer,
    $$TrackingEntriesCacheTableOrderingComposer,
    $$TrackingEntriesCacheTableAnnotationComposer,
    $$TrackingEntriesCacheTableCreateCompanionBuilder,
    $$TrackingEntriesCacheTableUpdateCompanionBuilder,
    (
      TrackingEntriesCacheData,
      BaseReferences<_$LocalDatabase, $TrackingEntriesCacheTable,
          TrackingEntriesCacheData>
    ),
    TrackingEntriesCacheData,
    PrefetchHooks Function()> {
  $$TrackingEntriesCacheTableTableManager(
      _$LocalDatabase db, $TrackingEntriesCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackingEntriesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackingEntriesCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackingEntriesCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String?> ownedItemId = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> bundleReleaseId = const Value.absent(),
            Value<String?> sourceType = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<int?> rating = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<int?> progressCurrent = const Value.absent(),
            Value<int?> progressTotal = const Value.absent(),
            Value<int?> timesCompleted = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> seasonNumber = const Value.absent(),
            Value<int?> episodeNumber = const Value.absent(),
            Value<String?> episodeRatings = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingEntriesCacheCompanion(
            id: id,
            itemId: itemId,
            ownedItemId: ownedItemId,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
            sourceType: sourceType,
            status: status,
            rating: rating,
            startedAt: startedAt,
            finishedAt: finishedAt,
            progressCurrent: progressCurrent,
            progressTotal: progressTotal,
            timesCompleted: timesCompleted,
            notes: notes,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            episodeRatings: episodeRatings,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            Value<String?> ownedItemId = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> bundleReleaseId = const Value.absent(),
            Value<String?> sourceType = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<int?> rating = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<int?> progressCurrent = const Value.absent(),
            Value<int?> progressTotal = const Value.absent(),
            Value<int?> timesCompleted = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> seasonNumber = const Value.absent(),
            Value<int?> episodeNumber = const Value.absent(),
            Value<String?> episodeRatings = const Value.absent(),
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingEntriesCacheCompanion.insert(
            id: id,
            itemId: itemId,
            ownedItemId: ownedItemId,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
            sourceType: sourceType,
            status: status,
            rating: rating,
            startedAt: startedAt,
            finishedAt: finishedAt,
            progressCurrent: progressCurrent,
            progressTotal: progressTotal,
            timesCompleted: timesCompleted,
            notes: notes,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            episodeRatings: episodeRatings,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TrackingEntriesCacheTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $TrackingEntriesCacheTable,
        TrackingEntriesCacheData,
        $$TrackingEntriesCacheTableFilterComposer,
        $$TrackingEntriesCacheTableOrderingComposer,
        $$TrackingEntriesCacheTableAnnotationComposer,
        $$TrackingEntriesCacheTableCreateCompanionBuilder,
        $$TrackingEntriesCacheTableUpdateCompanionBuilder,
        (
          TrackingEntriesCacheData,
          BaseReferences<_$LocalDatabase, $TrackingEntriesCacheTable,
              TrackingEntriesCacheData>
        ),
        TrackingEntriesCacheData,
        PrefetchHooks Function()>;
typedef $$TrackingUnitsCacheTableCreateCompanionBuilder
    = TrackingUnitsCacheCompanion Function({
  required String id,
  required String itemId,
  Value<String?> trackingEntryId,
  Value<String?> ownedItemId,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> bundleReleaseId,
  required String unitType,
  Value<int?> seasonNumber,
  Value<int?> episodeNumber,
  Value<int?> volumeNumber,
  Value<int?> chapterNumber,
  Value<String?> issueNumber,
  required DateTime completedAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$TrackingUnitsCacheTableUpdateCompanionBuilder
    = TrackingUnitsCacheCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String?> trackingEntryId,
  Value<String?> ownedItemId,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> bundleReleaseId,
  Value<String> unitType,
  Value<int?> seasonNumber,
  Value<int?> episodeNumber,
  Value<int?> volumeNumber,
  Value<int?> chapterNumber,
  Value<String?> issueNumber,
  Value<DateTime> completedAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$TrackingUnitsCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $TrackingUnitsCacheTable> {
  $$TrackingUnitsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trackingEntryId => $composableBuilder(
      column: $table.trackingEntryId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitType => $composableBuilder(
      column: $table.unitType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get volumeNumber => $composableBuilder(
      column: $table.volumeNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get issueNumber => $composableBuilder(
      column: $table.issueNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$TrackingUnitsCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $TrackingUnitsCacheTable> {
  $$TrackingUnitsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trackingEntryId => $composableBuilder(
      column: $table.trackingEntryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitType => $composableBuilder(
      column: $table.unitType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get volumeNumber => $composableBuilder(
      column: $table.volumeNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get issueNumber => $composableBuilder(
      column: $table.issueNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$TrackingUnitsCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $TrackingUnitsCacheTable> {
  $$TrackingUnitsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get trackingEntryId => $composableBuilder(
      column: $table.trackingEntryId, builder: (column) => column);

  GeneratedColumn<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => column);

  GeneratedColumn<String> get editionId =>
      $composableBuilder(column: $table.editionId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId, builder: (column) => column);

  GeneratedColumn<String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => column);

  GeneratedColumn<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => column);

  GeneratedColumn<int> get volumeNumber => $composableBuilder(
      column: $table.volumeNumber, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => column);

  GeneratedColumn<String> get issueNumber => $composableBuilder(
      column: $table.issueNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TrackingUnitsCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $TrackingUnitsCacheTable,
    TrackingUnitsCacheData,
    $$TrackingUnitsCacheTableFilterComposer,
    $$TrackingUnitsCacheTableOrderingComposer,
    $$TrackingUnitsCacheTableAnnotationComposer,
    $$TrackingUnitsCacheTableCreateCompanionBuilder,
    $$TrackingUnitsCacheTableUpdateCompanionBuilder,
    (
      TrackingUnitsCacheData,
      BaseReferences<_$LocalDatabase, $TrackingUnitsCacheTable,
          TrackingUnitsCacheData>
    ),
    TrackingUnitsCacheData,
    PrefetchHooks Function()> {
  $$TrackingUnitsCacheTableTableManager(
      _$LocalDatabase db, $TrackingUnitsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackingUnitsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackingUnitsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackingUnitsCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String?> trackingEntryId = const Value.absent(),
            Value<String?> ownedItemId = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> bundleReleaseId = const Value.absent(),
            Value<String> unitType = const Value.absent(),
            Value<int?> seasonNumber = const Value.absent(),
            Value<int?> episodeNumber = const Value.absent(),
            Value<int?> volumeNumber = const Value.absent(),
            Value<int?> chapterNumber = const Value.absent(),
            Value<String?> issueNumber = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingUnitsCacheCompanion(
            id: id,
            itemId: itemId,
            trackingEntryId: trackingEntryId,
            ownedItemId: ownedItemId,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
            unitType: unitType,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            volumeNumber: volumeNumber,
            chapterNumber: chapterNumber,
            issueNumber: issueNumber,
            completedAt: completedAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            Value<String?> trackingEntryId = const Value.absent(),
            Value<String?> ownedItemId = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> bundleReleaseId = const Value.absent(),
            required String unitType,
            Value<int?> seasonNumber = const Value.absent(),
            Value<int?> episodeNumber = const Value.absent(),
            Value<int?> volumeNumber = const Value.absent(),
            Value<int?> chapterNumber = const Value.absent(),
            Value<String?> issueNumber = const Value.absent(),
            required DateTime completedAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingUnitsCacheCompanion.insert(
            id: id,
            itemId: itemId,
            trackingEntryId: trackingEntryId,
            ownedItemId: ownedItemId,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
            unitType: unitType,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            volumeNumber: volumeNumber,
            chapterNumber: chapterNumber,
            issueNumber: issueNumber,
            completedAt: completedAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TrackingUnitsCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $TrackingUnitsCacheTable,
    TrackingUnitsCacheData,
    $$TrackingUnitsCacheTableFilterComposer,
    $$TrackingUnitsCacheTableOrderingComposer,
    $$TrackingUnitsCacheTableAnnotationComposer,
    $$TrackingUnitsCacheTableCreateCompanionBuilder,
    $$TrackingUnitsCacheTableUpdateCompanionBuilder,
    (
      TrackingUnitsCacheData,
      BaseReferences<_$LocalDatabase, $TrackingUnitsCacheTable,
          TrackingUnitsCacheData>
    ),
    TrackingUnitsCacheData,
    PrefetchHooks Function()>;
typedef $$WatchSessionsCacheTableCreateCompanionBuilder
    = WatchSessionsCacheCompanion Function({
  required String id,
  required String itemId,
  Value<String?> targetRefJson,
  Value<String?> trackingEntryId,
  Value<int?> seasonNumber,
  Value<int?> episodeNumber,
  Value<String?> sourceType,
  Value<String?> seenWhere,
  required DateTime watchedAt,
  Value<int?> rating,
  Value<String?> notes,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$WatchSessionsCacheTableUpdateCompanionBuilder
    = WatchSessionsCacheCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String?> targetRefJson,
  Value<String?> trackingEntryId,
  Value<int?> seasonNumber,
  Value<int?> episodeNumber,
  Value<String?> sourceType,
  Value<String?> seenWhere,
  Value<DateTime> watchedAt,
  Value<int?> rating,
  Value<String?> notes,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$WatchSessionsCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $WatchSessionsCacheTable> {
  $$WatchSessionsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetRefJson => $composableBuilder(
      column: $table.targetRefJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trackingEntryId => $composableBuilder(
      column: $table.trackingEntryId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seenWhere => $composableBuilder(
      column: $table.seenWhere, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get watchedAt => $composableBuilder(
      column: $table.watchedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$WatchSessionsCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $WatchSessionsCacheTable> {
  $$WatchSessionsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetRefJson => $composableBuilder(
      column: $table.targetRefJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trackingEntryId => $composableBuilder(
      column: $table.trackingEntryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seenWhere => $composableBuilder(
      column: $table.seenWhere, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get watchedAt => $composableBuilder(
      column: $table.watchedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$WatchSessionsCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $WatchSessionsCacheTable> {
  $$WatchSessionsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get targetRefJson => $composableBuilder(
      column: $table.targetRefJson, builder: (column) => column);

  GeneratedColumn<String> get trackingEntryId => $composableBuilder(
      column: $table.trackingEntryId, builder: (column) => column);

  GeneratedColumn<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => column);

  GeneratedColumn<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get seenWhere =>
      $composableBuilder(column: $table.seenWhere, builder: (column) => column);

  GeneratedColumn<DateTime> get watchedAt =>
      $composableBuilder(column: $table.watchedAt, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$WatchSessionsCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $WatchSessionsCacheTable,
    WatchSessionsCacheData,
    $$WatchSessionsCacheTableFilterComposer,
    $$WatchSessionsCacheTableOrderingComposer,
    $$WatchSessionsCacheTableAnnotationComposer,
    $$WatchSessionsCacheTableCreateCompanionBuilder,
    $$WatchSessionsCacheTableUpdateCompanionBuilder,
    (
      WatchSessionsCacheData,
      BaseReferences<_$LocalDatabase, $WatchSessionsCacheTable,
          WatchSessionsCacheData>
    ),
    WatchSessionsCacheData,
    PrefetchHooks Function()> {
  $$WatchSessionsCacheTableTableManager(
      _$LocalDatabase db, $WatchSessionsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchSessionsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchSessionsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchSessionsCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String?> targetRefJson = const Value.absent(),
            Value<String?> trackingEntryId = const Value.absent(),
            Value<int?> seasonNumber = const Value.absent(),
            Value<int?> episodeNumber = const Value.absent(),
            Value<String?> sourceType = const Value.absent(),
            Value<String?> seenWhere = const Value.absent(),
            Value<DateTime> watchedAt = const Value.absent(),
            Value<int?> rating = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WatchSessionsCacheCompanion(
            id: id,
            itemId: itemId,
            targetRefJson: targetRefJson,
            trackingEntryId: trackingEntryId,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            sourceType: sourceType,
            seenWhere: seenWhere,
            watchedAt: watchedAt,
            rating: rating,
            notes: notes,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            Value<String?> targetRefJson = const Value.absent(),
            Value<String?> trackingEntryId = const Value.absent(),
            Value<int?> seasonNumber = const Value.absent(),
            Value<int?> episodeNumber = const Value.absent(),
            Value<String?> sourceType = const Value.absent(),
            Value<String?> seenWhere = const Value.absent(),
            required DateTime watchedAt,
            Value<int?> rating = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WatchSessionsCacheCompanion.insert(
            id: id,
            itemId: itemId,
            targetRefJson: targetRefJson,
            trackingEntryId: trackingEntryId,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            sourceType: sourceType,
            seenWhere: seenWhere,
            watchedAt: watchedAt,
            rating: rating,
            notes: notes,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WatchSessionsCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $WatchSessionsCacheTable,
    WatchSessionsCacheData,
    $$WatchSessionsCacheTableFilterComposer,
    $$WatchSessionsCacheTableOrderingComposer,
    $$WatchSessionsCacheTableAnnotationComposer,
    $$WatchSessionsCacheTableCreateCompanionBuilder,
    $$WatchSessionsCacheTableUpdateCompanionBuilder,
    (
      WatchSessionsCacheData,
      BaseReferences<_$LocalDatabase, $WatchSessionsCacheTable,
          WatchSessionsCacheData>
    ),
    WatchSessionsCacheData,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  required String id,
  required String entityType,
  required String entityId,
  required String action,
  required String payloadJson,
  required DateTime clientChangedAt,
  Value<int> rowid,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> action,
  Value<String> payloadJson,
  Value<DateTime> clientChangedAt,
  Value<int> rowid,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$LocalDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get clientChangedAt => $composableBuilder(
      column: $table.clientChangedAt,
      builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$LocalDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get clientChangedAt => $composableBuilder(
      column: $table.clientChangedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get clientChangedAt => $composableBuilder(
      column: $table.clientChangedAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$LocalDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$LocalDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> clientChangedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payloadJson: payloadJson,
            clientChangedAt: clientChangedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required String action,
            required String payloadJson,
            required DateTime clientChangedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payloadJson: payloadJson,
            clientChangedAt: clientChangedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$LocalDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;
typedef $$UserMetadataOverridesCacheTableCreateCompanionBuilder
    = UserMetadataOverridesCacheCompanion Function({
  required String id,
  required String itemId,
  Value<String?> editionId,
  Value<String?> variantId,
  required String fieldPath,
  Value<String?> originalValue,
  required String overrideValue,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$UserMetadataOverridesCacheTableUpdateCompanionBuilder
    = UserMetadataOverridesCacheCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String> fieldPath,
  Value<String?> originalValue,
  Value<String> overrideValue,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$UserMetadataOverridesCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $UserMetadataOverridesCacheTable> {
  $$UserMetadataOverridesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldPath => $composableBuilder(
      column: $table.fieldPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalValue => $composableBuilder(
      column: $table.originalValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get overrideValue => $composableBuilder(
      column: $table.overrideValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$UserMetadataOverridesCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $UserMetadataOverridesCacheTable> {
  $$UserMetadataOverridesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldPath => $composableBuilder(
      column: $table.fieldPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalValue => $composableBuilder(
      column: $table.originalValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get overrideValue => $composableBuilder(
      column: $table.overrideValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserMetadataOverridesCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $UserMetadataOverridesCacheTable> {
  $$UserMetadataOverridesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get editionId =>
      $composableBuilder(column: $table.editionId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get fieldPath =>
      $composableBuilder(column: $table.fieldPath, builder: (column) => column);

  GeneratedColumn<String> get originalValue => $composableBuilder(
      column: $table.originalValue, builder: (column) => column);

  GeneratedColumn<String> get overrideValue => $composableBuilder(
      column: $table.overrideValue, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$UserMetadataOverridesCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $UserMetadataOverridesCacheTable,
    UserMetadataOverridesCacheData,
    $$UserMetadataOverridesCacheTableFilterComposer,
    $$UserMetadataOverridesCacheTableOrderingComposer,
    $$UserMetadataOverridesCacheTableAnnotationComposer,
    $$UserMetadataOverridesCacheTableCreateCompanionBuilder,
    $$UserMetadataOverridesCacheTableUpdateCompanionBuilder,
    (
      UserMetadataOverridesCacheData,
      BaseReferences<_$LocalDatabase, $UserMetadataOverridesCacheTable,
          UserMetadataOverridesCacheData>
    ),
    UserMetadataOverridesCacheData,
    PrefetchHooks Function()> {
  $$UserMetadataOverridesCacheTableTableManager(
      _$LocalDatabase db, $UserMetadataOverridesCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserMetadataOverridesCacheTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$UserMetadataOverridesCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserMetadataOverridesCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String> fieldPath = const Value.absent(),
            Value<String?> originalValue = const Value.absent(),
            Value<String> overrideValue = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserMetadataOverridesCacheCompanion(
            id: id,
            itemId: itemId,
            editionId: editionId,
            variantId: variantId,
            fieldPath: fieldPath,
            originalValue: originalValue,
            overrideValue: overrideValue,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            required String fieldPath,
            Value<String?> originalValue = const Value.absent(),
            required String overrideValue,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserMetadataOverridesCacheCompanion.insert(
            id: id,
            itemId: itemId,
            editionId: editionId,
            variantId: variantId,
            fieldPath: fieldPath,
            originalValue: originalValue,
            overrideValue: overrideValue,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserMetadataOverridesCacheTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $UserMetadataOverridesCacheTable,
        UserMetadataOverridesCacheData,
        $$UserMetadataOverridesCacheTableFilterComposer,
        $$UserMetadataOverridesCacheTableOrderingComposer,
        $$UserMetadataOverridesCacheTableAnnotationComposer,
        $$UserMetadataOverridesCacheTableCreateCompanionBuilder,
        $$UserMetadataOverridesCacheTableUpdateCompanionBuilder,
        (
          UserMetadataOverridesCacheData,
          BaseReferences<_$LocalDatabase, $UserMetadataOverridesCacheTable,
              UserMetadataOverridesCacheData>
        ),
        UserMetadataOverridesCacheData,
        PrefetchHooks Function()>;
typedef $$CustomEpisodesCacheTableCreateCompanionBuilder
    = CustomEpisodesCacheCompanion Function({
  required String id,
  required String itemId,
  required int seasonNumber,
  required int episodeNumber,
  required String title,
  Value<String?> overview,
  Value<String?> airDate,
  Value<int?> runtimeMinutes,
  Value<String?> stillImageUrl,
  Value<String?> localImagePath,
  Value<String?> thumbnailImageUrl,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$CustomEpisodesCacheTableUpdateCompanionBuilder
    = CustomEpisodesCacheCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<int> seasonNumber,
  Value<int> episodeNumber,
  Value<String> title,
  Value<String?> overview,
  Value<String?> airDate,
  Value<int?> runtimeMinutes,
  Value<String?> stillImageUrl,
  Value<String?> localImagePath,
  Value<String?> thumbnailImageUrl,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$CustomEpisodesCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $CustomEpisodesCacheTable> {
  $$CustomEpisodesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get overview => $composableBuilder(
      column: $table.overview, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get airDate => $composableBuilder(
      column: $table.airDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get runtimeMinutes => $composableBuilder(
      column: $table.runtimeMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stillImageUrl => $composableBuilder(
      column: $table.stillImageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailImageUrl => $composableBuilder(
      column: $table.thumbnailImageUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$CustomEpisodesCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $CustomEpisodesCacheTable> {
  $$CustomEpisodesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get overview => $composableBuilder(
      column: $table.overview, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get airDate => $composableBuilder(
      column: $table.airDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get runtimeMinutes => $composableBuilder(
      column: $table.runtimeMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stillImageUrl => $composableBuilder(
      column: $table.stillImageUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailImageUrl => $composableBuilder(
      column: $table.thumbnailImageUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomEpisodesCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CustomEpisodesCacheTable> {
  $$CustomEpisodesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => column);

  GeneratedColumn<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get overview =>
      $composableBuilder(column: $table.overview, builder: (column) => column);

  GeneratedColumn<String> get airDate =>
      $composableBuilder(column: $table.airDate, builder: (column) => column);

  GeneratedColumn<int> get runtimeMinutes => $composableBuilder(
      column: $table.runtimeMinutes, builder: (column) => column);

  GeneratedColumn<String> get stillImageUrl => $composableBuilder(
      column: $table.stillImageUrl, builder: (column) => column);

  GeneratedColumn<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailImageUrl => $composableBuilder(
      column: $table.thumbnailImageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$CustomEpisodesCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $CustomEpisodesCacheTable,
    CustomEpisodesCacheData,
    $$CustomEpisodesCacheTableFilterComposer,
    $$CustomEpisodesCacheTableOrderingComposer,
    $$CustomEpisodesCacheTableAnnotationComposer,
    $$CustomEpisodesCacheTableCreateCompanionBuilder,
    $$CustomEpisodesCacheTableUpdateCompanionBuilder,
    (
      CustomEpisodesCacheData,
      BaseReferences<_$LocalDatabase, $CustomEpisodesCacheTable,
          CustomEpisodesCacheData>
    ),
    CustomEpisodesCacheData,
    PrefetchHooks Function()> {
  $$CustomEpisodesCacheTableTableManager(
      _$LocalDatabase db, $CustomEpisodesCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomEpisodesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomEpisodesCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomEpisodesCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<int> seasonNumber = const Value.absent(),
            Value<int> episodeNumber = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> overview = const Value.absent(),
            Value<String?> airDate = const Value.absent(),
            Value<int?> runtimeMinutes = const Value.absent(),
            Value<String?> stillImageUrl = const Value.absent(),
            Value<String?> localImagePath = const Value.absent(),
            Value<String?> thumbnailImageUrl = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomEpisodesCacheCompanion(
            id: id,
            itemId: itemId,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            title: title,
            overview: overview,
            airDate: airDate,
            runtimeMinutes: runtimeMinutes,
            stillImageUrl: stillImageUrl,
            localImagePath: localImagePath,
            thumbnailImageUrl: thumbnailImageUrl,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            required int seasonNumber,
            required int episodeNumber,
            required String title,
            Value<String?> overview = const Value.absent(),
            Value<String?> airDate = const Value.absent(),
            Value<int?> runtimeMinutes = const Value.absent(),
            Value<String?> stillImageUrl = const Value.absent(),
            Value<String?> localImagePath = const Value.absent(),
            Value<String?> thumbnailImageUrl = const Value.absent(),
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomEpisodesCacheCompanion.insert(
            id: id,
            itemId: itemId,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            title: title,
            overview: overview,
            airDate: airDate,
            runtimeMinutes: runtimeMinutes,
            stillImageUrl: stillImageUrl,
            localImagePath: localImagePath,
            thumbnailImageUrl: thumbnailImageUrl,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomEpisodesCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $CustomEpisodesCacheTable,
    CustomEpisodesCacheData,
    $$CustomEpisodesCacheTableFilterComposer,
    $$CustomEpisodesCacheTableOrderingComposer,
    $$CustomEpisodesCacheTableAnnotationComposer,
    $$CustomEpisodesCacheTableCreateCompanionBuilder,
    $$CustomEpisodesCacheTableUpdateCompanionBuilder,
    (
      CustomEpisodesCacheData,
      BaseReferences<_$LocalDatabase, $CustomEpisodesCacheTable,
          CustomEpisodesCacheData>
    ),
    CustomEpisodesCacheData,
    PrefetchHooks Function()>;
typedef $$UserExternalLinksCacheTableCreateCompanionBuilder
    = UserExternalLinksCacheCompanion Function({
  required String id,
  required String itemId,
  Value<String?> editionId,
  Value<String?> variantId,
  required String label,
  required String url,
  required String kind,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$UserExternalLinksCacheTableUpdateCompanionBuilder
    = UserExternalLinksCacheCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String> label,
  Value<String> url,
  Value<String> kind,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$UserExternalLinksCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $UserExternalLinksCacheTable> {
  $$UserExternalLinksCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UserExternalLinksCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $UserExternalLinksCacheTable> {
  $$UserExternalLinksCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserExternalLinksCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $UserExternalLinksCacheTable> {
  $$UserExternalLinksCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get editionId =>
      $composableBuilder(column: $table.editionId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserExternalLinksCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $UserExternalLinksCacheTable,
    UserExternalLinksCacheData,
    $$UserExternalLinksCacheTableFilterComposer,
    $$UserExternalLinksCacheTableOrderingComposer,
    $$UserExternalLinksCacheTableAnnotationComposer,
    $$UserExternalLinksCacheTableCreateCompanionBuilder,
    $$UserExternalLinksCacheTableUpdateCompanionBuilder,
    (
      UserExternalLinksCacheData,
      BaseReferences<_$LocalDatabase, $UserExternalLinksCacheTable,
          UserExternalLinksCacheData>
    ),
    UserExternalLinksCacheData,
    PrefetchHooks Function()> {
  $$UserExternalLinksCacheTableTableManager(
      _$LocalDatabase db, $UserExternalLinksCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserExternalLinksCacheTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$UserExternalLinksCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserExternalLinksCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserExternalLinksCacheCompanion(
            id: id,
            itemId: itemId,
            editionId: editionId,
            variantId: variantId,
            label: label,
            url: url,
            kind: kind,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            required String label,
            required String url,
            required String kind,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserExternalLinksCacheCompanion.insert(
            id: id,
            itemId: itemId,
            editionId: editionId,
            variantId: variantId,
            label: label,
            url: url,
            kind: kind,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserExternalLinksCacheTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $UserExternalLinksCacheTable,
        UserExternalLinksCacheData,
        $$UserExternalLinksCacheTableFilterComposer,
        $$UserExternalLinksCacheTableOrderingComposer,
        $$UserExternalLinksCacheTableAnnotationComposer,
        $$UserExternalLinksCacheTableCreateCompanionBuilder,
        $$UserExternalLinksCacheTableUpdateCompanionBuilder,
        (
          UserExternalLinksCacheData,
          BaseReferences<_$LocalDatabase, $UserExternalLinksCacheTable,
              UserExternalLinksCacheData>
        ),
        UserExternalLinksCacheData,
        PrefetchHooks Function()>;
typedef $$CustomFieldDefinitionsCacheTableCreateCompanionBuilder
    = CustomFieldDefinitionsCacheCompanion Function({
  required String id,
  required String name,
  required String fieldType,
  Value<String?> mediaKind,
  Value<String?> editScope,
  Value<int> sortOrder,
  Value<String?> options,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CustomFieldDefinitionsCacheTableUpdateCompanionBuilder
    = CustomFieldDefinitionsCacheCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> fieldType,
  Value<String?> mediaKind,
  Value<String?> editScope,
  Value<int> sortOrder,
  Value<String?> options,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CustomFieldDefinitionsCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $CustomFieldDefinitionsCacheTable> {
  $$CustomFieldDefinitionsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldType => $composableBuilder(
      column: $table.fieldType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaKind => $composableBuilder(
      column: $table.mediaKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editScope => $composableBuilder(
      column: $table.editScope, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get options => $composableBuilder(
      column: $table.options, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CustomFieldDefinitionsCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $CustomFieldDefinitionsCacheTable> {
  $$CustomFieldDefinitionsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldType => $composableBuilder(
      column: $table.fieldType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaKind => $composableBuilder(
      column: $table.mediaKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editScope => $composableBuilder(
      column: $table.editScope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get options => $composableBuilder(
      column: $table.options, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomFieldDefinitionsCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CustomFieldDefinitionsCacheTable> {
  $$CustomFieldDefinitionsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fieldType =>
      $composableBuilder(column: $table.fieldType, builder: (column) => column);

  GeneratedColumn<String> get mediaKind =>
      $composableBuilder(column: $table.mediaKind, builder: (column) => column);

  GeneratedColumn<String> get editScope =>
      $composableBuilder(column: $table.editScope, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get options =>
      $composableBuilder(column: $table.options, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomFieldDefinitionsCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $CustomFieldDefinitionsCacheTable,
    CustomFieldDefinitionsCacheData,
    $$CustomFieldDefinitionsCacheTableFilterComposer,
    $$CustomFieldDefinitionsCacheTableOrderingComposer,
    $$CustomFieldDefinitionsCacheTableAnnotationComposer,
    $$CustomFieldDefinitionsCacheTableCreateCompanionBuilder,
    $$CustomFieldDefinitionsCacheTableUpdateCompanionBuilder,
    (
      CustomFieldDefinitionsCacheData,
      BaseReferences<_$LocalDatabase, $CustomFieldDefinitionsCacheTable,
          CustomFieldDefinitionsCacheData>
    ),
    CustomFieldDefinitionsCacheData,
    PrefetchHooks Function()> {
  $$CustomFieldDefinitionsCacheTableTableManager(
      _$LocalDatabase db, $CustomFieldDefinitionsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomFieldDefinitionsCacheTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomFieldDefinitionsCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomFieldDefinitionsCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> fieldType = const Value.absent(),
            Value<String?> mediaKind = const Value.absent(),
            Value<String?> editScope = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String?> options = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomFieldDefinitionsCacheCompanion(
            id: id,
            name: name,
            fieldType: fieldType,
            mediaKind: mediaKind,
            editScope: editScope,
            sortOrder: sortOrder,
            options: options,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String fieldType,
            Value<String?> mediaKind = const Value.absent(),
            Value<String?> editScope = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String?> options = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomFieldDefinitionsCacheCompanion.insert(
            id: id,
            name: name,
            fieldType: fieldType,
            mediaKind: mediaKind,
            editScope: editScope,
            sortOrder: sortOrder,
            options: options,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomFieldDefinitionsCacheTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $CustomFieldDefinitionsCacheTable,
        CustomFieldDefinitionsCacheData,
        $$CustomFieldDefinitionsCacheTableFilterComposer,
        $$CustomFieldDefinitionsCacheTableOrderingComposer,
        $$CustomFieldDefinitionsCacheTableAnnotationComposer,
        $$CustomFieldDefinitionsCacheTableCreateCompanionBuilder,
        $$CustomFieldDefinitionsCacheTableUpdateCompanionBuilder,
        (
          CustomFieldDefinitionsCacheData,
          BaseReferences<_$LocalDatabase, $CustomFieldDefinitionsCacheTable,
              CustomFieldDefinitionsCacheData>
        ),
        CustomFieldDefinitionsCacheData,
        PrefetchHooks Function()>;
typedef $$CustomFieldValuesCacheTableCreateCompanionBuilder
    = CustomFieldValuesCacheCompanion Function({
  required String id,
  required String targetId,
  required String targetScope,
  Value<String?> catalogRefJson,
  required String fieldDefinitionId,
  Value<String?> value,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CustomFieldValuesCacheTableUpdateCompanionBuilder
    = CustomFieldValuesCacheCompanion Function({
  Value<String> id,
  Value<String> targetId,
  Value<String> targetScope,
  Value<String?> catalogRefJson,
  Value<String> fieldDefinitionId,
  Value<String?> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CustomFieldValuesCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $CustomFieldValuesCacheTable> {
  $$CustomFieldValuesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetScope => $composableBuilder(
      column: $table.targetScope, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get catalogRefJson => $composableBuilder(
      column: $table.catalogRefJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldDefinitionId => $composableBuilder(
      column: $table.fieldDefinitionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CustomFieldValuesCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $CustomFieldValuesCacheTable> {
  $$CustomFieldValuesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetScope => $composableBuilder(
      column: $table.targetScope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get catalogRefJson => $composableBuilder(
      column: $table.catalogRefJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldDefinitionId => $composableBuilder(
      column: $table.fieldDefinitionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomFieldValuesCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CustomFieldValuesCacheTable> {
  $$CustomFieldValuesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get targetScope => $composableBuilder(
      column: $table.targetScope, builder: (column) => column);

  GeneratedColumn<String> get catalogRefJson => $composableBuilder(
      column: $table.catalogRefJson, builder: (column) => column);

  GeneratedColumn<String> get fieldDefinitionId => $composableBuilder(
      column: $table.fieldDefinitionId, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CustomFieldValuesCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $CustomFieldValuesCacheTable,
    CustomFieldValuesCacheData,
    $$CustomFieldValuesCacheTableFilterComposer,
    $$CustomFieldValuesCacheTableOrderingComposer,
    $$CustomFieldValuesCacheTableAnnotationComposer,
    $$CustomFieldValuesCacheTableCreateCompanionBuilder,
    $$CustomFieldValuesCacheTableUpdateCompanionBuilder,
    (
      CustomFieldValuesCacheData,
      BaseReferences<_$LocalDatabase, $CustomFieldValuesCacheTable,
          CustomFieldValuesCacheData>
    ),
    CustomFieldValuesCacheData,
    PrefetchHooks Function()> {
  $$CustomFieldValuesCacheTableTableManager(
      _$LocalDatabase db, $CustomFieldValuesCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomFieldValuesCacheTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomFieldValuesCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomFieldValuesCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> targetId = const Value.absent(),
            Value<String> targetScope = const Value.absent(),
            Value<String?> catalogRefJson = const Value.absent(),
            Value<String> fieldDefinitionId = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomFieldValuesCacheCompanion(
            id: id,
            targetId: targetId,
            targetScope: targetScope,
            catalogRefJson: catalogRefJson,
            fieldDefinitionId: fieldDefinitionId,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String targetId,
            required String targetScope,
            Value<String?> catalogRefJson = const Value.absent(),
            required String fieldDefinitionId,
            Value<String?> value = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomFieldValuesCacheCompanion.insert(
            id: id,
            targetId: targetId,
            targetScope: targetScope,
            catalogRefJson: catalogRefJson,
            fieldDefinitionId: fieldDefinitionId,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomFieldValuesCacheTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $CustomFieldValuesCacheTable,
        CustomFieldValuesCacheData,
        $$CustomFieldValuesCacheTableFilterComposer,
        $$CustomFieldValuesCacheTableOrderingComposer,
        $$CustomFieldValuesCacheTableAnnotationComposer,
        $$CustomFieldValuesCacheTableCreateCompanionBuilder,
        $$CustomFieldValuesCacheTableUpdateCompanionBuilder,
        (
          CustomFieldValuesCacheData,
          BaseReferences<_$LocalDatabase, $CustomFieldValuesCacheTable,
              CustomFieldValuesCacheData>
        ),
        CustomFieldValuesCacheData,
        PrefetchHooks Function()>;
typedef $$ItemImagesCacheTableCreateCompanionBuilder = ItemImagesCacheCompanion
    Function({
  required String id,
  required String ownedItemId,
  Value<String> imageType,
  required Uint8List imageData,
  Value<String?> caption,
  Value<int> sortOrder,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ItemImagesCacheTableUpdateCompanionBuilder = ItemImagesCacheCompanion
    Function({
  Value<String> id,
  Value<String> ownedItemId,
  Value<String> imageType,
  Value<Uint8List> imageData,
  Value<String?> caption,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ItemImagesCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $ItemImagesCacheTable> {
  $$ItemImagesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageType => $composableBuilder(
      column: $table.imageType, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get imageData => $composableBuilder(
      column: $table.imageData, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ItemImagesCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $ItemImagesCacheTable> {
  $$ItemImagesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageType => $composableBuilder(
      column: $table.imageType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get imageData => $composableBuilder(
      column: $table.imageData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ItemImagesCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ItemImagesCacheTable> {
  $$ItemImagesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => column);

  GeneratedColumn<String> get imageType =>
      $composableBuilder(column: $table.imageType, builder: (column) => column);

  GeneratedColumn<Uint8List> get imageData =>
      $composableBuilder(column: $table.imageData, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ItemImagesCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $ItemImagesCacheTable,
    ItemImagesCacheData,
    $$ItemImagesCacheTableFilterComposer,
    $$ItemImagesCacheTableOrderingComposer,
    $$ItemImagesCacheTableAnnotationComposer,
    $$ItemImagesCacheTableCreateCompanionBuilder,
    $$ItemImagesCacheTableUpdateCompanionBuilder,
    (
      ItemImagesCacheData,
      BaseReferences<_$LocalDatabase, $ItemImagesCacheTable,
          ItemImagesCacheData>
    ),
    ItemImagesCacheData,
    PrefetchHooks Function()> {
  $$ItemImagesCacheTableTableManager(
      _$LocalDatabase db, $ItemImagesCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemImagesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemImagesCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemImagesCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> ownedItemId = const Value.absent(),
            Value<String> imageType = const Value.absent(),
            Value<Uint8List> imageData = const Value.absent(),
            Value<String?> caption = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemImagesCacheCompanion(
            id: id,
            ownedItemId: ownedItemId,
            imageType: imageType,
            imageData: imageData,
            caption: caption,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String ownedItemId,
            Value<String> imageType = const Value.absent(),
            required Uint8List imageData,
            Value<String?> caption = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemImagesCacheCompanion.insert(
            id: id,
            ownedItemId: ownedItemId,
            imageType: imageType,
            imageData: imageData,
            caption: caption,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemImagesCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $ItemImagesCacheTable,
    ItemImagesCacheData,
    $$ItemImagesCacheTableFilterComposer,
    $$ItemImagesCacheTableOrderingComposer,
    $$ItemImagesCacheTableAnnotationComposer,
    $$ItemImagesCacheTableCreateCompanionBuilder,
    $$ItemImagesCacheTableUpdateCompanionBuilder,
    (
      ItemImagesCacheData,
      BaseReferences<_$LocalDatabase, $ItemImagesCacheTable,
          ItemImagesCacheData>
    ),
    ItemImagesCacheData,
    PrefetchHooks Function()>;
typedef $$LoansCacheTableCreateCompanionBuilder = LoansCacheCompanion Function({
  required String id,
  required String ownedItemId,
  required String borrowerName,
  required DateTime lentDate,
  Value<DateTime?> dueDate,
  Value<DateTime?> returnedDate,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$LoansCacheTableUpdateCompanionBuilder = LoansCacheCompanion Function({
  Value<String> id,
  Value<String> ownedItemId,
  Value<String> borrowerName,
  Value<DateTime> lentDate,
  Value<DateTime?> dueDate,
  Value<DateTime?> returnedDate,
  Value<String?> notes,
  Value<int> rowid,
});

class $$LoansCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $LoansCacheTable> {
  $$LoansCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get borrowerName => $composableBuilder(
      column: $table.borrowerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lentDate => $composableBuilder(
      column: $table.lentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get returnedDate => $composableBuilder(
      column: $table.returnedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$LoansCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $LoansCacheTable> {
  $$LoansCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get borrowerName => $composableBuilder(
      column: $table.borrowerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lentDate => $composableBuilder(
      column: $table.lentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get returnedDate => $composableBuilder(
      column: $table.returnedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$LoansCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LoansCacheTable> {
  $$LoansCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => column);

  GeneratedColumn<String> get borrowerName => $composableBuilder(
      column: $table.borrowerName, builder: (column) => column);

  GeneratedColumn<DateTime> get lentDate =>
      $composableBuilder(column: $table.lentDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get returnedDate => $composableBuilder(
      column: $table.returnedDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$LoansCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LoansCacheTable,
    LoansCacheData,
    $$LoansCacheTableFilterComposer,
    $$LoansCacheTableOrderingComposer,
    $$LoansCacheTableAnnotationComposer,
    $$LoansCacheTableCreateCompanionBuilder,
    $$LoansCacheTableUpdateCompanionBuilder,
    (
      LoansCacheData,
      BaseReferences<_$LocalDatabase, $LoansCacheTable, LoansCacheData>
    ),
    LoansCacheData,
    PrefetchHooks Function()> {
  $$LoansCacheTableTableManager(_$LocalDatabase db, $LoansCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoansCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoansCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoansCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> ownedItemId = const Value.absent(),
            Value<String> borrowerName = const Value.absent(),
            Value<DateTime> lentDate = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> returnedDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoansCacheCompanion(
            id: id,
            ownedItemId: ownedItemId,
            borrowerName: borrowerName,
            lentDate: lentDate,
            dueDate: dueDate,
            returnedDate: returnedDate,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String ownedItemId,
            required String borrowerName,
            required DateTime lentDate,
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> returnedDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoansCacheCompanion.insert(
            id: id,
            ownedItemId: ownedItemId,
            borrowerName: borrowerName,
            lentDate: lentDate,
            dueDate: dueDate,
            returnedDate: returnedDate,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LoansCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LoansCacheTable,
    LoansCacheData,
    $$LoansCacheTableFilterComposer,
    $$LoansCacheTableOrderingComposer,
    $$LoansCacheTableAnnotationComposer,
    $$LoansCacheTableCreateCompanionBuilder,
    $$LoansCacheTableUpdateCompanionBuilder,
    (
      LoansCacheData,
      BaseReferences<_$LocalDatabase, $LoansCacheTable, LoansCacheData>
    ),
    LoansCacheData,
    PrefetchHooks Function()>;
typedef $$LocationsCacheTableCreateCompanionBuilder = LocationsCacheCompanion
    Function({
  required String id,
  required String name,
  Value<String?> parentId,
  Value<String?> description,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$LocationsCacheTableUpdateCompanionBuilder = LocationsCacheCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> parentId,
  Value<String?> description,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$LocationsCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $LocationsCacheTable> {
  $$LocationsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$LocationsCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocationsCacheTable> {
  $$LocationsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$LocationsCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocationsCacheTable> {
  $$LocationsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LocationsCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocationsCacheTable,
    LocationsCacheData,
    $$LocationsCacheTableFilterComposer,
    $$LocationsCacheTableOrderingComposer,
    $$LocationsCacheTableAnnotationComposer,
    $$LocationsCacheTableCreateCompanionBuilder,
    $$LocationsCacheTableUpdateCompanionBuilder,
    (
      LocationsCacheData,
      BaseReferences<_$LocalDatabase, $LocationsCacheTable, LocationsCacheData>
    ),
    LocationsCacheData,
    PrefetchHooks Function()> {
  $$LocationsCacheTableTableManager(
      _$LocalDatabase db, $LocationsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocationsCacheCompanion(
            id: id,
            name: name,
            parentId: parentId,
            description: description,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> parentId = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocationsCacheCompanion.insert(
            id: id,
            name: name,
            parentId: parentId,
            description: description,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocationsCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocationsCacheTable,
    LocationsCacheData,
    $$LocationsCacheTableFilterComposer,
    $$LocationsCacheTableOrderingComposer,
    $$LocationsCacheTableAnnotationComposer,
    $$LocationsCacheTableCreateCompanionBuilder,
    $$LocationsCacheTableUpdateCompanionBuilder,
    (
      LocationsCacheData,
      BaseReferences<_$LocalDatabase, $LocationsCacheTable, LocationsCacheData>
    ),
    LocationsCacheData,
    PrefetchHooks Function()>;
typedef $$SmartListsCacheTableCreateCompanionBuilder = SmartListsCacheCompanion
    Function({
  required String id,
  required String name,
  Value<String?> mediaKind,
  required String criteriaJson,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SmartListsCacheTableUpdateCompanionBuilder = SmartListsCacheCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> mediaKind,
  Value<String> criteriaJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SmartListsCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $SmartListsCacheTable> {
  $$SmartListsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaKind => $composableBuilder(
      column: $table.mediaKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get criteriaJson => $composableBuilder(
      column: $table.criteriaJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SmartListsCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $SmartListsCacheTable> {
  $$SmartListsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaKind => $composableBuilder(
      column: $table.mediaKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get criteriaJson => $composableBuilder(
      column: $table.criteriaJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SmartListsCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SmartListsCacheTable> {
  $$SmartListsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get mediaKind =>
      $composableBuilder(column: $table.mediaKind, builder: (column) => column);

  GeneratedColumn<String> get criteriaJson => $composableBuilder(
      column: $table.criteriaJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SmartListsCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $SmartListsCacheTable,
    SmartListsCacheData,
    $$SmartListsCacheTableFilterComposer,
    $$SmartListsCacheTableOrderingComposer,
    $$SmartListsCacheTableAnnotationComposer,
    $$SmartListsCacheTableCreateCompanionBuilder,
    $$SmartListsCacheTableUpdateCompanionBuilder,
    (
      SmartListsCacheData,
      BaseReferences<_$LocalDatabase, $SmartListsCacheTable,
          SmartListsCacheData>
    ),
    SmartListsCacheData,
    PrefetchHooks Function()> {
  $$SmartListsCacheTableTableManager(
      _$LocalDatabase db, $SmartListsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmartListsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmartListsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmartListsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> mediaKind = const Value.absent(),
            Value<String> criteriaJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SmartListsCacheCompanion(
            id: id,
            name: name,
            mediaKind: mediaKind,
            criteriaJson: criteriaJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> mediaKind = const Value.absent(),
            required String criteriaJson,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SmartListsCacheCompanion.insert(
            id: id,
            name: name,
            mediaKind: mediaKind,
            criteriaJson: criteriaJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SmartListsCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $SmartListsCacheTable,
    SmartListsCacheData,
    $$SmartListsCacheTableFilterComposer,
    $$SmartListsCacheTableOrderingComposer,
    $$SmartListsCacheTableAnnotationComposer,
    $$SmartListsCacheTableCreateCompanionBuilder,
    $$SmartListsCacheTableUpdateCompanionBuilder,
    (
      SmartListsCacheData,
      BaseReferences<_$LocalDatabase, $SmartListsCacheTable,
          SmartListsCacheData>
    ),
    SmartListsCacheData,
    PrefetchHooks Function()>;
typedef $$UserFoldersCacheTableCreateCompanionBuilder
    = UserFoldersCacheCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<String?> parentId,
  Value<String?> iconName,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$UserFoldersCacheTableUpdateCompanionBuilder
    = UserFoldersCacheCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String?> parentId,
  Value<String?> iconName,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$UserFoldersCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $UserFoldersCacheTable> {
  $$UserFoldersCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$UserFoldersCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $UserFoldersCacheTable> {
  $$UserFoldersCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$UserFoldersCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $UserFoldersCacheTable> {
  $$UserFoldersCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$UserFoldersCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $UserFoldersCacheTable,
    UserFoldersCacheData,
    $$UserFoldersCacheTableFilterComposer,
    $$UserFoldersCacheTableOrderingComposer,
    $$UserFoldersCacheTableAnnotationComposer,
    $$UserFoldersCacheTableCreateCompanionBuilder,
    $$UserFoldersCacheTableUpdateCompanionBuilder,
    (
      UserFoldersCacheData,
      BaseReferences<_$LocalDatabase, $UserFoldersCacheTable,
          UserFoldersCacheData>
    ),
    UserFoldersCacheData,
    PrefetchHooks Function()> {
  $$UserFoldersCacheTableTableManager(
      _$LocalDatabase db, $UserFoldersCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserFoldersCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserFoldersCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserFoldersCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserFoldersCacheCompanion(
            id: id,
            name: name,
            description: description,
            parentId: parentId,
            iconName: iconName,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserFoldersCacheCompanion.insert(
            id: id,
            name: name,
            description: description,
            parentId: parentId,
            iconName: iconName,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserFoldersCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $UserFoldersCacheTable,
    UserFoldersCacheData,
    $$UserFoldersCacheTableFilterComposer,
    $$UserFoldersCacheTableOrderingComposer,
    $$UserFoldersCacheTableAnnotationComposer,
    $$UserFoldersCacheTableCreateCompanionBuilder,
    $$UserFoldersCacheTableUpdateCompanionBuilder,
    (
      UserFoldersCacheData,
      BaseReferences<_$LocalDatabase, $UserFoldersCacheTable,
          UserFoldersCacheData>
    ),
    UserFoldersCacheData,
    PrefetchHooks Function()>;
typedef $$UserFolderItemsCacheTableCreateCompanionBuilder
    = UserFolderItemsCacheCompanion Function({
  required String folderId,
  required String ownedItemId,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$UserFolderItemsCacheTableUpdateCompanionBuilder
    = UserFolderItemsCacheCompanion Function({
  Value<String> folderId,
  Value<String> ownedItemId,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$UserFolderItemsCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $UserFolderItemsCacheTable> {
  $$UserFolderItemsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$UserFolderItemsCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $UserFolderItemsCacheTable> {
  $$UserFolderItemsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$UserFolderItemsCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $UserFolderItemsCacheTable> {
  $$UserFolderItemsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$UserFolderItemsCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $UserFolderItemsCacheTable,
    UserFolderItemsCacheData,
    $$UserFolderItemsCacheTableFilterComposer,
    $$UserFolderItemsCacheTableOrderingComposer,
    $$UserFolderItemsCacheTableAnnotationComposer,
    $$UserFolderItemsCacheTableCreateCompanionBuilder,
    $$UserFolderItemsCacheTableUpdateCompanionBuilder,
    (
      UserFolderItemsCacheData,
      BaseReferences<_$LocalDatabase, $UserFolderItemsCacheTable,
          UserFolderItemsCacheData>
    ),
    UserFolderItemsCacheData,
    PrefetchHooks Function()> {
  $$UserFolderItemsCacheTableTableManager(
      _$LocalDatabase db, $UserFolderItemsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserFolderItemsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserFolderItemsCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserFolderItemsCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> folderId = const Value.absent(),
            Value<String> ownedItemId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserFolderItemsCacheCompanion(
            folderId: folderId,
            ownedItemId: ownedItemId,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String folderId,
            required String ownedItemId,
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserFolderItemsCacheCompanion.insert(
            folderId: folderId,
            ownedItemId: ownedItemId,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserFolderItemsCacheTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $UserFolderItemsCacheTable,
        UserFolderItemsCacheData,
        $$UserFolderItemsCacheTableFilterComposer,
        $$UserFolderItemsCacheTableOrderingComposer,
        $$UserFolderItemsCacheTableAnnotationComposer,
        $$UserFolderItemsCacheTableCreateCompanionBuilder,
        $$UserFolderItemsCacheTableUpdateCompanionBuilder,
        (
          UserFolderItemsCacheData,
          BaseReferences<_$LocalDatabase, $UserFolderItemsCacheTable,
              UserFolderItemsCacheData>
        ),
        UserFolderItemsCacheData,
        PrefetchHooks Function()>;
typedef $$ReadingQueueCacheTableCreateCompanionBuilder
    = ReadingQueueCacheCompanion Function({
  required String ownedItemId,
  required int position,
  required DateTime addedAt,
  Value<int> rowid,
});
typedef $$ReadingQueueCacheTableUpdateCompanionBuilder
    = ReadingQueueCacheCompanion Function({
  Value<String> ownedItemId,
  Value<int> position,
  Value<DateTime> addedAt,
  Value<int> rowid,
});

class $$ReadingQueueCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $ReadingQueueCacheTable> {
  $$ReadingQueueCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));
}

class $$ReadingQueueCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $ReadingQueueCacheTable> {
  $$ReadingQueueCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));
}

class $$ReadingQueueCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ReadingQueueCacheTable> {
  $$ReadingQueueCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$ReadingQueueCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $ReadingQueueCacheTable,
    ReadingQueueCacheData,
    $$ReadingQueueCacheTableFilterComposer,
    $$ReadingQueueCacheTableOrderingComposer,
    $$ReadingQueueCacheTableAnnotationComposer,
    $$ReadingQueueCacheTableCreateCompanionBuilder,
    $$ReadingQueueCacheTableUpdateCompanionBuilder,
    (
      ReadingQueueCacheData,
      BaseReferences<_$LocalDatabase, $ReadingQueueCacheTable,
          ReadingQueueCacheData>
    ),
    ReadingQueueCacheData,
    PrefetchHooks Function()> {
  $$ReadingQueueCacheTableTableManager(
      _$LocalDatabase db, $ReadingQueueCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingQueueCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingQueueCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingQueueCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> ownedItemId = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingQueueCacheCompanion(
            ownedItemId: ownedItemId,
            position: position,
            addedAt: addedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String ownedItemId,
            required int position,
            required DateTime addedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingQueueCacheCompanion.insert(
            ownedItemId: ownedItemId,
            position: position,
            addedAt: addedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReadingQueueCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $ReadingQueueCacheTable,
    ReadingQueueCacheData,
    $$ReadingQueueCacheTableFilterComposer,
    $$ReadingQueueCacheTableOrderingComposer,
    $$ReadingQueueCacheTableAnnotationComposer,
    $$ReadingQueueCacheTableCreateCompanionBuilder,
    $$ReadingQueueCacheTableUpdateCompanionBuilder,
    (
      ReadingQueueCacheData,
      BaseReferences<_$LocalDatabase, $ReadingQueueCacheTable,
          ReadingQueueCacheData>
    ),
    ReadingQueueCacheData,
    PrefetchHooks Function()>;
typedef $$PickListValuesCacheTableCreateCompanionBuilder
    = PickListValuesCacheCompanion Function({
  required String id,
  required String listName,
  Value<String?> mediaKind,
  required String value,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$PickListValuesCacheTableUpdateCompanionBuilder
    = PickListValuesCacheCompanion Function({
  Value<String> id,
  Value<String> listName,
  Value<String?> mediaKind,
  Value<String> value,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$PickListValuesCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $PickListValuesCacheTable> {
  $$PickListValuesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get listName => $composableBuilder(
      column: $table.listName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaKind => $composableBuilder(
      column: $table.mediaKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$PickListValuesCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $PickListValuesCacheTable> {
  $$PickListValuesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get listName => $composableBuilder(
      column: $table.listName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaKind => $composableBuilder(
      column: $table.mediaKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$PickListValuesCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $PickListValuesCacheTable> {
  $$PickListValuesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get listName =>
      $composableBuilder(column: $table.listName, builder: (column) => column);

  GeneratedColumn<String> get mediaKind =>
      $composableBuilder(column: $table.mediaKind, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$PickListValuesCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $PickListValuesCacheTable,
    PickListValuesCacheData,
    $$PickListValuesCacheTableFilterComposer,
    $$PickListValuesCacheTableOrderingComposer,
    $$PickListValuesCacheTableAnnotationComposer,
    $$PickListValuesCacheTableCreateCompanionBuilder,
    $$PickListValuesCacheTableUpdateCompanionBuilder,
    (
      PickListValuesCacheData,
      BaseReferences<_$LocalDatabase, $PickListValuesCacheTable,
          PickListValuesCacheData>
    ),
    PickListValuesCacheData,
    PrefetchHooks Function()> {
  $$PickListValuesCacheTableTableManager(
      _$LocalDatabase db, $PickListValuesCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PickListValuesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PickListValuesCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PickListValuesCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> listName = const Value.absent(),
            Value<String?> mediaKind = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PickListValuesCacheCompanion(
            id: id,
            listName: listName,
            mediaKind: mediaKind,
            value: value,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String listName,
            Value<String?> mediaKind = const Value.absent(),
            required String value,
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PickListValuesCacheCompanion.insert(
            id: id,
            listName: listName,
            mediaKind: mediaKind,
            value: value,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PickListValuesCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $PickListValuesCacheTable,
    PickListValuesCacheData,
    $$PickListValuesCacheTableFilterComposer,
    $$PickListValuesCacheTableOrderingComposer,
    $$PickListValuesCacheTableAnnotationComposer,
    $$PickListValuesCacheTableCreateCompanionBuilder,
    $$PickListValuesCacheTableUpdateCompanionBuilder,
    (
      PickListValuesCacheData,
      BaseReferences<_$LocalDatabase, $PickListValuesCacheTable,
          PickListValuesCacheData>
    ),
    PickListValuesCacheData,
    PrefetchHooks Function()>;
typedef $$SerialAuthorityCacheTableCreateCompanionBuilder
    = SerialAuthorityCacheCompanion Function({
  required String id,
  required String mediaKind,
  required String title,
  required String normalizedTitle,
  Value<String?> sortTitle,
  Value<String?> normalizedSortTitle,
  Value<String?> coreSeriesId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SerialAuthorityCacheTableUpdateCompanionBuilder
    = SerialAuthorityCacheCompanion Function({
  Value<String> id,
  Value<String> mediaKind,
  Value<String> title,
  Value<String> normalizedTitle,
  Value<String?> sortTitle,
  Value<String?> normalizedSortTitle,
  Value<String?> coreSeriesId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SerialAuthorityCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $SerialAuthorityCacheTable> {
  $$SerialAuthorityCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaKind => $composableBuilder(
      column: $table.mediaKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get normalizedTitle => $composableBuilder(
      column: $table.normalizedTitle,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sortTitle => $composableBuilder(
      column: $table.sortTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get normalizedSortTitle => $composableBuilder(
      column: $table.normalizedSortTitle,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coreSeriesId => $composableBuilder(
      column: $table.coreSeriesId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SerialAuthorityCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $SerialAuthorityCacheTable> {
  $$SerialAuthorityCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaKind => $composableBuilder(
      column: $table.mediaKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get normalizedTitle => $composableBuilder(
      column: $table.normalizedTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sortTitle => $composableBuilder(
      column: $table.sortTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get normalizedSortTitle => $composableBuilder(
      column: $table.normalizedSortTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coreSeriesId => $composableBuilder(
      column: $table.coreSeriesId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SerialAuthorityCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SerialAuthorityCacheTable> {
  $$SerialAuthorityCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mediaKind =>
      $composableBuilder(column: $table.mediaKind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get normalizedTitle => $composableBuilder(
      column: $table.normalizedTitle, builder: (column) => column);

  GeneratedColumn<String> get sortTitle =>
      $composableBuilder(column: $table.sortTitle, builder: (column) => column);

  GeneratedColumn<String> get normalizedSortTitle => $composableBuilder(
      column: $table.normalizedSortTitle, builder: (column) => column);

  GeneratedColumn<String> get coreSeriesId => $composableBuilder(
      column: $table.coreSeriesId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SerialAuthorityCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $SerialAuthorityCacheTable,
    SerialAuthorityCacheData,
    $$SerialAuthorityCacheTableFilterComposer,
    $$SerialAuthorityCacheTableOrderingComposer,
    $$SerialAuthorityCacheTableAnnotationComposer,
    $$SerialAuthorityCacheTableCreateCompanionBuilder,
    $$SerialAuthorityCacheTableUpdateCompanionBuilder,
    (
      SerialAuthorityCacheData,
      BaseReferences<_$LocalDatabase, $SerialAuthorityCacheTable,
          SerialAuthorityCacheData>
    ),
    SerialAuthorityCacheData,
    PrefetchHooks Function()> {
  $$SerialAuthorityCacheTableTableManager(
      _$LocalDatabase db, $SerialAuthorityCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SerialAuthorityCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SerialAuthorityCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SerialAuthorityCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> mediaKind = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> normalizedTitle = const Value.absent(),
            Value<String?> sortTitle = const Value.absent(),
            Value<String?> normalizedSortTitle = const Value.absent(),
            Value<String?> coreSeriesId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SerialAuthorityCacheCompanion(
            id: id,
            mediaKind: mediaKind,
            title: title,
            normalizedTitle: normalizedTitle,
            sortTitle: sortTitle,
            normalizedSortTitle: normalizedSortTitle,
            coreSeriesId: coreSeriesId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String mediaKind,
            required String title,
            required String normalizedTitle,
            Value<String?> sortTitle = const Value.absent(),
            Value<String?> normalizedSortTitle = const Value.absent(),
            Value<String?> coreSeriesId = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SerialAuthorityCacheCompanion.insert(
            id: id,
            mediaKind: mediaKind,
            title: title,
            normalizedTitle: normalizedTitle,
            sortTitle: sortTitle,
            normalizedSortTitle: normalizedSortTitle,
            coreSeriesId: coreSeriesId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SerialAuthorityCacheTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $SerialAuthorityCacheTable,
        SerialAuthorityCacheData,
        $$SerialAuthorityCacheTableFilterComposer,
        $$SerialAuthorityCacheTableOrderingComposer,
        $$SerialAuthorityCacheTableAnnotationComposer,
        $$SerialAuthorityCacheTableCreateCompanionBuilder,
        $$SerialAuthorityCacheTableUpdateCompanionBuilder,
        (
          SerialAuthorityCacheData,
          BaseReferences<_$LocalDatabase, $SerialAuthorityCacheTable,
              SerialAuthorityCacheData>
        ),
        SerialAuthorityCacheData,
        PrefetchHooks Function()>;
typedef $$ProviderAccountsCacheTableCreateCompanionBuilder
    = ProviderAccountsCacheCompanion Function({
  required String id,
  required String provider,
  required String displayName,
  required String authType,
  Value<String?> remoteAccountId,
  Value<String?> remoteHandle,
  Value<String?> username,
  Value<String?> avatarUrl,
  Value<DateTime?> connectedAt,
  Value<DateTime?> lastSyncAt,
  required String enabledCapabilitiesJson,
  required String syncPolicyJson,
  Value<int> rowid,
});
typedef $$ProviderAccountsCacheTableUpdateCompanionBuilder
    = ProviderAccountsCacheCompanion Function({
  Value<String> id,
  Value<String> provider,
  Value<String> displayName,
  Value<String> authType,
  Value<String?> remoteAccountId,
  Value<String?> remoteHandle,
  Value<String?> username,
  Value<String?> avatarUrl,
  Value<DateTime?> connectedAt,
  Value<DateTime?> lastSyncAt,
  Value<String> enabledCapabilitiesJson,
  Value<String> syncPolicyJson,
  Value<int> rowid,
});

class $$ProviderAccountsCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $ProviderAccountsCacheTable> {
  $$ProviderAccountsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authType => $composableBuilder(
      column: $table.authType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteAccountId => $composableBuilder(
      column: $table.remoteAccountId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteHandle => $composableBuilder(
      column: $table.remoteHandle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get connectedAt => $composableBuilder(
      column: $table.connectedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get enabledCapabilitiesJson => $composableBuilder(
      column: $table.enabledCapabilitiesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncPolicyJson => $composableBuilder(
      column: $table.syncPolicyJson,
      builder: (column) => ColumnFilters(column));
}

class $$ProviderAccountsCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $ProviderAccountsCacheTable> {
  $$ProviderAccountsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authType => $composableBuilder(
      column: $table.authType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteAccountId => $composableBuilder(
      column: $table.remoteAccountId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteHandle => $composableBuilder(
      column: $table.remoteHandle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get connectedAt => $composableBuilder(
      column: $table.connectedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get enabledCapabilitiesJson => $composableBuilder(
      column: $table.enabledCapabilitiesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncPolicyJson => $composableBuilder(
      column: $table.syncPolicyJson,
      builder: (column) => ColumnOrderings(column));
}

class $$ProviderAccountsCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ProviderAccountsCacheTable> {
  $$ProviderAccountsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get authType =>
      $composableBuilder(column: $table.authType, builder: (column) => column);

  GeneratedColumn<String> get remoteAccountId => $composableBuilder(
      column: $table.remoteAccountId, builder: (column) => column);

  GeneratedColumn<String> get remoteHandle => $composableBuilder(
      column: $table.remoteHandle, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get connectedAt => $composableBuilder(
      column: $table.connectedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => column);

  GeneratedColumn<String> get enabledCapabilitiesJson => $composableBuilder(
      column: $table.enabledCapabilitiesJson, builder: (column) => column);

  GeneratedColumn<String> get syncPolicyJson => $composableBuilder(
      column: $table.syncPolicyJson, builder: (column) => column);
}

class $$ProviderAccountsCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $ProviderAccountsCacheTable,
    ProviderAccountsCacheData,
    $$ProviderAccountsCacheTableFilterComposer,
    $$ProviderAccountsCacheTableOrderingComposer,
    $$ProviderAccountsCacheTableAnnotationComposer,
    $$ProviderAccountsCacheTableCreateCompanionBuilder,
    $$ProviderAccountsCacheTableUpdateCompanionBuilder,
    (
      ProviderAccountsCacheData,
      BaseReferences<_$LocalDatabase, $ProviderAccountsCacheTable,
          ProviderAccountsCacheData>
    ),
    ProviderAccountsCacheData,
    PrefetchHooks Function()> {
  $$ProviderAccountsCacheTableTableManager(
      _$LocalDatabase db, $ProviderAccountsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProviderAccountsCacheTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ProviderAccountsCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProviderAccountsCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> provider = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> authType = const Value.absent(),
            Value<String?> remoteAccountId = const Value.absent(),
            Value<String?> remoteHandle = const Value.absent(),
            Value<String?> username = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<DateTime?> connectedAt = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<String> enabledCapabilitiesJson = const Value.absent(),
            Value<String> syncPolicyJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProviderAccountsCacheCompanion(
            id: id,
            provider: provider,
            displayName: displayName,
            authType: authType,
            remoteAccountId: remoteAccountId,
            remoteHandle: remoteHandle,
            username: username,
            avatarUrl: avatarUrl,
            connectedAt: connectedAt,
            lastSyncAt: lastSyncAt,
            enabledCapabilitiesJson: enabledCapabilitiesJson,
            syncPolicyJson: syncPolicyJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String provider,
            required String displayName,
            required String authType,
            Value<String?> remoteAccountId = const Value.absent(),
            Value<String?> remoteHandle = const Value.absent(),
            Value<String?> username = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<DateTime?> connectedAt = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            required String enabledCapabilitiesJson,
            required String syncPolicyJson,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProviderAccountsCacheCompanion.insert(
            id: id,
            provider: provider,
            displayName: displayName,
            authType: authType,
            remoteAccountId: remoteAccountId,
            remoteHandle: remoteHandle,
            username: username,
            avatarUrl: avatarUrl,
            connectedAt: connectedAt,
            lastSyncAt: lastSyncAt,
            enabledCapabilitiesJson: enabledCapabilitiesJson,
            syncPolicyJson: syncPolicyJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProviderAccountsCacheTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $ProviderAccountsCacheTable,
        ProviderAccountsCacheData,
        $$ProviderAccountsCacheTableFilterComposer,
        $$ProviderAccountsCacheTableOrderingComposer,
        $$ProviderAccountsCacheTableAnnotationComposer,
        $$ProviderAccountsCacheTableCreateCompanionBuilder,
        $$ProviderAccountsCacheTableUpdateCompanionBuilder,
        (
          ProviderAccountsCacheData,
          BaseReferences<_$LocalDatabase, $ProviderAccountsCacheTable,
              ProviderAccountsCacheData>
        ),
        ProviderAccountsCacheData,
        PrefetchHooks Function()>;
typedef $$ProviderItemLinksCacheTableCreateCompanionBuilder
    = ProviderItemLinksCacheCompanion Function({
  required String accountId,
  required String provider,
  required String remoteItemId,
  Value<String?> remoteEntryId,
  required String localEntityRefJson,
  Value<String?> baseSnapshotJson,
  Value<DateTime?> lastPulledAt,
  Value<DateTime?> lastPushedAt,
  Value<String?> remoteRevision,
  required String metadataJson,
  Value<int> rowid,
});
typedef $$ProviderItemLinksCacheTableUpdateCompanionBuilder
    = ProviderItemLinksCacheCompanion Function({
  Value<String> accountId,
  Value<String> provider,
  Value<String> remoteItemId,
  Value<String?> remoteEntryId,
  Value<String> localEntityRefJson,
  Value<String?> baseSnapshotJson,
  Value<DateTime?> lastPulledAt,
  Value<DateTime?> lastPushedAt,
  Value<String?> remoteRevision,
  Value<String> metadataJson,
  Value<int> rowid,
});

class $$ProviderItemLinksCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $ProviderItemLinksCacheTable> {
  $$ProviderItemLinksCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteItemId => $composableBuilder(
      column: $table.remoteItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteEntryId => $composableBuilder(
      column: $table.remoteEntryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localEntityRefJson => $composableBuilder(
      column: $table.localEntityRefJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get baseSnapshotJson => $composableBuilder(
      column: $table.baseSnapshotJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastPulledAt => $composableBuilder(
      column: $table.lastPulledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastPushedAt => $composableBuilder(
      column: $table.lastPushedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteRevision => $composableBuilder(
      column: $table.remoteRevision,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));
}

class $$ProviderItemLinksCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $ProviderItemLinksCacheTable> {
  $$ProviderItemLinksCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteItemId => $composableBuilder(
      column: $table.remoteItemId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteEntryId => $composableBuilder(
      column: $table.remoteEntryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localEntityRefJson => $composableBuilder(
      column: $table.localEntityRefJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get baseSnapshotJson => $composableBuilder(
      column: $table.baseSnapshotJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastPulledAt => $composableBuilder(
      column: $table.lastPulledAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastPushedAt => $composableBuilder(
      column: $table.lastPushedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteRevision => $composableBuilder(
      column: $table.remoteRevision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));
}

class $$ProviderItemLinksCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ProviderItemLinksCacheTable> {
  $$ProviderItemLinksCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get remoteItemId => $composableBuilder(
      column: $table.remoteItemId, builder: (column) => column);

  GeneratedColumn<String> get remoteEntryId => $composableBuilder(
      column: $table.remoteEntryId, builder: (column) => column);

  GeneratedColumn<String> get localEntityRefJson => $composableBuilder(
      column: $table.localEntityRefJson, builder: (column) => column);

  GeneratedColumn<String> get baseSnapshotJson => $composableBuilder(
      column: $table.baseSnapshotJson, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPulledAt => $composableBuilder(
      column: $table.lastPulledAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPushedAt => $composableBuilder(
      column: $table.lastPushedAt, builder: (column) => column);

  GeneratedColumn<String> get remoteRevision => $composableBuilder(
      column: $table.remoteRevision, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);
}

class $$ProviderItemLinksCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $ProviderItemLinksCacheTable,
    ProviderItemLinksCacheData,
    $$ProviderItemLinksCacheTableFilterComposer,
    $$ProviderItemLinksCacheTableOrderingComposer,
    $$ProviderItemLinksCacheTableAnnotationComposer,
    $$ProviderItemLinksCacheTableCreateCompanionBuilder,
    $$ProviderItemLinksCacheTableUpdateCompanionBuilder,
    (
      ProviderItemLinksCacheData,
      BaseReferences<_$LocalDatabase, $ProviderItemLinksCacheTable,
          ProviderItemLinksCacheData>
    ),
    ProviderItemLinksCacheData,
    PrefetchHooks Function()> {
  $$ProviderItemLinksCacheTableTableManager(
      _$LocalDatabase db, $ProviderItemLinksCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProviderItemLinksCacheTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ProviderItemLinksCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProviderItemLinksCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> accountId = const Value.absent(),
            Value<String> provider = const Value.absent(),
            Value<String> remoteItemId = const Value.absent(),
            Value<String?> remoteEntryId = const Value.absent(),
            Value<String> localEntityRefJson = const Value.absent(),
            Value<String?> baseSnapshotJson = const Value.absent(),
            Value<DateTime?> lastPulledAt = const Value.absent(),
            Value<DateTime?> lastPushedAt = const Value.absent(),
            Value<String?> remoteRevision = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProviderItemLinksCacheCompanion(
            accountId: accountId,
            provider: provider,
            remoteItemId: remoteItemId,
            remoteEntryId: remoteEntryId,
            localEntityRefJson: localEntityRefJson,
            baseSnapshotJson: baseSnapshotJson,
            lastPulledAt: lastPulledAt,
            lastPushedAt: lastPushedAt,
            remoteRevision: remoteRevision,
            metadataJson: metadataJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String accountId,
            required String provider,
            required String remoteItemId,
            Value<String?> remoteEntryId = const Value.absent(),
            required String localEntityRefJson,
            Value<String?> baseSnapshotJson = const Value.absent(),
            Value<DateTime?> lastPulledAt = const Value.absent(),
            Value<DateTime?> lastPushedAt = const Value.absent(),
            Value<String?> remoteRevision = const Value.absent(),
            required String metadataJson,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProviderItemLinksCacheCompanion.insert(
            accountId: accountId,
            provider: provider,
            remoteItemId: remoteItemId,
            remoteEntryId: remoteEntryId,
            localEntityRefJson: localEntityRefJson,
            baseSnapshotJson: baseSnapshotJson,
            lastPulledAt: lastPulledAt,
            lastPushedAt: lastPushedAt,
            remoteRevision: remoteRevision,
            metadataJson: metadataJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProviderItemLinksCacheTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $ProviderItemLinksCacheTable,
        ProviderItemLinksCacheData,
        $$ProviderItemLinksCacheTableFilterComposer,
        $$ProviderItemLinksCacheTableOrderingComposer,
        $$ProviderItemLinksCacheTableAnnotationComposer,
        $$ProviderItemLinksCacheTableCreateCompanionBuilder,
        $$ProviderItemLinksCacheTableUpdateCompanionBuilder,
        (
          ProviderItemLinksCacheData,
          BaseReferences<_$LocalDatabase, $ProviderItemLinksCacheTable,
              ProviderItemLinksCacheData>
        ),
        ProviderItemLinksCacheData,
        PrefetchHooks Function()>;
typedef $$ComicMediaRowsTableCreateCompanionBuilder = ComicMediaRowsCompanion
    Function({
  required String id,
  required String title,
  Value<String?> sortTitle,
  Value<String?> seriesTitle,
  Value<String?> issueNumber,
  Value<String?> publisher,
  Value<String?> imprint,
  Value<DateTime?> releaseDate,
  Value<DateTime?> coverDate,
  Value<int?> pageCount,
  Value<String> country,
  Value<String> language,
  Value<String?> ageRating,
  Value<String?> crossover,
  Value<String?> synopsis,
  Value<String> genresJson,
  Value<String> searchAliasesJson,
  Value<String> writersJson,
  Value<String> artistsJson,
  Value<String> inkersJson,
  Value<String> coloristsJson,
  Value<String> letterersJson,
  Value<String> editorsJson,
  Value<String> coverArtistsJson,
  Value<String> creatorCreditsJson,
  Value<String> charactersJson,
  Value<String> characterDetailsJson,
  Value<String> creatorsJson,
  Value<String> storyArcsJson,
  Value<String> keyEventsJson,
  Value<bool> isKeyComic,
  Value<String?> keyReason,
  Value<String?> variant,
  Value<String?> variantDescription,
  Value<String?> barcode,
  Value<String?> seriesJson,
  Value<String?> publishingJson,
  Value<String?> editionTitle,
  Value<String?> titleExtension,
  Value<String?> physicalFormat,
  Value<String?> physicalFormatLabel,
  Value<String> linksJson,
  Value<String> rawPayloadJson,
  Value<int> rowid,
});
typedef $$ComicMediaRowsTableUpdateCompanionBuilder = ComicMediaRowsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String?> sortTitle,
  Value<String?> seriesTitle,
  Value<String?> issueNumber,
  Value<String?> publisher,
  Value<String?> imprint,
  Value<DateTime?> releaseDate,
  Value<DateTime?> coverDate,
  Value<int?> pageCount,
  Value<String> country,
  Value<String> language,
  Value<String?> ageRating,
  Value<String?> crossover,
  Value<String?> synopsis,
  Value<String> genresJson,
  Value<String> searchAliasesJson,
  Value<String> writersJson,
  Value<String> artistsJson,
  Value<String> inkersJson,
  Value<String> coloristsJson,
  Value<String> letterersJson,
  Value<String> editorsJson,
  Value<String> coverArtistsJson,
  Value<String> creatorCreditsJson,
  Value<String> charactersJson,
  Value<String> characterDetailsJson,
  Value<String> creatorsJson,
  Value<String> storyArcsJson,
  Value<String> keyEventsJson,
  Value<bool> isKeyComic,
  Value<String?> keyReason,
  Value<String?> variant,
  Value<String?> variantDescription,
  Value<String?> barcode,
  Value<String?> seriesJson,
  Value<String?> publishingJson,
  Value<String?> editionTitle,
  Value<String?> titleExtension,
  Value<String?> physicalFormat,
  Value<String?> physicalFormatLabel,
  Value<String> linksJson,
  Value<String> rawPayloadJson,
  Value<int> rowid,
});

class $$ComicMediaRowsTableFilterComposer
    extends Composer<_$LocalDatabase, $ComicMediaRowsTable> {
  $$ComicMediaRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sortTitle => $composableBuilder(
      column: $table.sortTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seriesTitle => $composableBuilder(
      column: $table.seriesTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get issueNumber => $composableBuilder(
      column: $table.issueNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get publisher => $composableBuilder(
      column: $table.publisher, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imprint => $composableBuilder(
      column: $table.imprint, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get releaseDate => $composableBuilder(
      column: $table.releaseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get coverDate => $composableBuilder(
      column: $table.coverDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get country => $composableBuilder(
      column: $table.country, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ageRating => $composableBuilder(
      column: $table.ageRating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get crossover => $composableBuilder(
      column: $table.crossover, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get synopsis => $composableBuilder(
      column: $table.synopsis, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get genresJson => $composableBuilder(
      column: $table.genresJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get searchAliasesJson => $composableBuilder(
      column: $table.searchAliasesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get writersJson => $composableBuilder(
      column: $table.writersJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artistsJson => $composableBuilder(
      column: $table.artistsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inkersJson => $composableBuilder(
      column: $table.inkersJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coloristsJson => $composableBuilder(
      column: $table.coloristsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get letterersJson => $composableBuilder(
      column: $table.letterersJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editorsJson => $composableBuilder(
      column: $table.editorsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverArtistsJson => $composableBuilder(
      column: $table.coverArtistsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get creatorCreditsJson => $composableBuilder(
      column: $table.creatorCreditsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get charactersJson => $composableBuilder(
      column: $table.charactersJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get characterDetailsJson => $composableBuilder(
      column: $table.characterDetailsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get creatorsJson => $composableBuilder(
      column: $table.creatorsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storyArcsJson => $composableBuilder(
      column: $table.storyArcsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get keyEventsJson => $composableBuilder(
      column: $table.keyEventsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isKeyComic => $composableBuilder(
      column: $table.isKeyComic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get keyReason => $composableBuilder(
      column: $table.keyReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variant => $composableBuilder(
      column: $table.variant, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantDescription => $composableBuilder(
      column: $table.variantDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seriesJson => $composableBuilder(
      column: $table.seriesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get publishingJson => $composableBuilder(
      column: $table.publishingJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editionTitle => $composableBuilder(
      column: $table.editionTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titleExtension => $composableBuilder(
      column: $table.titleExtension,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get physicalFormat => $composableBuilder(
      column: $table.physicalFormat,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get physicalFormatLabel => $composableBuilder(
      column: $table.physicalFormatLabel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linksJson => $composableBuilder(
      column: $table.linksJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawPayloadJson => $composableBuilder(
      column: $table.rawPayloadJson,
      builder: (column) => ColumnFilters(column));
}

class $$ComicMediaRowsTableOrderingComposer
    extends Composer<_$LocalDatabase, $ComicMediaRowsTable> {
  $$ComicMediaRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sortTitle => $composableBuilder(
      column: $table.sortTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seriesTitle => $composableBuilder(
      column: $table.seriesTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get issueNumber => $composableBuilder(
      column: $table.issueNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get publisher => $composableBuilder(
      column: $table.publisher, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imprint => $composableBuilder(
      column: $table.imprint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get releaseDate => $composableBuilder(
      column: $table.releaseDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get coverDate => $composableBuilder(
      column: $table.coverDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get country => $composableBuilder(
      column: $table.country, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ageRating => $composableBuilder(
      column: $table.ageRating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get crossover => $composableBuilder(
      column: $table.crossover, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get synopsis => $composableBuilder(
      column: $table.synopsis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get genresJson => $composableBuilder(
      column: $table.genresJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get searchAliasesJson => $composableBuilder(
      column: $table.searchAliasesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get writersJson => $composableBuilder(
      column: $table.writersJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artistsJson => $composableBuilder(
      column: $table.artistsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inkersJson => $composableBuilder(
      column: $table.inkersJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coloristsJson => $composableBuilder(
      column: $table.coloristsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get letterersJson => $composableBuilder(
      column: $table.letterersJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editorsJson => $composableBuilder(
      column: $table.editorsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverArtistsJson => $composableBuilder(
      column: $table.coverArtistsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get creatorCreditsJson => $composableBuilder(
      column: $table.creatorCreditsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get charactersJson => $composableBuilder(
      column: $table.charactersJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get characterDetailsJson => $composableBuilder(
      column: $table.characterDetailsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get creatorsJson => $composableBuilder(
      column: $table.creatorsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storyArcsJson => $composableBuilder(
      column: $table.storyArcsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get keyEventsJson => $composableBuilder(
      column: $table.keyEventsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isKeyComic => $composableBuilder(
      column: $table.isKeyComic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get keyReason => $composableBuilder(
      column: $table.keyReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variant => $composableBuilder(
      column: $table.variant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantDescription => $composableBuilder(
      column: $table.variantDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seriesJson => $composableBuilder(
      column: $table.seriesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get publishingJson => $composableBuilder(
      column: $table.publishingJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editionTitle => $composableBuilder(
      column: $table.editionTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titleExtension => $composableBuilder(
      column: $table.titleExtension,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get physicalFormat => $composableBuilder(
      column: $table.physicalFormat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get physicalFormatLabel => $composableBuilder(
      column: $table.physicalFormatLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linksJson => $composableBuilder(
      column: $table.linksJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawPayloadJson => $composableBuilder(
      column: $table.rawPayloadJson,
      builder: (column) => ColumnOrderings(column));
}

class $$ComicMediaRowsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ComicMediaRowsTable> {
  $$ComicMediaRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get sortTitle =>
      $composableBuilder(column: $table.sortTitle, builder: (column) => column);

  GeneratedColumn<String> get seriesTitle => $composableBuilder(
      column: $table.seriesTitle, builder: (column) => column);

  GeneratedColumn<String> get issueNumber => $composableBuilder(
      column: $table.issueNumber, builder: (column) => column);

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<String> get imprint =>
      $composableBuilder(column: $table.imprint, builder: (column) => column);

  GeneratedColumn<DateTime> get releaseDate => $composableBuilder(
      column: $table.releaseDate, builder: (column) => column);

  GeneratedColumn<DateTime> get coverDate =>
      $composableBuilder(column: $table.coverDate, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get ageRating =>
      $composableBuilder(column: $table.ageRating, builder: (column) => column);

  GeneratedColumn<String> get crossover =>
      $composableBuilder(column: $table.crossover, builder: (column) => column);

  GeneratedColumn<String> get synopsis =>
      $composableBuilder(column: $table.synopsis, builder: (column) => column);

  GeneratedColumn<String> get genresJson => $composableBuilder(
      column: $table.genresJson, builder: (column) => column);

  GeneratedColumn<String> get searchAliasesJson => $composableBuilder(
      column: $table.searchAliasesJson, builder: (column) => column);

  GeneratedColumn<String> get writersJson => $composableBuilder(
      column: $table.writersJson, builder: (column) => column);

  GeneratedColumn<String> get artistsJson => $composableBuilder(
      column: $table.artistsJson, builder: (column) => column);

  GeneratedColumn<String> get inkersJson => $composableBuilder(
      column: $table.inkersJson, builder: (column) => column);

  GeneratedColumn<String> get coloristsJson => $composableBuilder(
      column: $table.coloristsJson, builder: (column) => column);

  GeneratedColumn<String> get letterersJson => $composableBuilder(
      column: $table.letterersJson, builder: (column) => column);

  GeneratedColumn<String> get editorsJson => $composableBuilder(
      column: $table.editorsJson, builder: (column) => column);

  GeneratedColumn<String> get coverArtistsJson => $composableBuilder(
      column: $table.coverArtistsJson, builder: (column) => column);

  GeneratedColumn<String> get creatorCreditsJson => $composableBuilder(
      column: $table.creatorCreditsJson, builder: (column) => column);

  GeneratedColumn<String> get charactersJson => $composableBuilder(
      column: $table.charactersJson, builder: (column) => column);

  GeneratedColumn<String> get characterDetailsJson => $composableBuilder(
      column: $table.characterDetailsJson, builder: (column) => column);

  GeneratedColumn<String> get creatorsJson => $composableBuilder(
      column: $table.creatorsJson, builder: (column) => column);

  GeneratedColumn<String> get storyArcsJson => $composableBuilder(
      column: $table.storyArcsJson, builder: (column) => column);

  GeneratedColumn<String> get keyEventsJson => $composableBuilder(
      column: $table.keyEventsJson, builder: (column) => column);

  GeneratedColumn<bool> get isKeyComic => $composableBuilder(
      column: $table.isKeyComic, builder: (column) => column);

  GeneratedColumn<String> get keyReason =>
      $composableBuilder(column: $table.keyReason, builder: (column) => column);

  GeneratedColumn<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => column);

  GeneratedColumn<String> get variantDescription => $composableBuilder(
      column: $table.variantDescription, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get seriesJson => $composableBuilder(
      column: $table.seriesJson, builder: (column) => column);

  GeneratedColumn<String> get publishingJson => $composableBuilder(
      column: $table.publishingJson, builder: (column) => column);

  GeneratedColumn<String> get editionTitle => $composableBuilder(
      column: $table.editionTitle, builder: (column) => column);

  GeneratedColumn<String> get titleExtension => $composableBuilder(
      column: $table.titleExtension, builder: (column) => column);

  GeneratedColumn<String> get physicalFormat => $composableBuilder(
      column: $table.physicalFormat, builder: (column) => column);

  GeneratedColumn<String> get physicalFormatLabel => $composableBuilder(
      column: $table.physicalFormatLabel, builder: (column) => column);

  GeneratedColumn<String> get linksJson =>
      $composableBuilder(column: $table.linksJson, builder: (column) => column);

  GeneratedColumn<String> get rawPayloadJson => $composableBuilder(
      column: $table.rawPayloadJson, builder: (column) => column);
}

class $$ComicMediaRowsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $ComicMediaRowsTable,
    ComicMediaRow,
    $$ComicMediaRowsTableFilterComposer,
    $$ComicMediaRowsTableOrderingComposer,
    $$ComicMediaRowsTableAnnotationComposer,
    $$ComicMediaRowsTableCreateCompanionBuilder,
    $$ComicMediaRowsTableUpdateCompanionBuilder,
    (
      ComicMediaRow,
      BaseReferences<_$LocalDatabase, $ComicMediaRowsTable, ComicMediaRow>
    ),
    ComicMediaRow,
    PrefetchHooks Function()> {
  $$ComicMediaRowsTableTableManager(
      _$LocalDatabase db, $ComicMediaRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComicMediaRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComicMediaRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComicMediaRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> sortTitle = const Value.absent(),
            Value<String?> seriesTitle = const Value.absent(),
            Value<String?> issueNumber = const Value.absent(),
            Value<String?> publisher = const Value.absent(),
            Value<String?> imprint = const Value.absent(),
            Value<DateTime?> releaseDate = const Value.absent(),
            Value<DateTime?> coverDate = const Value.absent(),
            Value<int?> pageCount = const Value.absent(),
            Value<String> country = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String?> ageRating = const Value.absent(),
            Value<String?> crossover = const Value.absent(),
            Value<String?> synopsis = const Value.absent(),
            Value<String> genresJson = const Value.absent(),
            Value<String> searchAliasesJson = const Value.absent(),
            Value<String> writersJson = const Value.absent(),
            Value<String> artistsJson = const Value.absent(),
            Value<String> inkersJson = const Value.absent(),
            Value<String> coloristsJson = const Value.absent(),
            Value<String> letterersJson = const Value.absent(),
            Value<String> editorsJson = const Value.absent(),
            Value<String> coverArtistsJson = const Value.absent(),
            Value<String> creatorCreditsJson = const Value.absent(),
            Value<String> charactersJson = const Value.absent(),
            Value<String> characterDetailsJson = const Value.absent(),
            Value<String> creatorsJson = const Value.absent(),
            Value<String> storyArcsJson = const Value.absent(),
            Value<String> keyEventsJson = const Value.absent(),
            Value<bool> isKeyComic = const Value.absent(),
            Value<String?> keyReason = const Value.absent(),
            Value<String?> variant = const Value.absent(),
            Value<String?> variantDescription = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String?> seriesJson = const Value.absent(),
            Value<String?> publishingJson = const Value.absent(),
            Value<String?> editionTitle = const Value.absent(),
            Value<String?> titleExtension = const Value.absent(),
            Value<String?> physicalFormat = const Value.absent(),
            Value<String?> physicalFormatLabel = const Value.absent(),
            Value<String> linksJson = const Value.absent(),
            Value<String> rawPayloadJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ComicMediaRowsCompanion(
            id: id,
            title: title,
            sortTitle: sortTitle,
            seriesTitle: seriesTitle,
            issueNumber: issueNumber,
            publisher: publisher,
            imprint: imprint,
            releaseDate: releaseDate,
            coverDate: coverDate,
            pageCount: pageCount,
            country: country,
            language: language,
            ageRating: ageRating,
            crossover: crossover,
            synopsis: synopsis,
            genresJson: genresJson,
            searchAliasesJson: searchAliasesJson,
            writersJson: writersJson,
            artistsJson: artistsJson,
            inkersJson: inkersJson,
            coloristsJson: coloristsJson,
            letterersJson: letterersJson,
            editorsJson: editorsJson,
            coverArtistsJson: coverArtistsJson,
            creatorCreditsJson: creatorCreditsJson,
            charactersJson: charactersJson,
            characterDetailsJson: characterDetailsJson,
            creatorsJson: creatorsJson,
            storyArcsJson: storyArcsJson,
            keyEventsJson: keyEventsJson,
            isKeyComic: isKeyComic,
            keyReason: keyReason,
            variant: variant,
            variantDescription: variantDescription,
            barcode: barcode,
            seriesJson: seriesJson,
            publishingJson: publishingJson,
            editionTitle: editionTitle,
            titleExtension: titleExtension,
            physicalFormat: physicalFormat,
            physicalFormatLabel: physicalFormatLabel,
            linksJson: linksJson,
            rawPayloadJson: rawPayloadJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> sortTitle = const Value.absent(),
            Value<String?> seriesTitle = const Value.absent(),
            Value<String?> issueNumber = const Value.absent(),
            Value<String?> publisher = const Value.absent(),
            Value<String?> imprint = const Value.absent(),
            Value<DateTime?> releaseDate = const Value.absent(),
            Value<DateTime?> coverDate = const Value.absent(),
            Value<int?> pageCount = const Value.absent(),
            Value<String> country = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String?> ageRating = const Value.absent(),
            Value<String?> crossover = const Value.absent(),
            Value<String?> synopsis = const Value.absent(),
            Value<String> genresJson = const Value.absent(),
            Value<String> searchAliasesJson = const Value.absent(),
            Value<String> writersJson = const Value.absent(),
            Value<String> artistsJson = const Value.absent(),
            Value<String> inkersJson = const Value.absent(),
            Value<String> coloristsJson = const Value.absent(),
            Value<String> letterersJson = const Value.absent(),
            Value<String> editorsJson = const Value.absent(),
            Value<String> coverArtistsJson = const Value.absent(),
            Value<String> creatorCreditsJson = const Value.absent(),
            Value<String> charactersJson = const Value.absent(),
            Value<String> characterDetailsJson = const Value.absent(),
            Value<String> creatorsJson = const Value.absent(),
            Value<String> storyArcsJson = const Value.absent(),
            Value<String> keyEventsJson = const Value.absent(),
            Value<bool> isKeyComic = const Value.absent(),
            Value<String?> keyReason = const Value.absent(),
            Value<String?> variant = const Value.absent(),
            Value<String?> variantDescription = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String?> seriesJson = const Value.absent(),
            Value<String?> publishingJson = const Value.absent(),
            Value<String?> editionTitle = const Value.absent(),
            Value<String?> titleExtension = const Value.absent(),
            Value<String?> physicalFormat = const Value.absent(),
            Value<String?> physicalFormatLabel = const Value.absent(),
            Value<String> linksJson = const Value.absent(),
            Value<String> rawPayloadJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ComicMediaRowsCompanion.insert(
            id: id,
            title: title,
            sortTitle: sortTitle,
            seriesTitle: seriesTitle,
            issueNumber: issueNumber,
            publisher: publisher,
            imprint: imprint,
            releaseDate: releaseDate,
            coverDate: coverDate,
            pageCount: pageCount,
            country: country,
            language: language,
            ageRating: ageRating,
            crossover: crossover,
            synopsis: synopsis,
            genresJson: genresJson,
            searchAliasesJson: searchAliasesJson,
            writersJson: writersJson,
            artistsJson: artistsJson,
            inkersJson: inkersJson,
            coloristsJson: coloristsJson,
            letterersJson: letterersJson,
            editorsJson: editorsJson,
            coverArtistsJson: coverArtistsJson,
            creatorCreditsJson: creatorCreditsJson,
            charactersJson: charactersJson,
            characterDetailsJson: characterDetailsJson,
            creatorsJson: creatorsJson,
            storyArcsJson: storyArcsJson,
            keyEventsJson: keyEventsJson,
            isKeyComic: isKeyComic,
            keyReason: keyReason,
            variant: variant,
            variantDescription: variantDescription,
            barcode: barcode,
            seriesJson: seriesJson,
            publishingJson: publishingJson,
            editionTitle: editionTitle,
            titleExtension: titleExtension,
            physicalFormat: physicalFormat,
            physicalFormatLabel: physicalFormatLabel,
            linksJson: linksJson,
            rawPayloadJson: rawPayloadJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ComicMediaRowsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $ComicMediaRowsTable,
    ComicMediaRow,
    $$ComicMediaRowsTableFilterComposer,
    $$ComicMediaRowsTableOrderingComposer,
    $$ComicMediaRowsTableAnnotationComposer,
    $$ComicMediaRowsTableCreateCompanionBuilder,
    $$ComicMediaRowsTableUpdateCompanionBuilder,
    (
      ComicMediaRow,
      BaseReferences<_$LocalDatabase, $ComicMediaRowsTable, ComicMediaRow>
    ),
    ComicMediaRow,
    PrefetchHooks Function()>;
typedef $$ComicReleaseRowsTableCreateCompanionBuilder
    = ComicReleaseRowsCompanion Function({
  required String mediaId,
  required String id,
  required String title,
  Value<String?> publisher,
  Value<String?> imprint,
  Value<String?> isbn,
  Value<String?> upc,
  Value<DateTime?> releaseDate,
  Value<String?> coverImageUrl,
  Value<String> variantsJson,
  Value<int> rowid,
});
typedef $$ComicReleaseRowsTableUpdateCompanionBuilder
    = ComicReleaseRowsCompanion Function({
  Value<String> mediaId,
  Value<String> id,
  Value<String> title,
  Value<String?> publisher,
  Value<String?> imprint,
  Value<String?> isbn,
  Value<String?> upc,
  Value<DateTime?> releaseDate,
  Value<String?> coverImageUrl,
  Value<String> variantsJson,
  Value<int> rowid,
});

class $$ComicReleaseRowsTableFilterComposer
    extends Composer<_$LocalDatabase, $ComicReleaseRowsTable> {
  $$ComicReleaseRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get publisher => $composableBuilder(
      column: $table.publisher, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imprint => $composableBuilder(
      column: $table.imprint, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get isbn => $composableBuilder(
      column: $table.isbn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get upc => $composableBuilder(
      column: $table.upc, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get releaseDate => $composableBuilder(
      column: $table.releaseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantsJson => $composableBuilder(
      column: $table.variantsJson, builder: (column) => ColumnFilters(column));
}

class $$ComicReleaseRowsTableOrderingComposer
    extends Composer<_$LocalDatabase, $ComicReleaseRowsTable> {
  $$ComicReleaseRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get publisher => $composableBuilder(
      column: $table.publisher, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imprint => $composableBuilder(
      column: $table.imprint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get isbn => $composableBuilder(
      column: $table.isbn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get upc => $composableBuilder(
      column: $table.upc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get releaseDate => $composableBuilder(
      column: $table.releaseDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantsJson => $composableBuilder(
      column: $table.variantsJson,
      builder: (column) => ColumnOrderings(column));
}

class $$ComicReleaseRowsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ComicReleaseRowsTable> {
  $$ComicReleaseRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<String> get imprint =>
      $composableBuilder(column: $table.imprint, builder: (column) => column);

  GeneratedColumn<String> get isbn =>
      $composableBuilder(column: $table.isbn, builder: (column) => column);

  GeneratedColumn<String> get upc =>
      $composableBuilder(column: $table.upc, builder: (column) => column);

  GeneratedColumn<DateTime> get releaseDate => $composableBuilder(
      column: $table.releaseDate, builder: (column) => column);

  GeneratedColumn<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => column);

  GeneratedColumn<String> get variantsJson => $composableBuilder(
      column: $table.variantsJson, builder: (column) => column);
}

class $$ComicReleaseRowsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $ComicReleaseRowsTable,
    ComicReleaseRow,
    $$ComicReleaseRowsTableFilterComposer,
    $$ComicReleaseRowsTableOrderingComposer,
    $$ComicReleaseRowsTableAnnotationComposer,
    $$ComicReleaseRowsTableCreateCompanionBuilder,
    $$ComicReleaseRowsTableUpdateCompanionBuilder,
    (
      ComicReleaseRow,
      BaseReferences<_$LocalDatabase, $ComicReleaseRowsTable, ComicReleaseRow>
    ),
    ComicReleaseRow,
    PrefetchHooks Function()> {
  $$ComicReleaseRowsTableTableManager(
      _$LocalDatabase db, $ComicReleaseRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComicReleaseRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComicReleaseRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComicReleaseRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> mediaId = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> publisher = const Value.absent(),
            Value<String?> imprint = const Value.absent(),
            Value<String?> isbn = const Value.absent(),
            Value<String?> upc = const Value.absent(),
            Value<DateTime?> releaseDate = const Value.absent(),
            Value<String?> coverImageUrl = const Value.absent(),
            Value<String> variantsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ComicReleaseRowsCompanion(
            mediaId: mediaId,
            id: id,
            title: title,
            publisher: publisher,
            imprint: imprint,
            isbn: isbn,
            upc: upc,
            releaseDate: releaseDate,
            coverImageUrl: coverImageUrl,
            variantsJson: variantsJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String mediaId,
            required String id,
            required String title,
            Value<String?> publisher = const Value.absent(),
            Value<String?> imprint = const Value.absent(),
            Value<String?> isbn = const Value.absent(),
            Value<String?> upc = const Value.absent(),
            Value<DateTime?> releaseDate = const Value.absent(),
            Value<String?> coverImageUrl = const Value.absent(),
            Value<String> variantsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ComicReleaseRowsCompanion.insert(
            mediaId: mediaId,
            id: id,
            title: title,
            publisher: publisher,
            imprint: imprint,
            isbn: isbn,
            upc: upc,
            releaseDate: releaseDate,
            coverImageUrl: coverImageUrl,
            variantsJson: variantsJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ComicReleaseRowsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $ComicReleaseRowsTable,
    ComicReleaseRow,
    $$ComicReleaseRowsTableFilterComposer,
    $$ComicReleaseRowsTableOrderingComposer,
    $$ComicReleaseRowsTableAnnotationComposer,
    $$ComicReleaseRowsTableCreateCompanionBuilder,
    $$ComicReleaseRowsTableUpdateCompanionBuilder,
    (
      ComicReleaseRow,
      BaseReferences<_$LocalDatabase, $ComicReleaseRowsTable, ComicReleaseRow>
    ),
    ComicReleaseRow,
    PrefetchHooks Function()>;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$CatalogCacheTableTableManager get catalogCache =>
      $$CatalogCacheTableTableManager(_db, _db.catalogCache);
  $$OwnedItemsCacheTableTableManager get ownedItemsCache =>
      $$OwnedItemsCacheTableTableManager(_db, _db.ownedItemsCache);
  $$WishlistItemsCacheTableTableManager get wishlistItemsCache =>
      $$WishlistItemsCacheTableTableManager(_db, _db.wishlistItemsCache);
  $$TrackingEntriesCacheTableTableManager get trackingEntriesCache =>
      $$TrackingEntriesCacheTableTableManager(_db, _db.trackingEntriesCache);
  $$TrackingUnitsCacheTableTableManager get trackingUnitsCache =>
      $$TrackingUnitsCacheTableTableManager(_db, _db.trackingUnitsCache);
  $$WatchSessionsCacheTableTableManager get watchSessionsCache =>
      $$WatchSessionsCacheTableTableManager(_db, _db.watchSessionsCache);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$UserMetadataOverridesCacheTableTableManager
      get userMetadataOverridesCache =>
          $$UserMetadataOverridesCacheTableTableManager(
              _db, _db.userMetadataOverridesCache);
  $$CustomEpisodesCacheTableTableManager get customEpisodesCache =>
      $$CustomEpisodesCacheTableTableManager(_db, _db.customEpisodesCache);
  $$UserExternalLinksCacheTableTableManager get userExternalLinksCache =>
      $$UserExternalLinksCacheTableTableManager(
          _db, _db.userExternalLinksCache);
  $$CustomFieldDefinitionsCacheTableTableManager
      get customFieldDefinitionsCache =>
          $$CustomFieldDefinitionsCacheTableTableManager(
              _db, _db.customFieldDefinitionsCache);
  $$CustomFieldValuesCacheTableTableManager get customFieldValuesCache =>
      $$CustomFieldValuesCacheTableTableManager(
          _db, _db.customFieldValuesCache);
  $$ItemImagesCacheTableTableManager get itemImagesCache =>
      $$ItemImagesCacheTableTableManager(_db, _db.itemImagesCache);
  $$LoansCacheTableTableManager get loansCache =>
      $$LoansCacheTableTableManager(_db, _db.loansCache);
  $$LocationsCacheTableTableManager get locationsCache =>
      $$LocationsCacheTableTableManager(_db, _db.locationsCache);
  $$SmartListsCacheTableTableManager get smartListsCache =>
      $$SmartListsCacheTableTableManager(_db, _db.smartListsCache);
  $$UserFoldersCacheTableTableManager get userFoldersCache =>
      $$UserFoldersCacheTableTableManager(_db, _db.userFoldersCache);
  $$UserFolderItemsCacheTableTableManager get userFolderItemsCache =>
      $$UserFolderItemsCacheTableTableManager(_db, _db.userFolderItemsCache);
  $$ReadingQueueCacheTableTableManager get readingQueueCache =>
      $$ReadingQueueCacheTableTableManager(_db, _db.readingQueueCache);
  $$PickListValuesCacheTableTableManager get pickListValuesCache =>
      $$PickListValuesCacheTableTableManager(_db, _db.pickListValuesCache);
  $$SerialAuthorityCacheTableTableManager get serialAuthorityCache =>
      $$SerialAuthorityCacheTableTableManager(_db, _db.serialAuthorityCache);
  $$ProviderAccountsCacheTableTableManager get providerAccountsCache =>
      $$ProviderAccountsCacheTableTableManager(_db, _db.providerAccountsCache);
  $$ProviderItemLinksCacheTableTableManager get providerItemLinksCache =>
      $$ProviderItemLinksCacheTableTableManager(
          _db, _db.providerItemLinksCache);
  $$ComicMediaRowsTableTableManager get comicMediaRows =>
      $$ComicMediaRowsTableTableManager(_db, _db.comicMediaRows);
  $$ComicReleaseRowsTableTableManager get comicReleaseRows =>
      $$ComicReleaseRowsTableTableManager(_db, _db.comicReleaseRows);
}
