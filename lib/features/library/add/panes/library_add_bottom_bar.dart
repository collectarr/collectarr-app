import 'library_add_pane_dependencies.dart';

class LibraryAddBottomBar extends StatelessWidget {
  const LibraryAddBottomBar({
    super.key,
    required this.request,
  });

  final LibraryAddBottomBarRequest request;

  LibraryKindRegistration get type => request.type;
  bool get isWideLayout => request.isWideLayout;
  List<String> get conditions => request.conditions;
  String? get defaultTags => request.defaultTags;
  Color get accent => request.accent;
  CatalogSearchCandidate? get selectedItem => request.selectedItem;
  LibraryAddTarget get addTarget => request.addTarget;
  int get addCount => request.addCount;
  bool get hasCheckedSelection => request.hasCheckedSelection;
  bool get isAdding => request.isAdding;
  String get defaultCondition => request.defaultCondition;
  String? get defaultLocationLabel => request.defaultLocationLabel;
  DateTime? get defaultPurchaseDate => request.defaultPurchaseDate;
  ValueChanged<LibraryAddTarget> get onAddTargetChanged =>
      request.onAddTargetChanged;
  ValueChanged<String> get onDefaultConditionChanged =>
      request.onDefaultConditionChanged;
  VoidCallback get onEditDefaultTagsPressed => request.onEditDefaultTagsPressed;
  VoidCallback get onDefaultLocationPressed => request.onDefaultLocationPressed;
  ValueChanged<DateTime?> get onDefaultPurchaseDateChanged =>
      request.onDefaultPurchaseDateChanged;
  VoidCallback? get onAdd => request.onAdd;

  @override
  Widget build(BuildContext context) {
    return _buildResponsiveMenu(context);
  }

  Widget _buildResponsiveMenu(BuildContext context) {
    final palette = appPalette(context);
    final hasSelection = hasCheckedSelection || selectedItem != null;
    final effectiveCount = addCount > 0 ? addCount : (hasSelection ? 1 : 0);
    final addLabel = hasCheckedSelection
        ? LibraryAddCopy.addToTargetLabel(
            count: effectiveCount,
            type: type,
            target: addTarget,
          )
        : effectiveCount > 0
            ? LibraryAddCopy.addToTargetLabel(
                count: effectiveCount,
                type: type,
                target: addTarget,
              )
            : 'Select a ${type.identity.singularLabel.toLowerCase()} to add';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          kLibraryDialogFooterHorizontalPadding,
          isWideLayout
              ? kLibraryDialogFooterVerticalPadding
              : kLibraryDialogFooterVerticalPadding,
          kLibraryDialogFooterHorizontalPadding,
          isWideLayout
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
              ],
            ),
            if (addTarget == LibraryAddTarget.entry && !isWideLayout) ...[
              const SizedBox(height: 8),
              _AddTargetDefaultsBar(
                accent: accent,
                conditions: conditions,
                condition: defaultCondition,
                tags: defaultTags,
                locationLabel: defaultLocationLabel,
                purchaseDate: defaultPurchaseDate,
                onConditionChanged: onDefaultConditionChanged,
                onEditTagsPressed: onEditDefaultTagsPressed,
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
                        : Text(isWideLayout ? _wideLayoutAddLabel() : addLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _wideLayoutAddLabel() {
    return switch (addTarget) {
      LibraryAddTarget.entry => 'Add to Collection',
      LibraryAddTarget.wishlist => 'Add to Wishlist',
      LibraryAddTarget.track => 'Track in Library',
    };
  }
}

class _AddTargetDefaultsBar extends StatelessWidget {
  const _AddTargetDefaultsBar({
    required this.accent,
    required this.conditions,
    required this.condition,
    required this.tags,
    required this.locationLabel,
    required this.purchaseDate,
    required this.onConditionChanged,
    required this.onEditTagsPressed,
    required this.onLocationPressed,
    required this.onPurchaseDateChanged,
  });

  final Color accent;
  final List<String> conditions;
  final String condition;
  final String? tags;
  final String? locationLabel;
  final DateTime? purchaseDate;
  final ValueChanged<String> onConditionChanged;
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
          'Entry defaults',
          style: TextStyle(fontWeight: FontWeight.w600),
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
        InkWell(
          mouseCursor: WidgetStateMouseCursor.clickable,
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
          mouseCursor: WidgetStateMouseCursor.clickable,
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
          value: LibraryAddTarget.entry,
          label: LibraryAddTarget.entry.actionLabel,
          selected: value == LibraryAddTarget.entry,
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
