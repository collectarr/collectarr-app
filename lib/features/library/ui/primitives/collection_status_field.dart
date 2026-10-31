import 'package:collectarr_app/ui/app_dropdown_menu.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/ui/primitives/fixed_select_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// CLZ's grouped status menu: dimmed bold group headings over indented
/// statuses, with the [selected] status and the hovered one shaded.
List<PopupMenuEntry<LibraryCollectionStatusScope>>
    libraryCollectionStatusEditMenuItems(BuildContext context,
        {LibraryCollectionStatusScope? selected, double rowHeight = 32}) {
  final palette = appPalette(context);
  final menu = AppDropdownMenuStyle.of(context);
  PopupMenuEntry<LibraryCollectionStatusScope> heading(String label) =>
      PopupMenuItem(
          enabled: false,
          height: rowHeight - 1,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Text(label,
              style: TextStyle(
                  color: palette.textPrimary.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w700)));
  PopupMenuEntry<LibraryCollectionStatusScope> item(
          LibraryCollectionStatusScope status) =>
      menu.shaded(PopupMenuItem(
          value: status,
          height: rowHeight,
          padding: EdgeInsets.zero,
          child: Container(
              height: rowHeight,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 24, right: 7),
              color: status == selected ? menu.shade : null,
              child: Text(
                  status == LibraryCollectionStatusScope.wishList
                      ? 'On Wish List'
                      : status.label,
                  style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400)))));
  return [
    heading('Collection'),
    item(LibraryCollectionStatusScope.inCollection),
    item(LibraryCollectionStatusScope.forSale),
    heading('Wish List'),
    item(LibraryCollectionStatusScope.wishList),
    item(LibraryCollectionStatusScope.onOrder),
    heading('Not in Collection'),
    item(LibraryCollectionStatusScope.sold),
    item(LibraryCollectionStatusScope.notInCollection)
  ];
}

class LibraryCollectionStatusField extends StatelessWidget {
  const LibraryCollectionStatusField(
      {super.key,
      required this.value,
      required this.onChanged,
      this.label = 'Collection Status'});
  final String? value;
  final ValueChanged<String> onChanged;
  final String label;
  @override
  Widget build(BuildContext context) {
    final status = libraryCollectionStatusFromValue(value);
    return LibraryMenuSelectField<LibraryCollectionStatusScope>(
      label: label,
      tooltip: 'Choose collection status',
      display: Text(status.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
      itemBuilder: (context) =>
          libraryCollectionStatusEditMenuItems(context, selected: status),
      onSelected: (value) => onChanged(libraryCollectionStatusValue(value)),
    );
  }
}

LibraryCollectionStatusScope libraryCollectionStatusFromValue(String? value) =>
    switch (value?.trim().toLowerCase()) {
      'for sale' => LibraryCollectionStatusScope.forSale,
      'wish list' ||
      'wishlist' ||
      'on wish list' =>
        LibraryCollectionStatusScope.wishList,
      'on order' => LibraryCollectionStatusScope.onOrder,
      'sold' => LibraryCollectionStatusScope.sold,
      'not in collection' => LibraryCollectionStatusScope.notInCollection,
      _ => LibraryCollectionStatusScope.inCollection,
    };

String libraryCollectionStatusValue(LibraryCollectionStatusScope status) =>
    status == LibraryCollectionStatusScope.wishList
        ? 'Wish List'
        : status.label;
