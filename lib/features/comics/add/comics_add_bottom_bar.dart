import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/inspector/comics_inspector.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/add/compact_controls.dart';
import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:flutter/material.dart';

class AddComicBottomBar extends StatelessWidget {
  const AddComicBottomBar({
    super.key,
    required this.selectedItem,
    required this.selectedCandidate,
    required this.selectedIsOwned,
    required this.selectedIsWishlisted,
    required this.proposalProviderLabel,
    required this.proposalCount,
    required this.addTarget,
    required this.addCount,
    required this.isSubmitting,
    required this.defaultCondition,
    required this.defaultGrade,
    required this.defaultStorageBoxController,
    required this.defaultPurchaseDate,
    required this.onAddTargetChanged,
    required this.onDefaultConditionChanged,
    required this.onDefaultGradeChanged,
    required this.onDefaultPurchaseDateChanged,
    required this.onAdd,
    required this.onPropose,
  });

  final CatalogItem? selectedItem;
  final ProviderCandidate? selectedCandidate;
  final bool selectedIsOwned;
  final bool selectedIsWishlisted;
  final String proposalProviderLabel;
  final int proposalCount;
  final LibraryAddTarget addTarget;
  final int addCount;
  final bool isSubmitting;
  final String? defaultCondition;
  final String? defaultGrade;
  final TextEditingController defaultStorageBoxController;
  final DateTime? defaultPurchaseDate;
  final ValueChanged<LibraryAddTarget> onAddTargetChanged;
  final ValueChanged<String?> onDefaultConditionChanged;
  final ValueChanged<String?> onDefaultGradeChanged;
  final ValueChanged<DateTime?> onDefaultPurchaseDateChanged;
  final VoidCallback? onAdd;
  final VoidCallback? onPropose;

  @override
  Widget build(BuildContext context) {
    final isProposal = selectedItem == null && proposalCount > 0;
    final disabledByLocalStatus = addTarget == LibraryAddTarget.owned
        ? selectedIsOwned
        : selectedIsWishlisted;
    final label = isProposal
        ? proposalCount == 1
            ? 'Propose $proposalProviderLabel Metadata'
            : 'Propose $proposalCount Metadata Proposals'
        : disabledByLocalStatus
            ? addTarget == LibraryAddTarget.owned
                ? 'Already in Collection'
                : 'Already in Wishlist'
            : LibraryAddCopy.addToTargetLabel(
                count: addCount,
                type: comicsLibraryConfig,
                target: addTarget,
              );
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kClzToolbar,
        border: Border(top: BorderSide(color: kClzDivider)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isProposal) ...[
              _AddTargetDefaultsBar(
                addTarget: addTarget,
                addCount: addCount,
                isSubmitting: isSubmitting,
                condition: defaultCondition,
                grade: defaultGrade,
                storageBoxController: defaultStorageBoxController,
                purchaseDate: defaultPurchaseDate,
                onAddTargetChanged: onAddTargetChanged,
                onConditionChanged: onDefaultConditionChanged,
                onGradeChanged: onDefaultGradeChanged,
                onPurchaseDateChanged: onDefaultPurchaseDateChanged,
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: isSubmitting
                        ? null
                        : isProposal
                            ? onPropose
                            : disabledByLocalStatus
                                ? null
                                : onAdd,
                    style: FilledButton.styleFrom(
                      backgroundColor: kClzAccent,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    child: Text(label),
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

class _AddTargetDefaultsBar extends StatelessWidget {
  const _AddTargetDefaultsBar({
    required this.addTarget,
    required this.addCount,
    required this.isSubmitting,
    required this.condition,
    required this.grade,
    required this.storageBoxController,
    required this.purchaseDate,
    required this.onAddTargetChanged,
    required this.onConditionChanged,
    required this.onGradeChanged,
    required this.onPurchaseDateChanged,
  });

  final LibraryAddTarget addTarget;
  final int addCount;
  final bool isSubmitting;
  final String? condition;
  final String? grade;
  final TextEditingController storageBoxController;
  final DateTime? purchaseDate;
  final ValueChanged<LibraryAddTarget> onAddTargetChanged;
  final ValueChanged<String?> onConditionChanged;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<DateTime?> onPurchaseDateChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        LibraryAddResultBadge('$addCount selected'),
        _TargetMenu(
          value: addTarget,
          enabled: !isSubmitting,
          onChanged: onAddTargetChanged,
        ),
        if (addTarget == LibraryAddTarget.owned) ...[
          const Text(
            'Owned defaults',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          CompactDropdownWithNone(
            width: 118,
            value: condition,
            items: ComicInspector.conditions,
            label: 'Condition',
            accent: kClzAccent,
            onChanged: onConditionChanged,
          ),
          CompactDropdownWithNone(
            width: 104,
            value: grade,
            items: ComicInspector.grades,
            label: 'Grade',
            accent: kClzAccent,
            onChanged: onGradeChanged,
          ),
          SizedBox(
            width: 132,
            height: kCompactControlHeight,
            child: CompactInputShell(
              accent: kClzAccent,
              child: TextField(
                controller: storageBoxController,
                keyboardType: TextInputType.text,
                inputFormatters: [noNewlineFormatter],
                expands: true,
                minLines: null,
                maxLines: null,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                textAlignVertical: TextAlignVertical.center,
                strutStyle: const StrutStyle(
                  fontSize: 13,
                  height: 1,
                  forceStrutHeight: true,
                ),
                style: const TextStyle(
                  color: kCompactMenuText,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  labelText: 'Storage box',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          CompactDateButton(
            label: purchaseDate == null
                ? 'Purchase date'
                : formatCompactDate(purchaseDate!),
            accent: kClzAccent,
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
      ],
    );
  }
}

class _TargetMenu extends StatelessWidget {
  const _TargetMenu({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final LibraryAddTarget value;
  final bool enabled;
  final ValueChanged<LibraryAddTarget> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<LibraryAddTarget>(
      initialValue: value,
      enabled: enabled,
      tooltip: 'Add target',
      position: PopupMenuPosition.under,
      color: kCompactMenuBackground,
      elevation: 10,
      constraints: const BoxConstraints(minWidth: 158, maxWidth: 210),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: BorderSide(color: kClzAccent.withValues(alpha: 0.74)),
      ),
      onSelected: onChanged,
      itemBuilder: (context) => [
        compactPopupMenuItem(
          value: LibraryAddTarget.owned,
          label: LibraryAddTarget.owned.actionLabel,
          selected: value == LibraryAddTarget.owned,
          accent: kClzAccent,
        ),
        compactPopupMenuItem(
          value: LibraryAddTarget.wishlist,
          label: LibraryAddTarget.wishlist.actionLabel,
          selected: value == LibraryAddTarget.wishlist,
          accent: kClzAccent,
        ),
      ],
      child: CompactMenuButton(
        width: 158,
        label: value.actionLabel,
        accent: kClzAccent,
        enabled: enabled,
      ),
    );
  }
}
