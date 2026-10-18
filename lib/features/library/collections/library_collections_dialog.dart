import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_chrome.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showLibraryCollectionsDialog(BuildContext context,
        {required String kind}) =>
    showAppDialog<void>(
        context: context, builder: (_) => _CollectionsDialog(kind: kind));

Future<String?> chooseLibraryCollection(BuildContext context,
    {required LocalDatabase db,
    required String kind,
    String? excluding,
    String title = 'Move to other collection'}) async {
  final collections = await LibraryCollectionRepository(db).watch(kind).first;
  if (!context.mounted) return null;
  return showAppDialog<String>(
      context: context,
      builder: (context) => Theme(
          data: libraryAccentTheme(context,
              libraryAccentForKind(catalogMediaKindFromApiValue(kind))),
          child: AccentAlertDialog(
              headerIcon: AppIcons.collections,
              title: Text(title),
              content: SizedBox(
                  width: 380,
                  child: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    for (final collection in collections)
                      if (collection.id != excluding)
                        ListTile(
                            leading: const Icon(AppIcons.collections),
                            title: Text(collection.name),
                            trailing: Text('${collection.count}'),
                            onTap: () =>
                                Navigator.of(context).pop(collection.id)),
                  ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'))
              ])));
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
    final basePalette = appPalette(context);
    final palette = basePalette.copyWith(
        panel: basePalette.isDark ? const Color(0xff262626) : basePalette.panel,
        panelRaised: basePalette.isDark
            ? const Color(0xff383838)
            : basePalette.panelRaised,
        accent: accent,
        selection: Color.alphaBlend(
            accent.withValues(alpha: 0.22), basePalette.panel));
    return Theme(
      data: editDialogTheme(palette: palette),
      child: Builder(
        builder: (context) => Dialog(
            backgroundColor: palette.panel,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.topCenter,
            insetPadding:
                const EdgeInsets.fromLTRB(16, kAppDialogTopInset, 16, 24),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AccentDialogHeader(
                          title: 'Manage Collections',
                          icon: AppIcons.collections,
                          accent: accent,
                          minHeight: 38,
                          onClose: () => Navigator.of(context).pop()),
                      Container(
                          height: 40,
                          color: pickListToolbar(context),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: FilledButton.icon(
                              style: _collectionButtonStyle(context).copyWith(
                                minimumSize:
                                    const WidgetStatePropertyAll(Size(0, 29)),
                                maximumSize: const WidgetStatePropertyAll(
                                    Size(double.infinity, 29)),
                                padding: const WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(horizontal: 10)),
                              ),
                              label: const Text('Create new collection'),
                              icon: const Icon(AppIcons.add, size: 14),
                              onPressed: () => showAppDialog<void>(
                                  context: context,
                                  builder: (_) => _CollectionNameDialog(
                                      repo: repo, kind: kind)))),
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
                                  // No elevation shadow, and the row's own 1 px
                                  // right and bottom border lines are cut off:
                                  // lifted out of the table they read as a
                                  // highlight along those edges.
                                  proxyDecorator: (child, _, __) => Material(
                                      type: MaterialType.transparency,
                                      child: ClipRect(
                                          clipper: const _DragRowClipper(),
                                          child: child)),
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
                                    return _CollectionRow(
                                      key: ValueKey(collection.id),
                                      collection: collection,
                                      index: index,
                                      itemLabel: defaultLibraryKindRegistry
                                          .require(catalogMediaKindFromApiValue(
                                              kind))
                                          .identity
                                          .countLabel(collection.count)
                                          .toLowerCase(),
                                      onRename: () => showAppDialog<void>(
                                          context: context,
                                          builder: (_) => _CollectionNameDialog(
                                              repo: repo,
                                              kind: kind,
                                              collection: collection)),
                                      onDelete: values.length == 1
                                          ? null
                                          : () => _delete(context, db, repo,
                                              collection, values),
                                    );
                                  }))),
                      const SizedBox(height: 15),
                      Container(
                          color: palette.panelRaised,
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                              width: 100,
                              child: FilledButton(
                                  style: _collectionButtonStyle(context),
                                  child: const Text('OK'),
                                  onPressed: () =>
                                      Navigator.of(context).pop()))),
                    ]))),
      ),
    );
  }

  Future<void> _delete(
      BuildContext context,
      LocalDatabase db,
      LibraryCollectionRepository repo,
      LibraryCollectionSummary collection,
      List<LibraryCollectionSummary> values) async {
    final destination = await chooseLibraryCollection(context,
        db: db,
        kind: kind,
        excluding: collection.id,
        title: 'Move items before deleting ${collection.name}');
    if (destination == null || !context.mounted) return;
    final confirmed = await showAppDialog<bool>(
        context: context,
        builder: (context) => AccentAlertDialog(
                headerIcon: AppIcons.delete,
                title: Text('Delete ${collection.name}?'),
                content: Text(
                    '${collection.count} item${collection.count == 1 ? '' : 's'} will move to ${values.firstWhere((c) => c.id == destination).name}.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'))
                ]));
    if (confirmed == true) {
      await repo.delete(collection.id, moveTo: destination);
    }
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
  Widget build(BuildContext context) => AccentAlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          headerIcon:
              widget.collection == null ? AppIcons.add : AppIcons.inlineEdit,
          title: Text(
              widget.collection == null ? 'Add Collection' : 'Edit Collection'),
          contentPadding: const EdgeInsets.all(15),
          actionsPadding: EdgeInsets.zero,
          buttonPadding: EdgeInsets.zero,
          content: SizedBox(
              width: 570,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Collection Name',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 20 / 14)),
                    const SizedBox(height: 5),
                    LibraryTextFormControl(
                        controller: _name,
                        autofocus: true,
                        decoration: InputDecoration(errorText: _error),
                        onFieldSubmitted: (_) => _save()),
                    const SizedBox(height: 10),
                    const Text('Visibility',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 20 / 14)),
                    const SizedBox(height: 5),
                    Container(
                        height: 32,
                        color: appPalette(context).field,
                        alignment: Alignment.center,
                        child: const _CollectionPrivacyIndicator()),
                  ])),
          actions: [
            Container(
                width: double.infinity,
                color: appPalette(context).panelRaised,
                padding: const EdgeInsets.all(10),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  FilledButton(
                      style: pickListButtonStyle(context,
                          primary: false, footer: true),
                      onPressed:
                          _saving ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel')),
                  const SizedBox(width: 5),
                  FilledButton(
                      style: _collectionButtonStyle(context),
                      onPressed: _saving ? null : _save,
                      child: const Text('Save')),
                ])),
          ]);
}

class _CollectionPrivacyIndicator extends StatelessWidget {
  const _CollectionPrivacyIndicator();
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(AppIcons.coverIndicator, size: 12, color: const Color(0xffd43f3a)),
        const SizedBox(width: 5),
        Flexible(
            child: Text('Private',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: const Color(0xffd43f3a),
                    fontSize: 14,
                    fontWeight: FontWeight.w400))),
      ]);
}

class _CollectionRow extends StatefulWidget {
  const _CollectionRow(
      {super.key,
      required this.collection,
      required this.index,
      required this.itemLabel,
      required this.onRename,
      this.onDelete});
  final LibraryCollectionSummary collection;
  final int index;
  final String itemLabel;
  final VoidCallback onRename;
  final VoidCallback? onDelete;
  @override
  State<_CollectionRow> createState() => _CollectionRowState();
}

class _CollectionRowState extends State<_CollectionRow> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final border = palette.isDark ? const Color(0xff383838) : palette.divider;
    Widget cell(Widget child, {double? width, bool padded = true}) => Container(
          width: width,
          height: 37,
          padding: padded
              ? const EdgeInsets.symmetric(horizontal: 8)
              : EdgeInsets.zero,
          alignment: Alignment.centerLeft,
          decoration:
              BoxDecoration(border: Border(right: BorderSide(color: border))),
          child: child,
        );
    Widget action(IconData icon, String tooltip, VoidCallback? callback) =>
        cell(
            IconButton(
                tooltip: tooltip,
                onPressed: callback,
                icon: Icon(icon, size: 14),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints.tightFor(width: 30, height: 37),
                style: IconButton.styleFrom(
                    foregroundColor: palette.textPrimary,
                    hoverColor: palette.isDark
                        ? const Color(0x26ffffff)
                        : const Color(0x14000000),
                    shape: const RoundedRectangleBorder(),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
            width: 30,
            padded: false);
    return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Container(
          height: 37,
          decoration: BoxDecoration(
              color: _hovered
                  ? pickListToolbar(context)
                  : widget.index.isEven
                      ? (palette.isDark
                          ? const Color(0xff2d2d2d)
                          : palette.panelRaised)
                      : palette.panel,
              border: Border(
                  bottom: BorderSide(color: border),
                  left: BorderSide(color: border))),
          child: DefaultTextStyle(
              style: TextStyle(
                  fontFamily: appFontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                  color: palette.textPrimary),
              child: LayoutBuilder(builder: (context, constraints) {
                final compact = constraints.maxWidth < 480;
                return Row(children: [
                  cell(
                      ReorderableDragStartListener(
                          index: widget.index,
                          child: MouseRegion(
                              cursor: SystemMouseCursors.grab,
                              child: SizedBox(
                                  key: ValueKey(
                                      'collection-drag-${widget.collection.id}'),
                                  width: 30,
                                  height: 37,
                                  child: Icon(AppIcons.menu,
                                      size: 14, color: palette.textPrimary)))),
                      width: 30,
                      padded: false),
                  Expanded(
                      child: cell(Text(widget.collection.name,
                          maxLines: 1, overflow: TextOverflow.ellipsis))),
                  cell(
                      Text('${widget.collection.count} ${widget.itemLabel}',
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      width: compact ? 70 : 84),
                  cell(
                      compact
                          ? Tooltip(
                              message: 'Private',
                              child: Icon(AppIcons.coverIndicator,
                                  size: 12, color: const Color(0xffd43f3a)))
                          : const _CollectionPrivacyIndicator(),
                      width: compact ? 30 : 100),
                  action(AppIcons.inlineEdit, 'Rename collection',
                      widget.onRename),
                  action(
                      AppIcons.removeAction,
                      widget.onDelete == null
                          ? 'Keep at least one collection'
                          : 'Delete collection',
                      widget.onDelete),
                ]);
              })),
        ));
  }
}

ButtonStyle _collectionButtonStyle(BuildContext context) =>
    pickListButtonStyle(context, footer: true).copyWith(
      foregroundColor: const WidgetStatePropertyAll(Colors.white),
    );

/// Cuts the 1 px border lines off the right and bottom of a dragged row.
class _DragRowClipper extends CustomClipper<Rect> {
  const _DragRowClipper();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, 0, size.width - 1, size.height - 1);

  @override
  bool shouldReclip(_DragRowClipper oldClipper) => false;
}
