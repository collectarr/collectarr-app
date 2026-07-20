class CatalogVariantDto {
  const CatalogVariantDto({
    required this.id,
    required this.name,
    this.variantType,
    this.sku,
    this.barcode,
    this.isbn,
    this.region,
    this.platform,
    this.coverPriceCents,
    this.currency,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.description,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.metadata,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final String? variantType;
  final String? sku;
  final String? barcode;
  final String? isbn;
  final String? region;
  final String? platform;
  final int? coverPriceCents;
  final String? currency;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? description;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final Map<String, dynamic>? metadata;
  final bool isPrimary;

  factory CatalogVariantDto.fromJson(Map<String, dynamic> json) {
    return CatalogVariantDto(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Variant',
      variantType: json['variant_type'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      isbn: json['isbn'] as String?,
      region: json['region'] as String?,
      platform: json['platform'] as String?,
      coverPriceCents: json['cover_price_cents'] as int?,
      currency: json['currency'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      description: json['description'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      metadata: const <String, dynamic>{},
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (variantType != null) 'variant_type': variantType,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      if (isbn != null) 'isbn': isbn,
      if (region != null) 'region': region,
      if (platform != null) 'platform': platform,
      if (coverPriceCents != null) 'cover_price_cents': coverPriceCents,
      if (currency != null) 'currency': currency,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
      if (description != null) 'description': description,
      if (physicalFormat != null) 'physical_format': physicalFormat,
      if (physicalFormatLabel != null)
        'physical_format_label': physicalFormatLabel,
      'is_primary': isPrimary,
    };
  }
}
