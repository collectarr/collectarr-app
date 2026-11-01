import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/collections/family.dart';
import 'package:collectarr_app/features/library/collections/repository.dart';
import 'package:collectarr_app/features/library/collections/dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/app_bottom_sheet.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'collection_selection.dart';

class NativeCollectionPicker extends ConsumerWidget {
  const NativeCollectionPicker(
      {super.key, required this.mediaKind, this.onSelected});
  final String mediaKind;
  final ValueChanged<LibraryCollectionSummary>? onSelected;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values =
        ref.watch(libraryCollectionFamilyProvider(mediaKind)).asData?.value ??
            const <LibraryCollectionSummary>[];
    final activeId = activeLibraryCollectionId(
        values.where((value) => value.kind == mediaKind).toList());
    final active = values.where((value) => value.id == activeId).firstOrNull;
    return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
            key: const Key('library.collection-picker'),
            style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                foregroundColor: appPalette(context).utilityAction),
            icon: const Icon(Icons.collections_bookmark_outlined),
            label: Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(
                  child: Text(active?.name ?? 'Collections',
                      overflow: TextOverflow.ellipsis)),
              const Icon(Icons.expand_more)
            ]),
            onPressed: () async {
              final repository =
                  LibraryCollectionRepository(ref.read(localDatabaseProvider));
              final selected = await showAppBottomSheet<
                      LibraryCollectionSummary>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (sheetContext) => ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight:
                              MediaQuery.sizeOf(sheetContext).height * .75),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const ListTile(
                            title: Text('Collections',
                                style: TextStyle(fontWeight: FontWeight.w700))),
                        Flexible(
                            child: ListView(shrinkWrap: true, children: [
                          for (final value in values)
                            ListTile(
                                title: Text(value.name),
                                subtitle:
                                    collectionFamilyKinds(mediaKind).length > 1
                                        ? Text(value.kind)
                                        : null,
                                selected: value.id == activeId,
                                selectedColor:
                                    appPalette(sheetContext).utilityAction,
                                trailing: value.id == activeId
                                    ? const Icon(Icons.check)
                                    : null,
                                onTap: () =>
                                    Navigator.of(sheetContext).pop(value))
                        ])),
                        ListTile(
                            leading: const Icon(Icons.settings_outlined),
                            title: const Text('Manage Collections'),
                            onTap: () {
                              Navigator.of(sheetContext).pop();
                              showLibraryCollectionsDialog(context,
                                  kind: mediaKind);
                            }),
                      ])));
              if (!context.mounted || selected == null) return;
              await selectLibraryCollection(context,
                  repository: repository,
                  mediaKind: mediaKind,
                  activeId: activeId,
                  collection: selected,
                  onSelected: onSelected);
            }));
  }
}
