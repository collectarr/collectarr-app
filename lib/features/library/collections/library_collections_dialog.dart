import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showLibraryCollectionsDialog(BuildContext context,
        {required String kind}) =>
    showDialog<void>(
        context: context, builder: (_) => _CollectionsDialog(kind: kind));

Future<String?> chooseLibraryCollection(BuildContext context,
    {required LocalDatabase db,
    required String kind,
    String? excluding,
    String title = 'Move to other collection'}) async {
  final collections = await LibraryCollectionRepository(db).watch(kind).first;
  if (!context.mounted) return null;
  return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
              title: Text(title),
              content: SizedBox(
                  width: 380,
                  child: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    for (final collection in collections)
                      if (collection.id != excluding)
                        ListTile(
                            leading: const Icon(Icons.folder_outlined),
                            title: Text(collection.name),
                            trailing: Text('${collection.count}'),
                            onTap: () =>
                                Navigator.of(context).pop(collection.id)),
                  ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'))
              ]));
}

final class _CollectionsDialog extends ConsumerWidget {
  const _CollectionsDialog({required this.kind});
  final String kind;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(libraryCollectionsProvider(kind));
    final db = ref.watch(localDatabaseProvider);
    final repo = LibraryCollectionRepository(db);
    final accent = defaultLibraryKindRegistry
        .require(catalogMediaKindFromApiValue(kind))
        .identity
        .accent;
    final palette = appPalette(context).copyWith(accent: accent);
    return Theme(
        data: editDialogTheme(palette: palette),
        child: Dialog(
            alignment: Alignment.topCenter,
            insetPadding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                          height: 38,
                          color: palette.accent,
                          padding: const EdgeInsets.only(left: 15, right: 6),
                          child: Row(children: [
                            Expanded(
                                child: Text('Manage Collections',
                                    style: context.libraryTextTheme.panelTitle
                                        .copyWith(
                                            color: appContrastingTextColor(
                                                palette.accent)))),
                            IconButton(
                                tooltip: 'Close',
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close, size: 18))
                          ])),
                      Container(
                          height: 40,
                          color: palette.toolbar,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: FilledButton.icon(
                              onPressed: () => showDialog<void>(
                                  context: context,
                                  builder: (_) => _CollectionNameDialog(
                                      repo: repo, kind: kind)),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Create new collection'))),
                      Flexible(
                          child: collections.when(
                              loading: () => const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(
                                      child: CircularProgressIndicator())),
                              error: (error, _) => Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text('$error')),
                              data: (values) => ReorderableListView.builder(
                                    shrinkWrap: true,
                                    buildDefaultDragHandles: false,
                                    itemCount: values.length,
                                    onReorderItem: (oldIndex, newIndex) async {
                                      final ids =
                                          values.map((c) => c.id).toList();
                                      final id = ids.removeAt(oldIndex);
                                      ids.insert(newIndex, id);
                                      await repo.reorder(kind, ids);
                                    },
                                    itemBuilder: (context, index) {
                                      final collection = values[index];
                                      return Container(
                                          key: ValueKey(collection.id),
                                          height: 38,
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: palette.divider))),
                                          child: Row(children: [
                                            ReorderableDragStartListener(
                                                index: index,
                                                child: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8),
                                                    child: Icon(
                                                        Icons.drag_handle,
                                                        size: 17))),
                                            Expanded(
                                                child: Text(collection.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: context
                                                        .libraryTextTheme
                                                        .controlText)),
                                            SizedBox(
                                                width: 82,
                                                child: Text(
                                                    '${collection.count} item${collection.count == 1 ? '' : 's'}',
                                                    textAlign: TextAlign.right,
                                                    style: context
                                                        .libraryTextTheme
                                                        .controlText)),
                                            const SizedBox(width: 10),
                                            SizedBox(
                                                width: 90,
                                                child: Row(children: [
                                                  Icon(Icons.lock, size: 14),
                                                  SizedBox(width: 4),
                                                  Expanded(
                                                      child: Text('Private',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: context
                                                              .libraryTextTheme
                                                              .controlText))
                                                ])),
                                            IconButton(
                                                tooltip: 'Rename collection',
                                                onPressed: () => showDialog<
                                                        void>(
                                                    context: context,
                                                    builder: (_) =>
                                                        _CollectionNameDialog(
                                                            repo: repo,
                                                            kind: kind,
                                                            collection:
                                                                collection)),
                                                icon: const Icon(Icons.edit,
                                                    size: 17)),
                                            IconButton(
                                                tooltip: values.length == 1
                                                    ? 'Keep at least one collection'
                                                    : 'Delete collection',
                                                onPressed: values.length == 1
                                                    ? null
                                                    : () async {
                                                        final destination =
                                                            await chooseLibraryCollection(
                                                                context,
                                                                db: db,
                                                                kind: kind,
                                                                excluding:
                                                                    collection
                                                                        .id,
                                                                title:
                                                                    'Move items before deleting ${collection.name}');
                                                        if (destination ==
                                                                null ||
                                                            !context.mounted) {
                                                          return;
                                                        }
                                                        final confirmed = await showDialog<
                                                                bool>(
                                                            context: context,
                                                            builder: (context) =>
                                                                AlertDialog(
                                                                    title: Text(
                                                                        'Delete ${collection.name}?'),
                                                                    content: Text(
                                                                        '${collection.count} item${collection.count == 1 ? '' : 's'} will move to ${values.firstWhere((c) => c.id == destination).name}.'),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed: () => Navigator.of(context).pop(
                                                                              false),
                                                                          child:
                                                                              const Text('Cancel')),
                                                                      FilledButton(
                                                                          onPressed: () => Navigator.of(context).pop(
                                                                              true),
                                                                          child:
                                                                              const Text('Delete'))
                                                                    ]));
                                                        if (confirmed == true) {
                                                          await repo.delete(
                                                              collection.id,
                                                              moveTo:
                                                                  destination);
                                                        }
                                                      },
                                                icon: const Icon(
                                                    Icons.delete_outline,
                                                    size: 18)),
                                          ]));
                                    },
                                  ))),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                  width: 100,
                                  height: 32,
                                  child: FilledButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('OK'))))),
                    ]))));
  }
}

final class _CollectionNameDialog extends StatefulWidget {
  const _CollectionNameDialog(
      {required this.repo, required this.kind, this.collection});
  final LibraryCollectionRepository repo;
  final String kind;
  final LibraryCollectionSummary? collection;
  @override
  State<_CollectionNameDialog> createState() => _CollectionNameDialogState();
}

final class _CollectionNameDialogState extends State<_CollectionNameDialog> {
  late final _name = TextEditingController(text: widget.collection?.name ?? '');
  String? _error;
  bool _saving = false;
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      if (widget.collection case final collection?) {
        await widget.repo.rename(collection.id, _name.text);
      } else {
        await widget.repo.create(widget.kind, _name.text);
      }
      if (mounted) Navigator.of(context).pop();
    } on ArgumentError catch (error) {
      if (mounted) setState(() => _error = error.message.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: Text(widget.collection == null
              ? 'Create new collection'
              : 'Rename collection'),
          content: SizedBox(
              width: 360,
              child: LibraryTextFormControl(
                  controller: _name,
                  autofocus: true,
                  decoration:
                      InputDecoration(labelText: 'Name', errorText: _error),
                  onFieldSubmitted: (_) => _save())),
          actions: [
            TextButton(
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(widget.collection == null ? 'Create' : 'Save'))
          ]);
}
