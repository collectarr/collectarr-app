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
    final groupedMembers = _groupBundleMembers(detail.members);
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x10000000),
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
                        style: const TextStyle(
                          color: kAppTextMuted,
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
    final editionAvailable = item.editions.isNotEmpty;
    final bundleAvailable = bundleReleases.isNotEmpty;
    final selectionLocked = addTarget == LibraryAddTarget.track;
    final selectedEdition = _previewEditionForItem(item, selectedEditionId);
    final selectedVariant = _selectedVariantForEdition(
      selectedEdition,
      selectedVariantId,
    );
    final selectionSummary = switch (addTarget) {
      LibraryAddTarget.track => item.mediaKind == CatalogMediaKind.music
          ? 'Tracking stays album-level here. Edition and variant scope are only available for owned or wishlist entries.'
          : 'Tracking stays item-centric here. Edition and bundle scope are only available for owned or wishlist entries.',
      LibraryAddTarget.owned => referenceType.helperLabelForMediaKind(item.mediaKind),
      LibraryAddTarget.wishlist => referenceType.helperLabelForMediaKind(item.mediaKind),
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
                  accent: accent,
                  selected: true,
                  enabled: !selectionLocked,
                  label: LibraryAddReferenceType.media.labelForMediaKind(item.mediaKind),
                  onPressed: () =>
                      onReferenceTypeChanged(LibraryAddReferenceType.media),
                ),
                if (!selectionLocked) ...[
                  _ReferenceChip(
                    accent: accent,
                    selected: referenceType == LibraryAddReferenceType.edition,
                    enabled: editionAvailable,
                    label: LibraryAddReferenceType.edition.labelForMediaKind(item.mediaKind),
                    onPressed: () => onReferenceTypeChanged(
                      LibraryAddReferenceType.edition,
                    ),
                  ),
                  _ReferenceChip(
                    accent: accent,
                    selected:
                        referenceType == LibraryAddReferenceType.bundleRelease,
                    enabled: bundleAvailable || isLoadingBundleReleases,
                    label: LibraryAddReferenceType.bundleRelease.labelForMediaKind(item.mediaKind),
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
              style: const TextStyle(
                color: kAppTextMuted,
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
              DropdownButtonFormField<String>(
                key: const ValueKey('library-add-edition-field'),
                isExpanded: true,
                initialValue: selectedEdition?.id,
                decoration: const InputDecoration(
                  labelText: 'Edition',
                  isDense: true,
                ),
                items: [
                  for (final edition in item.editions)
                    DropdownMenuItem<String>(
                      value: edition.id,
                      child: Text(
                        _editionOptionLabel(edition),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: !editionAvailable
                    ? null
                    : (value) {
                        if (value != null) {
                          onEditionSelected(value);
                        }
                      },
              ),
              const SizedBox(height: 8),
              if (selectedEdition == null)
                const Text(
                  'No canonical edition is attached to this item yet.',
                  style: TextStyle(color: kAppTextMuted),
                )
              else if (selectedEdition.variants.isEmpty)
                const Text(
                  'This edition has no canonical variants yet, so the edition itself will be used.',
                  style: TextStyle(color: kAppTextMuted),
                )
              else
                DropdownButtonFormField<String>(
                  key: const ValueKey('library-add-variant-field'),
                  isExpanded: true,
                  initialValue: selectedVariant?.id ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Variant',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Any / unspecified variant'),
                    ),
                    for (final variant in selectedEdition.variants)
                      DropdownMenuItem<String>(
                        value: variant.id,
                        child: Text(
                          _variantOptionLabel(variant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    onVariantSelected(value ?? '');
                  },
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

String _editionSummaryForSelection(
  CatalogEdition? edition,
  CatalogVariant? variant,
) {
  if (edition == null) {
    return 'No canonical edition is attached to this item yet.';
  }
  final parts = <String>[
    edition.title,
    if (variant?.name case final variantName? when variantName.trim().isNotEmpty)
      'Physical: $variantName',
    if (edition.physicalFormatLabel != null &&
        edition.physicalFormatLabel!.trim().isNotEmpty)
      edition.physicalFormatLabel!,
    if (edition.region != null && edition.region!.trim().isNotEmpty) edition.region!,
    if (edition.releaseDate != null)
      '${edition.releaseDate!.year}-${edition.releaseDate!.month.toString().padLeft(2, '0')}-${edition.releaseDate!.day.toString().padLeft(2, '0')}',
  ];
  return parts.join(' • ');
}

CatalogEdition? _previewEditionForItem(
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

CatalogVariant? _selectedVariantForEdition(
  CatalogEdition? edition,
  String? variantId,
) {
  final normalizedVariantId = variantId?.trim();
  if (edition != null && normalizedVariantId != null && normalizedVariantId.isNotEmpty) {
    for (final variant in edition.variants) {
      if (variant.id == normalizedVariantId) {
        return variant;
      }
    }
  }
  return null;
}

String _editionOptionLabel(CatalogEdition edition) {
  final parts = <String>[
    edition.title,
    if (edition.physicalFormatLabel != null &&
        edition.physicalFormatLabel!.trim().isNotEmpty)
      edition.physicalFormatLabel!,
    if (edition.releaseDate != null)
      '${edition.releaseDate!.year}-${edition.releaseDate!.month.toString().padLeft(2, '0')}-${edition.releaseDate!.day.toString().padLeft(2, '0')}',
  ];
  return parts.join(' • ');
}

String _variantOptionLabel(CatalogVariant variant) {
  final parts = <String>[
    variant.name,
    if (variant.variantType != null && variant.variantType!.trim().isNotEmpty)
      variant.variantType!,
    if (variant.physicalFormatLabel != null &&
        variant.physicalFormatLabel!.trim().isNotEmpty)
      variant.physicalFormatLabel!,
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
    final seasonsAsync = ref.watch(
      seasonsProvider((provider: provider, providerItemId: providerItemId)),
    );

    return seasonsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 22),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text(
              'Loading seasons...',
              style: TextStyle(color: kAppTextMuted),
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
                        style: const TextStyle(
                          color: kAppTextMuted,
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
                    color: kAppTextMuted,
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
                            style: const TextStyle(
                              color: kAppTextMuted,
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
