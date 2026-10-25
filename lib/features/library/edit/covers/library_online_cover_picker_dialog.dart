import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/features/library/ui/library_metrics.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// One online cover result: the item it belongs to and the image to fetch.
final class LibraryOnlineCoverCandidate {
  const LibraryOnlineCoverCandidate(
      {required this.title, required this.subtitle, required this.imageUrl});
  final String title;
  final String subtitle;
  final String imageUrl;
}

/// Kind-owned online cover search; [barcode] is set when the barcode token is
/// still part of the query.
typedef LibraryOnlineCoverSearch = Future<List<LibraryOnlineCoverCandidate>>
    Function(String query, {String? barcode});

final class LibraryOnlineCoverPickerDialog extends StatefulWidget {
  const LibraryOnlineCoverPickerDialog(
      {super.key,
      required this.search,
      required this.hint,
      this.tokens = const [],
      this.barcode = ''});

  /// Search terms offered as checkboxes and joined into the first query.
  final List<String> tokens;
  final String barcode;
  final LibraryOnlineCoverSearch search;

  /// What can be searched, e.g. "Album title, artist or barcode".
  final String hint;
  @override
  State<LibraryOnlineCoverPickerDialog> createState() =>
      _LibraryOnlineCoverPickerDialogState();
}

final class _LibraryOnlineCoverPickerDialogState
    extends State<LibraryOnlineCoverPickerDialog> {
  late final TextEditingController _queryController;
  late final Map<String, bool> _tokens = {
    for (final text in [...widget.tokens, widget.barcode])
      if (text.trim().isNotEmpty) text.trim(): true
  };
  List<LibraryOnlineCoverCandidate> _candidates = const [];
  String? _error;
  bool _loading = false;
  bool _hasSearched = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: _tokenQuery);
    if (_tokenQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _searchOnline());
    }
  }

  String get _tokenQuery => _tokens.entries
      .where((token) => token.value)
      .map((token) => token.key)
      .join(' ');
  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _searchOnline() async {
    final query = _queryController.text.trim();
    final request = ++_request;
    setState(() {
      _loading = query.isNotEmpty;
      _hasSearched = true;
      _error = query.isEmpty ? 'Enter ${widget.hint.toLowerCase()}.' : null;
      _candidates = const [];
    });
    if (query.isEmpty) return;
    try {
      final candidates = await widget.search(query,
          barcode:
              _tokens[widget.barcode.trim()] == true && query == _tokenQuery
                  ? widget.barcode.trim()
                  : null);
      if (!mounted || request != _request) return;
      setState(() => _candidates = candidates);
    } catch (_) {
      if (!mounted || request != _request) return;
      setState(() => _error =
          'Online cover search failed. Check your connection and retry.');
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final viewport = MediaQuery.sizeOf(context);
    final width = (viewport.width - 32).clamp(240.0, 1152.0).toDouble();
    final height = (viewport.height - 64).clamp(240.0, 600.0).toDouble();
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.fromLTRB(16, kAppDialogTopInset, 16, 24),
      child: SizedBox(
          width: width,
          height: height,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            AccentDialogHeader(
                title: 'Find Cover',
                icon: AppIcons.tabImages,
                onClose: () => Navigator.of(context).pop()),
            Padding(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 8),
                child: Row(children: [
                  Expanded(
                      child: TextField(
                          controller: _queryController,
                          autofocus: true,
                          style: context.libraryTextTheme.controlText,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                              hintText: widget.hint,
                              isDense: true,
                              constraints: BoxConstraints(
                                  minHeight: LibraryMetrics.defaultFieldHeight),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 7)),
                          onSubmitted: (_) => _searchOnline())),
                  const SizedBox(width: 16),
                  SizedBox(
                      width: width > 600 ? 258 : 90,
                      height: 34,
                      child: FilledButton(
                          onPressed: _loading ? null : _searchOnline,
                          child: const Text('Search'))),
                ])),
            if (_tokens.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                  child: Wrap(children: [
                    for (final token in _tokens.entries)
                      InkWell(
                          onTap: () => _toggle(token.key, !token.value),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            SizedBox(
                                width: 22,
                                height: 24,
                                child: Checkbox(
                                    value: token.value,
                                    onChanged: (value) =>
                                        _toggle(token.key, value ?? false),
                                    visualDensity: VisualDensity.compact)),
                            Text(token.key,
                                style: context.libraryTextTheme.metadataLabel),
                            const SizedBox(width: 10),
                          ])),
                  ])),
            Expanded(
                child: ColoredBox(
                    color: palette.surfaceBright,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(
                                child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(_error!,
                                        textAlign: TextAlign.center)))
                            : _candidates.isEmpty
                                ? Center(
                                    child: Text(_hasSearched
                                        ? 'No online covers found.'
                                        : 'Search by ${widget.hint.toLowerCase()}.'))
                                : GridView.builder(
                                    padding: const EdgeInsets.all(13),
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 127,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 10,
                                            mainAxisExtent: 138),
                                    itemCount: _candidates.length,
                                    itemBuilder: (_, index) => _OnlineCoverTile(
                                        candidate: _candidates[index],
                                        onSelected: () => Navigator.of(context)
                                            .pop(_candidates[index])),
                                  ))),
          ])),
    );
  }

  void _toggle(String token, bool selected) {
    setState(() => _tokens[token] = selected);
    _queryController.text = _tokenQuery;
  }
}

final class _OnlineCoverTile extends StatefulWidget {
  const _OnlineCoverTile({required this.candidate, required this.onSelected});
  final LibraryOnlineCoverCandidate candidate;
  final VoidCallback onSelected;
  @override
  State<_OnlineCoverTile> createState() => _OnlineCoverTileState();
}

final class _OnlineCoverTileState extends State<_OnlineCoverTile> {
  ImageStream? _stream;
  late final ImageStreamListener _listener = ImageStreamListener((info, _) {
    if (mounted) {
      setState(
          () => _dimensions = '${info.image.width} × ${info.image.height}');
    }
  }, onError: (_, __) {
    if (mounted) setState(() => _dimensions = 'Unavailable');
  });
  String _dimensions = 'Loading…';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stream = NetworkImage(widget.candidate.imageUrl)
        .resolve(createLocalImageConfiguration(context));
    if (_stream?.key == stream.key) return;
    _stream?.removeListener(_listener);
    _stream = stream;
    stream.addListener(_listener);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Tooltip(
      message: '${widget.candidate.title}\n${widget.candidate.subtitle}',
      child: Material(
        color: appPalette(context).panelRaised,
        child: InkWell(
            onTap: _dimensions == 'Unavailable' ? null : widget.onSelected,
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  Expanded(
                      child: Image.network(widget.candidate.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image_outlined))),
                  const SizedBox(height: 8),
                  Text(_dimensions,
                      style: context.libraryTextTheme.supportingText,
                      maxLines: 1),
                ]))),
      ));
}
