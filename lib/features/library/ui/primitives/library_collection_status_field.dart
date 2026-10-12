import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/ui/library_metrics.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_icon.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

List<PopupMenuEntry<LibraryCollectionStatusScope>>
    libraryCollectionStatusMenuItems(BuildContext context,
        {bool showIcons = true}) {
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
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: [
            if (showIcons) ...[
              LibraryCollectionStatusIcon(collectionStatus: status, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
                child: Text(status.label,
                    style: TextStyle(
                        color: appPalette(context).textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400)))
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
        child: LayoutBuilder(
          builder: (context, constraints) =>
              PopupMenuButton<LibraryCollectionStatusScope>(
            tooltip: 'Choose collection status',
            position: PopupMenuPosition.under,
            color: appPalette(context).panelRaised,
            shape: RoundedRectangleBorder(
                borderRadius: appPalette(context).menuBorderRadius,
                side: BorderSide(color: appPalette(context).divider)),
            surfaceTintColor: Colors.transparent,
            menuPadding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            itemBuilder: (context) =>
                libraryCollectionStatusMenuItems(context, showIcons: false),
            onSelected: (value) =>
                onChanged(libraryCollectionStatusValue(value)),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SizedBox(
                height: LibraryMetrics.defaultFieldHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor ??
                          appPalette(context).surface,
                      border: Border.all(color: appPalette(context).divider),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: Text(status.label,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w400)),
                      )),
                      ColoredBox(
                          color: appPalette(context).divider,
                          child: const SizedBox(
                              width: 34,
                              height: 34,
                              child: Center(
                                  child: Icon(AppIcons.caretDown, size: 12)))),
                    ]),
                  ),
                ),
              ),
            ),
          ),
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
