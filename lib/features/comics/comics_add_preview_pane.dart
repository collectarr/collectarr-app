import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/comic_detail.dart';
import 'package:collectarr_app/features/comics/comics_add_images.dart';
import 'package:collectarr_app/features/comics/comics_controller.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddComicPreviewPane extends ConsumerWidget {
  const AddComicPreviewPane({
    super.key,
    required this.item,
    required this.candidate,
    required this.selectedProviderLabel,
    required this.selectedIsOwned,
    required this.selectedIsWishlisted,
    required this.searchedServer,
  });

  final CatalogItem? item;
  final ProviderCandidate? candidate;
  final String selectedProviderLabel;
  final bool selectedIsOwned;
  final bool selectedIsWishlisted;
  final bool searchedServer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItem = item;
    final selectedCandidate = candidate;
    if (selectedItem == null && selectedCandidate == null) {
      return ColoredBox(
        color: const Color(0xFF060606),
        child: Center(
          child: Text(
            searchedServer
                ? 'Select a result or search $selectedProviderLabel.'
                : 'Search Collectarr Core to preview metadata.',
          ),
        ),
      );
    }
    final detail = selectedItem == null
        ? null
        : ref.watch(comicDetailProvider(selectedItem.id)).value;
    final title = selectedItem?.title ?? selectedCandidate!.title;
    final issue = selectedItem?.itemNumber;
    final localStatus = selectedIsOwned
        ? 'In local collection'
        : selectedIsWishlisted
            ? 'In local wishlist'
            : 'Not in local shelf';
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF020202),
            Color(0xFF082531),
            Color(0xFF050505),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF05AEEF),
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.02,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        selectedItem == null
                            ? 'Metadata candidate'
                            : 'Collectarr Core metadata',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 9),
                      _AddPreviewChips(
                        labels: [
                          localStatus,
                          if (selectedItem?.publisher != null)
                            selectedItem!.publisher!,
                          if (selectedItem?.releaseYear != null)
                            selectedItem!.releaseYear!.toString(),
                          if (selectedItem?.barcode != null)
                            'UPC ${selectedItem!.barcode}',
                        ],
                      ),
                    ],
                  ),
                ),
                if (issue != null)
                  Text(
                    '# $issue',
                    style: const TextStyle(
                      color: Color(0xFF05AEEF),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const Divider(height: 22, color: Color(0x664DBBD5)),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(color: Color(0xFF05AEEF)),
                        ),
                        const SizedBox(height: 6),
                        _AddPreviewDescription(
                          item: selectedItem,
                          candidate: selectedCandidate,
                          detail: detail,
                          localStatus: localStatus,
                        ),
                        if (detail?.creators.isNotEmpty ?? false) ...[
                          const SizedBox(height: 22),
                          const Text(
                            'Creators',
                            style: TextStyle(color: Color(0xFF05AEEF)),
                          ),
                          const SizedBox(height: 6),
                          _AddPreviewChips(
                            labels: [
                              for (final credit in detail!.creators)
                                credit.role == null
                                    ? credit.name
                                    : '${credit.name} - ${credit.role}',
                            ],
                          ),
                        ],
                        if (detail?.characters.isNotEmpty ?? false) ...[
                          const SizedBox(height: 22),
                          const Text(
                            'Characters',
                            style: TextStyle(color: Color(0xFF05AEEF)),
                          ),
                          const SizedBox(height: 6),
                          _AddPreviewChips(
                            labels: [
                              for (final credit in detail!.characters)
                                credit.name,
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 200,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0x99FFFFFF)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xCC000000),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: selectedItem == null
                            ? ProviderCandidateImage(
                                candidate: selectedCandidate!,
                              )
                            : AddComicCoverImage(item: selectedItem),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPreviewDescription extends StatelessWidget {
  const _AddPreviewDescription({
    required this.item,
    required this.candidate,
    required this.detail,
    required this.localStatus,
  });

  final CatalogItem? item;
  final ProviderCandidate? candidate;
  final ComicDetail? detail;
  final String localStatus;

  @override
  Widget build(BuildContext context) {
    final paragraph = _narrativeParagraph();
    final facts = _facts();
    if ((paragraph == null || paragraph.isEmpty) && facts.isEmpty) {
      return const Text('No description metadata available yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (paragraph != null && paragraph.isNotEmpty) ...[
          Text(
            paragraph,
            style: const TextStyle(height: 1.38),
          ),
          if (facts.isNotEmpty) const SizedBox(height: 14),
        ],
        if (facts.isNotEmpty)
          Text(
            facts.map((fact) => '${fact.label}: ${fact.value}').join('\n'),
            style: const TextStyle(
              height: 1.46,
              color: Color(0xFFDDE9EF),
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  String? _narrativeParagraph() {
    final selectedItem = item;
    final itemSynopsis = selectedItem?.synopsis ?? detail?.synopsis;
    if (_hasText(itemSynopsis)) {
      return itemSynopsis!.trim();
    }

    final selectedCandidate = candidate;
    final summary = selectedCandidate?.summary?.trim();
    if (summary == null || summary.isEmpty) {
      return null;
    }
    return _looksLikeMetadataSummary(summary) ? null : summary;
  }

  List<_PreviewFact> _facts() {
    final selectedItem = item;
    if (selectedItem == null) {
      final selectedCandidate = candidate;
      if (selectedCandidate == null) {
        return const [];
      }
      return _candidateFacts(selectedCandidate);
    }
    return _itemFacts(selectedItem);
  }

  List<_PreviewFact> _candidateFacts(ProviderCandidate selectedCandidate) {
    final identity = _PreviewCandidateIdentity.from(selectedCandidate);
    final summaryFacts = _summaryFacts(selectedCandidate.summary);
    return _dedupeFacts([
      _PreviewFact('Series', identity.seriesTitle),
      if (identity.issueLabel != 'Result')
        _PreviewFact('Issue', identity.issueLabel),
      _PreviewFact('Cover', identity.variantLabel),
      ...summaryFacts,
    ]);
  }

  List<_PreviewFact> _itemFacts(CatalogItem selectedItem) {
    final primaryVariant = detail?.primaryVariant;
    return _dedupeFacts([
      _PreviewFact('Status', localStatus),
      _PreviewFact('Series', detail?.seriesTitle ?? selectedItem.title),
      _PreviewFact('Issue', selectedItem.itemNumber),
      _PreviewFact(
        'Edition',
        selectedItem.displayEditionLabel ?? detail?.primaryEdition?.title,
      ),
      _PreviewFact('Cover', primaryVariant?.name),
      _PreviewFact('Publisher', detail?.publisher ?? selectedItem.publisher),
      _PreviewFact('Cover date', _formatOptionalDate(detail?.coverDate)),
      _PreviewFact(
        'Release',
        _formatOptionalDate(
          detail?.storeDate ?? selectedItem.releaseDate,
        ),
      ),
      _PreviewFact('Pages', _pageLabel(detail?.pageCount)),
      _PreviewFact('Barcode', detail?.barcode ?? selectedItem.barcode),
      _PreviewFact(
        'Price',
        _moneyLabel(
          primaryVariant?.coverPriceCents ?? detail?.coverPriceCents,
          primaryVariant?.currency ?? detail?.currency,
        ),
      ),
    ]);
  }

  List<_PreviewFact> _summaryFacts(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty || !_looksLikeMetadataSummary(text)) {
      return const [];
    }
    return [
      for (final part in text.split(' · '))
        if (part.trim().isNotEmpty) _summaryFact(part.trim()),
    ];
  }

  _PreviewFact _summaryFact(String value) {
    final lower = value.toLowerCase();
    if (RegExp(r'^\d+\s+pages?$').hasMatch(lower)) {
      return _PreviewFact('Pages', value);
    }
    if (lower == 'variant') {
      return const _PreviewFact('Type', 'Variant cover');
    }
    if (RegExp(r'\b\d+(?:[.,]\d+)?\s*[A-Z]{3}\b').hasMatch(value) ||
        lower.contains('[free]')) {
      return _PreviewFact('Cover price', value);
    }
    if (RegExp(r'\b(18|19|20|21|22)\d{2}\b').hasMatch(value) ||
        RegExp(
          r'\b(january|february|march|april|may|june|july|august|'
          r'september|october|november|december)\b',
          caseSensitive: false,
        ).hasMatch(value)) {
      return _PreviewFact('Publication', value);
    }
    return _PreviewFact('Metadata', value);
  }

  bool _looksLikeMetadataSummary(String value) {
    if (value.contains(' · ')) {
      return true;
    }
    final lower = value.trim().toLowerCase();
    return lower == 'variant' || RegExp(r'^\d+\s+pages?$').hasMatch(lower);
  }

  List<_PreviewFact> _dedupeFacts(List<_PreviewFact> facts) {
    final result = <_PreviewFact>[];
    final seen = <String>{};
    for (final fact in facts) {
      final normalizedValue = fact.value?.trim();
      if (normalizedValue == null || normalizedValue.isEmpty) {
        continue;
      }
      final key = '${fact.label}\n$normalizedValue';
      if (seen.add(key)) {
        result.add(_PreviewFact(fact.label, normalizedValue));
      }
    }
    return result;
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String? _pageLabel(int? value) {
    if (value == null) {
      return null;
    }
    return '$value page${value == 1 ? '' : 's'}';
  }

  String? _formatOptionalDate(DateTime? value) {
    return value == null ? null : _formatDate(value);
  }

  String? _moneyLabel(int? cents, String? currency) {
    if (cents == null) {
      return null;
    }
    final absolute = cents.abs();
    final sign = cents < 0 ? '-' : '';
    final whole = absolute ~/ 100;
    final fraction = (absolute % 100).toString().padLeft(2, '0');
    return '${currency ?? ''} $sign$whole.$fraction'.trim();
  }
}

class _PreviewFact {
  const _PreviewFact(this.label, this.value);

  final String label;
  final String? value;
}

class _PreviewCandidateIdentity {
  const _PreviewCandidateIdentity({
    required this.seriesTitle,
    required this.issueLabel,
    required this.variantLabel,
  });

  final String seriesTitle;
  final String issueLabel;
  final String variantLabel;

  factory _PreviewCandidateIdentity.from(ProviderCandidate candidate) {
    final title = candidate.title.trim();
    final bracketMatch = RegExp(r'\s*\[[^\]]+\]\s*$').firstMatch(title);
    final bracketLabel = bracketMatch == null
        ? null
        : title
            .substring(bracketMatch.start, bracketMatch.end)
            .replaceAll(RegExp(r'^\s*\[|\]\s*$'), '')
            .trim();
    final titleWithoutBracket = bracketMatch == null
        ? title
        : title.substring(0, bracketMatch.start).trim();
    final issueMatch = RegExp(
      r'^(.+?)\s+#\s*([A-Za-z0-9][A-Za-z0-9./-]*)(.*)$',
    ).firstMatch(titleWithoutBracket);
    if (issueMatch == null) {
      return _PreviewCandidateIdentity(
        seriesTitle:
            titleWithoutBracket.isEmpty ? candidate.title : titleWithoutBracket,
        issueLabel: 'Result',
        variantLabel: _variantLabel(
          candidate,
          bracketLabel: bracketLabel,
        ),
      );
    }

    final trailing = issueMatch.group(3)!.trim().replaceFirst(
          RegExp(r'^[\s:|\-]+'),
          '',
        );
    return _PreviewCandidateIdentity(
      seriesTitle: issueMatch.group(1)!.trim(),
      issueLabel: '#${issueMatch.group(2)!.trim()}',
      variantLabel: _variantLabel(
        candidate,
        bracketLabel: bracketLabel,
        trailingLabel: trailing,
      ),
    );
  }

  static String _variantLabel(
    ProviderCandidate candidate, {
    String? bracketLabel,
    String? trailingLabel,
  }) {
    final cleanTrailing = trailingLabel == null || trailingLabel.trim().isEmpty
        ? null
        : trailingLabel.trim();
    if (candidate.isVariant) {
      return bracketLabel == null || bracketLabel.isEmpty
          ? cleanTrailing ?? 'Variant cover'
          : bracketLabel;
    }
    if (bracketLabel != null && bracketLabel.isNotEmpty) {
      return 'Standard cover | $bracketLabel';
    }
    return cleanTrailing ?? 'Standard cover';
  }
}

class _AddPreviewChips extends StatelessWidget {
  const _AddPreviewChips({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final label in labels.take(12))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF242424),
              border: Border.all(color: const Color(0xFF555555)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
      ],
    );
  }
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
