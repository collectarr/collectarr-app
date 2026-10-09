import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_online_cover_search.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

final class MusicOnlineCoverPickerDialog extends StatefulWidget {
  const MusicOnlineCoverPickerDialog(
      {super.key,
      this.artist = '',
      this.title = '',
      this.barcode = '',
      this.search});
  final String artist;
  final String title;
  final String barcode;
  final MusicOnlineCoverSearch? search;
  @override
  State<MusicOnlineCoverPickerDialog> createState() =>
      _MusicOnlineCoverPickerDialogState();
}

final class _MusicOnlineCoverPickerDialogState
    extends State<MusicOnlineCoverPickerDialog> {
  late final _search = widget.search ?? MusicOnlineCoverSearch();
  late final TextEditingController _queryController;
  late final Map<String, bool> _tokens = {
    for (final text in [widget.artist, widget.title, widget.barcode])
      if (text.trim().isNotEmpty) text.trim(): true
  };
  List<MusicOnlineCoverCandidate> _candidates = const [];
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
      _error =
          query.isEmpty ? 'Enter an album title, artist or barcode.' : null;
      _candidates = const [];
    });
    if (query.isEmpty) return;
    try {
      final candidates = await _search.search(query,
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
    final accent = Theme.of(context).colorScheme.primary;
    final viewport = MediaQuery.sizeOf(context);
    final width = (viewport.width - 32).clamp(240.0, 1152.0).toDouble();
    final height = (viewport.height - 64).clamp(240.0, 600.0).toDouble();
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: SizedBox(
          width: width,
          height: height,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
                color: accent,
                height: 38,
                padding: const EdgeInsets.only(left: 15, right: 6),
                child: Row(children: [
                  Expanded(
                      child: Text('Find Cover',
                          style: context.libraryTextTheme.panelTitle.copyWith(
                              fontSize: 18,
                              color: appContrastingTextColor(accent)))),
                  IconButton(
                      tooltip: 'Close',
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close,
                          size: 18,
                          color: appContrastingTextColor(palette.accent))),
                ])),
            Padding(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 8),
                child: Row(children: [
                  Expanded(
                      child: TextField(
                          controller: _queryController,
                          autofocus: true,
                          style: context.libraryTextTheme.controlText,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                              hintText: 'Album title, artist or barcode',
                              isDense: true,
                              constraints: BoxConstraints(
                                  minHeight: kLibraryFormControlHeight),
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
                                        : 'Search by album title, artist or barcode.'))
                                : GridView.builder(
                                    padding: const EdgeInsets.all(13),
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 127,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 10,
                                            mainAxisExtent: 138),
                                    itemCount: _candidates.length,
                                    itemBuilder: (_, index) =>
                                        _MusicOnlineCoverTile(
                                            candidate: _candidates[index],
                                            onSelected: () =>
                                                Navigator.of(context)
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

final class _MusicOnlineCoverTile extends StatefulWidget {
  const _MusicOnlineCoverTile(
      {required this.candidate, required this.onSelected});
  final MusicOnlineCoverCandidate candidate;
  final VoidCallback onSelected;
  @override
  State<_MusicOnlineCoverTile> createState() => _MusicOnlineCoverTileState();
}

final class _MusicOnlineCoverTileState extends State<_MusicOnlineCoverTile> {
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
      message: '${widget.candidate.title}\n${widget.candidate.artist}',
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
