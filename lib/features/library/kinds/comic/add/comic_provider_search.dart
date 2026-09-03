import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/providers/adapters/comicvine/comicvine_provider.dart';
import 'package:collectarr_app/features/providers/adapters/comicvine/models/comic_vine_issue.dart';
import 'package:collectarr_app/features/providers/adapters/gcd/gcd_provider.dart';
import 'package:collectarr_app/features/providers/adapters/gcd/models/gcd_issue.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_search_result.dart';

abstract interface class ComicProviderSearchIntegration {
  bool supports(ProviderConnector provider);

  Future<List<ProviderCandidate>> search(
    ProviderConnector provider, {
    required String query,
    required String kind,
    required int limit,
  });
}

Future<List<ProviderCandidate>> searchComicProvider(
  ProviderConnector provider, {
  required String query,
  required String kind,
  required int limit,
}) async {
  for (final integration in _comicProviderSearchIntegrations) {
    if (integration.supports(provider)) {
      return integration.search(
        provider,
        query: query,
        kind: kind,
        limit: limit,
      );
    }
  }

  final results = await provider.search(query, kind: kind, limit: limit);
  return [
    for (final result in results)
      if (result.providerItemId.trim().isNotEmpty)
        _comicCandidateFromSearchResult(
          result,
          provider: provider.descriptor.name,
          fallbackKind: kind,
        ),
  ];
}

const _comicProviderSearchIntegrations = <ComicProviderSearchIntegration>[
  _GcdComicProviderSearchIntegration(),
  _ComicVineProviderSearchIntegration(),
];

final class _GcdComicProviderSearchIntegration
    implements ComicProviderSearchIntegration {
  const _GcdComicProviderSearchIntegration();

  @override
  bool supports(ProviderConnector provider) => provider.metadata is GCDProvider;

  @override
  Future<List<ProviderCandidate>> search(
    ProviderConnector provider, {
    required String query,
    required String kind,
    required int limit,
  }) async {
    final metadata = provider.metadata;
    if (metadata is! GCDProvider) return const [];
    final issues = await metadata.searchIssues(query, limit: limit);
    return [
      for (final issue in issues)
        _comicCandidateFromGcdIssue(issue, provider: provider.descriptor.name),
    ];
  }
}

final class _ComicVineProviderSearchIntegration
    implements ComicProviderSearchIntegration {
  const _ComicVineProviderSearchIntegration();

  @override
  bool supports(ProviderConnector provider) =>
      provider.metadata is ComicVineProvider;

  @override
  Future<List<ProviderCandidate>> search(
    ProviderConnector provider, {
    required String query,
    required String kind,
    required int limit,
  }) async {
    final metadata = provider.metadata;
    if (metadata is! ComicVineProvider) return const [];
    final issues = await metadata.searchIssues(query, limit: limit);
    return [
      for (final issue in issues)
        _comicCandidateFromComicVineIssue(
          issue,
          provider: provider.descriptor.name,
          kind: kind,
        ),
    ];
  }
}

ProviderCandidate _comicCandidateFromGcdIssue(
  GcdIssue issue, {
  required String provider,
}) {
  final issueId = _gcdIssueId(issue);
  final seriesName = issue.seriesName ?? 'Unknown GCD issue';
  final issueNumber = issue.descriptor ?? issue.number;
  final seriesTitle = _cleanGcdSeriesTitle(seriesName);
  final title = issue.descriptor != null
      ? '$seriesName #${issue.descriptor}'
      : seriesName;
  final summaryParts = <String>[
    if (issue.publicationDate != null) issue.publicationDate!,
    if (issue.price != null) issue.price!,
  ];

  final characterPreview = <String>[];
  final seenCharacters = <String>{};
  final storyArcPreview = <String>[];
  final seenStoryArcs = <String>{};
  for (final story in issue.stories) {
    final characters = story.characters;
    if (characters != null) {
      for (final rawName in characters.split(RegExp(r'[;\n]\s*'))) {
        final name = rawName.split('(').first.trim();
        if (name.isNotEmpty && seenCharacters.add(name.toLowerCase())) {
          characterPreview.add(name);
        }
      }
    }
    final storyArc = story.partOfIssueStoryArc;
    if (storyArc != null &&
        storyArc.isNotEmpty &&
        seenStoryArcs.add(storyArc.toLowerCase())) {
      storyArcPreview.add(storyArc);
    }
  }

  final isVariant = issue.variantOf != null;
  return ProviderCandidate(
    provider: provider,
    providerItemId: issueId,
    title: title,
    kind: 'comic',
    summary: summaryParts.isNotEmpty ? summaryParts.join(' · ') : null,
    imageUrl: issue.cover,
    candidateType: isVariant ? 'variant' : 'issue',
    issueNumber: issueNumber,
    series: CatalogSeriesDetailsDto(seriesTitle: seriesTitle),
    isVariantOverride: isVariant,
    publisher: issue.publisherName,
    characterPreview: characterPreview,
    storyArcPreview: storyArcPreview,
  );
}

ProviderCandidate _comicCandidateFromComicVineIssue(
  ComicVineIssue issue, {
  required String provider,
  required String kind,
}) {
  final volumeName = issue.volume?.name;
  final issueNumber = issue.issueNumber;
  final title = volumeName != null && volumeName.isNotEmpty
      ? issueNumber != null && issueNumber.isNotEmpty
          ? '$volumeName #$issueNumber'
          : volumeName
      : issue.name ?? 'Unknown Comic';
  final summaryParts = <String>[
    if (volumeName != null && volumeName.isNotEmpty) volumeName,
    if (issueNumber != null && issueNumber.isNotEmpty) '#$issueNumber',
  ];

  return ProviderCandidate(
    provider: provider,
    providerItemId: _comicVineIssueId(issue.id),
    title: title,
    kind: kind,
    summary: summaryParts.isNotEmpty ? summaryParts.join(' ') : null,
    imageUrl: _comicVineImageUrl(issue),
    candidateType: 'issue',
    issueNumber: issueNumber,
    series: CatalogSeriesDetailsDto(
      seriesTitle: volumeName,
      volumeStartYear: issue.volume?.startYear,
    ),
    publisher: issue.volume?.publisherName,
  );
}

ProviderCandidate _comicCandidateFromSearchResult(
  ProviderSearchResult result, {
  required String provider,
  required String fallbackKind,
}) {
  final series = CatalogSeriesDetailsDto(
    seriesTitle: result.seriesTitle,
    volumeStartYear: result.volumeStartYear,
  );
  return ProviderCandidate(
    provider: provider,
    providerItemId: result.providerItemId,
    title: result.title,
    kind: result.kind.trim().isEmpty ? fallbackKind : result.kind,
    summary: result.summary,
    imageUrl: result.imageUrl,
    candidateType: result.candidateType,
    issueNumber: result.issueNumber,
    series: series.hasData ? series : null,
    variantName: result.variantName,
    isVariantOverride: result.isVariant,
    publisher: result.publisher,
    issueCount: result.issueCount,
    characterPreview: result.characterPreview,
    storyArcPreview: result.storyArcPreview,
  );
}

String _gcdIssueId(GcdIssue issue) {
  final value = (issue.apiUrl ?? issue.id)?.trim() ?? '';
  if (RegExp(r'^\d+$').hasMatch(value)) return value;
  return RegExp(r'/issue/(\d+)/?').firstMatch(value)?.group(1) ?? '';
}

String _cleanGcdSeriesTitle(String value) {
  return value
      .replaceAll(RegExp(r'\s+\(\d{4}\s+series\)$', caseSensitive: false), '')
      .trim();
}

String _comicVineIssueId(String? value) {
  final text = value?.trim() ?? '';
  if (text.startsWith('4000-')) return text;
  if (int.tryParse(text) != null) return '4000-$text';
  return text;
}

String? _comicVineImageUrl(ComicVineIssue issue) {
  final image = issue.image;
  return image?.superUrl ??
      image?.mediumUrl ??
      image?.scaleLarge ??
      image?.originalUrl;
}
