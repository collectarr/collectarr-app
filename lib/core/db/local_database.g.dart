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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemNumberMeta =
      const VerificationMeta('itemNumber');
  @override
  late final GeneratedColumn<String> itemNumber = GeneratedColumn<String>(
      'item_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _synopsisMeta =
      const VerificationMeta('synopsis');
  @override
  late final GeneratedColumn<String> synopsis = GeneratedColumn<String>(
      'synopsis', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverImageUrlMeta =
      const VerificationMeta('coverImageUrl');
  @override
  late final GeneratedColumn<String> coverImageUrl = GeneratedColumn<String>(
      'cover_image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, kind, title, itemNumber, synopsis, coverImageUrl, cachedAt];
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
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('item_number')) {
      context.handle(
          _itemNumberMeta,
          itemNumber.isAcceptableOrUnknown(
              data['item_number']!, _itemNumberMeta));
    }
    if (data.containsKey('synopsis')) {
      context.handle(_synopsisMeta,
          synopsis.isAcceptableOrUnknown(data['synopsis']!, _synopsisMeta));
    }
    if (data.containsKey('cover_image_url')) {
      context.handle(
          _coverImageUrlMeta,
          coverImageUrl.isAcceptableOrUnknown(
              data['cover_image_url']!, _coverImageUrlMeta));
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
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      itemNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_number']),
      synopsis: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}synopsis']),
      coverImageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_image_url']),
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
  final String title;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;
  final DateTime cachedAt;
  const CatalogCacheData(
      {required this.id,
      required this.kind,
      required this.title,
      this.itemNumber,
      this.synopsis,
      this.coverImageUrl,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || itemNumber != null) {
      map['item_number'] = Variable<String>(itemNumber);
    }
    if (!nullToAbsent || synopsis != null) {
      map['synopsis'] = Variable<String>(synopsis);
    }
    if (!nullToAbsent || coverImageUrl != null) {
      map['cover_image_url'] = Variable<String>(coverImageUrl);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CatalogCacheCompanion toCompanion(bool nullToAbsent) {
    return CatalogCacheCompanion(
      id: Value(id),
      kind: Value(kind),
      title: Value(title),
      itemNumber: itemNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(itemNumber),
      synopsis: synopsis == null && nullToAbsent
          ? const Value.absent()
          : Value(synopsis),
      coverImageUrl: coverImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImageUrl),
      cachedAt: Value(cachedAt),
    );
  }

  factory CatalogCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogCacheData(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      itemNumber: serializer.fromJson<String?>(json['itemNumber']),
      synopsis: serializer.fromJson<String?>(json['synopsis']),
      coverImageUrl: serializer.fromJson<String?>(json['coverImageUrl']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'itemNumber': serializer.toJson<String?>(itemNumber),
      'synopsis': serializer.toJson<String?>(synopsis),
      'coverImageUrl': serializer.toJson<String?>(coverImageUrl),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CatalogCacheData copyWith(
          {String? id,
          String? kind,
          String? title,
          Value<String?> itemNumber = const Value.absent(),
          Value<String?> synopsis = const Value.absent(),
          Value<String?> coverImageUrl = const Value.absent(),
          DateTime? cachedAt}) =>
      CatalogCacheData(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        title: title ?? this.title,
        itemNumber: itemNumber.present ? itemNumber.value : this.itemNumber,
        synopsis: synopsis.present ? synopsis.value : this.synopsis,
        coverImageUrl:
            coverImageUrl.present ? coverImageUrl.value : this.coverImageUrl,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CatalogCacheData copyWithCompanion(CatalogCacheCompanion data) {
    return CatalogCacheData(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      itemNumber:
          data.itemNumber.present ? data.itemNumber.value : this.itemNumber,
      synopsis: data.synopsis.present ? data.synopsis.value : this.synopsis,
      coverImageUrl: data.coverImageUrl.present
          ? data.coverImageUrl.value
          : this.coverImageUrl,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCacheData(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('itemNumber: $itemNumber, ')
          ..write('synopsis: $synopsis, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, kind, title, itemNumber, synopsis, coverImageUrl, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogCacheData &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.itemNumber == this.itemNumber &&
          other.synopsis == this.synopsis &&
          other.coverImageUrl == this.coverImageUrl &&
          other.cachedAt == this.cachedAt);
}

class CatalogCacheCompanion extends UpdateCompanion<CatalogCacheData> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> title;
  final Value<String?> itemNumber;
  final Value<String?> synopsis;
  final Value<String?> coverImageUrl;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CatalogCacheCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.itemNumber = const Value.absent(),
    this.synopsis = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogCacheCompanion.insert({
    required String id,
    required String kind,
    required String title,
    this.itemNumber = const Value.absent(),
    this.synopsis = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        kind = Value(kind),
        title = Value(title),
        cachedAt = Value(cachedAt);
  static Insertable<CatalogCacheData> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? itemNumber,
    Expression<String>? synopsis,
    Expression<String>? coverImageUrl,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (itemNumber != null) 'item_number': itemNumber,
      if (synopsis != null) 'synopsis': synopsis,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? kind,
      Value<String>? title,
      Value<String?>? itemNumber,
      Value<String?>? synopsis,
      Value<String?>? coverImageUrl,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return CatalogCacheCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      itemNumber: itemNumber ?? this.itemNumber,
      synopsis: synopsis ?? this.synopsis,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (itemNumber.present) {
      map['item_number'] = Variable<String>(itemNumber.value);
    }
    if (synopsis.present) {
      map['synopsis'] = Variable<String>(synopsis.value);
    }
    if (coverImageUrl.present) {
      map['cover_image_url'] = Variable<String>(coverImageUrl.value);
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
          ..write('title: $title, ')
          ..write('itemNumber: $itemNumber, ')
          ..write('synopsis: $synopsis, ')
          ..write('coverImageUrl: $coverImageUrl, ')
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
        condition,
        grade,
        purchaseDate,
        pricePaidCents,
        currency,
        personalNotes,
        updatedAt,
        deletedAt
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
    if (data.containsKey('edition_id')) {
      context.handle(_editionIdMeta,
          editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta));
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
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
  OwnedItemsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OwnedItemsCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      editionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edition_id']),
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
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
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
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
  final String? editionId;
  final String? variantId;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const OwnedItemsCacheData(
      {required this.id,
      required this.itemId,
      this.editionId,
      this.variantId,
      this.condition,
      this.grade,
      this.purchaseDate,
      this.pricePaidCents,
      this.currency,
      this.personalNotes,
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
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  OwnedItemsCacheCompanion toCompanion(bool nullToAbsent) {
    return OwnedItemsCacheCompanion(
      id: Value(id),
      itemId: Value(itemId),
      editionId: editionId == null && nullToAbsent
          ? const Value.absent()
          : Value(editionId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
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
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory OwnedItemsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OwnedItemsCacheData(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      editionId: serializer.fromJson<String?>(json['editionId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      condition: serializer.fromJson<String?>(json['condition']),
      grade: serializer.fromJson<String?>(json['grade']),
      purchaseDate: serializer.fromJson<DateTime?>(json['purchaseDate']),
      pricePaidCents: serializer.fromJson<int?>(json['pricePaidCents']),
      currency: serializer.fromJson<String?>(json['currency']),
      personalNotes: serializer.fromJson<String?>(json['personalNotes']),
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
      'condition': serializer.toJson<String?>(condition),
      'grade': serializer.toJson<String?>(grade),
      'purchaseDate': serializer.toJson<DateTime?>(purchaseDate),
      'pricePaidCents': serializer.toJson<int?>(pricePaidCents),
      'currency': serializer.toJson<String?>(currency),
      'personalNotes': serializer.toJson<String?>(personalNotes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  OwnedItemsCacheData copyWith(
          {String? id,
          String? itemId,
          Value<String?> editionId = const Value.absent(),
          Value<String?> variantId = const Value.absent(),
          Value<String?> condition = const Value.absent(),
          Value<String?> grade = const Value.absent(),
          Value<DateTime?> purchaseDate = const Value.absent(),
          Value<int?> pricePaidCents = const Value.absent(),
          Value<String?> currency = const Value.absent(),
          Value<String?> personalNotes = const Value.absent(),
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      OwnedItemsCacheData(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        editionId: editionId.present ? editionId.value : this.editionId,
        variantId: variantId.present ? variantId.value : this.variantId,
        condition: condition.present ? condition.value : this.condition,
        grade: grade.present ? grade.value : this.grade,
        purchaseDate:
            purchaseDate.present ? purchaseDate.value : this.purchaseDate,
        pricePaidCents:
            pricePaidCents.present ? pricePaidCents.value : this.pricePaidCents,
        currency: currency.present ? currency.value : this.currency,
        personalNotes:
            personalNotes.present ? personalNotes.value : this.personalNotes,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  OwnedItemsCacheData copyWithCompanion(OwnedItemsCacheCompanion data) {
    return OwnedItemsCacheData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
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
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OwnedItemsCacheData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('condition: $condition, ')
          ..write('grade: $grade, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('pricePaidCents: $pricePaidCents, ')
          ..write('currency: $currency, ')
          ..write('personalNotes: $personalNotes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      itemId,
      editionId,
      variantId,
      condition,
      grade,
      purchaseDate,
      pricePaidCents,
      currency,
      personalNotes,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OwnedItemsCacheData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.editionId == this.editionId &&
          other.variantId == this.variantId &&
          other.condition == this.condition &&
          other.grade == this.grade &&
          other.purchaseDate == this.purchaseDate &&
          other.pricePaidCents == this.pricePaidCents &&
          other.currency == this.currency &&
          other.personalNotes == this.personalNotes &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class OwnedItemsCacheCompanion extends UpdateCompanion<OwnedItemsCacheData> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> editionId;
  final Value<String?> variantId;
  final Value<String?> condition;
  final Value<String?> grade;
  final Value<DateTime?> purchaseDate;
  final Value<int?> pricePaidCents;
  final Value<String?> currency;
  final Value<String?> personalNotes;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const OwnedItemsCacheCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.condition = const Value.absent(),
    this.grade = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.pricePaidCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.personalNotes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OwnedItemsCacheCompanion.insert({
    required String id,
    required String itemId,
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.condition = const Value.absent(),
    this.grade = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.pricePaidCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.personalNotes = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        updatedAt = Value(updatedAt);
  static Insertable<OwnedItemsCacheData> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? editionId,
    Expression<String>? variantId,
    Expression<String>? condition,
    Expression<String>? grade,
    Expression<DateTime>? purchaseDate,
    Expression<int>? pricePaidCents,
    Expression<String>? currency,
    Expression<String>? personalNotes,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (editionId != null) 'edition_id': editionId,
      if (variantId != null) 'variant_id': variantId,
      if (condition != null) 'condition': condition,
      if (grade != null) 'grade': grade,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (pricePaidCents != null) 'price_paid_cents': pricePaidCents,
      if (currency != null) 'currency': currency,
      if (personalNotes != null) 'personal_notes': personalNotes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OwnedItemsCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String?>? editionId,
      Value<String?>? variantId,
      Value<String?>? condition,
      Value<String?>? grade,
      Value<DateTime?>? purchaseDate,
      Value<int?>? pricePaidCents,
      Value<String?>? currency,
      Value<String?>? personalNotes,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return OwnedItemsCacheCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      condition: condition ?? this.condition,
      grade: grade ?? this.grade,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      pricePaidCents: pricePaidCents ?? this.pricePaidCents,
      currency: currency ?? this.currency,
      personalNotes: personalNotes ?? this.personalNotes,
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
    return (StringBuffer('OwnedItemsCacheCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('condition: $condition, ')
          ..write('grade: $grade, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('pricePaidCents: $pricePaidCents, ')
          ..write('currency: $currency, ')
          ..write('personalNotes: $personalNotes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
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
        editionId,
        variantId,
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
    if (data.containsKey('edition_id')) {
      context.handle(_editionIdMeta,
          editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta));
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
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
      editionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edition_id']),
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
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
  final String? editionId;
  final String? variantId;
  final int? targetPriceCents;
  final String? currency;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const WishlistItemsCacheData(
      {required this.id,
      required this.itemId,
      this.editionId,
      this.variantId,
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
    if (!nullToAbsent || editionId != null) {
      map['edition_id'] = Variable<String>(editionId);
    }
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
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
      editionId: editionId == null && nullToAbsent
          ? const Value.absent()
          : Value(editionId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
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
      editionId: serializer.fromJson<String?>(json['editionId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
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
      'editionId': serializer.toJson<String?>(editionId),
      'variantId': serializer.toJson<String?>(variantId),
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
          Value<String?> editionId = const Value.absent(),
          Value<String?> variantId = const Value.absent(),
          Value<int?> targetPriceCents = const Value.absent(),
          Value<String?> currency = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      WishlistItemsCacheData(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        editionId: editionId.present ? editionId.value : this.editionId,
        variantId: variantId.present ? variantId.value : this.variantId,
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
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
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
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
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
  int get hashCode => Object.hash(id, itemId, editionId, variantId,
      targetPriceCents, currency, notes, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WishlistItemsCacheData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.editionId == this.editionId &&
          other.variantId == this.variantId &&
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
  final Value<String?> editionId;
  final Value<String?> variantId;
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
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
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
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
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
    Expression<String>? editionId,
    Expression<String>? variantId,
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
      if (editionId != null) 'edition_id': editionId,
      if (variantId != null) 'variant_id': variantId,
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
      Value<String?>? editionId,
      Value<String?>? variantId,
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
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
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
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
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
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
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
      'entity_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id']),
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
  final String? entityId;
  final String action;
  final String payloadJson;
  final DateTime clientChangedAt;
  const SyncQueueData(
      {required this.id,
      required this.entityType,
      this.entityId,
      required this.action,
      required this.payloadJson,
      required this.clientChangedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    map['action'] = Variable<String>(action);
    map['payload_json'] = Variable<String>(payloadJson);
    map['client_changed_at'] = Variable<DateTime>(clientChangedAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
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
      entityId: serializer.fromJson<String?>(json['entityId']),
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
      'entityId': serializer.toJson<String?>(entityId),
      'action': serializer.toJson<String>(action),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'clientChangedAt': serializer.toJson<DateTime>(clientChangedAt),
    };
  }

  SyncQueueData copyWith(
          {String? id,
          String? entityType,
          Value<String?> entityId = const Value.absent(),
          String? action,
          String? payloadJson,
          DateTime? clientChangedAt}) =>
      SyncQueueData(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId.present ? entityId.value : this.entityId,
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
  final Value<String?> entityId;
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
    this.entityId = const Value.absent(),
    required String action,
    required String payloadJson,
    required DateTime clientChangedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
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
      Value<String?>? entityId,
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

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $CatalogCacheTable catalogCache = $CatalogCacheTable(this);
  late final $OwnedItemsCacheTable ownedItemsCache =
      $OwnedItemsCacheTable(this);
  late final $WishlistItemsCacheTable wishlistItemsCache =
      $WishlistItemsCacheTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [catalogCache, ownedItemsCache, wishlistItemsCache, syncQueue];
}

typedef $$CatalogCacheTableCreateCompanionBuilder = CatalogCacheCompanion
    Function({
  required String id,
  required String kind,
  required String title,
  Value<String?> itemNumber,
  Value<String?> synopsis,
  Value<String?> coverImageUrl,
  required DateTime cachedAt,
  Value<int> rowid,
});
typedef $$CatalogCacheTableUpdateCompanionBuilder = CatalogCacheCompanion
    Function({
  Value<String> id,
  Value<String> kind,
  Value<String> title,
  Value<String?> itemNumber,
  Value<String?> synopsis,
  Value<String?> coverImageUrl,
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

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemNumber => $composableBuilder(
      column: $table.itemNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get synopsis => $composableBuilder(
      column: $table.synopsis, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemNumber => $composableBuilder(
      column: $table.itemNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get synopsis => $composableBuilder(
      column: $table.synopsis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl,
      builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get itemNumber => $composableBuilder(
      column: $table.itemNumber, builder: (column) => column);

  GeneratedColumn<String> get synopsis =>
      $composableBuilder(column: $table.synopsis, builder: (column) => column);

  GeneratedColumn<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => column);

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
            Value<String> title = const Value.absent(),
            Value<String?> itemNumber = const Value.absent(),
            Value<String?> synopsis = const Value.absent(),
            Value<String?> coverImageUrl = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogCacheCompanion(
            id: id,
            kind: kind,
            title: title,
            itemNumber: itemNumber,
            synopsis: synopsis,
            coverImageUrl: coverImageUrl,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String kind,
            required String title,
            Value<String?> itemNumber = const Value.absent(),
            Value<String?> synopsis = const Value.absent(),
            Value<String?> coverImageUrl = const Value.absent(),
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogCacheCompanion.insert(
            id: id,
            kind: kind,
            title: title,
            itemNumber: itemNumber,
            synopsis: synopsis,
            coverImageUrl: coverImageUrl,
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
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> condition,
  Value<String?> grade,
  Value<DateTime?> purchaseDate,
  Value<int?> pricePaidCents,
  Value<String?> currency,
  Value<String?> personalNotes,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$OwnedItemsCacheTableUpdateCompanionBuilder = OwnedItemsCacheCompanion
    Function({
  Value<String> id,
  Value<String> itemId,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> condition,
  Value<String?> grade,
  Value<DateTime?> purchaseDate,
  Value<int?> pricePaidCents,
  Value<String?> currency,
  Value<String?> personalNotes,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
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

  ColumnFilters<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get editionId =>
      $composableBuilder(column: $table.editionId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
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
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> condition = const Value.absent(),
            Value<String?> grade = const Value.absent(),
            Value<DateTime?> purchaseDate = const Value.absent(),
            Value<int?> pricePaidCents = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<String?> personalNotes = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OwnedItemsCacheCompanion(
            id: id,
            itemId: itemId,
            editionId: editionId,
            variantId: variantId,
            condition: condition,
            grade: grade,
            purchaseDate: purchaseDate,
            pricePaidCents: pricePaidCents,
            currency: currency,
            personalNotes: personalNotes,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> condition = const Value.absent(),
            Value<String?> grade = const Value.absent(),
            Value<DateTime?> purchaseDate = const Value.absent(),
            Value<int?> pricePaidCents = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<String?> personalNotes = const Value.absent(),
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OwnedItemsCacheCompanion.insert(
            id: id,
            itemId: itemId,
            editionId: editionId,
            variantId: variantId,
            condition: condition,
            grade: grade,
            purchaseDate: purchaseDate,
            pricePaidCents: pricePaidCents,
            currency: currency,
            personalNotes: personalNotes,
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
  Value<String?> editionId,
  Value<String?> variantId,
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
  Value<String?> editionId,
  Value<String?> variantId,
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

  ColumnFilters<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get editionId =>
      $composableBuilder(column: $table.editionId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

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
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
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
            editionId: editionId,
            variantId: variantId,
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
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
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
            editionId: editionId,
            variantId: variantId,
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
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  required String id,
  required String entityType,
  Value<String?> entityId,
  required String action,
  required String payloadJson,
  required DateTime clientChangedAt,
  Value<int> rowid,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String?> entityId,
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
            Value<String?> entityId = const Value.absent(),
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
            Value<String?> entityId = const Value.absent(),
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

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$CatalogCacheTableTableManager get catalogCache =>
      $$CatalogCacheTableTableManager(_db, _db.catalogCache);
  $$OwnedItemsCacheTableTableManager get ownedItemsCache =>
      $$OwnedItemsCacheTableTableManager(_db, _db.ownedItemsCache);
  $$WishlistItemsCacheTableTableManager get wishlistItemsCache =>
      $$WishlistItemsCacheTableTableManager(_db, _db.wishlistItemsCache);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
