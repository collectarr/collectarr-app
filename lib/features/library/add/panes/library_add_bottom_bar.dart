import 'library_add_pane_dependencies.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';

class LibraryAddBottomBar extends StatelessWidget {
  const LibraryAddBottomBar({
    super.key,
    required this.request,
    this.presentation = LibraryAddBottomBarPresentation.responsiveMenu,
  });

  final LibraryAddBottomBarRequest request;
  final LibraryAddBottomBarPresentation presentation;

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
    return switch (presentation) {
      LibraryAddBottomBarPresentation.responsiveMenu =>
        _buildResponsiveMenu(context),
      LibraryAddBottomBarPresentation.segmentedTarget =>
        _buildSegmentedTarget(context),
    };
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
            if (addTarget == LibraryAddTarget.owned && !isWideLayout) ...[
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
      LibraryAddTarget.owned => 'Add to Collection',
      LibraryAddTarget.wishlist => 'Add to Wishlist',
      LibraryAddTarget.track => 'Track in Library',
    };
  }

  Widget _buildSegmentedTarget(BuildContext context) {
    final palette = appPalette(context);
    final hasSelection =
        request.hasCheckedSelection || request.selectedItem != null;
    final effectiveCount =
        request.addCount > 0 ? request.addCount : (hasSelection ? 1 : 0);
    final primaryLabel = _primaryAddLabel(request, effectiveCount);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<LibraryAddTarget>(
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        side: WidgetStatePropertyAll(
                          BorderSide(
                            color: request.accent.withValues(alpha: 0.32),
                          ),
                        ),
                      ),
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment<LibraryAddTarget>(
                          value: LibraryAddTarget.owned,
                          label: Text('Collection'),
                          icon: Icon(Icons.library_add_outlined, size: 18),
                        ),
                        ButtonSegment<LibraryAddTarget>(
                          value: LibraryAddTarget.wishlist,
                          label: Text('Wishlist'),
                          icon: Icon(Icons.favorite_border, size: 18),
                        ),
                        ButtonSegment<LibraryAddTarget>(
                          value: LibraryAddTarget.track,
                          label: Text('Track'),
                          icon: Icon(Icons.visibility_outlined, size: 18),
                        ),
                      ],
                      selected: {request.addTarget},
                      onSelectionChanged: request.isAdding
                          ? null
                          : (selection) {
                              if (selection.isNotEmpty) {
                                request.onAddTargetChanged(selection.first);
                              }
                            },
                    ),
                  ),
                ),
              ],
            ),
            if (request.addTarget == LibraryAddTarget.owned) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    child: CompactSearchDropdownFormField<String>(
                      initialValue: request.defaultCondition,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Condition',
                        isDense: true,
                      ),
                      items: [
                        for (final value in {
                          request.defaultCondition,
                          ...request.conditions,
                        })
                          DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                      ],
                      onChanged: request.isAdding
                          ? null
                          : (value) {
                              if (value != null) {
                                request.onDefaultConditionChanged(value);
                              }
                            },
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: request.isAdding
                        ? null
                        : request.onDefaultLocationPressed,
                    style: _kindOutlinedButtonStyle(request.accent),
                    icon: const Icon(Icons.place_outlined, size: 16),
                    label: Text(request.defaultLocationLabel ?? 'Location'),
                  ),
                  OutlinedButton.icon(
                    onPressed: request.isAdding
                        ? null
                        : () async {
                            final picked = await showLibraryDateEntryDialog(
                              context,
                              label: 'Purchase date',
                              initialDate: request.defaultPurchaseDate,
                            );
                            if (picked != null) {
                              request.onDefaultPurchaseDateChanged(picked);
                            }
                          },
                    style: _kindOutlinedButtonStyle(request.accent),
                    icon: const Icon(Icons.event_outlined, size: 16),
                    label:
                        Text(_purchaseDateLabel(request.defaultPurchaseDate)),
                  ),
                  OutlinedButton.icon(
                    onPressed: request.isAdding
                        ? null
                        : request.onEditDefaultTagsPressed,
                    style: _kindOutlinedButtonStyle(request.accent),
                    icon: const Icon(Icons.sell_outlined, size: 16),
                    label: Text(
                      request.defaultTags?.trim().isNotEmpty == true
                          ? 'Tags: ${request.defaultTags!}'
                          : 'Tags',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: request.isAdding ? null : request.onAdd,
                    style: libraryAddFilledButtonStyle(request.accent),
                    child: request.isAdding
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(primaryLabel),
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

ButtonStyle _kindOutlinedButtonStyle(Color accent) {
  return OutlinedButton.styleFrom(
    foregroundColor: accent,
    side: BorderSide(color: accent.withValues(alpha: 0.35)),
    minimumSize: const Size(0, 36),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    textStyle: const TextStyle(fontWeight: FontWeight.w600),
  );
}

String _primaryAddLabel(LibraryAddBottomBarRequest request, int count) {
  if (count <= 0) {
    return switch (request.addTarget) {
      LibraryAddTarget.owned => 'Select items to add',
      LibraryAddTarget.wishlist => 'Select items for wishlist',
      LibraryAddTarget.track => 'Select items to track',
    };
  }
  if (count == 1) {
    return switch (request.addTarget) {
      LibraryAddTarget.owned => 'Add to Collection',
      LibraryAddTarget.wishlist => 'Add to Wishlist',
      LibraryAddTarget.track => 'Track in Library',
    };
  }
  return switch (request.addTarget) {
    LibraryAddTarget.owned => 'Add $count to Collection',
    LibraryAddTarget.wishlist => 'Add $count to Wishlist',
    LibraryAddTarget.track => 'Track $count in Library',
  };
}

String _purchaseDateLabel(DateTime? date) {
  if (date == null) return 'Purchase date';
  final month = switch (date.month) {
    1 => 'Jan',
    2 => 'Feb',
    3 => 'Mar',
    4 => 'Apr',
    5 => 'May',
    6 => 'Jun',
    7 => 'Jul',
    8 => 'Aug',
    9 => 'Sep',
    10 => 'Oct',
    11 => 'Nov',
    _ => 'Dec',
  };
  return '$month ${date.day}, ${date.year}';
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
          'Owned defaults',
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
