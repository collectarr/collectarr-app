import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_icon.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

List<PopupMenuEntry<LibraryCollectionStatusScope>>
    libraryCollectionStatusMenuItems(BuildContext context) {
  PopupMenuEntry<LibraryCollectionStatusScope> heading(String label) =>
      PopupMenuItem(
          enabled: false,
          height: 26,
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
          child: Text(label,
              style: TextStyle(
                  color: appPalette(context).textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)));
  PopupMenuEntry<LibraryCollectionStatusScope> item(
          LibraryCollectionStatusScope status) =>
      PopupMenuItem(
          value: status,
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: [
            LibraryCollectionStatusIcon(status: status, size: 24),
            const SizedBox(width: 8),
            Expanded(
                child: Text(status.label,
                    style: TextStyle(
                        color: appPalette(context).textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)))
          ]));
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
    return LibraryFormField(
        label: label,
        child: PopupMenuButton<LibraryCollectionStatusScope>(
          tooltip: 'Choose collection status',
          itemBuilder: libraryCollectionStatusMenuItems,
          onSelected: (value) => onChanged(libraryCollectionStatusValue(value)),
          child: InputDecorator(
              decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  constraints: BoxConstraints(minHeight: 34)),
              child: Row(children: [
                LibraryCollectionStatusIcon(status: status, size: 24),
                const SizedBox(width: 8),
                Expanded(child: Text(status.label)),
                const Icon(Icons.arrow_drop_down, size: 20),
              ])),
        ));
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
