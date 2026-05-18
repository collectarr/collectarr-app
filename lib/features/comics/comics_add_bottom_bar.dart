import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_inspector.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
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

const double _kCompactControlHeight = 30;

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
          _SmallDropdown(
            width: 118,
            value: condition,
            items: ComicInspector.conditions,
            label: 'Condition',
            onChanged: onConditionChanged,
          ),
          _SmallDropdown(
            width: 104,
            value: grade,
            items: ComicInspector.grades,
            label: 'Grade',
            onChanged: onGradeChanged,
          ),
          SizedBox(
            width: 132,
            height: _kCompactControlHeight,
            child: _CompactInputShell(
              child: TextField(
                controller: storageBoxController,
                expands: true,
                minLines: null,
                maxLines: null,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                  color: Color(0xFFBFEFFF),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
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
          _CompactDateButton(
            label: purchaseDate == null
                ? 'Purchase date'
                : _formatDate(purchaseDate!),
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
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: LibraryAddTarget.owned,
          child: Text(LibraryAddTarget.owned.actionLabel),
        ),
        PopupMenuItem(
          value: LibraryAddTarget.wishlist,
          child: Text(LibraryAddTarget.wishlist.actionLabel),
        ),
      ],
      child: _CompactMenuButton(
        width: 158,
        label: value.actionLabel,
        enabled: enabled,
      ),
    );
  }
}

class _SmallDropdown extends StatelessWidget {
  const _SmallDropdown({
    required this.width,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
  });

  final double width;
  final String? value;
  final List<String> items;
  final String label;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValue = items.contains(value) ? value : null;
    return PopupMenuButton<String?>(
      initialValue: selectedValue,
      tooltip: label,
      position: PopupMenuPosition.under,
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem<String?>(
          value: null,
          child: Text('$label: none'),
        ),
        for (final item in items)
          PopupMenuItem<String?>(value: item, child: Text(item)),
      ],
      child: _CompactMenuButton(
        width: width,
        label: selectedValue ?? label,
      ),
    );
  }
}

class _CompactInputShell extends StatelessWidget {
  const _CompactInputShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kCompactControlHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF183246),
        border: Border.all(color: kClzAccent.withValues(alpha: 0.82)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: child,
    );
  }
}

class _CompactDateButton extends StatelessWidget {
  const _CompactDateButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(3),
      child: _CompactMenuFrame(
        width: 150,
        label: label,
        leading: Icons.calendar_today,
      ),
    );
  }
}

class _CompactMenuButton extends StatelessWidget {
  const _CompactMenuButton({
    required this.width,
    required this.label,
    this.enabled = true,
  });

  final double width;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? const Color(0xFFBFEFFF) : const Color(0xFF7B8790);
    return Opacity(
      opacity: enabled ? 1 : 0.62,
      child: _CompactMenuFrame(
        width: width,
        label: label,
        enabledColor: color,
        trailing: Icons.arrow_drop_down,
      ),
    );
  }
}

class _CompactMenuFrame extends StatelessWidget {
  const _CompactMenuFrame({
    required this.width,
    required this.label,
    this.enabledColor = const Color(0xFFBFEFFF),
    this.leading,
    this.trailing,
  });

  final double width;
  final String label;
  final Color enabledColor;
  final IconData? leading;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: _kCompactControlHeight,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF183246),
        border: Border.all(color: kClzAccent.withValues(alpha: 0.82)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            Icon(leading, color: enabledColor, size: 15),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: enabledColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (trailing != null) Icon(trailing, color: enabledColor, size: 18),
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
