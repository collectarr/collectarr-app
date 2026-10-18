import 'package:collectarr_app/ui/app_management_page_scaffold.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/app_progress_dialog.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'library_link_match.dart';
import 'library_link_candidate_dialog.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';

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
  final _matches = <String, LibraryLinkMatch>{};
  final _failures = <String, String>{};
  bool _busy = false;
  int _progress = 0;
  int _total = 0;
  String? _error;

  List<LibraryWorkspaceContext> get _unlinked => widget.entries
      .where((entry) =>
          entry.libraryEntryRef != null &&
          entry.sourceCatalogRef == null &&
          !_linked.contains(entry.libraryEntryRef!.key))
      .toList();

  Future<List<CatalogSearchCandidate>> _search(LibraryWorkspaceContext entry,
      {String? text}) async {
    final query = libraryMetadataForKind(widget.type.kind)
        .searchQueryFor(source: entry, title: text ?? entry.title);
    final results = await searchLibraryMetadata(
        ref.read(apiClientProvider), widget.type.kind,
        query: text ?? query.query,
        barcode: text == null ? query.barcode : null,
        series: text == null ? query.series : null,
        issueNumber: text == null ? query.issueNumber : null,
        publisher: text == null ? query.publisher : null,
        year: text == null ? query.year : null,
        limit: 30);
    return results.where((candidate) => candidate.catalogRef != null).toList();
  }

  Future<void> _findAll() async {
    if (_busy) return;
    final entries = _unlinked;
    setState(() {
      _busy = true;
      _error = null;
      _progress = 0;
      _total = entries.length;
      _failures.clear();
    });
    final capability = libraryMetadataForKind(widget.type.kind);
    for (final entry in entries) {
      if (!mounted) return;
      final key = entry.libraryEntryRef!.key;
      try {
        final results = await _search(entry);
        if (!mounted) return;
        _matches[key] =
            LibraryLinkMatch.rank(entry, results, capability.matchScorer);
      } catch (error) {
        if (!mounted) return;
        _matches.remove(key);
        _failures[key] = 'Could not find matches: $error';
      }
      setState(() => _progress++);
    }
    if (mounted) {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<bool> _linkEntry(
      LibraryWorkspaceContext entry, CatalogSearchCandidate candidate) async {
    try {
      await ref
          .read(libraryEntryMutationsProvider)
          .linkToCore(entry.libraryEntryRef!, candidate.catalogRef!);
      if (mounted) {
        setState(() {
          _linked.add(entry.libraryEntryRef!.key);
          _matches.remove(entry.libraryEntryRef!.key);
        });
      }
      return true;
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not link ${entry.title}: $error');
      }
      return false;
    }
  }

  Future<void> _accept(
      LibraryWorkspaceContext entry, CatalogSearchCandidate candidate) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _total = 0;
      _error = null;
    });
    await _linkEntry(entry, candidate);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _linkHighMatches() async {
    if (_busy) return;
    final entries = _unlinked
        .where((entry) =>
            _matches[entry.libraryEntryRef!.key]?.canBulkLink ?? false)
        .toList();
    setState(() {
      _busy = true;
      _total = 0;
      _error = null;
    });
    for (final entry in entries) {
      if (!mounted) return;
      if (!await _linkEntry(
          entry, _matches[entry.libraryEntryRef!.key]!.candidate!)) {
        break;
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _manual(LibraryWorkspaceContext entry) async {
    if (_busy) return;
    final candidate = await showAppDialog<CatalogSearchCandidate>(
        context: context,
        builder: (_) => LibraryLinkCandidateDialog(
            title: entry.title, search: (text) => _search(entry, text: text)));
    if (candidate != null && mounted) await _accept(entry, candidate);
  }

  @override
  Widget build(BuildContext context) => Theme(
      data: libraryAccentTheme(context, libraryAccentForKind(widget.type.kind)),
      child: Builder(builder: (context) {
        final entries = _unlinked;
        final palette = appPalette(context);
        final highCount = entries
            .where((entry) =>
                _matches[entry.libraryEntryRef!.key]?.canBulkLink ?? false)
            .length;
        final plural = widget.type.identity.pluralLabel;
        return AppManagementPageScaffold(
            icon: AppIcons.link,
            title: 'Link $plural',
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                child: Center(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 20),
                              Text('Find matches & link $plural',
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1)),
                              const SizedBox(height: 10),
                              _header(context, entries, highCount, plural),
                              if (_error != null)
                                Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(_error!,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error))),
                              const SizedBox(height: 20),
                              LayoutBuilder(builder: (context, constraints) {
                                final width = constraints.maxWidth < 680
                                    ? 680.0
                                    : constraints.maxWidth;
                                return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                        width: width,
                                        child: Table(
                                            columnWidths: const {
                                              0: FlexColumnWidth(43),
                                              1: FlexColumnWidth(42),
                                              2: FlexColumnWidth(15)
                                            },
                                            border: TableBorder.all(
                                                color: palette.isDark
                                                    ? const Color(0xff383838)
                                                    : palette.divider),
                                            defaultVerticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            children: [
                                              TableRow(
                                                  decoration: BoxDecoration(
                                                      color: palette.isDark
                                                          ? const Color(
                                                              0xff464950)
                                                          : palette
                                                              .panelRaised),
                                                  children: [
                                                    _cell(Text(
                                                        'Your ${widget.type.identity.singularLabel}',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700))),
                                                    _cell(const Text(
                                                        'Core result',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700))),
                                                    _cell(const Text('Link',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700))),
                                                  ]),
                                              for (final entry in entries)
                                                _row(context, entry),
                                              if (entries.isEmpty)
                                                const TableRow(children: [
                                                  _EmptyCell(),
                                                  SizedBox(),
                                                  SizedBox()
                                                ]),
                                            ])));
                              }),
                            ])))));
      }));

  /// The tinted box with the match progress bar, counts and bulk link button.
  Widget _header(BuildContext context, List<LibraryWorkspaceContext> entries,
      int highCount, String plural) {
    final palette = appPalette(context);
    final singular = widget.type.identity.singularLabel.toLowerCase();
    final lowerPlural = plural.toLowerCase();
    int count(LibraryMetadataMatchScore score) => entries
        .where((entry) => _matches[entry.libraryEntryRef!.key]?.score == score)
        .length;
    return Container(
      color: palette.isDark ? const Color(0xff464950) : palette.panelRaised,
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Expanded(
              child: AppStripedProgressBar(
                height: 32,
                animate: _busy,
                value: _busy && _total > 0 ? _progress / _total : 0,
                child: const Text('Automatch barcodes & find matches',
                    style: TextStyle(
                        color: Color(0xff333333),
                        fontSize: 12,
                        fontWeight: FontWeight.w400)),
              ),
            ),
            SizedBox(
              width: 110,
              height: 32,
              child: FilledButton(
                  style: dialogActionButtonStyle(context, primary: true)
                      .copyWith(
                          shape: const WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(4))))),
                  onPressed: _busy || entries.isEmpty ? null : _findAll,
                  child: const Text('Find matches')),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: LayoutBuilder(builder: (context, box) {
            final scores = Wrap(
                spacing: 3,
                runSpacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    decoration: BoxDecoration(
                        color: const Color(0xffcccccc),
                        borderRadius: BorderRadius.circular(4)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 3),
                          decoration: BoxDecoration(
                              color: const Color(0xff333333),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text('${entries.length}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12))),
                      const SizedBox(width: 5),
                      Text(
                          'unlinked ${entries.length == 1 ? singular : lowerPlural}',
                          style: const TextStyle(
                              color: Color(0xff444444), fontSize: 14)),
                    ]),
                  ),
                  const SizedBox(width: 27),
                  const Text('Match-score:'),
                  for (final score in LibraryMetadataMatchScore.values)
                    _scoreBadge(score, count(score)),
                ]);
            final bulk = SizedBox(
              height: 32,
              child: FilledButton(
                  style: dialogActionButtonStyle(context,
                      primary: true, width: 0, color: const Color(0xff5cb85c)),
                  onPressed: !_busy && highCount > 0 ? _linkHighMatches : null,
                  child: Text(
                      'Link $highCount ${highCount == 1 ? singular : lowerPlural} with high match-score')),
            );
            return box.maxWidth >= 700
                ? Row(children: [
                    Expanded(child: scores),
                    const SizedBox(width: 10),
                    bulk,
                  ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [scores, const SizedBox(height: 5), bulk]);
          }),
        ),
      ]),
    );
  }

  Widget _cell(Widget child) =>
      Padding(padding: const EdgeInsets.all(8), child: child);

  TableRow _row(BuildContext context, LibraryWorkspaceContext entry) {
    final key = entry.libraryEntryRef!.key;
    final match = _matches[key];
    final candidate = match?.candidate;
    final projection = LibraryProjectionItem.fromShelf(entry, widget.type);
    final local = projection.dto;
    final card = libraryCardPresentationForEntry(projection);
    return TableRow(children: [
      _cell(LinkItemSummary(
          title: entry.title,
          subtitle: card.seriesTitle ?? local.secondaryLabel,
          imageUrl: local.imageUrl,
          imageSize: 92)),
      _cell(candidate == null
          ? Text(_failures[key] ??
              (_matches.containsKey(key)
                  ? 'No matching catalog items found.'
                  : '-\n-'))
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              LinkItemSummary(
                  title: candidate.summary.primaryLabel,
                  subtitle: candidate.summary.subtitle,
                  imageUrl: candidate.summary.imageUrl,
                  imageSize: 92),
              const SizedBox(height: 5),
              _scoreBadge(match!.score!, null),
            ])),
      _cell(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (candidate != null) ...[
          FilledButton(
              style: dialogActionButtonStyle(context,
                  primary: true,
                  width: 0,
                  color: match!.canBulkLink
                      ? const Color(0xff5cb85c)
                      : const Color(0xfff0ad4e)),
              onPressed: _busy ? null : () => _accept(entry, candidate),
              child: const Text('Accept')),
          const SizedBox(height: 5),
        ],
        FilledButton(
            style: dialogActionButtonStyle(context, primary: true, width: 0),
            onPressed: _busy ? null : () => _manual(entry),
            child: const Text('Link manually')),
      ])),
    ]);
  }

  Widget _scoreBadge(LibraryMetadataMatchScore score, int? count) => Container(
      padding: const EdgeInsets.fromLTRB(8.4, 2.8, 8.4, 4.2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.5),
          color: switch (score) {
            LibraryMetadataMatchScore.high => const Color(0xff5cb85c),
            LibraryMetadataMatchScore.medium => const Color(0xfff0ad4e),
            LibraryMetadataMatchScore.low => const Color(0xffd9534f),
          }),
      child: Text(
          count == null ? '${score.name} match-score' : '$count ${score.name}',
          style: const TextStyle(color: Colors.white, fontSize: 14)));
}

class _EmptyCell extends StatelessWidget {
  const _EmptyCell();
  @override
  Widget build(BuildContext context) => const Padding(
      padding: EdgeInsets.all(16), child: Text('All entries are linked.'));
}
