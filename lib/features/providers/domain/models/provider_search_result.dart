import 'package:flutter/foundation.dart';

@immutable
class ProviderSearchResult {
  const ProviderSearchResult({
    required this.provider,
    required this.providerItemId,
    required this.title,
    required this.kind,
    this.summary,
    this.imageUrl,
    this.candidateType,
    this.seriesTitle,
    this.issueNumber,
    this.volumeStartYear,
    this.variantName,
    this.isVariant,
    this.issueCount,
    this.publisher,
    this.characterPreview = const [],
    this.storyArcPreview = const [],
    this.externalIds = const {},
  });

  final String provider;
  final String providerItemId;
  final String title;
  final String kind;
  final String? summary;
  final String? imageUrl;
  final String? candidateType;
  final String? seriesTitle;
  final String? issueNumber;
  final int? volumeStartYear;
  final String? variantName;
  final bool? isVariant;
  final int? issueCount;
  final String? publisher;
  final List<String> characterPreview;
  final List<String> storyArcPreview;
  final Map<String, String> externalIds;

  factory ProviderSearchResult.fromJson(Map<String, dynamic> json) {
    final rawCharacters = json['character_preview'];
    final characterPreview = <String>[];
    if (rawCharacters is List) {
      for (final item in rawCharacters) {
        if (item != null) {
          characterPreview.add(item.toString());
        }
      }
    }

    final rawStoryArcs = json['story_arc_preview'];
    final storyArcPreview = <String>[];
    if (rawStoryArcs is List) {
      for (final item in rawStoryArcs) {
        if (item != null) {
          storyArcPreview.add(item.toString());
        }
      }
    }

    final rawExternalIds = json['external_ids'];
    final externalIds = <String, String>{};
    if (rawExternalIds is Map) {
      for (final entry in rawExternalIds.entries) {
        if (entry.key != null && entry.value != null) {
          externalIds[entry.key.toString()] = entry.value.toString();
        }
      }
    }

    return ProviderSearchResult(
      provider: json['provider']?.toString() ?? '',
      providerItemId: json['provider_item_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      summary: json['summary']?.toString(),
      imageUrl: json['image_url']?.toString(),
      candidateType: json['candidate_type']?.toString(),
      seriesTitle: json['series_title']?.toString(),
      issueNumber: json['issue_number']?.toString(),
      volumeStartYear: json['volume_start_year'] is num
          ? (json['volume_start_year'] as num).toInt()
          : int.tryParse(json['volume_start_year']?.toString() ?? ''),
      variantName: json['variant_name']?.toString(),
      isVariant: json['is_variant'] != null
          ? (json['is_variant'] == true ||
              json['is_variant'].toString() == 'true')
          : null,
      issueCount: json['issue_count'] is num
          ? (json['issue_count'] as num).toInt()
          : int.tryParse(json['issue_count']?.toString() ?? ''),
      publisher: json['publisher']?.toString(),
      characterPreview: characterPreview,
      storyArcPreview: storyArcPreview,
      externalIds: externalIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'provider_item_id': providerItemId,
      'title': title,
      'kind': kind,
      'summary': summary,
      'image_url': imageUrl,
      'candidate_type': candidateType,
      'series_title': seriesTitle,
      'issue_number': issueNumber,
      'volume_start_year': volumeStartYear,
      'variant_name': variantName,
      'is_variant': isVariant,
      'issue_count': issueCount,
      'publisher': publisher,
      'character_preview': characterPreview,
      'story_arc_preview': storyArcPreview,
      'external_ids': externalIds,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderSearchResult &&
          runtimeType == other.runtimeType &&
          provider == other.provider &&
          providerItemId == other.providerItemId &&
          title == other.title &&
          kind == other.kind &&
          summary == other.summary &&
          imageUrl == other.imageUrl &&
          candidateType == other.candidateType &&
          seriesTitle == other.seriesTitle &&
          issueNumber == other.issueNumber &&
          volumeStartYear == other.volumeStartYear &&
          variantName == other.variantName &&
          isVariant == other.isVariant &&
          issueCount == other.issueCount &&
          publisher == other.publisher &&
          listEquals(characterPreview, other.characterPreview) &&
          listEquals(storyArcPreview, other.storyArcPreview) &&
          mapEquals(externalIds, other.externalIds);

  @override
  int get hashCode => Object.hash(
        provider,
        providerItemId,
        title,
        kind,
        summary,
        imageUrl,
        candidateType,
        seriesTitle,
        issueNumber,
        volumeStartYear,
        variantName,
        isVariant,
        issueCount,
        publisher,
        Object.hashAll(characterPreview),
        Object.hashAll(storyArcPreview),
        Object.hashAll(externalIds.entries),
      );
}
