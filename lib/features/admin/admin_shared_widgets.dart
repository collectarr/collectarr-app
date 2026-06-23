part of 'admin_page.dart';

// Metadata proposals, add dialog, shared widgets, utility functions

class _MetadataProposalPanel extends StatelessWidget {
  const _MetadataProposalPanel({
    required this.summary,
    required this.proposals,
    required this.statusFilter,
    required this.providerFilter,
    required this.providers,
    required this.isLoading,
    required this.actingProposalId,
    required this.activeProposalTitle,
    required this.statusMessage,
    required this.errorMessage,
    required this.onStatusChanged,
    required this.onProviderChanged,
    required this.onReview,
    required this.onEdit,
    required this.onApprove,
    required this.onApproveLinked,
    required this.onReject,
    required this.onClearReview,
    required this.canApproveLinkedItem,
  });

  final AdminMetadataProposalSummary? summary;
  final List<AdminMetadataProposal> proposals;
  final String statusFilter;
  final String? providerFilter;
  final List<AdminProviderStatus> providers;
  final bool isLoading;
  final String? actingProposalId;
  final String? activeProposalTitle;
  final String? statusMessage;
  final String? errorMessage;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onProviderChanged;
  final ValueChanged<AdminMetadataProposal> onReview;
  final ValueChanged<AdminMetadataProposal> onEdit;
  final ValueChanged<AdminMetadataProposal> onApprove;
  final ValueChanged<AdminMetadataProposal> onApproveLinked;
  final ValueChanged<AdminMetadataProposal> onReject;
  final VoidCallback onClearReview;
  final bool Function(String provider) canApproveLinkedItem;

  @override
  Widget build(BuildContext context) {
    final providerOptions = [
      const DropdownMenuItem<String>(value: '', child: Text('All providers')),
      for (final provider in providers)
        DropdownMenuItem<String>(
          value: provider.name,
          child: Text(provider.displayName),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusChip(
              icon: Icons.pending_actions_outlined,
              label: '${summary?.pending ?? 0} pending',
            ),
            _StatusChip(
              icon: Icons.task_alt_outlined,
              label: '${summary?.approved ?? 0} approved',
            ),
            _StatusChip(
              icon: Icons.block_outlined,
              label: '${summary?.rejected ?? 0} rejected',
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 760;
            final statusField = DropdownButtonFormField<String>(
              initialValue: statusFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: onStatusChanged,
            );
            final providerField = DropdownButtonFormField<String>(
              initialValue: providerFilter ?? '',
              decoration: const InputDecoration(
                labelText: 'Provider',
                border: OutlineInputBorder(),
              ),
              items: providerOptions,
              onChanged: onProviderChanged,
            );
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  statusField,
                  const SizedBox(height: 12),
                  providerField,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: statusField),
                const SizedBox(width: 12),
                Expanded(child: providerField),
              ],
            );
          },
        ),
        if (activeProposalTitle != null) ...[
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(Icons.travel_explore_outlined),
                  Text('Reviewing proposal: $activeProposalTitle'),
                  OutlinedButton.icon(
                    onPressed: onClearReview,
                    icon: const Icon(Icons.close_outlined),
                    label: const Text('Clear review'),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (statusMessage != null || errorMessage != null) ...[
          const SizedBox(height: 12),
          _MessageRow(
            message: errorMessage ?? statusMessage!,
            isError: errorMessage != null,
          ),
        ],
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (proposals.isEmpty)
          _MessageRow(
            message: 'No ${statusFilter.toLowerCase()} proposals found.',
            isError: false,
          )
        else
          Column(
            children: [
              for (final proposal in proposals)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MetadataProposalTile(
                    proposal: proposal,
                    isActing: actingProposalId == proposal.id,
                    canApproveLinkedItem:
                        canApproveLinkedItem(proposal.provider),
                    onReview: () => onReview(proposal),
                    onEdit: () => onEdit(proposal),
                    onApprove: () => onApprove(proposal),
                    onApproveLinked: () => onApproveLinked(proposal),
                    onReject: () => onReject(proposal),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _MetadataProposalTile extends StatelessWidget {
  const _MetadataProposalTile({
    required this.proposal,
    required this.isActing,
    required this.canApproveLinkedItem,
    required this.onReview,
    required this.onEdit,
    required this.onApprove,
    required this.onApproveLinked,
    required this.onReject,
  });

  final AdminMetadataProposal proposal;
  final bool isActing;
  final bool canApproveLinkedItem;
  final VoidCallback onReview;
  final VoidCallback onEdit;
  final VoidCallback onApprove;
  final VoidCallback onApproveLinked;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  proposal.displayTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                _MiniChip(label: proposal.provider),
                _MiniChip(label: proposal.status),
                _MiniChip(
                  label: _proposalKindLabel(
                    _inferProposalKind(
                        proposal.provider, proposal.metadataPayload),
                  ),
                ),
                if (proposal.providerItemId != null &&
                    proposal.providerItemId!.isNotEmpty)
                  _MiniChip(label: 'ID ${proposal.providerItemId}'),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              proposal.query,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            if (proposal.summary != null &&
                proposal.summary!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                proposal.summary!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if ((proposal.metadataPayload ?? const <String, dynamic>{})
                .isNotEmpty) ...[
              const SizedBox(height: 8),
              _ProposalPayloadPreview(payload: proposal.metadataPayload!),
            ],
            if (proposal.isPending) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: isActing ? null : onReview,
                    icon: const Icon(Icons.travel_explore_outlined),
                    label: const Text('Review in search'),
                  ),
                  OutlinedButton.icon(
                    onPressed: isActing ? null : onEdit,
                    icon: const Icon(Icons.edit_note_outlined),
                    label: const Text('Edit metadata'),
                  ),
                  if ((proposal.providerItemId?.isNotEmpty ?? false) &&
                      canApproveLinkedItem)
                    FilledButton.tonalIcon(
                      onPressed: isActing ? null : onApproveLinked,
                      icon: isActing
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.link_outlined),
                      label: const Text('Approve linked ID'),
                    ),
                  FilledButton.icon(
                    onPressed: isActing ? null : onApprove,
                    icon: isActing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.task_alt_outlined),
                    label: const Text('Approve'),
                  ),
                  OutlinedButton.icon(
                    onPressed: isActing ? null : onReject,
                    icon: const Icon(Icons.block_outlined),
                    label: const Text('Reject'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProposalPayloadPreview extends StatelessWidget {
  const _ProposalPayloadPreview({required this.payload});

  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context) {
    final genres = _payloadStringList(payload['genres']);
    final platforms = _payloadStringList(payload['platforms']);
    final tracks = _payloadTrackRows(payload['tracks']);
    final links = _payloadLinkRows(payload['external_links']);
    final badges = <String>[
      if (genres.isNotEmpty) 'Genres: ${genres.take(3).join(', ')}',
      if (platforms.isNotEmpty) 'Platforms: ${platforms.take(3).join(', ')}',
      if (tracks.isNotEmpty) '${tracks.length} tracks',
      if (links.isNotEmpty) '${links.length} external links',
    ];
    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final badge in badges) _MiniChip(label: badge),
      ],
    );
  }
}

class _ProposalMetadataEditResult {
  const _ProposalMetadataEditResult({
    required this.query,
    required this.providerItemId,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.metadataPayload,
  });

  final String query;
  final String? providerItemId;
  final String? title;
  final String? summary;
  final String? imageUrl;
  final Map<String, dynamic> metadataPayload;
}

class _ProposalMetadataEditDialog extends StatefulWidget {
  const _ProposalMetadataEditDialog({required this.proposal});

  final AdminMetadataProposal proposal;

  @override
  State<_ProposalMetadataEditDialog> createState() =>
      _ProposalMetadataEditDialogState();
}

class _ProposalMetadataEditDialogState
    extends State<_ProposalMetadataEditDialog> {
  late final TextEditingController _queryController;
  late final TextEditingController _providerItemIdController;
  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _itemNumberController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _publisherController;
  late final TextEditingController _synopsisController;
  late final TextEditingController _genresController;
  late final TextEditingController _platformsController;
  late final TextEditingController _tracksController;
  late final TextEditingController _externalLinksController;
  late final TextEditingController _payloadController;
  late String _kind;
  var _showRawPayload = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final proposal = widget.proposal;
    final payload = Map<String, dynamic>.from(
      proposal.metadataPayload ?? const <String, dynamic>{},
    );
    _kind = _inferProposalKind(proposal.provider, payload);
    _queryController = TextEditingController(text: proposal.query);
    _providerItemIdController =
        TextEditingController(text: proposal.providerItemId ?? '');
    _titleController = TextEditingController(text: proposal.title ?? '');
    _summaryController = TextEditingController(text: proposal.summary ?? '');
    _imageUrlController = TextEditingController(text: proposal.imageUrl ?? '');
    _itemNumberController =
        TextEditingController(text: payload['item_number']?.toString() ?? '');
    _subtitleController =
        TextEditingController(text: payload['subtitle']?.toString() ?? '');
    _publisherController =
        TextEditingController(text: payload['publisher']?.toString() ?? '');
    _synopsisController =
        TextEditingController(text: payload['synopsis']?.toString() ?? '');
    _genresController = TextEditingController(
      text: _payloadStringList(payload['genres']).join(', '),
    );
    _platformsController = TextEditingController(
      text: _payloadStringList(payload['platforms']).join(', '),
    );
    _tracksController = TextEditingController(
      text: _payloadTrackRows(payload['tracks'])
          .map(
            (track) => [
              track['title']?.toString() ?? '',
              track['artist']?.toString() ?? '',
              track['disc_number']?.toString() ?? '',
              track['position']?.toString() ?? '',
              track['duration_seconds']?.toString() ?? '',
            ].join(' | '),
          )
          .join('\n'),
    );
    _externalLinksController = TextEditingController(
      text: _payloadLinkRows(payload['external_links'])
          .map(
            (link) => [
              link['label']?.toString() ?? '',
              link['url']?.toString() ?? '',
              link['kind']?.toString() ?? '',
              link['description']?.toString() ?? '',
            ].join(' | '),
          )
          .join('\n'),
    );
    _payloadController = TextEditingController(
      text: const JsonEncoder.withIndent('  ').convert(payload),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    _providerItemIdController.dispose();
    _titleController.dispose();
    _summaryController.dispose();
    _imageUrlController.dispose();
    _itemNumberController.dispose();
    _subtitleController.dispose();
    _publisherController.dispose();
    _synopsisController.dispose();
    _genresController.dispose();
    _platformsController.dispose();
    _tracksController.dispose();
    _externalLinksController.dispose();
    _payloadController.dispose();
    super.dispose();
  }

  void _save() {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() => _errorMessage = 'Query is required.');
      return;
    }
    final rawPayload = _payloadController.text.trim();
    Map<String, dynamic> payload;
    try {
      final decoded =
          rawPayload.isEmpty ? <String, dynamic>{} : jsonDecode(rawPayload);
      if (decoded is! Map<String, dynamic>) {
        setState(() {
          _errorMessage = 'Metadata payload must be a JSON object.';
        });
        return;
      }
      payload = decoded;
    } catch (_) {
      setState(() {
        _errorMessage = 'Metadata payload contains invalid JSON.';
      });
      return;
    }
    _setPayloadTextValue(payload, 'kind', _kind);
    _setPayloadTextValue(payload, 'item_number', _itemNumberController.text);
    _setPayloadTextValue(payload, 'subtitle', _subtitleController.text);
    _setPayloadTextValue(payload, 'publisher', _publisherController.text);
    _setPayloadTextValue(payload, 'synopsis', _synopsisController.text);
    _setPayloadListValue(
      payload,
      'genres',
      _splitCommaSeparated(_genresController.text),
    );
    if (_kind == 'game') {
      _setPayloadListValue(
        payload,
        'platforms',
        _splitCommaSeparated(_platformsController.text),
      );
    } else {
      payload.remove('platforms');
    }
    if (_kind == 'music') {
      final tracksParse = _parseTrackLinesStrict(_tracksController.text);
      if (tracksParse.error != null) {
        setState(() {
          _errorMessage = tracksParse.error;
        });
        return;
      }
      _setPayloadListValue(
        payload,
        'tracks',
        tracksParse.rows,
      );
    } else {
      payload.remove('tracks');
    }
    final linksParse =
        _parseExternalLinkLinesStrict(_externalLinksController.text);
    if (linksParse.error != null) {
      setState(() {
        _errorMessage = linksParse.error;
      });
      return;
    }
    _setPayloadListValue(
      payload,
      'external_links',
      linksParse.rows,
    );
    setState(() {
      _errorMessage = null;
    });
    Navigator.of(context).pop(
      _ProposalMetadataEditResult(
        query: query,
        providerItemId: _emptyToNull(_providerItemIdController.text),
        title: _emptyToNull(_titleController.text),
        summary: _emptyToNull(_summaryController.text),
        imageUrl: _emptyToNull(_imageUrlController.text),
        metadataPayload: payload,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      title: Text('Edit proposal metadata - ${widget.proposal.displayTitle}'),
      content: SizedBox(
        width: 980,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      initialValue: _kind,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Kind',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'comic', child: Text('Comic')),
                        DropdownMenuItem(value: 'manga', child: Text('Manga')),
                        DropdownMenuItem(value: 'anime', child: Text('Anime')),
                        DropdownMenuItem(value: 'book', child: Text('Book')),
                        DropdownMenuItem(value: 'game', child: Text('Game')),
                        DropdownMenuItem(
                          value: 'boardgame',
                          child: Text('Board game'),
                        ),
                        DropdownMenuItem(value: 'movie', child: Text('Movie')),
                        DropdownMenuItem(value: 'tv', child: Text('TV')),
                        DropdownMenuItem(value: 'music', child: Text('Music')),
                      ],
                      onChanged: (value) {
                        if (value == null || value == _kind) {
                          return;
                        }
                        setState(() {
                          _kind = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      controller: _queryController,
                      decoration: const InputDecoration(
                        labelText: 'Query',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      controller: _providerItemIdController,
                      decoration: const InputDecoration(
                        labelText: 'Provider item id',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      controller: _itemNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Item number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      controller: _subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Subtitle',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      controller: _publisherController,
                      decoration: const InputDecoration(
                        labelText: 'Publisher',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _summaryController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Summary',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _synopsisController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Synopsis',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _genresController,
                decoration: const InputDecoration(
                  labelText: 'Genres (comma separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_kind == 'game') ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _platformsController,
                  decoration: const InputDecoration(
                    labelText: 'Platforms (comma separated)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              if (_kind == 'music') ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _tracksController,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText:
                        'Tracks (title | artist | disc | pos | duration)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              TextFormField(
                controller: _externalLinksController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText:
                      'External links (label | url | kind | description)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                value: _showRawPayload,
                contentPadding: EdgeInsets.zero,
                title: const Text('Show raw payload JSON'),
                subtitle: const Text('Advanced/manual override fields'),
                onChanged: (value) => setState(() {
                  _showRawPayload = value;
                }),
              ),
              if (_showRawPayload)
                TextFormField(
                  controller: _payloadController,
                  minLines: 8,
                  maxLines: 12,
                  decoration: const InputDecoration(
                    labelText: 'Metadata payload JSON',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Consolas',
                      ),
                )
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Kind-aware editor is active. Enable raw JSON only for advanced fields.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                _MessageRow(message: _errorMessage!, isError: true),
              ],
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save changes'),
        ),
      ],
    );
  }
}

enum _ProviderAddMode { search, direct }

class _ProviderAddRequest {
  const _ProviderAddRequest({
    required this.mode,
    required this.kind,
    required this.provider,
    required this.showMediaResults,
    required this.showReleaseResults,
    this.query,
    this.providerItemId,
  });

  final _ProviderAddMode mode;
  final String? kind;
  final String provider;
  final bool showMediaResults;
  final bool showReleaseResults;
  final String? query;
  final String? providerItemId;
}

class _ProviderAddDialog extends StatefulWidget {
  const _ProviderAddDialog({
    required this.providers,
    required this.kinds,
    required this.kindLabels,
    this.initialKind,
    this.initialProvider,
    this.initialQuery,
    this.initialProviderItemId,
    this.initialShowMediaResults = true,
    this.initialShowReleaseResults = true,
  });

  final List<AdminProviderStatus> providers;
  final List<String> kinds;
  final Map<String, String> kindLabels;
  final String? initialKind;
  final String? initialProvider;
  final String? initialQuery;
  final String? initialProviderItemId;
  final bool initialShowMediaResults;
  final bool initialShowReleaseResults;

  @override
  State<_ProviderAddDialog> createState() => _ProviderAddDialogState();
}

class _ProviderAddDialogState extends State<_ProviderAddDialog> {
  late _ProviderAddMode _mode;
  late String? _selectedKind;
  late String _selectedProvider;
  late final TextEditingController _queryController;
  late final TextEditingController _providerItemIdController;
  late bool _showMediaResults;
  late bool _showReleaseResults;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mode = _ProviderAddMode.search;
    _selectedKind = widget.initialKind;
    _selectedProvider = widget.initialProvider ?? '';
    _queryController = TextEditingController(text: widget.initialQuery ?? '');
    _providerItemIdController = TextEditingController(
      text: widget.initialProviderItemId ?? '',
    );
    _showMediaResults = widget.initialShowMediaResults;
    _showReleaseResults = widget.initialShowReleaseResults;
    _syncSelectedProvider();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _providerItemIdController.dispose();
    super.dispose();
  }

  List<AdminProviderStatus> get _availableProviders {
    return [
      for (final provider in widget.providers)
        if ((_mode == _ProviderAddMode.search
                ? provider.supportsSearch
                : provider.supportsIngest) &&
            (_selectedKind == null ||
                provider.effectiveKinds.contains(_selectedKind)))
          provider,
    ];
  }

  void _syncSelectedProvider() {
    final providers = _availableProviders;
    if (providers.any((provider) => provider.name == _selectedProvider)) {
      return;
    }
    _selectedProvider = providers.isEmpty ? '' : providers.first.name;
  }

  @override
  Widget build(BuildContext context) {
    final actionLabel =
        _mode == _ProviderAddMode.search ? 'Search provider' : 'Add to catalog';
    return AccentAlertDialog(
      shape: _kAdminDialogShape,
      title: const Text('Add metadata from provider'),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                _MessageRow(message: _error!, isError: true),
                const SizedBox(height: 12),
              ],
              SegmentedButton<_ProviderAddMode>(
                segments: const [
                  ButtonSegment<_ProviderAddMode>(
                    value: _ProviderAddMode.search,
                    icon: Icon(Icons.manage_search_outlined),
                    label: Text('Search first'),
                  ),
                  ButtonSegment<_ProviderAddMode>(
                    value: _ProviderAddMode.direct,
                    icon: Icon(Icons.download_for_offline_outlined),
                    label: Text('Known ID'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) {
                  setState(() {
                    _mode = selection.first;
                    _error = null;
                    _syncSelectedProvider();
                  });
                },
              ),
              const SizedBox(height: 16),
              _ProviderKindSelector(
                value: _selectedKind,
                kinds: widget.kinds,
                kindLabels: widget.kindLabels,
                isLoading: false,
                onChanged: (value) {
                  setState(() {
                    _selectedKind =
                        value == null || value.isEmpty ? null : value;
                    _error = null;
                    _syncSelectedProvider();
                  });
                },
              ),
              const SizedBox(height: 12),
              _ProviderSelector(
                value: _selectedProvider,
                providers: _availableProviders,
                isLoading: false,
                onChanged: (value) {
                  setState(() {
                    _selectedProvider = value?.trim() ?? '';
                    _error = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              Text(
                _mode == _ProviderAddMode.search
                    ? 'Search for candidates inside the selected category before creating anything in the canonical catalog.'
                    : 'Use a known provider item ID when you already know the exact external record you want to ingest.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 8,
                children: [
                  _ProviderEntityScopeToggle(
                    label: 'Media',
                    value: _showMediaResults,
                    onChanged: (value) {
                      if (!value && !_showReleaseResults) {
                        return;
                      }
                      setState(() {
                        _showMediaResults = value;
                      });
                    },
                  ),
                  _ProviderEntityScopeToggle(
                    label: 'Releases',
                    value: _showReleaseResults,
                    onChanged: (value) {
                      if (!value && !_showMediaResults) {
                        return;
                      }
                      setState(() {
                        _showReleaseResults = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_mode == _ProviderAddMode.search)
                TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    labelText: 'Provider query',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submit(),
                )
              else
                TextField(
                  controller: _providerItemIdController,
                  decoration: const InputDecoration(
                    labelText: 'Provider item ID',
                    prefixIcon: Icon(Icons.tag_outlined),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: Icon(
            _mode == _ProviderAddMode.search
                ? Icons.manage_search_outlined
                : Icons.download_for_offline_outlined,
          ),
          label: Text(actionLabel),
        ),
      ],
    );
  }

  void _submit() {
    final kind = _selectedKind?.trim();
    if (kind == null || kind.isEmpty) {
      setState(() {
        _error = 'Choose a media category first.';
      });
      return;
    }
    if (_selectedProvider.trim().isEmpty) {
      setState(() {
        _error = 'Choose a provider.';
      });
      return;
    }
    if (_mode == _ProviderAddMode.search) {
      final query = _queryController.text.trim();
      if (query.isEmpty) {
        setState(() {
          _error = 'Enter a provider query.';
        });
        return;
      }
      Navigator.of(context).pop(
        _ProviderAddRequest(
          mode: _mode,
          kind: kind,
          provider: _selectedProvider,
          showMediaResults: _showMediaResults,
          showReleaseResults: _showReleaseResults,
          query: query,
        ),
      );
      return;
    }
    final providerItemId = _providerItemIdController.text.trim();
    if (providerItemId.isEmpty) {
      setState(() {
        _error = 'Enter a provider item ID.';
      });
      return;
    }
    Navigator.of(context).pop(
      _ProviderAddRequest(
        mode: _mode,
        kind: kind,
        provider: _selectedProvider,
        showMediaResults: _showMediaResults,
        showReleaseResults: _showReleaseResults,
        providerItemId: providerItemId,
      ),
    );
  }
}

class _ReleaseMappingRuleFormResult {
  const _ReleaseMappingRuleFormResult({
    required this.provider,
    required this.releaseType,
    required this.targetKind,
    required this.priority,
    required this.isActive,
    this.notes,
  });

  final String? provider;
  final String releaseType;
  final String targetKind;
  final int priority;
  final bool isActive;
  final String? notes;
}

class _ReleaseMappingRuleDialog extends StatefulWidget {
  const _ReleaseMappingRuleDialog({
    required this.providers,
    required this.kinds,
    required this.kindLabels,
    this.initialProvider,
    this.initialReleaseType,
    this.initialTargetKind,
    this.initialPriority = 100,
    this.initialIsActive = true,
    this.initialNotes,
  });

  final List<String> providers;
  final List<String> kinds;
  final Map<String, String> kindLabels;
  final String? initialProvider;
  final String? initialReleaseType;
  final String? initialTargetKind;
  final int initialPriority;
  final bool initialIsActive;
  final String? initialNotes;

  @override
  State<_ReleaseMappingRuleDialog> createState() =>
      _ReleaseMappingRuleDialogState();
}

class _ReleaseMappingRuleDialogState extends State<_ReleaseMappingRuleDialog> {
  late final TextEditingController _releaseTypeController;
  late final TextEditingController _priorityController;
  late final TextEditingController _notesController;
  String? _provider;
  String? _targetKind;
  late bool _isActive;
  String? _error;

  @override
  void initState() {
    super.initState();
    _releaseTypeController = TextEditingController(
      text: widget.initialReleaseType ?? '',
    );
    _priorityController = TextEditingController(
      text: widget.initialPriority.toString(),
    );
    _notesController = TextEditingController(
      text: widget.initialNotes ?? '',
    );
    _provider = widget.initialProvider;
    _targetKind = widget.initialTargetKind ??
        (widget.kinds.contains('comic')
            ? 'comic'
            : (widget.kinds.isNotEmpty ? widget.kinds.first : null));
    _isActive = widget.initialIsActive;
  }

  @override
  void dispose() {
    _releaseTypeController.dispose();
    _priorityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: _kAdminDialogShape,
      title: const Text('Release mapping rule'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String?>(
              initialValue: _provider,
              decoration: const InputDecoration(
                labelText: 'Provider scope',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All providers'),
                ),
                for (final provider in widget.providers)
                  DropdownMenuItem<String?>(
                    value: provider,
                    child: Text(provider),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _provider = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _releaseTypeController,
              decoration: const InputDecoration(
                labelText: 'Release type',
                hintText: 'issue, variant, season, episode...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _targetKind,
              decoration: const InputDecoration(
                labelText: 'Target media kind',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final kind in widget.kinds)
                  DropdownMenuItem<String>(
                    value: kind,
                    child: Text(widget.kindLabels[kind] ?? kind),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _targetKind = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priorityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Priority (lower wins)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value ?? true;
                });
              },
              title: const Text('Rule is active'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _MessageRow(message: _error!, isError: true),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _submit() {
    final releaseType = _releaseTypeController.text.trim().toLowerCase();
    if (releaseType.isEmpty) {
      setState(() {
        _error = 'Release type is required.';
      });
      return;
    }
    final targetKind = _targetKind?.trim();
    if (targetKind == null || targetKind.isEmpty) {
      setState(() {
        _error = 'Select a target media kind.';
      });
      return;
    }
    final parsedPriority = int.tryParse(_priorityController.text.trim());
    if (parsedPriority == null || parsedPriority < 0) {
      setState(() {
        _error = 'Priority must be a positive number.';
      });
      return;
    }
    Navigator.of(context).pop(
      _ReleaseMappingRuleFormResult(
        provider:
            _provider?.trim().isNotEmpty == true ? _provider!.trim() : null,
        releaseType: releaseType,
        targetKind: targetKind,
        priority: parsedPriority,
        isActive: _isActive,
        notes: _notesController.text.trim(),
      ),
    );
  }
}

class _CatalogCorrection {
  const _CatalogCorrection({
    this.title,
    this.originalTitle,
    this.localizedTitle,
    this.sortKey,
    this.searchAliases,
    this.titleExtension,
    this.itemNumber,
    this.synopsis,
    this.crossover,
    this.plotSummary,
    this.plotDescription,
    this.genres,
    this.platforms,
    this.characters,
    this.storyArcs,
    this.creators,
    this.tracks,
    this.trailerUrls,
    this.externalLinks,
    this.editionTitle,
    this.pageCount,
    this.runtimeMinutes,
    this.color,
    this.nrDiscs,
    this.screenRatio,
    this.audioTracks,
    this.subtitles,
    this.layers,
    this.publisher,
    this.releaseDate,
    this.imprint,
    this.subtitle,
    this.seriesGroup,
    this.country,
    this.language,
    this.ageRating,
    this.audienceRating,
    this.catalogNumber,
    this.releaseStatus,
    this.physicalFormat,
    this.variantName,
    this.barcode,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.seriesTags,
  });

  final String? title;
  final String? originalTitle;
  final String? localizedTitle;
  final String? sortKey;
  final List<String>? searchAliases;
  final String? titleExtension;
  final String? itemNumber;
  final String? synopsis;
  final String? crossover;
  final String? plotSummary;
  final String? plotDescription;
  final List<String>? genres;
  final List<String>? platforms;
  final List<String>? characters;
  final List<String>? storyArcs;
  final List<Map<String, dynamic>>? creators;
  final List<CatalogTrack>? tracks;
  final List<TrailerLink>? trailerUrls;
  final List<TrailerLink>? externalLinks;
  final String? editionTitle;
  final int? pageCount;
  final int? runtimeMinutes;
  final String? color;
  final int? nrDiscs;
  final String? screenRatio;
  final String? audioTracks;
  final String? subtitles;
  final String? layers;
  final String? publisher;
  final DateTime? releaseDate;
  final String? imprint;
  final String? subtitle;
  final String? seriesGroup;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;
  final String? catalogNumber;
  final String? releaseStatus;
  final String? physicalFormat;
  final String? variantName;
  final String? barcode;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final List<String>? seriesTags;
}

class _CorrectionPreviewEntry {
  const _CorrectionPreviewEntry({
    required this.label,
    required this.before,
    required this.after,
  });

  final String label;
  final String before;
  final String after;
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          isError ? Icons.error_outline : Icons.info_outline,
          color: isError ? colorScheme.error : colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
      ],
    );
  }
}

class _DestructiveWarning extends StatelessWidget {
  const _DestructiveWarning({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.34),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.42)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.error, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _CorrectionPreviewRow extends StatelessWidget {
  const _CorrectionPreviewRow({required this.change});

  final _CorrectionPreviewEntry change;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                change.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Text('Before: ${change.before}'),
              Text('After: ${change.after}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

String _proposalKindLabel(String kind) {
  return switch (kind) {
    'boardgame' => 'Board game',
    'tv' => 'TV',
    _ =>
      kind.isEmpty ? 'Unknown' : '${kind[0].toUpperCase()}${kind.substring(1)}',
  };
}

String _inferProposalKind(String provider, Map<String, dynamic>? payload) {
  final map = payload ?? const <String, dynamic>{};
  final explicit = _emptyToNull(map['kind']?.toString() ?? '');
  if (explicit != null) {
    return explicit;
  }
  if (_payloadTrackRows(map['tracks']).isNotEmpty) {
    return 'music';
  }
  if (_payloadStringList(map['platforms']).isNotEmpty) {
    return 'game';
  }
  if (_payloadStringList(map['chapters']).isNotEmpty) {
    return 'manga';
  }
  if (_payloadStringList(map['episodes']).isNotEmpty) {
    return 'tv';
  }
  return switch (provider) {
    'gcd' || 'comicvine' => 'comic',
    'anilist' => 'anime',
    'igdb' => 'game',
    'tmdb' => 'movie',
    _ => 'comic',
  };
}

List<String> _payloadStringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return [
    for (final row in value)
      if (row != null && row.toString().trim().isNotEmpty)
        row.toString().trim(),
  ];
}

List<Map<String, dynamic>> _payloadTrackRows(Object? value) {
  if (value is! List) {
    return const [];
  }
  return [
    for (final row in value)
      if (row is Map<String, dynamic>) row,
  ];
}

List<Map<String, dynamic>> _payloadLinkRows(Object? value) {
  if (value is! List) {
    return const [];
  }
  return [
    for (final row in value)
      if (row is Map<String, dynamic> &&
          _emptyToNull(row['url']?.toString() ?? '') != null)
        row,
  ];
}

List<String> _splitCommaSeparated(String value) {
  return [
    for (final row in value.split(','))
      if (row.trim().isNotEmpty) row.trim(),
  ];
}

class _LinesParseResult {
  const _LinesParseResult({
    required this.rows,
    this.error,
  });

  final List<Map<String, dynamic>> rows;
  final String? error;
}

_LinesParseResult _parseTrackLinesStrict(String value) {
  final rows = <Map<String, dynamic>>[];
  final lines = value.split('\n');
  for (var index = 0; index < lines.length; index++) {
    final rawLine = lines[index];
    final line = rawLine.trim();
    if (line.isEmpty) {
      continue;
    }
    final columns =
        line.split('|').map((row) => row.trim()).toList(growable: false);
    final title = columns.isNotEmpty ? columns[0] : '';
    if (title.isEmpty) {
      return _LinesParseResult(
        rows: const [],
        error:
            'Tracks line ${index + 1} is invalid: title is required before "|"',
      );
    }
    final track = <String, dynamic>{'title': title};
    if (columns.length > 1 && columns[1].isNotEmpty) {
      track['artist'] = columns[1];
    }
    if (columns.length > 2) {
      final disc = int.tryParse(columns[2]);
      if (columns[2].isNotEmpty) {
        if (disc == null) {
          return _LinesParseResult(
            rows: const [],
            error:
                'Tracks line ${index + 1} has invalid disc number "${columns[2]}"',
          );
        }
        track['disc_number'] = disc;
      }
    }
    if (columns.length > 3) {
      final position = int.tryParse(columns[3]);
      if (columns[3].isNotEmpty) {
        if (position == null) {
          return _LinesParseResult(
            rows: const [],
            error:
                'Tracks line ${index + 1} has invalid position "${columns[3]}"',
          );
        }
        track['position'] = position;
      }
    }
    if (columns.length > 4) {
      final duration = int.tryParse(columns[4]);
      if (columns[4].isNotEmpty) {
        if (duration == null) {
          return _LinesParseResult(
            rows: const [],
            error:
                'Tracks line ${index + 1} has invalid duration "${columns[4]}"',
          );
        }
        track['duration_seconds'] = duration;
      }
    }
    rows.add(track);
  }
  return _LinesParseResult(rows: rows);
}

_LinesParseResult _parseExternalLinkLinesStrict(String value) {
  final rows = <Map<String, dynamic>>[];
  final lines = value.split('\n');
  for (var index = 0; index < lines.length; index++) {
    final rawLine = lines[index];
    final line = rawLine.trim();
    if (line.isEmpty) {
      continue;
    }
    final columns =
        line.split('|').map((row) => row.trim()).toList(growable: false);
    final label = columns.length > 1 ? columns[0] : '';
    final url = columns.length > 1 ? columns[1] : columns[0];
    final kind = columns.length > 2 ? columns[2] : '';
    final description = columns.length > 3 ? columns[3] : '';
    if (url.isEmpty) {
      return _LinesParseResult(
        rows: const [],
        error: 'External links line ${index + 1} is invalid: URL is required',
      );
    }
    final uri = Uri.tryParse(url);
    final scheme = uri?.scheme.toLowerCase();
    final isWebUrl = uri != null &&
        uri.hasScheme &&
        (scheme == 'http' || scheme == 'https') &&
        (uri.host.isNotEmpty);
    if (!isWebUrl) {
      return _LinesParseResult(
        rows: const [],
        error:
            'External links line ${index + 1} has invalid URL "$url" (use full http/https URL)',
      );
    }
    rows.add({
      if (label.isNotEmpty) 'label': label,
      'url': url,
      if (kind.isNotEmpty) 'kind': kind,
      if (description.isNotEmpty) 'description': description,
    });
  }
  return _LinesParseResult(rows: rows);
}

void _setPayloadTextValue(
    Map<String, dynamic> payload, String key, String value) {
  final normalized = _emptyToNull(value);
  if (normalized == null) {
    payload.remove(key);
    return;
  }
  payload[key] = normalized;
}

void _setPayloadListValue(
    Map<String, dynamic> payload, String key, List<dynamic> value) {
  if (value.isEmpty) {
    payload.remove(key);
    return;
  }
  payload[key] = value;
}

String _adminErrorMessage(Object error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return 'Admin access was rejected.';
    }
    if (statusCode == 422) {
      return 'Provider request was invalid.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Metadata server could not complete the admin request.';
    }
    final message = error.message?.trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }
  }
  return error.toString();
}

String _proposalAuditActionLabel(String action) {
  return switch (action) {
    'metadata_proposal.approve' => 'Approved proposal',
    'metadata_proposal.approve_provider' => 'Approved via provider',
    'metadata_proposal.reject' => 'Rejected proposal',
    _ => action,
  };
}

String _shortId(String id) {
  if (id.length <= 8) {
    return id;
  }
  return id.substring(0, 8);
}

String _providerKindLabel(String kind, Map<String, String> labels) {
  final label = labels[kind];
  if (label != null && label.isNotEmpty) {
    return label;
  }
  return switch (kind) {
    'boardgame' => 'Board game',
    'tv' => 'TV',
    _ => kind.isEmpty ? kind : '${kind[0].toUpperCase()}${kind.substring(1)}',
  };
}

String _mediaTypeDisplayLabel(CatalogMediaType type) {
  if (type.kind == 'tv') {
    return 'TV';
  }
  return type.pluralLabel.isNotEmpty ? type.pluralLabel : type.kind;
}

int _compareMediaKinds(String left, String right, Map<String, String> labels) {
  return _providerKindLabel(left, labels).compareTo(
    _providerKindLabel(right, labels),
  );
}

String _preferredProvider(
  List<AdminProviderStatus> providers, {
  required String current,
}) {
  if (current.isNotEmpty &&
      providers.any((provider) => provider.name == current)) {
    return current;
  }
  AdminProviderStatus? best;
  for (final provider in providers) {
    if (provider.isConfigured &&
        provider.supportsSearch &&
        provider.supportsIngest) {
      best = provider;
      break;
    }
  }
  best ??= _firstWhereOrNull(providers, (provider) => provider.isConfigured);
  best ??= _firstWhereOrNull(providers, (provider) => provider.supportsIngest);
  best ??= _firstWhereOrNull(providers, (provider) => provider.supportsSearch);
  best ??= providers.isEmpty ? null : providers.first;
  return best?.name ?? '';
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) {
      return item;
    }
  }
  return null;
}

String _formatDate(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  return '${_formatDate(local)} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

int _ingestJobAttemptsRemaining(AdminProviderIngestJob job) {
  final remaining = job.maxAttempts - job.attempts;
  return remaining < 0 ? 0 : remaining;
}

String _ingestJobStateDescription(AdminProviderIngestJob job) {
  return job.status.replaceAll('_', ' ');
}

String _formatMoney(int cents, String? currency) {
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null || currency.isEmpty ? amount : '$amount $currency';
}

String? _emptyToNull(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
