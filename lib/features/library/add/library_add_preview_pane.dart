part of 'library_add_dialog.dart';

class _LibraryAddPaneResizeDivider extends StatelessWidget {
  const _LibraryAddPaneResizeDivider({this.onDragDelta});

  final ValueChanged<double>? onDragDelta;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: onDragDelta == null
            ? null
            : (details) => onDragDelta!(details.delta.dx),
        child: Tooltip(
          message: 'Resize results pane',
          child: SizedBox(
            width: 10,
            child: Center(
              child: Container(width: 2, color: kAppDivider),
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryAddPreviewPane extends ConsumerWidget {
  const _LibraryAddPreviewPane({
    required this.type,
    required this.accent,
    required this.item,
    required this.candidate,
    required this.candidatePreview,
    required this.isFetchingPreview,
    required this.providerLabel,
    required this.searched,
    required this.addTarget,
    required this.referenceType,
    required this.availableBundleReleases,
    required this.selectedBundleReleaseId,
    required this.selectedBundleReleaseDetail,
    required this.isLoadingBundleReleases,
    required this.isLoadingBundleReleaseDetail,
    required this.onReferenceTypeChanged,
    required this.onBundleReleaseSelected,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final LibraryMetadataItem? item;
  final ProviderCandidate? candidate;
  final AdminProviderPreview? candidatePreview;
  final bool isFetchingPreview;
  final String providerLabel;
  final bool searched;
  final LibraryAddTarget addTarget;
  final LibraryAddReferenceType referenceType;
  final List<BundleReleaseSummary> availableBundleReleases;
  final String? selectedBundleReleaseId;
  final BundleReleaseDetail? selectedBundleReleaseDetail;
  final bool isLoadingBundleReleases;
  final bool isLoadingBundleReleaseDetail;
  final ValueChanged<LibraryAddReferenceType> onReferenceTypeChanged;
  final ValueChanged<String> onBundleReleaseSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItem = item;
    final selectedCandidate = candidate;
    final selectedBundle =
      referenceType == LibraryAddReferenceType.bundleRelease
        ? selectedBundleReleaseDetail
        : null;
    if (selectedItem == null && selectedCandidate == null) {
      return ColoredBox(
        color: const Color(0xFF060606),
        child: Center(
          child: Text(
            searched
                ? 'Select a result or search $providerLabel.'
                : 'Search Collectarr Core to preview metadata.',
          ),
        ),
      );
    }
    final title = selectedBundle?.title ?? selectedItem?.title ?? selectedCandidate!.title;
    final itemNumber = selectedBundle == null ? selectedItem?.itemNumber : null;
    final preview = candidatePreview;
    final synopsis = selectedItem?.synopsis ??
        preview?.synopsis ??
        selectedCandidate?.summary;
    final coverUrl = selectedBundle?.coverImageUrl ??
      selectedItem?.displayCoverUrl ??
        preview?.coverImageUrl ??
        selectedCandidate?.imageUrl;
    final rows = selectedItem == null
        ? (preview != null
        ? _metadataRowsForFullPreview(preview, type)
        : _metadataRowsForCandidate(selectedCandidate!, type))
        : _metadataRowsForItem(selectedItem, type);
    final seriesTree = _seriesTreeDataForSelection(
      type: type,
      item: selectedItem,
      candidate: selectedCandidate,
      preview: preview,
    );
    final statusSummary = _previewStatusSummary(
      item: selectedItem,
      candidate: selectedCandidate,
      preview: preview,
      isFetchingPreview: isFetchingPreview,
    );
    final discoverySections = _discoverySections(
      item: selectedItem,
      candidate: selectedCandidate,
      preview: preview,
    );
    final tracks = type.capabilities.showsTrackData
        ? _previewTracksForSelection(
            item: selectedItem,
            preview: preview,
          )
        : const <_PreviewTrackData>[];
    final customPreview = type.presentation.builder.buildAddPreviewPane(
      context: context,
      accent: accent,
      singularLabel: type.singularLabel,
      labels: type.presentation.fieldLabels,
      previewLabels: type.presentation.previewLabels,
      item: selectedItem,
      candidate: selectedCandidate,
      preview: preview,
      isFetchingPreview: isFetchingPreview,
      providerLabel: providerLabel,
    );
    if (customPreview != null) {
      return customPreview;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF020202),
            Color.alphaBlend(accent.withValues(alpha: 0.22), kAppCanvas),
            const Color(0xFF050505),
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
                        itemNumber == null ? title : '$title #$itemNumber',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accent,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.02,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedItem == null
                            ? '$providerLabel candidate'
                            : 'Collectarr Core metadata',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                LibraryAddResultBadge(
                  selectedItem == null ? providerLabel : type.singularLabel,
                ),
              ],
            ),
            Divider(height: 22, color: accent.withValues(alpha: 0.42)),
            if (selectedItem != null) ...[
              _LibraryAddReferenceSelector(
                accent: accent,
                addTarget: addTarget,
                referenceType: referenceType,
                item: selectedItem,
                bundleReleases: availableBundleReleases,
                selectedBundleReleaseId: selectedBundleReleaseId,
                isLoadingBundleReleases: isLoadingBundleReleases,
                onReferenceTypeChanged: onReferenceTypeChanged,
                onBundleReleaseSelected: onBundleReleaseSelected,
              ),
              const SizedBox(height: 14),
            ],
            _LibraryAddPreviewStatusBanner(
              accent: accent,
              summary: statusSummary,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        if (type.capabilities.showsSynopsis &&
                          synopsis != null &&
                            synopsis.trim().isNotEmpty) ...[
                          Text('Plot', style: TextStyle(color: accent)),
                          const SizedBox(height: 6),
                          Text(synopsis),
                          const SizedBox(height: 22),
                        ],
                        if (seriesTree != null) ...[
                          Text('Series', style: TextStyle(color: accent)),
                          const SizedBox(height: 8),
                          _LibraryAddPreviewSeriesTree(
                            data: seriesTree,
                            accent: accent,
                          ),
                        ],
                        if (discoverySections.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          Text('Discovery', style: TextStyle(color: accent)),
                          const SizedBox(height: 8),
                          for (final section in discoverySections)
                            _LibraryAddPreviewDiscoverySection(
                              title: section.title,
                              values: section.values,
                              accent: accent,
                            ),
                        ],
                        if (selectedItem != null &&
                            referenceType ==
                                LibraryAddReferenceType.bundleRelease) ...[
                          const SizedBox(height: 22),
                          Text('Bundle', style: TextStyle(color: accent)),
                          const SizedBox(height: 8),
                          if (selectedBundleReleaseId != null &&
                              isLoadingBundleReleaseDetail)
                            const Row(
                              children: [
                                SizedBox.square(
                                  dimension: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Loading bundle contents...',
                                  style: TextStyle(color: kAppTextMuted),
                                ),
                              ],
                            )
                          else if (selectedBundle != null)
                            _BundleReleaseDetailCard(
                              detail: selectedBundle,
                              accent: accent,
                            )
                          else
                            const Text(
                              'Select a bundle release to preview its members.',
                              style: TextStyle(color: kAppTextMuted),
                            ),
                        ],
                        const SizedBox(height: 22),
                        Text('Details', style: TextStyle(color: accent)),
                        const SizedBox(height: 8),
                        for (final row in rows)
                          if (row.$2 != null && row.$2!.trim().isNotEmpty)
                            _LibraryAddPreviewMetadataRow(
                              label: row.$1,
                              value: row.$2!,
                            ),
                        if (isFetchingPreview) ...[
                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              SizedBox.square(
                                dimension: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Fetching full metadata...',
                                style: TextStyle(color: kAppTextMuted),
                              ),
                            ],
                          ),
                        ],
                        if (tracks.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          Text(
                            'Tracks (${tracks.length})',
                            style: TextStyle(color: accent),
                          ),
                          const SizedBox(height: 8),
                          for (var i = 0; i < tracks.length; i++)
                            _PreviewTrackRow(
                              index: i + 1,
                              track: tracks[i],
                              accent: accent,
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
                        color: const Color(0x12000000),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: AspectRatio(
                          aspectRatio: 2 / 3,
                          child: LibraryInteractiveCover(
                            title: title,
                            itemNumber: itemNumber,
                            imageUrl: coverUrl,
                            accentColor: accent,
                            borderRadius: 6,
                          ),
                        ),
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

class _BundleReleaseDetailCard extends StatelessWidget {
  const _BundleReleaseDetailCard({
    required this.detail,
    required this.accent,
  });

  final BundleReleaseDetail detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final summaryParts = <String>[
      if (detail.bundleType != null && detail.bundleType!.trim().isNotEmpty)
        detail.bundleType!,
      if (detail.packagingType != null && detail.packagingType!.trim().isNotEmpty)
        detail.packagingType!,
      if (detail.publisher != null && detail.publisher!.trim().isNotEmpty)
        detail.publisher!,
      '${detail.contentSummary.totalItems} items',
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x12000000),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (summaryParts.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                summaryParts.join(' • '),
                style: const TextStyle(
                  color: kAppTextMuted,
                  fontSize: 12,
                ),
              ),
            ],
            if (detail.members.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (final member in detail.members)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        member.isPrimary
                            ? Icons.radio_button_checked
                            : Icons.subdirectory_arrow_right,
                        size: 16,
                        color: member.isPrimary
                            ? accent
                            : accent.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _bundleMemberTitle(member),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              _bundleMemberSubtitle(member),
                              style: const TextStyle(
                                color: kAppTextMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

String _bundleMemberTitle(BundleReleaseMember member) {
  final number = member.itemNumber;
  if (number != null && number.trim().isNotEmpty) {
    return '${member.title} #$number';
  }
  return member.title;
}

String _bundleMemberSubtitle(BundleReleaseMember member) {
  final parts = <String>[
    if (member.role.trim().isNotEmpty) member.role,
    if (member.seriesTitle != null && member.seriesTitle!.trim().isNotEmpty)
      member.seriesTitle!,
    if (member.volumeName != null && member.volumeName!.trim().isNotEmpty)
      member.volumeName!,
    if (member.discNumber != null) 'Disc ${member.discNumber}',
    if (member.quantity > 1) 'x${member.quantity}',
  ];
  return parts.join(' • ');
}

class _LibraryAddReferenceSelector extends StatelessWidget {
  const _LibraryAddReferenceSelector({
    required this.accent,
    required this.addTarget,
    required this.referenceType,
    required this.item,
    required this.bundleReleases,
    required this.selectedBundleReleaseId,
    required this.isLoadingBundleReleases,
    required this.onReferenceTypeChanged,
    required this.onBundleReleaseSelected,
  });

  final Color accent;
  final LibraryAddTarget addTarget;
  final LibraryAddReferenceType referenceType;
  final LibraryMetadataItem item;
  final List<BundleReleaseSummary> bundleReleases;
  final String? selectedBundleReleaseId;
  final bool isLoadingBundleReleases;
  final ValueChanged<LibraryAddReferenceType> onReferenceTypeChanged;
  final ValueChanged<String> onBundleReleaseSelected;

  @override
  Widget build(BuildContext context) {
    final releaseAvailable = item.editions.isNotEmpty;
    final bundleAvailable = bundleReleases.isNotEmpty;
    final selectionLocked = addTarget == LibraryAddTarget.track;
    final selectionSummary = switch (addTarget) {
      LibraryAddTarget.track =>
        'Tracking stays item-centric even when ownership points to a release or bundle.',
      LibraryAddTarget.owned => referenceType.helperLabel,
      LibraryAddTarget.wishlist => referenceType.helperLabel,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x10000000),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Reference',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                LibraryAddResultBadge(addTarget.destinationLabel),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ReferenceChip(
                  accent: accent,
                  selected: referenceType == LibraryAddReferenceType.media,
                  enabled: !selectionLocked,
                  label: LibraryAddReferenceType.media.label,
                  onPressed: () =>
                      onReferenceTypeChanged(LibraryAddReferenceType.media),
                ),
                _ReferenceChip(
                  accent: accent,
                  selected: referenceType == LibraryAddReferenceType.release,
                  enabled: !selectionLocked && releaseAvailable,
                  label: LibraryAddReferenceType.release.label,
                  onPressed: () =>
                      onReferenceTypeChanged(LibraryAddReferenceType.release),
                ),
                _ReferenceChip(
                  accent: accent,
                  selected:
                      referenceType == LibraryAddReferenceType.bundleRelease,
                  enabled: !selectionLocked && (bundleAvailable || isLoadingBundleReleases),
                  label: LibraryAddReferenceType.bundleRelease.label,
                  onPressed: () => onReferenceTypeChanged(
                    LibraryAddReferenceType.bundleRelease,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              selectionSummary,
              style: const TextStyle(
                color: kAppTextMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!selectionLocked &&
                referenceType == LibraryAddReferenceType.release) ...[
              const SizedBox(height: 8),
              Text(
                _releaseSummary(item),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
            if (!selectionLocked &&
                referenceType == LibraryAddReferenceType.bundleRelease) ...[
              const SizedBox(height: 10),
              if (isLoadingBundleReleases)
                const Row(
                  children: [
                    SizedBox.square(
                      dimension: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Loading bundle releases...',
                      style: TextStyle(color: kAppTextMuted),
                    ),
                  ],
                )
              else if (bundleReleases.isEmpty)
                const Text(
                  'No bundle releases are linked to this item yet.',
                  style: TextStyle(color: kAppTextMuted),
                )
              else
                Column(
                  children: [
                    for (final bundle in bundleReleases)
                      _BundleReleaseOptionCard(
                        bundle: bundle,
                        accent: accent,
                        selected: bundle.id == selectedBundleReleaseId,
                        onPressed: () => onBundleReleaseSelected(bundle.id),
                      ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReferenceChip extends StatelessWidget {
  const _ReferenceChip({
    required this.accent,
    required this.selected,
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final Color accent;
  final bool selected;
  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: enabled ? (_) => onPressed() : null,
      selectedColor: accent.withValues(alpha: 0.2),
      side: BorderSide(
        color: selected
            ? accent.withValues(alpha: 0.8)
            : kAppDivider.withValues(alpha: enabled ? 1 : 0.5),
      ),
      labelStyle: TextStyle(
        color: enabled ? null : kAppTextMuted,
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: const Color(0x12000000),
    );
  }
}

class _BundleReleaseOptionCard extends StatelessWidget {
  const _BundleReleaseOptionCard({
    required this.bundle,
    required this.accent,
    required this.selected,
    required this.onPressed,
  });

  final BundleReleaseSummary bundle;
  final Color accent;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final releaseDate = bundle.releaseDate;
    final subtitleParts = <String>[
      if (bundle.bundleType != null && bundle.bundleType!.trim().isNotEmpty)
        bundle.bundleType!,
      if (bundle.packagingType != null && bundle.packagingType!.trim().isNotEmpty)
        bundle.packagingType!,
      if (releaseDate != null)
        '${releaseDate.year}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}',
      '${bundle.contentSummary.totalItems} items',
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.14)
                : const Color(0x0E000000),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.85)
                  : kAppDivider,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected ? accent : kAppTextMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bundle.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      if (subtitleParts.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitleParts.join(' • '),
                          style: const TextStyle(
                            color: kAppTextMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (bundle.primaryItemTitle != null &&
                          bundle.primaryItemTitle!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Primary: ${bundle.primaryItemTitle}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _releaseSummary(LibraryMetadataItem item) {
  final edition = _previewPrimaryEditionForItem(item);
  final variant = _previewPrimaryVariantForEdition(edition);
  if (edition == null) {
    return 'No canonical release is attached to this item yet.';
  }
  final parts = <String>[
    edition.title,
    if (variant?.name case final variantName? when variantName.trim().isNotEmpty)
      variantName,
    if (edition.physicalFormatLabel != null &&
        edition.physicalFormatLabel!.trim().isNotEmpty)
      edition.physicalFormatLabel!,
  ];
  return parts.join(' • ');
}

CatalogEdition? _previewPrimaryEditionForItem(LibraryMetadataItem item) {
  if (item.editions.isEmpty) {
    return null;
  }
  for (final edition in item.editions) {
    if (_previewPrimaryVariantForEdition(edition) != null) {
      return edition;
    }
  }
  return item.editions.first;
}

CatalogVariant? _previewPrimaryVariantForEdition(CatalogEdition? edition) {
  if (edition == null || edition.variants.isEmpty) {
    return null;
  }
  for (final variant in edition.variants) {
    if (variant.isPrimary) {
      return variant;
    }
  }
  return edition.variants.first;
}

List<(String, String?)> _metadataRowsForCandidate(
  ProviderCandidate candidate,
  LibraryTypeConfig type,
) {
  final labels = libraryMediaFieldLabels(type);
  final previewLabels = type.presentation.previewLabels;
  return [
    if (candidate.series?.seriesTitle != null)
      (previewLabels.series, candidate.series!.seriesTitle),
    if (candidate.issueNumber != null) (labels.number, candidate.issueNumber),
    if (candidate.publisher != null) (labels.publisher, candidate.publisher),
    if (candidate.series?.volumeStartYear != null)
      ('Year', candidate.series!.volumeStartYear.toString()),
    if (candidate.variantName != null) (labels.variant, candidate.variantName),
    if (candidate.issueCount != null)
      (previewLabels.itemCount, candidate.issueCount.toString()),
  ];
}

List<(String, String?)> _metadataRowsForItem(
  LibraryMetadataItem item,
  LibraryTypeConfig type,
) {
  final labels = libraryMediaFieldLabels(type);
  final previewLabels = type.presentation.previewLabels;
  final series = item.series;
  final video = item.video;
  final music = item.music;
  final game = item.game;
  final publishing = item.publishing;
  return [
    if (series?.seriesTitle != null) (previewLabels.series, series!.seriesTitle),
    (labels.publisher, item.publisher),
    ('Released', item.releaseDate != null
        ? '${item.releaseDate!.year}-${item.releaseDate!.month.toString().padLeft(2, '0')}-${item.releaseDate!.day.toString().padLeft(2, '0')}'
        : item.releaseYear?.toString()),
    if (video?.runtimeMinutes != null) ('Runtime', '${video!.runtimeMinutes} min'),
    if (item.itemNumber != null) (labels.number, item.itemNumber),
    if (item.displayEditionLabel != null)
      (labels.variant, item.displayEditionLabel),
    (labels.barcode, item.barcode),
    if (type.capabilities.showsTrackData &&
      music?.trackCount != null)
      ('Tracks', music!.trackCount.toString()),
    if (music?.catalogNumber != null) ('Catalog No.', music!.catalogNumber),
    if (game?.platforms case final platforms? when platforms.isNotEmpty)
      ('Platforms', platforms.join(', ')),
    if (publishing?.pageCount != null) ('Pages', publishing!.pageCount.toString()),
    if (item.country != null) ('Country', item.country),
    if (music?.releaseStatus != null)
      ('Release Status', music!.releaseStatus),
    if (item.language != null) ('Language', item.language),
  ];
}

_PreviewSeriesTreeData? _seriesTreeDataForSelection({
  required LibraryTypeConfig type,
  required LibraryMetadataItem? item,
  required ProviderCandidate? candidate,
  required AdminProviderPreview? preview,
}) {
  final labels = libraryMediaFieldLabels(type);
  final seriesTitle =
      item?.series?.seriesTitle ??
      preview?.series?.seriesTitle ??
      candidate?.series?.seriesTitle;
  if (seriesTitle == null || seriesTitle.trim().isEmpty) {
    return null;
  }
  final issueNumber = item?.itemNumber ?? preview?.itemNumber ?? candidate?.issueNumber;
  final selectedTitle = item?.title ?? preview?.title ?? candidate?.title;
  final year =
      preview?.series?.volumeStartYear ??
      candidate?.series?.volumeStartYear ??
      item?.releaseYear;
  final issueCount = candidate?.issueCount;
  final variantLabel =
      item?.displayEditionLabel ?? preview?.variantName ?? candidate?.variantName;
  final children = <_PreviewSeriesTreeChildData>[];

  if (issueNumber != null && issueNumber.trim().isNotEmpty) {
    final childTitle = '${labels.number}: $issueNumber';
    final childSubtitle = selectedTitle != null &&
            selectedTitle.trim().isNotEmpty &&
            selectedTitle.trim() != seriesTitle.trim()
        ? selectedTitle
        : variantLabel;
    children.add(
      _PreviewSeriesTreeChildData(
        title: childTitle,
        subtitle: childSubtitle,
      ),
    );
  } else if (selectedTitle != null &&
      selectedTitle.trim().isNotEmpty &&
      selectedTitle.trim() != seriesTitle.trim()) {
    children.add(_PreviewSeriesTreeChildData(title: selectedTitle));
  }

  final badges = <String>[
    if (year != null) '$year',
    if (issueCount != null)
      '$issueCount ${issueCount == 1 ? labels.number.toLowerCase() : '${labels.number.toLowerCase()}s'}',
  ];

  return _PreviewSeriesTreeData(
    title: seriesTitle,
    badges: badges,
    children: children,
  );
}

class _LibraryAddPreviewMetadataRow extends StatelessWidget {
  const _LibraryAddPreviewMetadataRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                color: kAppTextMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewSeriesTreeData {
  const _PreviewSeriesTreeData({
    required this.title,
    required this.badges,
    required this.children,
  });

  final String title;
  final List<String> badges;
  final List<_PreviewSeriesTreeChildData> children;
}

class _PreviewSeriesTreeChildData {
  const _PreviewSeriesTreeChildData({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
}

class _LibraryAddPreviewSeriesTree extends StatelessWidget {
  const _LibraryAddPreviewSeriesTree({
    required this.data,
    required this.accent,
  });

  final _PreviewSeriesTreeData data;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x14000000),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_tree_outlined,
                  size: 16,
                  color: accent.withValues(alpha: 0.95),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (data.badges.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final badge in data.badges)
                              _LibraryAddPreviewSeriesBadge(
                                label: badge,
                                accent: accent,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (data.children.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (final child in data.children)
                Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.subdirectory_arrow_right,
                        size: 16,
                        color: accent.withValues(alpha: 0.72),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (child.subtitle != null &&
                                child.subtitle!.trim().isNotEmpty)
                              Text(
                                child.subtitle!,
                                style: const TextStyle(
                                  color: kAppTextMuted,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LibraryAddPreviewSeriesBadge extends StatelessWidget {
  const _LibraryAddPreviewSeriesBadge({
    required this.label,
    required this.accent,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: accent.withValues(alpha: 0.95),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

List<(String, String?)> _metadataRowsForFullPreview(
  AdminProviderPreview preview,
  LibraryTypeConfig type,
) {
  final labels = libraryMediaFieldLabels(type);
  final previewLabels = type.presentation.previewLabels;
  final series = preview.series;
  final publishing = preview.publishing;
  final music = preview.music;
  final video = preview.video;
  final game = preview.game;
  final releaseDateStr = preview.releaseDate != null
      ? '${preview.releaseDate!.year}-${preview.releaseDate!.month.toString().padLeft(2, '0')}-${preview.releaseDate!.day.toString().padLeft(2, '0')}'
      : null;
  return [
    if (series?.seriesTitle != null) (previewLabels.series, series!.seriesTitle),
    if (preview.publisher != null) (labels.publisher, preview.publisher),
    if (publishing?.imprint != null) ('Imprint', publishing!.imprint),
    if (releaseDateStr != null) ('Released', releaseDateStr),
    if (series?.volumeStartYear != null)
      ('Year', series!.volumeStartYear.toString()),
    if (preview.itemNumber != null) (labels.number, preview.itemNumber),
    if (preview.barcode != null) (labels.barcode, preview.barcode),
    if (preview.isbn != null) ('ISBN', preview.isbn),
    if (preview.country != null) ('Country', preview.country),
    if (preview.language != null) ('Language', preview.language),
    if (preview.physicalFormatLabel != null)
      ('Format', preview.physicalFormatLabel),
    if (preview.variantName != null) (labels.variant, preview.variantName),
    if (collectarrLibraryTypes.capabilitiesForKind(preview.kind).showsTrackData &&
      music?.trackCount != null)
      ('Tracks', music!.trackCount.toString()),
    if (music?.catalogNumber != null)
      ('Catalog No.', music!.catalogNumber),
    if (game?.platforms case final platforms? when platforms.isNotEmpty)
      ('Platforms', platforms.join(', ')),
    if (video?.runtimeMinutes != null)
      ('Runtime', '${video!.runtimeMinutes} min'),
    if (publishing?.pageCount != null) ('Pages', publishing!.pageCount.toString()),
    if (music?.releaseStatus != null)
      ('Release Status', music!.releaseStatus),
    if (publishing?.seriesGroup != null) ('Series Group', publishing!.seriesGroup),
  ];
}

String _previewStatusSummary({
  required LibraryMetadataItem? item,
  required ProviderCandidate? candidate,
  required AdminProviderPreview? preview,
  required bool isFetchingPreview,
}) {
  if (item != null) {
    return 'Using cached Collectarr Core metadata already stored in the app.';
  }
  if (preview != null) {
    return 'Provider metadata loaded directly from search results.';
  }
  if (candidate?.isStub ?? false) {
    return 'Provider metadata is unavailable for this result.';
  }
  if (isFetchingPreview) {
    return 'Loading provider metadata.';
  }
  return 'Provider metadata is unavailable for this result.';
}

List<_PreviewDiscoverySectionData> _discoverySections({
  required LibraryMetadataItem? item,
  required ProviderCandidate? candidate,
  required AdminProviderPreview? preview,
}) {
  final creators = item?.creators
          ?.map((credit) => credit['name']?.toString() ?? '')
          .where((name) => name.trim().isNotEmpty)
          .toList(growable: false) ??
      (preview?.creators
              .map((credit) => credit.role == null
                  ? credit.name
                  : '${credit.name} (${credit.role})')
              .toList(growable: false) ??
          const <String>[]);
  final characters = item?.characters ?? preview?.characters ?? candidate?.characterPreview ?? const <String>[];
  final storyArcs = item?.storyArcs ?? preview?.storyArcs ?? candidate?.storyArcPreview ?? const <String>[];
  final genres = item?.genres ?? preview?.genres ?? const <String>[];

  return [
    if (creators.isNotEmpty)
      _PreviewDiscoverySectionData('Creators', creators),
    if (characters.isNotEmpty)
      _PreviewDiscoverySectionData('Characters', characters),
    if (storyArcs.isNotEmpty)
      _PreviewDiscoverySectionData('Story Arcs', storyArcs),
    if (genres.isNotEmpty) _PreviewDiscoverySectionData('Genres', genres),
  ];
}

class _LibraryAddPreviewStatusBanner extends StatelessWidget {
  const _LibraryAddPreviewStatusBanner({
    required this.accent,
    required this.summary,
  });

  final Color accent;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 16, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                summary,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewDiscoverySectionData {
  const _PreviewDiscoverySectionData(this.title, this.values);

  final String title;
  final List<String> values;
}

class _LibraryAddPreviewDiscoverySection extends StatelessWidget {
  const _LibraryAddPreviewDiscoverySection({
    required this.title,
    required this.values,
    required this.accent,
  });

  final String title;
  final List<String> values;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accent.withValues(alpha: 0.95),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final value in values)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF183B44),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: const Color(0x8837C7E8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewTrackRow extends StatelessWidget {
  const _PreviewTrackRow({
    required this.index,
    required this.track,
    required this.accent,
  });

  final int index;
  final _PreviewTrackData track;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final duration = track.durationSeconds;
    final durationStr = duration != null
        ? '${duration ~/ 60}:${(duration % 60).toString().padLeft(2, '0')}'
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '${track.position ?? index}',
              style: TextStyle(
                color: accent.withValues(alpha: 0.7),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          if (durationStr != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                durationStr,
                style: const TextStyle(
                  color: kAppTextMuted,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PreviewTrackData {
  const _PreviewTrackData({
    required this.title,
    this.position,
    this.durationSeconds,
  });

  final String title;
  final int? position;
  final int? durationSeconds;
}

List<_PreviewTrackData> _previewTracksForSelection({
  required LibraryMetadataItem? item,
  required AdminProviderPreview? preview,
}) {
  final tracks = item?.music?.tracks;
  if (tracks != null && tracks.isNotEmpty) {
    return [
      for (final track in tracks)
        _PreviewTrackData(
          title: track.title.trim().isEmpty ? 'Untitled track' : track.title,
          position: track.position,
          durationSeconds: track.durationSeconds,
        ),
    ];
  }
  final previewTracks = preview?.music?.tracks;
  if (previewTracks == null || previewTracks.isEmpty) {
    return const [];
  }
  return [
    for (final track in previewTracks)
      _PreviewTrackData(
        title: track.title,
        position: track.position,
        durationSeconds: track.durationSeconds,
      ),
  ];
}

/// A decorated dialog shell with resize handles on the right and bottom edges.
class _ResizableDialogShell extends StatelessWidget {
  const _ResizableDialogShell({
    required this.accent,
    required this.onResizeWidth,
    required this.onResizeHeight,
    required this.child,
  });

  final Color accent;
  final ValueChanged<double> onResizeWidth;
  final ValueChanged<double> onResizeHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: kAppPanel,
            border: Border.all(color: kAppDivider),
            boxShadow: const [
              BoxShadow(
                color: Color(0xCC000000),
                blurRadius: 22,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
        // Right edge resize handle.
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (d) => onResizeWidth(d.delta.dx * 2),
              child: const SizedBox(width: 6),
            ),
          ),
        ),
        // Bottom edge resize handle.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (d) => onResizeHeight(d.delta.dy * 2),
              child: const SizedBox(height: 6),
            ),
          ),
        ),
        // Bottom-right corner resize handle.
        Positioned(
          right: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeDownRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (d) {
                onResizeWidth(d.delta.dx * 2);
                onResizeHeight(d.delta.dy * 2);
              },
              child: const SizedBox(width: 12, height: 12),
            ),
          ),
        ),
      ],
    );
  }
}
