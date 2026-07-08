import 'library_add_pane_dependencies.dart';

class LibraryAddPaneResizeDivider extends StatelessWidget {
  const LibraryAddPaneResizeDivider({super.key, this.onDragDelta});

  final ValueChanged<double>? onDragDelta;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
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
              child: Container(width: 2, color: palette.divider),
            ),
          ),
        ),
      ),
    );
  }
}

class LibraryAddPreviewPane extends ConsumerWidget {
  const LibraryAddPreviewPane({
    super.key,
    required this.type,
    required this.accent,
    required this.isMovieDesktopChrome,
    required this.previewPaneBuilder,
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
    required this.selectedEditionId,
    required this.selectedVariantId,
    required this.isLoadingBundleReleases,
    required this.isLoadingBundleReleaseDetail,
    required this.onReferenceTypeChanged,
    required this.onEditionSelected,
    required this.onVariantSelected,
    required this.onBundleReleaseSelected,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final bool isMovieDesktopChrome;
  final LibraryAddPreviewPaneBuilder? previewPaneBuilder;
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
  final String? selectedEditionId;
  final String? selectedVariantId;
  final bool isLoadingBundleReleases;
  final bool isLoadingBundleReleaseDetail;
  final ValueChanged<LibraryAddReferenceType> onReferenceTypeChanged;
  final ValueChanged<String> onEditionSelected;
  final ValueChanged<String> onVariantSelected;
  final ValueChanged<String> onBundleReleaseSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final selectedItem = item;
    final selectedCandidate = candidate;
    final selectedBundle =
        referenceType == LibraryAddReferenceType.bundleRelease
            ? selectedBundleReleaseDetail
            : null;
    if (selectedItem == null && selectedCandidate == null) {
      return ColoredBox(
        color: palette.panel,
        child: Center(
          child: Text(
            searched
                ? 'Select a result or search $providerLabel.'
                : 'Search Collectarr Core to preview metadata.',
            style: TextStyle(
              color: palette.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
    final title = selectedBundle?.title ??
        selectedItem?.title ??
        selectedCandidate!.title;
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
    final previewRequest = LibraryAddPreviewPaneRequest(
      type: type,
      accent: accent,
      item: selectedItem,
      candidate: selectedCandidate,
      candidatePreview: preview,
      isFetchingPreview: isFetchingPreview,
      providerLabel: providerLabel,
      searched: searched,
      addTarget: addTarget,
      referenceType: referenceType,
      availableBundleReleases: availableBundleReleases,
      selectedBundleReleaseId: selectedBundleReleaseId,
      selectedBundleReleaseDetail: selectedBundleReleaseDetail,
      selectedEditionId: selectedEditionId,
      selectedVariantId: selectedVariantId,
      isLoadingBundleReleases: isLoadingBundleReleases,
      isLoadingBundleReleaseDetail: isLoadingBundleReleaseDetail,
      onReferenceTypeChanged: onReferenceTypeChanged,
      onEditionSelected: onEditionSelected,
      onVariantSelected: onVariantSelected,
      onBundleReleaseSelected: onBundleReleaseSelected,
    );
    final launcherPreview = previewPaneBuilder?.call(context, previewRequest);
    if (launcherPreview != null) {
      return launcherPreview;
    }
    final customPreview = type.presentation.builder.buildAddPreviewPane(
      context: context,
      accent: accent,
      singularLabel: type.singularLabel,
      mediaFields: type.mediaFields,
      releaseFields: type.releaseFields,
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
            palette.panelRaised,
            Color.alphaBlend(accent.withValues(alpha: 0.12), palette.panel),
            palette.panel,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                      _buildPreviewFormatBadges(selectedItem),
                    ],
                  ),
                ),
                LibraryAddResultBadge(
                  selectedItem == null ? providerLabel : type.singularLabel,
                ),
              ],
            ),
            Divider(height: 18, color: accent.withValues(alpha: 0.42)),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        if (selectedItem != null) ...[
                          _LibraryAddReferenceSelector(
                            type: type,
                            accent: accent,
                            addTarget: addTarget,
                            referenceType: referenceType,
                            item: selectedItem,
                            bundleReleases: availableBundleReleases,
                            selectedBundleReleaseId: selectedBundleReleaseId,
                            selectedEditionId: selectedEditionId,
                            selectedVariantId: selectedVariantId,
                            isLoadingBundleReleases: isLoadingBundleReleases,
                            onReferenceTypeChanged: onReferenceTypeChanged,
                            onEditionSelected: onEditionSelected,
                            onVariantSelected: onVariantSelected,
                            onBundleReleaseSelected: onBundleReleaseSelected,
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (type.capabilities.showsSynopsis &&
                            synopsis != null &&
                            synopsis.trim().isNotEmpty) ...[
                          Text('Plot', style: TextStyle(color: accent)),
                          const SizedBox(height: 6),
                          Text(synopsis),
                          const SizedBox(height: 22),
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
                            Row(
                              children: [
                                const SizedBox.square(
                                  dimension: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Loading bundle contents...',
                                  style: TextStyle(color: palette.textMuted),
                                ),
                              ],
                            )
                          else if (selectedBundle != null)
                            _BundleReleaseDetailCard(
                              detail: selectedBundle,
                              accent: accent,
                            )
                          else
                            Text(
                              'Select a bundle release to preview its members.',
                              style: TextStyle(color: palette.textMuted),
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
                          Row(
                            children: [
                              const SizedBox.square(
                                dimension: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Fetching full metadata...',
                                style: TextStyle(color: palette.textMuted),
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
                        if (type.capabilities.usesSeasonHierarchy &&
                            selectedCandidate != null)
                          _PreviewSeasonsSection(
                            provider: selectedCandidate.provider,
                            providerItemId: selectedCandidate.providerItemId,
                            accent: accent,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 200,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: appPalette(context)
                            .surfaceSubtle
                            .withValues(alpha: 0.74),
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

class BundleReleaseDetailCard extends StatelessWidget {
  const BundleReleaseDetailCard({
    super.key,
    required this.detail,
    required this.accent,
  });

  final BundleReleaseDetail detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _BundleReleaseDetailCard(
      detail: detail,
      accent: accent,
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
    final palette = appPalette(context);
    final groupedMembers = _groupBundleMembers(detail.members);
    final summaryParts = <String>[
      if (detail.bundleType != null && detail.bundleType!.trim().isNotEmpty)
        detail.bundleType!,
      if (detail.packagingType != null &&
          detail.packagingType!.trim().isNotEmpty)
        detail.packagingType!,
      if (detail.publisher != null && detail.publisher!.trim().isNotEmpty)
        detail.publisher!,
      '${detail.contentSummary.totalItems} items',
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle.withValues(alpha: 0.74),
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
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
            if (detail.members.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (final group in groupedMembers) ...[
                _BundleReleaseDiscSection(
                  group: group,
                  accent: accent,
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class LibraryAddReferenceSelector extends StatelessWidget {
  const LibraryAddReferenceSelector({
    super.key,
    required this.type,
    required this.accent,
    required this.addTarget,
    required this.referenceType,
    required this.item,
    required this.bundleReleases,
    required this.selectedBundleReleaseId,
    required this.selectedEditionId,
    required this.selectedVariantId,
    required this.isLoadingBundleReleases,
    required this.onReferenceTypeChanged,
    required this.onEditionSelected,
    required this.onVariantSelected,
    required this.onBundleReleaseSelected,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final LibraryAddTarget addTarget;
  final LibraryAddReferenceType referenceType;
  final LibraryMetadataItem item;
  final List<BundleReleaseSummary> bundleReleases;
  final String? selectedBundleReleaseId;
  final String? selectedEditionId;
  final String? selectedVariantId;
  final bool isLoadingBundleReleases;
  final ValueChanged<LibraryAddReferenceType> onReferenceTypeChanged;
  final ValueChanged<String> onEditionSelected;
  final ValueChanged<String> onVariantSelected;
  final ValueChanged<String> onBundleReleaseSelected;

  @override
  Widget build(BuildContext context) {
    return _LibraryAddReferenceSelector(
      type: type,
      accent: accent,
      addTarget: addTarget,
      referenceType: referenceType,
      item: item,
      bundleReleases: bundleReleases,
      selectedBundleReleaseId: selectedBundleReleaseId,
      selectedEditionId: selectedEditionId,
      selectedVariantId: selectedVariantId,
      isLoadingBundleReleases: isLoadingBundleReleases,
      onReferenceTypeChanged: onReferenceTypeChanged,
      onEditionSelected: onEditionSelected,
      onVariantSelected: onVariantSelected,
      onBundleReleaseSelected: onBundleReleaseSelected,
    );
  }
}

List<(String, String?)> libraryAddMetadataRowsForItem(
  LibraryMetadataItem item,
  LibraryTypeConfig type,
) =>
    _metadataRowsForItem(item, type);

List<(String, String?)> libraryAddMetadataRowsForCandidate(
  ProviderCandidate candidate,
  LibraryTypeConfig type,
) =>
    _metadataRowsForCandidate(candidate, type);

List<(String, String?)> libraryAddMetadataRowsForFullPreview(
  AdminProviderPreview preview,
  LibraryTypeConfig type,
) =>
    _metadataRowsForFullPreview(preview, type);

class LibraryAddPreviewMetadataRow extends StatelessWidget {
  const LibraryAddPreviewMetadataRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _LibraryAddPreviewMetadataRow(
      label: label,
      value: value,
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

class _BundleReleaseDiscSection extends StatelessWidget {
  const _BundleReleaseDiscSection({
    required this.group,
    required this.accent,
  });

  final _BundleReleaseDiscGroup group;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.label,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            for (final member in group.members)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        member.sequenceNumber?.toString() ?? '•',
                        style: TextStyle(
                          color: palette.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
                            style: TextStyle(
                              color: palette.textMuted,
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
        ),
      ),
    );
  }
}

class _BundleReleaseDiscGroup {
  const _BundleReleaseDiscGroup({
    required this.label,
    required this.members,
  });

  final String label;
  final List<BundleReleaseMember> members;
}

List<_BundleReleaseDiscGroup> _groupBundleMembers(
  List<BundleReleaseMember> members,
) {
  if (members.isEmpty) {
    return const <_BundleReleaseDiscGroup>[];
  }
  final grouped = <String, List<BundleReleaseMember>>{};
  final orderedKeys = <String>[];
  for (final member in members) {
    final key = member.discNumber != null
        ? 'disc:${member.discNumber}'
        : member.discLabel != null && member.discLabel!.trim().isNotEmpty
            ? 'label:${member.discLabel!.trim()}'
            : 'disc:none';
    if (!grouped.containsKey(key)) {
      grouped[key] = <BundleReleaseMember>[];
      orderedKeys.add(key);
    }
    grouped[key]!.add(member);
  }
  return [
    for (final key in orderedKeys)
      _BundleReleaseDiscGroup(
        label: _bundleDiscLabel(grouped[key]!.first),
        members: [...grouped[key]!]..sort((left, right) {
            final leftSequence = left.sequenceNumber ?? 999999;
            final rightSequence = right.sequenceNumber ?? 999999;
            return leftSequence.compareTo(rightSequence);
          }),
      ),
  ];
}

String _bundleDiscLabel(BundleReleaseMember member) {
  final discLabel = member.discLabel?.trim();
  if (discLabel != null && discLabel.isNotEmpty) {
    return discLabel;
  }
  final discNumber = member.discNumber;
  if (discNumber != null) {
    return 'Disc $discNumber';
  }
  return 'Main contents';
}

class _LibraryAddReferenceSelector extends StatelessWidget {
  const _LibraryAddReferenceSelector({
    required this.type,
    required this.accent,
    required this.addTarget,
    required this.referenceType,
    required this.item,
    required this.bundleReleases,
    required this.selectedBundleReleaseId,
    required this.selectedEditionId,
    required this.selectedVariantId,
    required this.isLoadingBundleReleases,
    required this.onReferenceTypeChanged,
    required this.onEditionSelected,
    required this.onVariantSelected,
    required this.onBundleReleaseSelected,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final LibraryAddTarget addTarget;
  final LibraryAddReferenceType referenceType;
  final LibraryMetadataItem item;
  final List<BundleReleaseSummary> bundleReleases;
  final String? selectedBundleReleaseId;
  final String? selectedEditionId;
  final String? selectedVariantId;
  final bool isLoadingBundleReleases;
  final ValueChanged<LibraryAddReferenceType> onReferenceTypeChanged;
  final ValueChanged<String> onEditionSelected;
  final ValueChanged<String> onVariantSelected;
  final ValueChanged<String> onBundleReleaseSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final editionAvailable = item.editions.isNotEmpty;
    final bundleAvailable = bundleReleases.isNotEmpty;
    final selectionLocked = addTarget == LibraryAddTarget.track;
    final selectedEdition = previewEditionForItem(item, selectedEditionId);
    final selectedVariant = selectedVariantForEdition(
      selectedEdition,
      selectedVariantId,
    );
    final selectionSummary = switch (addTarget) {
      LibraryAddTarget.track => type.addChrome.trackScopeSummary,
      LibraryAddTarget.owned => referenceType.helperLabelForType(type),
      LibraryAddTarget.wishlist => referenceType.helperLabelForType(type),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle.withValues(alpha: 0.82),
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
                  'Scope',
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
                  chipKey: const ValueKey('library-add-reference-media'),
                  accent: accent,
                  selected: true,
                  enabled: !selectionLocked,
                  label: LibraryAddReferenceType.media.labelForType(type),
                  onPressed: () =>
                      onReferenceTypeChanged(LibraryAddReferenceType.media),
                ),
                if (!selectionLocked) ...[
                  _ReferenceChip(
                    chipKey: const ValueKey('library-add-reference-edition'),
                    accent: accent,
                    selected: referenceType == LibraryAddReferenceType.edition,
                    enabled: editionAvailable,
                    label: LibraryAddReferenceType.edition.labelForType(type),
                    onPressed: () => onReferenceTypeChanged(
                      LibraryAddReferenceType.edition,
                    ),
                  ),
                  _ReferenceChip(
                    chipKey: const ValueKey('library-add-reference-bundle'),
                    accent: accent,
                    selected:
                        referenceType == LibraryAddReferenceType.bundleRelease,
                    enabled: bundleAvailable || isLoadingBundleReleases,
                    label: LibraryAddReferenceType.bundleRelease
                        .labelForType(type),
                    onPressed: () => onReferenceTypeChanged(
                      LibraryAddReferenceType.bundleRelease,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              selectionSummary,
              style: TextStyle(
                color: palette.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!selectionLocked &&
                referenceType == LibraryAddReferenceType.edition) ...[
              const SizedBox(height: 8),
              Text(
                _editionSummaryForSelection(
                  selectedEdition,
                  selectedVariant,
                ),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _EditionGrid(
                key: const ValueKey('library-add-edition-field'),
                editions: item.editions,
                selectedEditionId: selectedEditionId,
                accent: accent,
                onEditionSelected: onEditionSelected,
              ),
              const SizedBox(height: 8),
              if (selectedEdition == null)
                Text(
                  'No canonical edition is attached to this item yet.',
                  style: TextStyle(color: palette.textMuted),
                )
              else if (selectedEdition.variants.isEmpty)
                Text(
                  'This edition has no canonical variants yet, so the edition itself will be used.',
                  style: TextStyle(color: palette.textMuted),
                )
              else
                _VariantGrid(
                  key: const ValueKey('library-add-variant-field'),
                  variants: selectedEdition.variants,
                  selectedVariantId: selectedVariantId,
                  accent: accent,
                  onVariantSelected: onVariantSelected,
                ),
            ],
            if (!selectionLocked &&
                referenceType == LibraryAddReferenceType.bundleRelease) ...[
              const SizedBox(height: 10),
              if (isLoadingBundleReleases)
                Row(
                  children: [
                    const SizedBox.square(
                      dimension: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Loading bundle releases...',
                      style: TextStyle(color: palette.textMuted),
                    ),
                  ],
                )
              else if (bundleReleases.isEmpty)
                Text(
                  'No bundle releases are linked to this item yet.',
                  style: TextStyle(color: palette.textMuted),
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
    this.chipKey,
    required this.accent,
    required this.selected,
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final Key? chipKey;
  final Color accent;
  final bool selected;
  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return ChoiceChip(
      key: chipKey,
      label: Text(label),
      selected: selected,
      onSelected: enabled ? (_) => onPressed() : null,
      selectedColor: accent.withValues(alpha: 0.2),
      side: BorderSide(
        color: selected
            ? accent.withValues(alpha: 0.8)
            : palette.divider.withValues(alpha: enabled ? 1 : 0.5),
      ),
      labelStyle: TextStyle(
        color: enabled ? null : palette.textMuted,
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: palette.surfaceSubtle.withValues(alpha: 0.9),
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
    final palette = appPalette(context);
    final releaseDate = bundle.releaseDate;
    final subtitleParts = <String>[
      if (bundle.bundleType != null && bundle.bundleType!.trim().isNotEmpty)
        bundle.bundleType!,
      if (bundle.packagingType != null &&
          bundle.packagingType!.trim().isNotEmpty)
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
                : palette.surfaceSubtle.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  selected ? accent.withValues(alpha: 0.85) : palette.divider,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? accent : palette.textMuted,
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
                          style: TextStyle(
                            color: palette.textMuted,
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

String _editionSummaryForSelection(
  CatalogEdition? edition,
  CatalogVariant? variant,
) {
  if (edition == null) {
    return 'No canonical edition is attached to this item yet.';
  }
  final parts = <String>[
    edition.title,
    if (variant?.name case final variantName?
        when variantName.trim().isNotEmpty)
      'Physical: $variantName',
    if (edition.physicalFormatLabel != null &&
        edition.physicalFormatLabel!.trim().isNotEmpty)
      edition.physicalFormatLabel!,
    if (edition.region != null && edition.region!.trim().isNotEmpty)
      edition.region!,
    if (edition.releaseDate != null)
      '${edition.releaseDate!.year}-${edition.releaseDate!.month.toString().padLeft(2, '0')}-${edition.releaseDate!.day.toString().padLeft(2, '0')}',
  ];
  return parts.join(' • ');
}

CatalogEdition? previewEditionForItem(
  LibraryMetadataItem item,
  String? editionId,
) {
  final normalizedEditionId = editionId?.trim();
  if (normalizedEditionId != null && normalizedEditionId.isNotEmpty) {
    for (final edition in item.editions) {
      if (edition.id == normalizedEditionId) {
        return edition;
      }
    }
  }
  return _previewPrimaryEditionForItem(item);
}

CatalogVariant? selectedVariantForEdition(
  CatalogEdition? edition,
  String? variantId,
) {
  final normalizedVariantId = variantId?.trim();
  if (edition != null &&
      normalizedVariantId != null &&
      normalizedVariantId.isNotEmpty) {
    for (final variant in edition.variants) {
      if (variant.id == normalizedVariantId) {
        return variant;
      }
    }
  }
  return null;
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

Widget _buildPreviewFormatBadges(LibraryMetadataItem? item) {
  if (item == null || item.editions.isEmpty) return const SizedBox.shrink();
  final seen = <String>{};
  final badges = <Widget>[];
  for (final edition in item.editions) {
    final id = edition.physicalFormat;
    if (id == null || !seen.add(id)) continue;
    badges.add(
      FormatBadge.fromFormat(
        id: id,
        label: edition.physicalFormatLabel ?? id,
      ),
    );
  }
  if (badges.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Wrap(spacing: 4, runSpacing: 4, children: badges),
  );
}

List<(String, String?)> _metadataRowsForCandidate(
  ProviderCandidate candidate,
  LibraryTypeConfig type,
) {
  final media = type.mediaFields;
  final release = type.releaseFields;
  final previewLabels = type.presentation.previewLabels;
  return [
    if (candidate.series?.seriesTitle != null)
      (previewLabels.series, candidate.series!.seriesTitle),
    if (candidate.issueNumber != null)
      (media.numberLabel, candidate.issueNumber),
    if (candidate.publisher != null)
      (media.publisherLabel, candidate.publisher),
    if (candidate.series?.volumeStartYear != null)
      ('Year', candidate.series!.volumeStartYear.toString()),
    if (candidate.variantName != null)
      (release.variantLabel, candidate.variantName),
    if (candidate.issueCount != null)
      (previewLabels.itemCount, candidate.issueCount.toString()),
  ];
}

List<(String, String?)> _metadataRowsForItem(
  LibraryMetadataItem item,
  LibraryTypeConfig type,
) {
  final media = type.mediaFields;
  final release = type.releaseFields;
  final previewLabels = type.presentation.previewLabels;
  final series = item.series;
  final video = item.video;
  final music = item.music;
  final game = item.game;
  final publishing = item.publishing;
  return [
    if (series?.seriesTitle != null)
      (previewLabels.series, series!.seriesTitle),
    (media.publisherLabel, item.publisher),
    (
      'Released',
      item.releaseDate != null
          ? '${item.releaseDate!.year}-${item.releaseDate!.month.toString().padLeft(2, '0')}-${item.releaseDate!.day.toString().padLeft(2, '0')}'
          : item.releaseYear?.toString()
    ),
    if (video?.runtimeMinutes != null)
      ('Runtime', '${video!.runtimeMinutes} min'),
    if (item.itemNumber != null) (media.numberLabel, item.itemNumber),
    if (item.displayEditionLabel != null)
      (release.variantLabel, item.displayEditionLabel),
    (release.barcodeLabel, item.barcode),
    if (type.capabilities.showsTrackData && music?.trackCount != null)
      ('Tracks', music!.trackCount.toString()),
    if (music?.catalogNumber != null) ('Catalog No.', music!.catalogNumber),
    if (game?.platforms case final platforms? when platforms.isNotEmpty)
      ('Platforms', platforms.join(', ')),
    if (publishing?.pageCount != null)
      ('Pages', publishing!.pageCount.toString()),
    if (item.country != null) ('Country', item.country),
    if (music?.releaseStatus != null) ('Release Status', music!.releaseStatus),
    if (item.language != null) ('Language', item.language),
  ];
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
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(
                color: palette.textMuted,
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

List<(String, String?)> _metadataRowsForFullPreview(
  AdminProviderPreview preview,
  LibraryTypeConfig type,
) {
  final media = type.mediaFields;
  final release = type.releaseFields;
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
    if (series?.seriesTitle != null)
      (previewLabels.series, series!.seriesTitle),
    if (preview.publisher != null) (media.publisherLabel, preview.publisher),
    if (publishing?.imprint != null) ('Imprint', publishing!.imprint),
    if (releaseDateStr != null) ('Released', releaseDateStr),
    if (series?.volumeStartYear != null)
      ('Year', series!.volumeStartYear.toString()),
    if (preview.itemNumber != null) (media.numberLabel, preview.itemNumber),
    if (preview.barcode != null) (release.barcodeLabel, preview.barcode),
    if (preview.isbn != null) ('ISBN', preview.isbn),
    if (preview.country != null) ('Country', preview.country),
    if (preview.language != null) ('Language', preview.language),
    if (preview.physicalFormatLabel != null)
      ('Format', preview.physicalFormatLabel),
    if (preview.variantName != null)
      (release.variantLabel, preview.variantName),
    if (collectarrLibraryTypes
            .capabilitiesForKind(preview.kind)
            .showsTrackData &&
        music?.trackCount != null)
      ('Tracks', music!.trackCount.toString()),
    if (music?.catalogNumber != null) ('Catalog No.', music!.catalogNumber),
    if (game?.platforms case final platforms? when platforms.isNotEmpty)
      ('Platforms', platforms.join(', ')),
    if (video?.runtimeMinutes != null)
      ('Runtime', '${video!.runtimeMinutes} min'),
    if (publishing?.pageCount != null)
      ('Pages', publishing!.pageCount.toString()),
    if (music?.releaseStatus != null) ('Release Status', music!.releaseStatus),
    if (publishing?.seriesGroup != null)
      ('Series Group', publishing!.seriesGroup),
  ];
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
  final characters = item?.characters ??
      preview?.characters ??
      candidate?.characterPreview ??
      const <String>[];
  final storyArcs = item?.storyArcs ??
      preview?.storyArcs ??
      candidate?.storyArcPreview ??
      const <String>[];
  final genres = item?.genres ?? preview?.genres ?? const <String>[];

  return [
    if (creators.isNotEmpty) _PreviewDiscoverySectionData('Creators', creators),
    if (characters.isNotEmpty)
      _PreviewDiscoverySectionData('Characters', characters),
    if (storyArcs.isNotEmpty)
      _PreviewDiscoverySectionData('Story Arcs', storyArcs),
    if (genres.isNotEmpty) _PreviewDiscoverySectionData('Genres', genres),
  ];
}

class _PreviewDiscoverySectionData {
  const _PreviewDiscoverySectionData(this.title, this.values);

  final String title;
  final List<String> values;
}

class LibraryAddPreviewDiscoverySectionData {
  const LibraryAddPreviewDiscoverySectionData({
    required this.title,
    required this.values,
  });

  final String title;
  final List<String> values;
}

List<LibraryAddPreviewDiscoverySectionData> libraryAddPreviewDiscoverySections({
  required LibraryMetadataItem? item,
  required ProviderCandidate? candidate,
  required AdminProviderPreview? preview,
}) {
  return [
    for (final section in _discoverySections(
      item: item,
      candidate: candidate,
      preview: preview,
    ))
      LibraryAddPreviewDiscoverySectionData(
        title: section.title,
        values: section.values,
      ),
  ];
}

class LibraryAddPreviewDiscoverySection extends StatelessWidget {
  const LibraryAddPreviewDiscoverySection({
    super.key,
    required this.title,
    required this.values,
    required this.accent,
  });

  final String title;
  final List<String> values;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _LibraryAddPreviewDiscoverySection(
      title: title,
      values: values,
      accent: accent,
    );
  }
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
    final palette = appPalette(context);
    final chipBackground = Color.alphaBlend(
      accent.withValues(alpha: palette.isDark ? 0.22 : 0.1),
      palette.surface,
    );
    final chipBorder = accent.withValues(alpha: palette.isDark ? 0.58 : 0.42);
    final chipTextColor =
        ThemeData.estimateBrightnessForColor(chipBackground) == Brightness.dark
            ? Colors.white
            : palette.textPrimary;
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
                    color: chipBackground,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: chipBorder),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: chipTextColor,
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
  static const double _durationColumnWidth = 52;

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
            SizedBox(
              width: _durationColumnWidth,
              child: Text(
                durationStr,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: appPalette(context).textMuted,
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

class _PreviewSeasonsSection extends ConsumerWidget {
  const _PreviewSeasonsSection({
    required this.provider,
    required this.providerItemId,
    required this.accent,
  });

  final String provider;
  final String providerItemId;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final seasonsAsync = ref.watch(
      seasonsProvider((provider: provider, providerItemId: providerItemId)),
    );

    return seasonsAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.only(top: 22),
        child: Row(
          children: [
            const SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading seasons...',
              style: TextStyle(color: palette.textMuted),
            ),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (seasons) {
        if (seasons.isEmpty) return const SizedBox.shrink();
        final totalEpisodes = seasons.fold<int>(
          0,
          (sum, s) => sum + (s.episodeCount ?? s.episodes.length),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),
            Text(
              'Seasons (${seasons.length}) · $totalEpisodes episodes',
              style: TextStyle(color: accent),
            ),
            const SizedBox(height: 8),
            for (final season in seasons)
              _PreviewSeasonNode(season: season, accent: accent),
          ],
        );
      },
    );
  }
}

class _PreviewSeasonNode extends StatefulWidget {
  const _PreviewSeasonNode({required this.season, required this.accent});

  final Season season;
  final Color accent;

  @override
  State<_PreviewSeasonNode> createState() => _PreviewSeasonNodeState();
}

class _PreviewSeasonNodeState extends State<_PreviewSeasonNode> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final season = widget.season;
    final episodeCount = season.episodeCount ?? season.episodes.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: season.episodes.isNotEmpty
              ? () => setState(() => _expanded = !_expanded)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                if (season.posterUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Image.network(
                      season.posterUrl!,
                      width: 28,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        season.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        [
                          '$episodeCount episodes',
                          if (season.airDate != null) season.airDate!,
                        ].join(' · '),
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (season.episodes.isNotEmpty)
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: palette.textMuted,
                  ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(left: 36, bottom: 4),
            child: Column(
              children: [
                for (final ep in season.episodes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 26,
                          child: Text(
                            '${ep.episodeNumber}',
                            style: TextStyle(
                              color: widget.accent.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ep.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (ep.runtimeMinutes != null)
                          Text(
                            '${ep.runtimeMinutes} min',
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _EditionGrid extends StatelessWidget {
  const _EditionGrid({
    super.key,
    required this.editions,
    required this.selectedEditionId,
    required this.accent,
    required this.onEditionSelected,
  });

  final List<CatalogEdition> editions;
  final String? selectedEditionId;
  final Color accent;
  final ValueChanged<String> onEditionSelected;

  @override
  Widget build(BuildContext context) {
    if (editions.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final edition in editions)
          _EditionCard(
            key: ValueKey('library-add-edition-card-${edition.id}'),
            edition: edition,
            selected: edition.id == selectedEditionId,
            accent: accent,
            onTap: () => onEditionSelected(edition.id),
          ),
      ],
    );
  }
}

class _EditionCard extends StatelessWidget {
  const _EditionCard({
    super.key,
    required this.edition,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final CatalogEdition edition;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final coverUrl = edition.variants.isNotEmpty
        ? edition.variants.first.coverImageUrl
        : null;
    final barcode = edition.isbn ??
        edition.upc ??
        (edition.variants.isNotEmpty ? edition.variants.first.barcode : null);
    final formatId = edition.physicalFormat;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 100,
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.12)
              : const Color(0x08000000),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? accent.withValues(alpha: 0.8) : kAppBorderSubtle,
            width: selected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: coverUrl != null
                  ? Image.network(
                      coverUrl,
                      width: 88,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _EditionPlaceholder(
                        label: edition.title,
                      ),
                    )
                  : _EditionPlaceholder(label: edition.title),
            ),
            const SizedBox(height: 4),
            // Format badge
            if (formatId != null)
              FormatBadge.fromFormat(
                id: formatId,
                label: edition.physicalFormatLabel ?? formatId,
                compact: true,
              ),
            const SizedBox(height: 2),
            // Title
            Text(
              edition.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? accent : kAppTextSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            // Barcode
            if (barcode != null)
              Text(
                barcode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kAppTextHint,
                  fontSize: 8,
                  fontFamily: kClzMonospaceFontFamily,
                  fontFamilyFallback: kClzMonospaceFontFallback,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EditionPlaceholder extends StatelessWidget {
  const _EditionPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      width: 88,
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.field,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: palette.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _VariantGrid extends StatelessWidget {
  const _VariantGrid({
    super.key,
    required this.variants,
    required this.selectedVariantId,
    required this.accent,
    required this.onVariantSelected,
  });

  final List<CatalogVariant> variants;
  final String? selectedVariantId;
  final Color accent;
  final ValueChanged<String> onVariantSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variant',
          style: TextStyle(
            color: palette.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _VariantChip(
              key: const ValueKey('library-add-variant-card-any'),
              label: 'Any',
              selected: selectedVariantId == null || selectedVariantId!.isEmpty,
              accent: accent,
              onTap: () => onVariantSelected(''),
            ),
            for (final variant in variants)
              _VariantChip(
                key: ValueKey('library-add-variant-card-${variant.id}'),
                label: variant.name,
                coverUrl: variant.coverImageUrl,
                barcode: variant.barcode,
                formatId: variant.physicalFormat,
                selected: variant.id == selectedVariantId,
                accent: accent,
                onTap: () => onVariantSelected(variant.id),
              ),
          ],
        ),
      ],
    );
  }
}

class _VariantChip extends StatelessWidget {
  const _VariantChip({
    super.key,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
    this.coverUrl,
    this.barcode,
    this.formatId,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  final String? coverUrl;
  final String? barcode;
  final String? formatId;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(maxWidth: 120),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.12)
              : palette.surfaceSubtle.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? accent.withValues(alpha: 0.8) : palette.divider,
            width: selected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (coverUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image.network(
                  coverUrl!,
                  width: 24,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox(width: 24, height: 32),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? accent : palette.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (formatId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: FormatBadge.fromId(formatId!, compact: true),
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
