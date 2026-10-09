import 'package:collectarr_app/features/library/kinds/music/edit/music_online_cover_search.dart';
import 'package:flutter/material.dart';

final class MusicOnlineCoverPickerDialog extends StatefulWidget {
  const MusicOnlineCoverPickerDialog({
    super.key,
    required this.initialQuery,
  });

  final String initialQuery;

  @override
  State<MusicOnlineCoverPickerDialog> createState() =>
      _MusicOnlineCoverPickerDialogState();
}

final class _MusicOnlineCoverPickerDialogState
    extends State<MusicOnlineCoverPickerDialog> {
  final _search = MusicOnlineCoverSearch();
  late final TextEditingController _queryController;
  List<MusicOnlineCoverCandidate> _candidates = const [];
  String? _error;
  bool _loading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _searchOnline());
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _searchOnline() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _hasSearched = true;
        _candidates = const [];
        _error = 'Enter an album title or artist to search.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _hasSearched = true;
      _error = null;
      _candidates = const [];
    });
    try {
      final candidates = await _search.search(query);
      if (!mounted) return;
      setState(() => _candidates = candidates);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Online cover search failed. Check your connection and retry.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    final viewport = MediaQuery.sizeOf(context);
    final contentWidth = (viewport.width - 24).clamp(240.0, 760.0).toDouble();
    final contentHeight = (viewport.height - 24).clamp(260.0, 540.0).toDouble();
    final columnCount = (contentWidth / 142).floor().clamp(1, 5).toInt();
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: SizedBox(
        width: contentWidth,
        height: contentHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 15, 12, 12),
              child: Row(
                children: [
                  Icon(Icons.image_search_outlined, color: palette.primary),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Find Online Cover',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchOnline(),
                      decoration: const InputDecoration(
                        hintText: 'Album title or artist',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _loading ? null : _searchOnline,
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Search'),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _candidates.isEmpty
                          ? Center(
                              child: Text(
                                _hasSearched
                                    ? 'No online covers found.'
                                    : 'Search by album title or artist.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(14),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columnCount,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.72,
                              ),
                              itemCount: _candidates.length,
                              itemBuilder: (context, index) =>
                                  _MusicOnlineCoverTile(
                                candidate: _candidates[index],
                                onSelected: () => Navigator.of(context)
                                    .pop(_candidates[index]),
                              ),
                            ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 16, 10),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _MusicOnlineCoverTile extends StatelessWidget {
  const _MusicOnlineCoverTile({
    required this.candidate,
    required this.onSelected,
  });

  final MusicOnlineCoverCandidate candidate;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: '${candidate.title}\n${candidate.artist}',
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        child: InkWell(
          onTap: onSelected,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    candidate.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_outlined, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  candidate.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  candidate.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
