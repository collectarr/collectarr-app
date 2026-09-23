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
    required this.isWideLayout,
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

  final LibraryKindRegistration type;
  final Color accent;
  final bool isWideLayout;
  final LibraryAddPreviewPaneBuilder? previewPaneBuilder;
  final CatalogSearchCandidate? item;
  final ProviderSearchCandidate? candidate;
  final AdminProviderPreview? candidatePreview;
  final bool isFetchingPreview;
  final String providerLabel;
  final bool searched;
  final LibraryAddTarget addTarget;
  final LibraryAddReferenceType referenceType;
  final List<LibraryBundleSummary> availableBundleReleases;
  final String? selectedBundleReleaseId;
  final LibraryBundleDetail? selectedBundleReleaseDetail;
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
        (selectedItem == null
            ? selectedCandidate!.title
            : libraryPresentationForKind(type.kind)
                .builder
                .buildAddPreviewTitle(item: selectedItem));
    final itemNumber = selectedBundle == null && selectedItem != null
        ? libraryPresentationForKind(type.kind)
            .builder
            .buildAddPreviewItemNumber(
              item: selectedItem,
            )
        : null;
    final preview = candidatePreview;
    final selectedSynopsis = selectedItem == null
        ? null
        : libraryPresentationForKind(type.kind)
            .builder
            .buildAddPreviewSynopsis(item: selectedItem);
    final synopsis =
        selectedSynopsis ?? preview?.synopsis ?? selectedCandidate?.summary;
    final coverUrl = selectedBundle?.coverImageUrl ??
        selectedItem?.imageUrl ??
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
    final kindPreviewSections = selectedCandidate == null
        ? const <Widget>[]
        : libraryPresentationForKind(type.kind).builder.buildAddPreviewSections(
              accent: accent,
              kind: type.kind,
              provider: selectedCandidate.provider,
              providerItemId: selectedCandidate.providerItemId,
            );
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
    final customPreview = libraryPresentationForKind(type.kind)
        .builder
        .buildAddPreviewPaneForSearchCandidate(
          context: context,
          accent: accent,
          singularLabel: type.identity.singularLabel,
          previewLabels: libraryPresentationForKind(type.kind).previewLabels,
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
                          color: libraryAccentTextColor(accent, palette.panel),
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
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
                      _buildPreviewFormatBadges(
                        selectedItem == null
                            ? const []
                            : libraryPresentationForKind(type.kind)
                                .builder
                                .buildAddPreviewFormatBadges(
                                  item: selectedItem,
                                ),
                      ),
                    ],
                  ),
                ),
                LibraryAddResultBadge(
                  selectedItem == null
                      ? providerLabel
                      : type.identity.singularLabel,
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
                        if (synopsis != null && synopsis.trim().isNotEmpty) ...[
                          Text(
                            'Plot',
                            style: TextStyle(
                              color:
                                  libraryAccentTextColor(accent, palette.panel),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(synopsis),
                          const SizedBox(height: 22),
                        ],
                        if (discoverySections.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          Text(
                            'Discovery',
                            style: TextStyle(
                              color:
                                  libraryAccentTextColor(accent, palette.panel),
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final section in discoverySections)
                            _LibraryAddPreviewDiscoverySection(
                              title: section.title,
                              values: section.values,
                              accent: accent,
                            ),
                        ],
                        for (final section in kindPreviewSections) ...[
                          const SizedBox(height: 22),
                          section,
                        ],
                        if (selectedItem != null &&
                            referenceType ==
                                LibraryAddReferenceType.bundleRelease) ...[
                          const SizedBox(height: 22),
                          Text(
                            'Bundle',
                            style: TextStyle(
                              color:
                                  libraryAccentTextColor(accent, palette.panel),
                            ),
                          ),
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
                            BundleReleaseContentsCard(
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
                        Text(
                          'Details',
                          style: TextStyle(
                            color:
                                libraryAccentTextColor(accent, palette.panel),
                          ),
                        ),
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

class LibraryBundleDetailCard extends StatelessWidget {
  const LibraryBundleDetailCard({
    super.key,
    required this.detail,
    required this.accent,
  });

  final LibraryBundleDetail detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _LibraryBundleDetailCard(
      detail: detail,
      accent: accent,
    );
  }
}

class _LibraryBundleDetailCard extends StatelessWidget {
  const _LibraryBundleDetailCard({
    required this.detail,
    required this.accent,
  });

  final LibraryBundleDetail detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final groupedMembers = _groupBundleMembers(detail.members);
    final summaryParts = <String>[
      '${detail.memberCount} items',
      if (detail.primaryMemberCount > 0) '${detail.primaryMemberCount} primary',
      if (detail.bonusMemberCount > 0) '${detail.bonusMemberCount} bonus',
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
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (summaryParts.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                summaryParts.join(' / '),
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

  final LibraryKindRegistration type;
  final Color accent;
  final LibraryAddTarget addTarget;
  final LibraryAddReferenceType referenceType;
  final CatalogSearchCandidate item;
  final List<LibraryBundleSummary> bundleReleases;
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
  CatalogSearchCandidate item,
  LibraryKindRegistration type,
) =>
    _metadataRowsForItem(item, type);

List<(String, String?)> libraryAddMetadataRowsForCandidate(
  ProviderSearchCandidate candidate,
  LibraryKindRegistration type,
) =>
    _metadataRowsForCandidate(candidate, type);

List<(String, String?)> libraryAddMetadataRowsForFullPreview(
  AdminProviderPreview preview,
  LibraryKindRegistration type,
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

String _bundleMemberTitle(LibraryBundleMemberSummary member) {
  return member.title;
}

String _bundleMemberSubtitle(LibraryBundleMemberSummary member) {
  final parts = <String>[
    if (member.role.trim().isNotEmpty) member.role,
    if (member.quantity > 1) 'x${member.quantity}',
  ];
  return parts.join(' / ');
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
                color: libraryAccentTextColor(accent, palette.surfaceSubtle),
                fontWeight: FontWeight.w700,
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
                        member.sequenceNumber?.toString() ?? '-',
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
  final List<LibraryBundleMemberSummary> members;
}

List<_BundleReleaseDiscGroup> _groupBundleMembers(
  List<LibraryBundleMemberSummary> members,
) {
  if (members.isEmpty) {
    return const <_BundleReleaseDiscGroup>[];
  }
  return [
    _BundleReleaseDiscGroup(
      label: 'Members',
      members: [...members]..sort((left, right) {
          final leftSequence = left.sequenceNumber ?? 999999;
          final rightSequence = right.sequenceNumber ?? 999999;
          return leftSequence.compareTo(rightSequence);
        }),
    ),
  ];
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

  final LibraryKindRegistration type;
  final Color accent;
  final LibraryAddTarget addTarget;
  final LibraryAddReferenceType referenceType;
  final CatalogSearchCandidate item;
  final List<LibraryBundleSummary> bundleReleases;
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
    final releases = libraryPresentationForKind(type.kind)
        .builder
        .buildReleaseOptions(item: item);
    final releaseAvailable = releases.isNotEmpty;
    final bundleAvailable = bundleReleases.isNotEmpty;
    final selectionLocked = addTarget == LibraryAddTarget.track;
    final selectedRelease = previewReleaseForItem(releases, selectedEditionId);
    final selectedVariant = selectedVariantForRelease(
      selectedRelease,
      selectedVariantId,
    );
    final selectionSummary = switch (addTarget) {
      LibraryAddTarget.track =>
        libraryAddChromeForKind(type.kind).trackScopeSummary,
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
                    color:
                        libraryAccentTextColor(accent, palette.surfaceSubtle),
                    fontWeight: FontWeight.w700,
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
                    enabled: releaseAvailable,
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
                _releaseSummaryForSelection(
                  selectedRelease,
                  selectedVariant,
                ),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _EditionGrid(
                key: const ValueKey('library-add-edition-field'),
                releases: releases,
                selectedEditionId: selectedEditionId,
                accent: accent,
                onEditionSelected: onEditionSelected,
              ),
              const SizedBox(height: 8),
              if (selectedRelease == null)
                Text(
                  'No canonical edition is attached to this item yet.',
                  style: TextStyle(color: palette.textMuted),
                )
              else if (selectedRelease.variants.isEmpty)
                Text(
                  'This edition has no canonical variants yet, so the edition itself will be used.',
                  style: TextStyle(color: palette.textMuted),
                )
              else
                _VariantGrid(
                  key: const ValueKey('library-add-variant-field'),
                  variants: selectedRelease.variants,
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

  final LibraryBundleSummary bundle;
  final Color accent;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final subtitleParts = <String>[
      if (bundle.memberCount > 0) '${bundle.memberCount} items',
      if (bundle.primaryMemberCount > 0) '${bundle.primaryMemberCount} primary',
      if (bundle.bonusMemberCount > 0) '${bundle.bonusMemberCount} bonus',
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
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (subtitleParts.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitleParts.join(' / '),
                          style: TextStyle(
                            color: palette.textMuted,
                            fontSize: 12,
                          ),
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

String _releaseSummaryForSelection(
  LibraryAddReleaseOption? release,
  LibraryAddVariantOption? variant,
) {
  if (release == null) {
    return 'No canonical edition is attached to this item yet.';
  }
  final parts = <String>[
    release.title,
    if (variant?.name case final variantName?
        when variantName.trim().isNotEmpty)
      'Physical: $variantName',
    if (release.formatLabel != null && release.formatLabel!.trim().isNotEmpty)
      release.formatLabel!,
    if (release.releaseDate != null)
      '${release.releaseDate!.year}-${release.releaseDate!.month.toString().padLeft(2, '0')}-${release.releaseDate!.day.toString().padLeft(2, '0')}',
  ];
  return parts.join(' / ');
}

LibraryAddReleaseOption? previewReleaseForItem(
  List<LibraryAddReleaseOption> releases,
  String? editionId,
) {
  final normalizedEditionId = editionId?.trim();
  if (normalizedEditionId != null && normalizedEditionId.isNotEmpty) {
    for (final release in releases) {
      if (release.id == normalizedEditionId) {
        return release;
      }
    }
  }
  return _previewPrimaryRelease(releases);
}

LibraryAddVariantOption? selectedVariantForRelease(
  LibraryAddReleaseOption? release,
  String? variantId,
) {
  final normalizedVariantId = variantId?.trim();
  if (release != null &&
      normalizedVariantId != null &&
      normalizedVariantId.isNotEmpty) {
    for (final variant in release.variants) {
      if (variant.id == normalizedVariantId) {
        return variant;
      }
    }
  }
  return null;
}

LibraryAddReleaseOption? _previewPrimaryRelease(
  List<LibraryAddReleaseOption> releases,
) {
  if (releases.isEmpty) {
    return null;
  }
  for (final release in releases) {
    if (_previewPrimaryVariantForRelease(release) != null) {
      return release;
    }
  }
  return releases.first;
}

LibraryAddVariantOption? _previewPrimaryVariantForRelease(
    LibraryAddReleaseOption? release) {
  if (release == null || release.variants.isEmpty) {
    return null;
  }
  for (final variant in release.variants) {
    if (variant.isPrimary) {
      return variant;
    }
  }
  return release.variants.first;
}

Widget _buildPreviewFormatBadges(
  List<LibraryFormatBadgeDescriptor> formatValues,
) {
  if (formatValues.isEmpty) return const SizedBox.shrink();
  final seen = <String>{};
  final badges = <Widget>[];
  for (final format in formatValues) {
    if (!seen.add(format.key)) continue;
    badges.add(FormatBadge.fromDescriptor(descriptor: format));
  }
  if (badges.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Wrap(spacing: 4, runSpacing: 4, children: badges),
  );
}

List<(String, String?)> _metadataRowsForCandidate(
  ProviderSearchCandidate candidate,
  LibraryKindRegistration type,
) =>
    libraryPresentationForKind(type.kind)
        .builder
        .buildAddPreviewMetadataRowsForSearchCandidate(
          candidate: candidate,
          previewLabels: libraryPresentationForKind(type.kind).previewLabels,
        );

List<(String, String?)> _metadataRowsForItem(
  CatalogSearchCandidate item,
  LibraryKindRegistration type,
) =>
    libraryPresentationForKind(type.kind).builder.buildAddPreviewMetadataRows(
          item: item,
          previewLabels: libraryPresentationForKind(type.kind).previewLabels,
        );

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
                fontWeight: FontWeight.w700,
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
  LibraryKindRegistration type,
) =>
    libraryPresentationForKind(type.kind)
        .builder
        .buildAddPreviewMetadataRowsForFullPreview(
          preview: preview,
          previewLabels: libraryPresentationForKind(type.kind).previewLabels,
        );

List<_PreviewDiscoverySectionData> _discoverySections({
  required CatalogSearchCandidate? item,
  required ProviderSearchCandidate? candidate,
  required AdminProviderPreview? preview,
}) {
  final creators = preview?.creators
          .map((credit) => credit.role == null
              ? credit.name
              : '${credit.name} (${credit.role})')
          .toList(growable: false) ??
      const <String>[];
  final characters = preview?.characters ?? const <String>[];
  final genres = preview?.genres ?? const <String>[];

  return [
    if (creators.isNotEmpty) _PreviewDiscoverySectionData('Creators', creators),
    if (characters.isNotEmpty)
      _PreviewDiscoverySectionData('Characters', characters),
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
  required CatalogSearchCandidate? item,
  required ProviderSearchCandidate? candidate,
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
              color: libraryAccentTextColor(accent, palette.surfaceSubtle),
              fontWeight: FontWeight.w700,
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

class _EditionGrid extends StatelessWidget {
  const _EditionGrid({
    super.key,
    required this.releases,
    required this.selectedEditionId,
    required this.accent,
    required this.onEditionSelected,
  });

  final List<LibraryAddReleaseOption> releases;
  final String? selectedEditionId;
  final Color accent;
  final ValueChanged<String> onEditionSelected;

  @override
  Widget build(BuildContext context) {
    if (releases.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final release in releases)
          _EditionCard(
            key: ValueKey('library-add-edition-card-${release.id}'),
            release: release,
            selected: release.id == selectedEditionId,
            accent: accent,
            onTap: () => onEditionSelected(release.id),
          ),
      ],
    );
  }
}

class _EditionCard extends StatelessWidget {
  const _EditionCard({
    super.key,
    required this.release,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final LibraryAddReleaseOption release;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final selectedFill = Color.alphaBlend(
      accent.withValues(alpha: 0.12),
      palette.surfaceSubtle,
    );
    final coverUrl = release.coverImageUrl;
    final identifierCode = release.identifierCode;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 100,
        decoration: BoxDecoration(
          color: selected ? selectedFill : const Color(0x08000000),
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
                        label: release.title,
                      ),
                    )
                  : _EditionPlaceholder(label: release.title),
            ),
            const SizedBox(height: 4),
            // Format badge
            if (release.formatBadge != null)
              FormatBadge.fromDescriptor(
                descriptor: release.formatBadge!,
                compact: true,
              ),
            const SizedBox(height: 2),
            // Title
            Text(
              release.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected
                    ? libraryAccentTextColor(accent, selectedFill)
                    : palette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            // Barcode
            if (identifierCode != null)
              Text(
                identifierCode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 12,
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
          fontSize: 12,
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

  final List<LibraryAddVariantOption> variants;
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
            fontSize: 12,
            fontWeight: FontWeight.w700,
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
                identifierCode: variant.identifierCode,
                formatId: variant.formatId,
                formatBadge: variant.formatBadge,
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
    this.identifierCode,
    this.formatId,
    this.formatBadge,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  final String? coverUrl;
  final String? identifierCode;
  final String? formatId;
  final LibraryFormatBadgeDescriptor? formatBadge;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final selectedFill = Color.alphaBlend(
      accent.withValues(alpha: 0.12),
      palette.surfaceSubtle,
    );
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(maxWidth: 120),
        decoration: BoxDecoration(
          color: selected
              ? selectedFill
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
                      color: selected
                          ? libraryAccentTextColor(accent, selectedFill)
                          : palette.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (formatBadge != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: FormatBadge.fromDescriptor(
                        descriptor: formatBadge!,
                        compact: true,
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
