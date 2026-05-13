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
    required this.selectedIsOwned,
    required this.selectedIsWishlisted,
    required this.searchedServer,
  });

  final CatalogItem? item;
  final ProviderCandidate? candidate;
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
                ? 'Select a result or search ComicVine.'
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
    final synopsis = selectedItem?.synopsis ?? selectedCandidate?.summary;
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
                            ? 'ComicVine candidate'
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
                          if (selectedCandidate != null)
                            selectedCandidate.provider,
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
                          'Plot',
                          style: TextStyle(color: Color(0xFF05AEEF)),
                        ),
                        const SizedBox(height: 6),
                        Text(synopsis ?? 'No plot metadata available yet.'),
                        const SizedBox(height: 22),
                        const Text(
                          'Details',
                          style: TextStyle(color: Color(0xFF05AEEF)),
                        ),
                        const SizedBox(height: 6),
                        _AddPreviewMetadata(
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

class _AddPreviewMetadata extends StatelessWidget {
  const _AddPreviewMetadata({
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
    final selectedItem = item;
    final rows = selectedItem == null
        ? [
            ('Provider', candidate?.provider),
            ('Provider ID', candidate?.providerItemId),
          ]
        : [
            ('Status', localStatus),
            ('Catalog ID', selectedItem.id),
            ('Series', detail?.seriesTitle ?? selectedItem.title),
            ('Issue', selectedItem.itemNumber),
            ('Publisher', detail?.publisher ?? selectedItem.publisher),
            ('Cover Date', _formatOptionalDate(detail?.coverDate)),
            ('Release', _formatOptionalDate(selectedItem.releaseDate)),
            ('Pages', detail?.pageCount?.toString()),
            ('Barcode', detail?.barcode ?? selectedItem.barcode),
            ('Price', _moneyLabel(detail?.coverPriceCents, detail?.currency)),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows)
          if (row.$2 != null && row.$2!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 88,
                    child: Text(
                      row.$1,
                      style: const TextStyle(
                        color: Color(0xFFB8B8B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(child: Text(row.$2!)),
                ],
              ),
            ),
      ],
    );
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
