import 'library_add_pane_dependencies.dart';

class LibraryAddBottomBar extends StatelessWidget {
  const LibraryAddBottomBar({
    super.key,
    required this.type,
    required this.isMovieDesktopChrome,
    required this.conditions,
    required this.grades,
    required this.defaultTags,
    required this.accent,
    required this.selectedItem,
    required this.selectedCandidate,
    required this.selectedQueuedIngest,
    required this.providerLabel,
    required this.addTarget,
    required this.addCount,
    required this.isAdding,
    required this.isQueueingIngest,
    required this.isAdmin,
    required this.defaultCondition,
    required this.defaultGrade,
    required this.defaultLocationLabel,
    required this.defaultPurchaseDate,
    required this.onAddTargetChanged,
    required this.onDefaultConditionChanged,
    required this.onDefaultGradeChanged,
    required this.onEditDefaultTagsPressed,
    required this.onDefaultLocationPressed,
    required this.onDefaultPurchaseDateChanged,
    required this.onAdd,
    required this.onQueueIngest,
    required this.onPropose,
  });

  final LibraryTypeConfig type;
  final bool isMovieDesktopChrome;
  final List<String> conditions;
  final List<String> grades;
  final String? defaultTags;
  final Color accent;
  final LibraryMetadataItem? selectedItem;
  final ProviderCandidate? selectedCandidate;
  final LibraryQueuedProviderIngest? selectedQueuedIngest;
  final String providerLabel;
  final LibraryAddTarget addTarget;
  final int addCount;
  final bool isAdding;
  final bool isQueueingIngest;
  final bool isAdmin;
  final String defaultCondition;
  final String defaultGrade;
  final String? defaultLocationLabel;
  final DateTime? defaultPurchaseDate;
  final ValueChanged<LibraryAddTarget> onAddTargetChanged;
  final ValueChanged<String> onDefaultConditionChanged;
  final ValueChanged<String> onDefaultGradeChanged;
  final VoidCallback onEditDefaultTagsPressed;
  final VoidCallback onDefaultLocationPressed;
  final ValueChanged<DateTime?> onDefaultPurchaseDateChanged;
  final VoidCallback? onAdd;
  final VoidCallback? onQueueIngest;
  final VoidCallback? onPropose;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final hasSelection = selectedItem != null || selectedCandidate != null;
    final effectiveCount = addCount > 0 ? addCount : (hasSelection ? 1 : 0);
    final addLabel =
        selectedCandidate != null && (!isAdmin || selectedCandidate!.isStub)
            ? _localCandidateAddLabel()
            : effectiveCount > 0
                ? LibraryAddCopy.addToTargetLabel(
                    count: effectiveCount,
                    type: type,
                    target: addTarget,
                  )
                : 'Select a ${type.singularLabel.toLowerCase()} to add';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          kLibraryDialogFooterHorizontalPadding,
          isMovieDesktopChrome
              ? kLibraryDialogFooterVerticalPadding
              : kLibraryDialogFooterVerticalPadding,
          kLibraryDialogFooterHorizontalPadding,
          isMovieDesktopChrome
              ? kLibraryDialogFooterVerticalPadding
              : kLibraryDialogFooterVerticalPadding + 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                LibraryAddResultBadge(effectiveCount > 0
                    ? '$effectiveCount selected'
                    : '0 selected'),
                _LibraryAddTargetMenu(
                  value: addTarget,
                  enabled: !isAdding,
                  accent: accent,
                  onChanged: onAddTargetChanged,
                ),
                if (selectedCandidate != null && !isMovieDesktopChrome) ...[
                  LibraryAddResultBadge(providerLabel),
                  if (isAdmin)
                    _LibraryAddBottomActionButton(
                      tooltip: selectedQueuedIngest == null
                          ? 'Queue Core ingest'
                          : 'Core ingest queued',
                      icon: Icons.playlist_add_check,
                      label: selectedQueuedIngest == null
                          ? 'Queue ingest'
                          : 'Queued ${selectedQueuedIngest!.shortId}',
                      accent: accent,
                      onPressed: selectedQueuedIngest != null ||
                              isQueueingIngest ||
                              isAdding
                          ? null
                          : onQueueIngest,
                    ),
                  _LibraryAddBottomActionButton(
                    icon: Icons.outbox_outlined,
                    tooltip: 'Propose metadata to Core',
                    label: 'Propose',
                    accent: accent,
                    onPressed: isAdding || isQueueingIngest ? null : onPropose,
                  ),
                ],
              ],
            ),
            if (addTarget == LibraryAddTarget.owned &&
                !isMovieDesktopChrome) ...[
              const SizedBox(height: 8),
              _AddTargetDefaultsBar(
                accent: accent,
                conditions: conditions,
                grades: grades,
                condition: defaultCondition,
                grade: defaultGrade,
                tags: defaultTags,
                locationLabel: defaultLocationLabel,
                purchaseDate: defaultPurchaseDate,
                onConditionChanged: onDefaultConditionChanged,
                onGradeChanged: onDefaultGradeChanged,
                onEditTagsPressed: onEditDefaultTagsPressed,
                onLocationPressed: onDefaultLocationPressed,
                onPurchaseDateChanged: onDefaultPurchaseDateChanged,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (isMovieDesktopChrome && selectedCandidate != null) ...[
                  if (isAdmin)
                    _LibraryAddBottomActionButton(
                      tooltip: selectedQueuedIngest == null
                          ? 'Queue Core ingest'
                          : 'Core ingest queued',
                      icon: Icons.playlist_add_check,
                      label: selectedQueuedIngest == null
                          ? 'Queue ingest'
                          : 'Queued ${selectedQueuedIngest!.shortId}',
                      accent: accent,
                      onPressed:
                          selectedQueuedIngest != null || isQueueingIngest
                              ? null
                              : onQueueIngest,
                    ),
                  const SizedBox(width: 8),
                  _LibraryAddBottomActionButton(
                    icon: Icons.outbox_outlined,
                    tooltip: 'Propose metadata to Core',
                    label: 'Propose',
                    accent: accent,
                    onPressed: isAdding || isQueueingIngest ? null : onPropose,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: isAdding ? null : onAdd,
                    style: libraryAddFilledButtonStyle(accent),
                    child: isAdding
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            isMovieDesktopChrome ? _movieAddLabel() : addLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _localCandidateAddLabel() {
    final noun = type.singularLabel.toLowerCase();
    return switch (addTarget) {
      LibraryAddTarget.owned => 'Add local $noun to Collection',
      LibraryAddTarget.wishlist => 'Add local $noun to Wishlist',
      LibraryAddTarget.track => 'Track local $noun',
    };
  }

  String _movieAddLabel() {
    return switch (addTarget) {
      LibraryAddTarget.owned => 'Add to Collection',
      LibraryAddTarget.wishlist => 'Add to Wishlist',
      LibraryAddTarget.track => 'Track in Library',
    };
  }
}

class _LibraryAddBottomActionButton extends StatelessWidget {
  const _LibraryAddBottomActionButton({
    required this.tooltip,
    required this.icon,
    required this.label,
    required this.accent,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: libraryAddOutlinedButtonStyle(accent),
        icon: Icon(icon, size: 17),
        label: Text(label),
      ),
    );
  }
}

class _AddTargetDefaultsBar extends StatelessWidget {
  const _AddTargetDefaultsBar({
    required this.accent,
    required this.conditions,
    required this.grades,
    required this.condition,
    required this.grade,
    required this.tags,
    required this.locationLabel,
    required this.purchaseDate,
    required this.onConditionChanged,
    required this.onGradeChanged,
    required this.onEditTagsPressed,
    required this.onLocationPressed,
    required this.onPurchaseDateChanged,
  });

  final Color accent;
  final List<String> conditions;
  final List<String> grades;
  final String condition;
  final String grade;
  final String? tags;
  final String? locationLabel;
  final DateTime? purchaseDate;
  final ValueChanged<String> onConditionChanged;
  final ValueChanged<String> onGradeChanged;
  final VoidCallback onEditTagsPressed;
  final VoidCallback onLocationPressed;
  final ValueChanged<DateTime?> onPurchaseDateChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Owned defaults',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        CompactDropdown(
          width: 118,
          value: condition,
          items: conditions,
          label: 'Condition',
          accent: accent,
          onChanged: (v) {
            if (v != null) onConditionChanged(v);
          },
        ),
        if (grades.isNotEmpty)
          CompactDropdown(
            width: 104,
            value: grade,
            items: grades,
            label: 'Grade',
            accent: accent,
            onChanged: (v) {
              if (v != null) onGradeChanged(v);
            },
          ),
        InkWell(
          onTap: onEditTagsPressed,
          borderRadius: BorderRadius.circular(3),
          child: CompactMenuFrame(
            width: 210,
            label: _tagSummary(tags),
            accent: accent,
            leading: Icons.sell_outlined,
            trailing: Icons.edit_outlined,
          ),
        ),
        InkWell(
          onTap: onLocationPressed,
          borderRadius: BorderRadius.circular(3),
          child: CompactMenuFrame(
            width: 184,
            label: locationLabel ?? 'Location',
            accent: accent,
            leading: Icons.place,
            trailing: Icons.arrow_drop_down,
          ),
        ),
        CompactDateButton(
          label: 'Purchase date',
          accent: accent,
          value: purchaseDate,
          onChanged: onPurchaseDateChanged,
        ),
        if (purchaseDate != null)
          IconButton(
            tooltip: 'Clear purchase date',
            onPressed: () => onPurchaseDateChanged(null),
            icon: const Icon(Icons.clear, size: 18),
          ),
      ],
    );
  }

  String _tagSummary(String? value) {
    final tags = splitPickListValues(value);
    if (tags.isEmpty) {
      return 'Tags';
    }
    if (tags.length == 1) {
      return tags.first;
    }
    return '${tags.first} +${tags.length - 1}';
  }
}

class _LibraryAddTargetMenu extends StatelessWidget {
  const _LibraryAddTargetMenu({
    required this.value,
    required this.enabled,
    required this.accent,
    required this.onChanged,
  });

  final LibraryAddTarget value;
  final bool enabled;
  final Color accent;
  final ValueChanged<LibraryAddTarget> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return PopupMenuButton<LibraryAddTarget>(
      initialValue: value,
      enabled: enabled,
      tooltip: 'Add target',
      position: PopupMenuPosition.under,
      color: compactMenuBackgroundFor(accent, palette),
      elevation: 10,
      constraints: const BoxConstraints(minWidth: 158, maxWidth: 210),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: BorderSide(color: compactMenuBorderFor(accent, palette)),
      ),
      padding: EdgeInsets.zero,
      onSelected: onChanged,
      itemBuilder: (context) => [
        compactPopupMenuItem(
          value: LibraryAddTarget.owned,
          label: LibraryAddTarget.owned.actionLabel,
          selected: value == LibraryAddTarget.owned,
          accent: accent,
        ),
        compactPopupMenuItem(
          value: LibraryAddTarget.wishlist,
          label: LibraryAddTarget.wishlist.actionLabel,
          selected: value == LibraryAddTarget.wishlist,
          accent: accent,
        ),
        compactPopupMenuItem(
          value: LibraryAddTarget.track,
          label: LibraryAddTarget.track.actionLabel,
          selected: value == LibraryAddTarget.track,
          accent: accent,
        ),
      ],
      child: CompactMenuButton(
        width: 158,
        label: value.actionLabel,
        accent: accent,
        enabled: enabled,
      ),
    );
  }
}
