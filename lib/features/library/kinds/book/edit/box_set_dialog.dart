import 'dart:typed_data';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/utils/sort_title.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/features/pick_lists/list_value_images.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_chrome.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/app_page_tabs.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// The books of the box set [name], in the set's order: by their place in
/// the set, then by year and title.
List<BookLibraryEntry> bookBoxSetMembers(
    Iterable<BookLibraryEntry> books, String name) {
  int year(BookLibraryEntry book) =>
      book.metadata.releaseDateParts?.year ??
      book.metadata.releaseDate?.year ??
      0;
  return [
    for (final book in books)
      if (book.metadata.boxSet == name) book,
  ]..sort((a, b) {
      final byPlace = (a.personal.details.boxSetPosition ?? 1 << 30)
          .compareTo(b.personal.details.boxSetPosition ?? 1 << 30);
      if (byPlace != 0) return byPlace;
      final byYear = year(a).compareTo(year(b));
      return byYear != 0
          ? byYear
          : a.metadata.title.compareTo(b.metadata.title);
    });
}

/// Opens the reference's Edit Box Set dialog for [name]: its Details (Name,
/// Sort Name, Barcode and Release Date), the order of its Books and its
/// Cover. Returns the set's name after saving, null when cancelled.
Future<String?> showBookBoxSetDialog({
  required BuildContext context,
  required LocalDatabase db,
  required String name,
}) =>
    showAppDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BookBoxSetDialog(db: db, name: name),
    );

class _BookBoxSetDialog extends StatefulWidget {
  const _BookBoxSetDialog({required this.db, required this.name});

  final LocalDatabase db;
  final String name;

  @override
  State<_BookBoxSetDialog> createState() => _BookBoxSetDialogState();
}

class _BookBoxSetDialogState extends State<_BookBoxSetDialog> {
  static final _list = BookVocabularyIds.boxSet.value;

  late final _name = TextEditingController(text: widget.name);
  final _sortName = TextEditingController();
  final _barcode = TextEditingController();
  late String _lastName = widget.name;
  PartialDate? _releaseDate;
  List<BookLibraryEntry> _books = const [];
  PickListValue? _value;
  Uint8List? _cover;
  bool _coverChanged = false;
  String? _error;
  int _tab = 0;
  bool _loading = true;
  bool _saving = false;

  ListValueImages get _images => ListValueImages(widget.db);

  @override
  void initState() {
    super.initState();
    _name.addListener(_followName);
    _load();
  }

  Future<void> _load() async {
    final books = bookBoxSetMembers(
        await BookEntryRepository(widget.db).listActive(), widget.name);
    final values = await PickListRepository(widget.db)
        .valuesForList(listName: _list, mediaKind: 'book', includeHidden: true);
    final value = values
        .where((value) =>
            value.effectiveNormalizedValue ==
            normalizePickListValue(widget.name))
        .firstOrNull;
    final cover = await _images.watch(_list, widget.name).first;
    if (!mounted) return;
    final details = books
        .map((book) => book.personal.details)
        .where((details) =>
            details.boxSetBarcode != null || details.boxSetReleaseDate != null)
        .firstOrNull;
    setState(() {
      _books = books;
      _value = value;
      _cover = cover;
      _sortName.text = value?.sortName ?? widget.name;
      _barcode.text = details?.boxSetBarcode ?? '';
      _releaseDate = details?.boxSetReleaseDate;
      _loading = false;
    });
  }

  /// The Sort Name follows the Name until someone types one of their own.
  void _followName() {
    final name = _name.text;
    if (name == _lastName) return;
    final sortName =
        followTitleChange(_lastName.trim(), name.trim(), _sortName.text.trim());
    _lastName = name;
    if (sortName != _sortName.text.trim()) _sortName.text = sortName;
  }

  @override
  void dispose() {
    _name.dispose();
    _sortName.dispose();
    _barcode.dispose();
    super.dispose();
  }

  Future<void> _chooseCover() async {
    final file = await openFile(acceptedTypeGroups: listValueImageFileTypes);
    if (file == null) return;
    try {
      final bytes = await file.readAsBytes();
      await validateListValueImage(bytes);
      if (!mounted) return;
      setState(() {
        _cover = bytes;
        _coverChanged = true;
        _error = null;
      });
    } on FormatException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() {
        _tab = 0;
        _error = 'Enter a name.';
      });
      return;
    }
    setState(() => _saving = true);
    final sortName = _sortName.text.trim();
    final barcode = _barcode.text.trim();
    final renamed = name != widget.name;
    await PickListRepository(widget.db).upsertValue(PickListValue(
      id: _value?.id ?? const Uuid().v4(),
      listName: _list,
      mediaKind: 'book',
      value: name,
      sortName: sortName.isEmpty || sortName == name ? null : sortName,
      sortOrder: _value?.sortOrder ?? 0,
    ));
    final now = DateTime.now().toUtc();
    await BookEntryRepository(widget.db).upsertAll([
      for (final (index, book) in _books.indexed)
        book.copyWith(
          updatedAt: now,
          metadata: renamed ? book.metadata.copyWith(boxSet: name) : null,
          personal: book.personal.copyWith(
            details: book.personal.details.copyWith(
              boxSetPosition: index + 1,
              boxSetBarcode: barcode.isEmpty ? null : barcode,
              boxSetReleaseDate: _releaseDate == null || _releaseDate!.isEmpty
                  ? null
                  : _releaseDate,
            ),
          ),
        ),
    ]);
    if (renamed || _coverChanged) {
      if (renamed || _cover == null) await _images.remove(_list, widget.name);
      if (_cover case final cover?) await _images.save(_list, name, cover);
    }
    if (mounted) Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Dialog(
      insetPadding: const EdgeInsets.fromLTRB(16, kAppDialogTopInset, 16, 24),
      alignment: kDefaultDialogAlignment,
      backgroundColor: pickListSurface(context),
      shape: appDialogShape,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: MediaQuery.sizeOf(context).height - 48,
        ),
        child: Material(
          color: pickListSurface(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PickListHeader(
                  title: 'Edit Box Set',
                  icon: AppIcons.book,
                  onClose: () => Navigator.of(context).pop()),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: AppPageTabs(
                  tabs: const [
                    AppPageTab(label: 'Details'),
                    AppPageTab(label: 'Books'),
                    AppPageTab(label: 'Cover'),
                  ],
                  selectedIndex: _tab,
                  onSelected: (index) => setState(() => _tab = index),
                ),
              ),
              Divider(height: 1, color: palette.divider),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: _loading
                      ? const SizedBox(height: 120)
                      : switch (_tab) {
                          0 => _details(),
                          1 => _booksTab(palette),
                          _ => _coverTab(palette),
                        },
                ),
              ),
              if (_error case final error?)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(error,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
              Divider(height: 1, color: palette.divider),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  FilledButton(
                    style: pickListButtonStyle(context,
                        primary: false, footer: true),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 5),
                  FilledButton(
                    style: pickListButtonStyle(context, footer: true),
                    onPressed: _loading || _saving ? null : _save,
                    child: const Text('Save'),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _details() {
    Widget pair(Widget left, Widget right) =>
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: left),
          const SizedBox(width: 30),
          Expanded(child: right),
        ]);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      pair(
        LibraryFormField(
            label: 'Name',
            child: LibraryTextFormControl(controller: _name, autofocus: true)),
        LibraryFormField(
          label: 'Sort Name',
          action: InkWell(
            onTap: () => setState(() =>
                _sortName.text = followTitleChange('', _name.text.trim(), '')),
            child: Text('Generate',
                style:
                    TextStyle(fontSize: 13, color: appPalette(context).link)),
          ),
          child: LibraryTextFormControl(controller: _sortName),
        ),
      ),
      const SizedBox(height: 12),
      pair(
        LibraryFormField(
            label: 'Barcode',
            child: LibraryTextFormControl(controller: _barcode)),
        LibraryPartialDateField(
          label: 'Release Date',
          value: _releaseDate,
          onChanged: (value) => setState(() => _releaseDate = value),
        ),
      ),
    ]);
  }

  Widget _booksTab(AppThemePalette palette) {
    if (_books.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text('No books are in this box set yet.',
            style: TextStyle(color: palette.textMuted)),
      );
    }
    void move(int index, int delta) => setState(() {
          final books = List.of(_books);
          final book = books.removeAt(index);
          books.insert(index + delta, book);
          _books = books;
        });
    return Column(children: [
      for (final (index, book) in _books.indexed)
        Container(
          key: ValueKey(book.id.value),
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          color: pickListRow(context, index),
          child: Row(children: [
            SizedBox(width: 28, child: Text('${index + 1}')),
            Expanded(
              child: Text(book.metadata.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            IconButton(
              tooltip: 'Move up',
              visualDensity: VisualDensity.compact,
              iconSize: 14,
              onPressed: index == 0 ? null : () => move(index, -1),
              icon: const Icon(AppIcons.caretUp),
            ),
            IconButton(
              tooltip: 'Move down',
              visualDensity: VisualDensity.compact,
              iconSize: 14,
              onPressed:
                  index == _books.length - 1 ? null : () => move(index, 1),
              icon: const Icon(AppIcons.caretDown),
            ),
          ]),
        ),
    ]);
  }

  Widget _coverTab(AppThemePalette palette) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          FilledButton(
            style: pickListButtonStyle(context, primary: false),
            onPressed: _chooseCover,
            child: const Text('Upload'),
          ),
          const SizedBox(width: 5),
          FilledButton(
            style: pickListButtonStyle(context, primary: false),
            onPressed: _cover == null
                ? null
                : () => setState(() {
                      _cover = null;
                      _coverChanged = true;
                    }),
            child: const Text('Remove'),
          ),
        ]),
        const SizedBox(height: 10),
        Container(
          width: 210,
          height: 315,
          alignment: Alignment.center,
          decoration: BoxDecoration(border: Border.all(color: palette.divider)),
          child: switch (_cover) {
            final cover? => ListValueImageView(cover),
            null => Icon(AppIcons.book, size: 48, color: palette.textMuted),
          },
        ),
      ]);
}
