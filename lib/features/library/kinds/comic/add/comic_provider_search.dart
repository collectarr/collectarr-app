import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/provider/comic_provider_candidates.dart';
import 'package:collectarr_app/features/providers/transport/provider_series_hint.dart';
import 'package:collectarr_app/features/providers/adapters/comicvine/comicvine_provider.dart';
import 'package:collectarr_app/features/providers/adapters/comicvine/models/comic_vine_issue.dart';
import 'package:collectarr_app/features/providers/adapters/gcd/gcd_provider.dart';
import 'package:collectarr_app/features/providers/adapters/gcd/models/gcd_issue.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';

abstract interface class ComicProviderSearchIntegration {
  bool supports(ProviderConnector provider);

  Future<List<ComicProviderCandidate>> search(
    ProviderConnector provider, {
    required String query,
    required CatalogMediaKind kind,
    required int limit,
  });
}

Future<List<ComicProviderCandidate>> searchComicProvider(
  ProviderConnector provider, {
  required String query,
  required CatalogMediaKind kind,
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
      if (result.providerItemId.trim().isNotEmpty && result.kind == kind)
        _comicCandidateFromSearchResult(
          result,
          provider: provider.descriptor.name,
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
  bool supports(ProviderConnector provider) =>
      provider.rawMetadata is GCDProvider;

  @override
  Future<List<ComicProviderCandidate>> search(
    ProviderConnector provider, {
    required String query,
    required CatalogMediaKind kind,
    required int limit,
  }) async {
    final metadata = provider.rawMetadata;
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
      provider.rawMetadata is ComicVineProvider;

  @override
  Future<List<ComicProviderCandidate>> search(
    ProviderConnector provider, {
    required String query,
    required CatalogMediaKind kind,
    required int limit,
  }) async {
    final metadata = provider.rawMetadata;
    if (metadata is! ComicVineProvider) return const [];
    final issues = await metadata.searchIssues(query, limit: limit);
    return [
      for (final issue in issues)
        _comicCandidateFromComicVineIssue(
          issue,
          provider: provider.descriptor.name,
        ),
    ];
  }
}

ComicProviderCandidate _comicCandidateFromGcdIssue(
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

  final candidate = issue.variantOf != null
      ? ComicVariantCandidate(
          provider: provider,
          providerItemId: issueId,
          title: title,
          summary: summaryParts.isNotEmpty ? summaryParts.join(' · ') : null,
          imageUrl: issue.cover,
          issueNumber: issueNumber,
          series: ProviderSeriesHint(seriesTitle: seriesTitle),
          variantName: issue.variantOf?.toString(),
          publisher: issue.publisherName,
          characterPreview: characterPreview,
          storyArcPreview: storyArcPreview,
        )
      : ComicIssueCandidate(
          provider: provider,
          providerItemId: issueId,
          title: title,
          summary: summaryParts.isNotEmpty ? summaryParts.join(' · ') : null,
          imageUrl: issue.cover,
          issueNumber: issueNumber,
          series: ProviderSeriesHint(seriesTitle: seriesTitle),
          publisher: issue.publisherName,
          characterPreview: characterPreview,
          storyArcPreview: storyArcPreview,
        );
  return candidate;
}

ComicProviderCandidate _comicCandidateFromComicVineIssue(
  ComicVineIssue issue, {
  required String provider,
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

  return ComicIssueCandidate(
    provider: provider,
    providerItemId: _comicVineIssueId(issue.id),
    title: title,
    summary: summaryParts.isNotEmpty ? summaryParts.join(' ') : null,
    imageUrl: _comicVineImageUrl(issue),
    issueNumber: issueNumber,
    series: ProviderSeriesHint(
      seriesTitle: volumeName,
      volumeStartYear: issue.volume?.startYear,
    ),
    publisher: issue.volume?.publisherName,
  );
}

ComicProviderCandidate _comicCandidateFromSearchResult(
  ProviderSearchResult result, {
  required String provider,
}) {
  return ComicProviderCandidate.fromSearchResult(result, provider: provider);
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
