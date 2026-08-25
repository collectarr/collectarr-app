import 'package:flutter/foundation.dart';

import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'provider_attribution.dart';
import 'provider_image_ref.dart';
import 'provider_provenance.dart';

@immutable
class NormalizedProviderEnvelopeV1 {
  const NormalizedProviderEnvelopeV1({
    this.schemaVersion = 'v1',
    required this.provider,
    required this.providerItemId,
    required this.kind,
    required this.normalized,
    required this.provenance,
    required this.images,
    required this.attribution,
  });

  final String schemaVersion;
  final String provider;
  final String providerItemId;
  final String kind;
  final Map<String, dynamic> normalized;
  final ProviderProvenance provenance;
  final List<ProviderImageRef> images;
  final ProviderAttribution attribution;

  factory NormalizedProviderEnvelopeV1.fromAdminPreview(
    AdminProviderPreview preview, {
    required String itemId,
  }) {
    return NormalizedProviderEnvelopeV1(
      provider: preview.provider,
      providerItemId: itemId,
      kind: preview.kind,
      normalized: {
        'title': preview.title,
        'item_number': preview.itemNumber,
        'synopsis': preview.synopsis,
        'cover_image_url': preview.coverImageUrl,
        'edition_title': preview.editionTitle,
        'physical_format': preview.physicalFormat,
        'physical_format_label': preview.physicalFormatLabel,
        'publisher': preview.publisher,
        'release_date': preview.releaseDate?.toIso8601String(),
        'barcode': preview.barcode,
        'isbn': preview.isbn,
        'variant': preview.variantName,
        'country': preview.country,
        'language': preview.language,
        'age_rating': preview.ageRating,
        'audience_rating': preview.audienceRating,
        'genres': preview.genres,
        'characters': preview.characters,
        'story_arcs': preview.storyArcs,
        if (preview.creators.isNotEmpty)
          'creators': [
            for (final creator in preview.creators)
              {
                'name': creator.name,
                if (creator.role != null) 'role': creator.role,
                if (creator.imageUrl != null) 'image_url': creator.imageUrl,
              },
          ],
        if (preview.series != null) 'series_title': preview.series!.seriesTitle,
        if (preview.publishing != null)
          'publishing': preview.publishing!.toJson(),
        if (preview.music != null) ...{
          if (preview.music!['track_count'] != null)
            'track_count': preview.music!['track_count'],
          if (preview.music!['tracks'] != null)
            'tracks': preview.music!['tracks'],
          'music': preview.music!,
        },
        if (preview.video != null) 'video': preview.video!,
        if (preview.game != null) 'game': preview.game!,
      },
      provenance: const ProviderProvenance(fetchedAt: ''),
      images: preview.coverImageUrl == null
          ? const []
          : [
              ProviderImageRef(
                provider: preview.provider,
                url: preview.coverImageUrl!,
              ),
            ],
      attribution: const ProviderAttribution(required: false),
    );
  }

  factory NormalizedProviderEnvelopeV1.fromJson(Map<String, dynamic> json) {
    final rawNormalized = json['normalized'];
    final normalized = <String, dynamic>{};
    if (rawNormalized is Map) {
      for (final entry in rawNormalized.entries) {
        if (entry.key != null) {
          normalized[entry.key.toString()] = entry.value;
        }
      }
    }

    final rawImages = json['images'];
    final images = <ProviderImageRef>[];
    if (rawImages is List) {
      for (final item in rawImages) {
        if (item is Map) {
          images
              .add(ProviderImageRef.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final rawProvenance = json['provenance'];
    final provenance = rawProvenance is Map
        ? ProviderProvenance.fromJson(Map<String, dynamic>.from(rawProvenance))
        : const ProviderProvenance(fetchedAt: '');

    final rawAttribution = json['attribution'];
    final attribution = rawAttribution is Map
        ? ProviderAttribution.fromJson(
            Map<String, dynamic>.from(rawAttribution))
        : const ProviderAttribution(required: false);

    return NormalizedProviderEnvelopeV1(
      schemaVersion: json['schema_version']?.toString() ?? 'v1',
      provider: json['provider']?.toString() ?? '',
      providerItemId: json['provider_item_id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      normalized: normalized,
      provenance: provenance,
      images: images,
      attribution: attribution,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schema_version': schemaVersion,
      'provider': provider,
      'provider_item_id': providerItemId,
      'kind': kind,
      'normalized': normalized,
      'provenance': provenance.toJson(),
      'images': images.map((img) => img.toJson()).toList(growable: false),
      'attribution': attribution.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NormalizedProviderEnvelopeV1 &&
          runtimeType == other.runtimeType &&
          schemaVersion == other.schemaVersion &&
          provider == other.provider &&
          providerItemId == other.providerItemId &&
          kind == other.kind &&
          mapEquals(normalized, other.normalized) &&
          provenance == other.provenance &&
          listEquals(images, other.images) &&
          attribution == other.attribution;

  @override
  int get hashCode => Object.hash(
        schemaVersion,
        provider,
        providerItemId,
        kind,
        Object.hashAll(normalized.entries),
        provenance,
        Object.hashAll(images),
        attribution,
      );
}
