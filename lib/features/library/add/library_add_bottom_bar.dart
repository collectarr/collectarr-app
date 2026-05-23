part of 'library_add_dialog.dart';

class _LibraryAddBottomBar extends StatelessWidget {
  const _LibraryAddBottomBar({
    required this.type,
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
    required this.onDefaultLocationPressed,
    required this.onDefaultPurchaseDateChanged,
    required this.onAdd,
    required this.onQueueIngest,
    required this.onPropose,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final LibraryMetadataItem? selectedItem;
  final ProviderCandidate? selectedCandidate;
  final _QueuedProviderIngest? selectedQueuedIngest;
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
  final VoidCallback onDefaultLocationPressed;
  final ValueChanged<DateTime?> onDefaultPurchaseDateChanged;
  final VoidCallback? onAdd;
  final VoidCallback? onQueueIngest;
  final VoidCallback? onPropose;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedItem != null || selectedCandidate != null;
    final effectiveCount = addCount > 0 ? addCount : (hasSelection ? 1 : 0);
    final addLabel = effectiveCount > 0
        ? LibraryAddCopy.addToTargetLabel(
            count: effectiveCount,
            type: type,
            target: addTarget,
          )
        : 'Select a ${type.singularLabel.toLowerCase()} to add';
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kAppToolbar,
        border: Border(top: BorderSide(color: kAppDivider)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                LibraryAddResultBadge(
                    effectiveCount > 0
                        ? '$effectiveCount selected'
                        : '0 selected'),
                _LibraryAddTargetMenu(
                  value: addTarget,
                  enabled: !isAdding,
                  accent: accent,
                  onChanged: onAddTargetChanged,
                ),
                if (selectedCandidate != null) ...[
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
                      onPressed:
                          selectedQueuedIngest != null || isQueueingIngest
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
            if (addTarget == LibraryAddTarget.owned) ...[
              const SizedBox(height: 8),
              _AddTargetDefaultsBar(
                accent: accent,
                conditions: type.conditions,
                grades: type.grades,
                condition: defaultCondition,
                grade: defaultGrade,
                locationLabel: defaultLocationLabel,
                purchaseDate: defaultPurchaseDate,
                onConditionChanged: onDefaultConditionChanged,
                onGradeChanged: onDefaultGradeChanged,
                onLocationPressed: onDefaultLocationPressed,
                onPurchaseDateChanged: onDefaultPurchaseDateChanged,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: isAdding ? null : onAdd,
                    style: libraryAddFilledButtonStyle(accent),
                    child: isAdding
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(addLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
        style: _libraryAddOutlinedButtonStyle(accent),
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
    required this.locationLabel,
    required this.purchaseDate,
    required this.onConditionChanged,
    required this.onGradeChanged,
    required this.onLocationPressed,
    required this.onPurchaseDateChanged,
  });

  final Color accent;
  final List<String> conditions;
  final List<String> grades;
  final String condition;
  final String grade;
  final String? locationLabel;
  final DateTime? purchaseDate;
  final ValueChanged<String> onConditionChanged;
  final ValueChanged<String> onGradeChanged;
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
          label: purchaseDate == null
              ? 'Purchase date'
              : formatCompactDate(purchaseDate!),
          accent: accent,
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: purchaseDate ?? DateTime.now(),
              firstDate: DateTime(1970),
              lastDate: DateTime(2100),
            );
            onPurchaseDateChanged(picked);
          },
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
    return PopupMenuButton<LibraryAddTarget>(
      initialValue: value,
      enabled: enabled,
      tooltip: 'Add target',
      position: PopupMenuPosition.under,
      color: compactMenuBackgroundFor(accent),
      elevation: 10,
      constraints: const BoxConstraints(minWidth: 158, maxWidth: 210),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: BorderSide(color: accent.withValues(alpha: 0.74)),
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

