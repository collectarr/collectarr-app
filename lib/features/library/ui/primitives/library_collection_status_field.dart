import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/ui/library_metrics.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// CLZ's grouped status menu: dimmed bold group headings over indented
/// statuses, with the [selected] status shaded.
List<PopupMenuEntry<LibraryCollectionStatusScope>>
    libraryCollectionStatusEditMenuItems(BuildContext context,
        {LibraryCollectionStatusScope? selected, double rowHeight = 32}) {
  final palette = appPalette(context);
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
      PopupMenuItem(
          value: status,
          height: rowHeight,
          padding: EdgeInsets.zero,
          child: Container(
              height: rowHeight,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 24, right: 7),
              color: status == selected ? palette.divider : null,
              child: Text(
                  status == LibraryCollectionStatusScope.wishList
                      ? 'On Wish List'
                      : status.label,
                  style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400))));
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
            popUpAnimationStyle: AnimationStyle.noAnimation,
            tooltip: 'Choose collection status',
            position: PopupMenuPosition.under,
            color: appPalette(context).isDark
                ? const Color(0xff444444)
                : appPalette(context).panelRaised,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: appPalette(context).divider)),
            elevation: 6,
            surfaceTintColor: Colors.transparent,
            menuPadding: const EdgeInsets.only(top: 5),
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            itemBuilder: (context) =>
                libraryCollectionStatusEditMenuItems(context, selected: status),
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
                          child: SizedBox(
                              width: 34,
                              height: 34,
                              child: Center(
                                  child: Icon(AppIcons.caretDown,
                                      size: 12,
                                      color: appPalette(context).textMuted)))),
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
