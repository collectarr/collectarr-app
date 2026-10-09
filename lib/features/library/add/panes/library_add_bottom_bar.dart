import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart';
import 'library_add_status_button.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
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
            Align(
              alignment: Alignment.centerRight,
              child: LibraryAddStatusButton(
                collectionStatus: addTarget == LibraryAddTarget.wishlist
                    ? LibraryCollectionStatusScope.wishList
                    : addTarget == LibraryAddTarget.track
                        ? LibraryCollectionStatusScope.notInCollection
                        : libraryCollectionStatusFromValue(
                            request.collectionStatus),
                isBusy: isAdding,
                onAdd: onAdd,
                onStatusChanged: request.onCollectionStatusChanged == null
                    ? null
                    : (status) => request.onCollectionStatusChanged!(
                        libraryCollectionStatusValue(status)),
              ),
            ),
          ],
        ),
      ),
    );
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
