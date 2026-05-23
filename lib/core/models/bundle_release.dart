class BundleReleaseContentSummary {
  const BundleReleaseContentSummary({
    required this.totalItems,
    required this.primaryCount,
    required this.bonusCount,
  });

  final int totalItems;
  final int primaryCount;
  final int bonusCount;

  factory BundleReleaseContentSummary.fromJson(Map<String, dynamic> json) {
    return BundleReleaseContentSummary(
      totalItems: json['total_items'] as int? ?? 0,
      primaryCount: json['primary_count'] as int? ?? 0,
      bonusCount: json['bonus_count'] as int? ?? 0,
    );
  }
}

class BundleReleaseSummary {
  const BundleReleaseSummary({
    required this.id,
    required this.kind,
    required this.title,
    required this.contentSummary,
    this.bundleType,
    this.format,
    this.variantType,
    this.packagingType,
    this.region,
    this.language,
    this.publisher,
    this.sku,
    this.barcode,
    this.releaseDate,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.primaryItemId,
    this.primaryItemTitle,
    this.seriesId,
    this.seriesTitle,
    this.volumeId,
    this.volumeName,
  });

  final String id;
  final String kind;
  final String title;
  final String? bundleType;
  final String? format;
  final String? variantType;
  final String? packagingType;
  final String? region;
  final String? language;
  final String? publisher;
  final String? sku;
  final String? barcode;
  final DateTime? releaseDate;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? primaryItemId;
  final String? primaryItemTitle;
  final String? seriesId;
  final String? seriesTitle;
  final String? volumeId;
  final String? volumeName;
  final BundleReleaseContentSummary contentSummary;

  factory BundleReleaseSummary.fromJson(Map<String, dynamic> json) {
    return BundleReleaseSummary(
      id: json['id'] as String,
      kind: json['kind'] as String? ?? 'unknown',
      title: json['title'] as String? ?? 'Bundle release',
      bundleType: json['bundle_type'] as String?,
      format: json['format'] as String?,
      variantType: json['variant_type'] as String?,
      packagingType: json['packaging_type'] as String?,
      region: json['region'] as String?,
      language: json['language'] as String?,
      publisher: json['publisher'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      releaseDate: _parseDate(json['release_date'] as String?),
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      primaryItemId: json['primary_item_id'] as String?,
      primaryItemTitle: json['primary_item_title'] as String?,
      seriesId: json['series_id'] as String?,
      seriesTitle: json['series_title'] as String?,
      volumeId: json['volume_id'] as String?,
      volumeName: json['volume_name'] as String?,
      contentSummary: BundleReleaseContentSummary.fromJson(
        (json['content_summary'] as Map<String, dynamic>? ?? const {})
            .cast<String, dynamic>(),
      ),
    );
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toUtc();
  }
}

class BundleReleaseMember {
  const BundleReleaseMember({
    required this.itemId,
    required this.role,
    required this.quantity,
    required this.isPrimary,
    required this.kind,
    required this.title,
    this.sequenceNumber,
    this.discNumber,
    this.discLabel,
    this.itemNumber,
    this.seriesId,
    this.seriesTitle,
    this.volumeName,
    this.volumeNumber,
  });

  final String itemId;
  final String role;
  final int? sequenceNumber;
  final int? discNumber;
  final String? discLabel;
  final int quantity;
  final bool isPrimary;
  final String kind;
  final String title;
  final String? itemNumber;
  final String? seriesId;
  final String? seriesTitle;
  final String? volumeName;
  final int? volumeNumber;

  factory BundleReleaseMember.fromJson(Map<String, dynamic> json) {
    return BundleReleaseMember(
      itemId: json['item_id'] as String,
      role: json['role'] as String? ?? 'member',
      sequenceNumber: json['sequence_number'] as int?,
      discNumber: json['disc_number'] as int?,
      discLabel: json['disc_label'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      isPrimary: json['is_primary'] as bool? ?? false,
      kind: json['kind'] as String? ?? 'unknown',
      title: json['title'] as String? ?? 'Item',
      itemNumber: json['item_number'] as String?,
      seriesId: json['series_id'] as String?,
      seriesTitle: json['series_title'] as String?,
      volumeName: json['volume_name'] as String?,
      volumeNumber: json['volume_number'] as int?,
    );
  }
}

class BundleReleaseDetail extends BundleReleaseSummary {
  const BundleReleaseDetail({
    required super.id,
    required super.kind,
    required super.title,
    required super.contentSummary,
    required this.members,
    this.franchiseId,
    this.metadataJson,
    this.externalIds,
    super.bundleType,
    super.format,
    super.variantType,
    super.packagingType,
    super.region,
    super.language,
    super.publisher,
    super.sku,
    super.barcode,
    super.releaseDate,
    super.coverImageUrl,
    super.thumbnailImageUrl,
    super.primaryItemId,
    super.primaryItemTitle,
    super.seriesId,
    super.seriesTitle,
    super.volumeId,
    super.volumeName,
  });

  final String? franchiseId;
  final Map<String, dynamic>? metadataJson;
  final Map<String, dynamic>? externalIds;
  final List<BundleReleaseMember> members;

  factory BundleReleaseDetail.fromJson(Map<String, dynamic> json) {
    final summary = BundleReleaseSummary.fromJson(json);
    return BundleReleaseDetail(
      id: summary.id,
      kind: summary.kind,
      title: summary.title,
      contentSummary: summary.contentSummary,
      bundleType: summary.bundleType,
      format: summary.format,
      variantType: summary.variantType,
      packagingType: summary.packagingType,
      region: summary.region,
      language: summary.language,
      publisher: summary.publisher,
      sku: summary.sku,
      barcode: summary.barcode,
      releaseDate: summary.releaseDate,
      coverImageUrl: summary.coverImageUrl,
      thumbnailImageUrl: summary.thumbnailImageUrl,
      primaryItemId: summary.primaryItemId,
      primaryItemTitle: summary.primaryItemTitle,
      seriesId: summary.seriesId,
      seriesTitle: summary.seriesTitle,
      volumeId: summary.volumeId,
      volumeName: summary.volumeName,
      franchiseId: json['franchise_id'] as String?,
      metadataJson: (json['metadata_json'] as Map<String, dynamic>?)
          ?.cast<String, dynamic>(),
      externalIds: (json['external_ids'] as Map<String, dynamic>?)
          ?.cast<String, dynamic>(),
      members: (json['members'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(BundleReleaseMember.fromJson)
          .toList(growable: false),
    );
  }
}