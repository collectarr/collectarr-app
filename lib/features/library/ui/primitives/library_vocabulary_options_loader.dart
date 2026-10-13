import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads persistent choices for both the inline menu and full list picker.
class LibraryVocabularyOptionsLoader extends ConsumerStatefulWidget {
  const LibraryVocabularyOptionsLoader(
      {super.key,
      required this.listName,
      required this.mediaKind,
      required this.builtIns,
      required this.selected,
      required this.builder});
  final String listName;
  final String mediaKind;
  final List<String> builtIns;
  final List<String> selected;
  final Widget Function(List<String> options) builder;
  @override
  ConsumerState<LibraryVocabularyOptionsLoader> createState() =>
      _LibraryVocabularyOptionsLoaderState();
}

class _LibraryVocabularyOptionsLoaderState
    extends ConsumerState<LibraryVocabularyOptionsLoader> {
  late Future<List<String>> _options;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _options = loadMultiValuePickListOptions(ref.read(localDatabaseProvider),
        listName: widget.listName,
        mediaKind: widget.mediaKind,
        builtInValues: widget.builtIns,
        selectedValues: widget.selected);
  }

  @override
  void didUpdateWidget(LibraryVocabularyOptionsLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listName != widget.listName ||
        oldWidget.mediaKind != widget.mediaKind ||
        !listEquals(oldWidget.builtIns, widget.builtIns) ||
        !listEquals(oldWidget.selected, widget.selected)) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<String>>(
        future: _options,
        builder: (context, snapshot) =>
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          widget.builder(mergePickListValues(
              builtInValues: snapshot.hasData ? const [] : widget.builtIns,
              customValues: snapshot.data ?? const [],
              selectedValues: widget.selected)),
          if (snapshot.hasError)
            TextButton.icon(
                onPressed: () => setState(_load),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Could not load saved choices. Retry')),
        ]),
      );
}
