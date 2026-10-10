import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryLinkItemsPage extends ConsumerStatefulWidget {
  const LibraryLinkItemsPage(
      {super.key, required this.type, required this.entries});
  final LibraryKindRegistration type;
  final List<LibraryWorkspaceContext> entries;
  @override
  ConsumerState<LibraryLinkItemsPage> createState() =>
      _LibraryLinkItemsPageState();
}

class _LibraryLinkItemsPageState extends ConsumerState<LibraryLinkItemsPage> {
  final _linked = <String>{};
  LibraryWorkspaceContext? _selected;
  List<CatalogSearchCandidate> _matches = [];
  bool _busy = false;
  String? _error;

  List<LibraryWorkspaceContext> get _unlinked => widget.entries
      .where((entry) =>
          entry.libraryEntryRef != null &&
          entry.libraryEntrySummary?.sourceCatalogRef == null &&
          !_linked.contains(entry.libraryEntryRef!.key))
      .toList();

  Future<void> _find(LibraryWorkspaceContext entry) async {
    setState(() {
      _selected = entry;
      _busy = true;
      _error = null;
      _matches = [];
    });
    try {
      final query = libraryMetadataForKind(widget.type.kind)
          .searchQueryFor(source: entry, title: entry.title);
      final result = await searchLibraryMetadata(
          ref.read(apiClientProvider), widget.type.kind,
          query: query.query,
          barcode: query.barcode,
          series: query.series,
          issueNumber: query.issueNumber,
          publisher: query.publisher,
          year: query.year,
          limit: 30);
      if (mounted) {
        setState(() => _matches =
            result.where((candidate) => candidate.catalogRef != null).toList());
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not find catalog matches: $error');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _link(CatalogSearchCandidate candidate) async {
    final entry = _selected?.libraryEntryRef;
    final catalog = candidate.catalogRef;
    if (entry == null || catalog == null || _busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(libraryEntryMutationsProvider).linkToCore(entry, catalog);
      if (mounted) {
        setState(() {
          _linked.add(entry.key);
          _selected = null;
          _matches = [];
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not link item: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
        data:
            libraryAccentTheme(context, libraryAccentForKind(widget.type.kind)),
        child: Scaffold(
          appBar:
              AppBar(title: Text('Link ${widget.type.identity.pluralLabel}')),
          body: LayoutBuilder(builder: (context, constraints) {
            final entries = _unlinked;
            final list = ListView(children: [
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('${entries.length} unlinked items')),
              for (final entry in entries)
                ListTile(
                    title: Text(entry.title),
                    selected: _selected == entry,
                    selectedColor: libraryAccentForKind(widget.type.kind),
                    trailing: const Icon(Icons.search),
                    onTap: _busy ? null : () => _find(entry)),
              if (entries.isEmpty)
                const ListTile(title: Text('All entries are linked.')),
            ]);
            final preview =
                ListView(padding: const EdgeInsets.all(16), children: [
              const Text(
                  'Choose a matching catalog item to attach Core provenance.'),
              const SizedBox(height: 8),
              const Text(
                  'Your local metadata and personal data are preserved.'),
              if (_selected != null)
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(_selected!.title)),
              if (_busy) const LinearProgressIndicator(),
              if (_error != null) Text(_error!),
              if (!_busy &&
                  _selected != null &&
                  _matches.isEmpty &&
                  _error == null)
                const Text('No matching catalog items found.'),
              for (final match in _matches)
                Card(
                    child: ListTile(
                        title: Text(match.summary.primaryLabel),
                        subtitle: Text(match.catalogRef!.key),
                        trailing: FilledButton(
                            onPressed: _busy ? null : () => _link(match),
                            child: const Text('Link')))),
            ]);
            return constraints.maxWidth >= 700
                ? Row(children: [
                    Expanded(child: list),
                    const VerticalDivider(width: 1),
                    Expanded(child: preview)
                  ])
                : Column(children: [
                    Expanded(child: list),
                    const Divider(height: 1),
                    Expanded(child: preview)
                  ]);
          }),
        ),
      );
}
