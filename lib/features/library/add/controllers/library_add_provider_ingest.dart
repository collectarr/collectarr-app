part of '../library_add_dialog.dart';

// ---------------------------------------------------------------------------
// Provider ingest pipeline: preview → edit → ingest → corrections → add
// ---------------------------------------------------------------------------

extension _LibraryAddProviderIngest on _LibraryAddDialogState {
  Future<void> addProviderCandidate(
    ProviderCandidate candidate,
    LibraryAddTarget target,
  ) async {
    final isAdmin = ref.read(authControllerProvider).isAdmin;
    if (!isAdmin || candidate.isStub) {
      final previewItem = await _providerAddItemForCandidate(candidate);
      await _addItems([previewItem], target);
      return;
    }
    var currentCandidate = candidate;
    try {
      while (mounted) {
        // Preview: fetch + normalize without creating in core DB.
        final preview = await ref.read(apiClientProvider).adminProviderPreview(
              provider: currentCandidate.provider,
              providerItemId: currentCandidate.providerItemId,
            );
        if (!mounted) return;

        final previewItem = metadataItemFromPreview(preview);
        final catalog = ref.read(mediaCatalogProvider).maybeWhen(
              data: (value) => value,
              orElse: () => fallbackMediaCatalog,
            );
        final visibleCandidates = _visibleProviderResults();
        final currentIndex = visibleCandidates.indexWhere(
          (entry) => entry.localCatalogId == currentCandidate.localCatalogId,
        );
        ProviderCandidate? navigateCandidate;

        // Open edit dialog so the user can review / modify all fields.
        final result = await showLibraryEditDialog(
          context: context,
          request: LibraryEditDialogRequest(
            type: widget.type,
            item: previewItem,
            ownedItem: null,
            accent: LibraryAccentScope.accentOf(context),
            scope: LibraryEditScope.all,
            physicalFormats: physicalMediaFormatsForKind(
              catalog,
              widget.type.workspace.kind,
            ),
            onPrevious: currentIndex > 0
                ? () {
                    navigateCandidate = visibleCandidates[currentIndex - 1];
                    Navigator.of(context).pop();
                  }
                : null,
            onNext:
                currentIndex >= 0 && currentIndex < visibleCandidates.length - 1
                    ? () {
                        navigateCandidate = visibleCandidates[currentIndex + 1];
                        Navigator.of(context).pop();
                      }
                    : null,
          ),
        );
        if (!mounted) return;
        if (navigateCandidate != null) {
          currentCandidate = navigateCandidate!;
          continue;
        }
        if (result == null) return;

        // Ingest: create item in core DB.
        final ingest = await ref.read(apiClientProvider).adminProviderIngest(
              provider: currentCandidate.provider,
              providerItemId: currentCandidate.providerItemId,
            );

        // Apply user corrections if any fields differ from the ingested item.
        final edited = result.item;
        final ingested = metadataItemFromIngestResult(ingest.item);
        if (mounted) {
          await applyIngestCorrections(
            kind: ingested.kind,
            itemId: ingest.itemId,
            preview: previewItem,
            edited: edited,
          );
        }

        // Use the ingested item as base but overlay the user's edits.
        final finalItem = mergeProviderAddResult(
          ingested: ingested,
          edited: edited,
        );
        await _addItems([finalItem], target);
        return;
      }
    } catch (error) {
      if (mounted &&
          await _clearRejectedMetadataSession(error, 'Provider ingest')) {
        return;
      }
      if (mounted) {
        final api = ref.read(apiClientProvider);
        _rebuild(
          () => _error =
              'Provider ingest failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)}',
        );
      }
    }
  }

  Future<LibraryMetadataItem> _providerAddItemForCandidate(
    ProviderCandidate candidate,
  ) async {
    if (candidate.isStub) {
      return candidate.placeholderItem();
    }
    final cachedPreview = _providerPreviews[candidate.localCatalogId];
    if (cachedPreview != null) {
      return metadataItemFromPreview(cachedPreview);
    }
    try {
      final preview = await ref.read(apiClientProvider).providerPreview(
            provider: candidate.provider,
            providerItemId: candidate.providerItemId,
          );
      if (mounted) {
        _rebuild(() {
          _providerPreviews[candidate.localCatalogId] = preview;
        });
      }
      return metadataItemFromPreview(preview);
    } catch (error) {
      if (mounted && _isMissingBearerTokenError(error)) {
        _rebuild(
          () => _error =
              'Provider preview needs authentication. Adding basic provider metadata only.',
        );
        return candidate.placeholderItem();
      }
      rethrow;
    }
  }

  LibraryMetadataItem metadataItemFromPreview(AdminProviderPreview preview) {
    final series = preview.series;
    final publishing = preview.publishing;
    final previewMusic = preview.music;
    final music = previewMusic;
    final video = preview.video;
    final game = preview.game;
    return LibraryMetadataItem(
      id: buildPreviewCatalogItemId(
        kind: preview.kind,
        provider: preview.provider,
        providerItemId: preview.providerItemId,
      ),
      kind: preview.kind,
      title: preview.title,
      itemNumber: preview.itemNumber,
      synopsis: preview.synopsis,
      coverImageUrl: preview.coverImageUrl,
      thumbnailImageUrl: preview.coverImageUrl,
      editionTitle: preview.editionTitle,
      physicalFormat: preview.physicalFormat,
      physicalFormatLabel: preview.physicalFormatLabel,
      publisher: preview.publisher,
      releaseDate: preview.releaseDate,
      releaseYear: preview.releaseDate?.year ?? preview.series?.volumeStartYear,
      barcode: preview.barcode,
      variant: preview.variantName,
      series: series,
      publishing: publishing,
      music: music,
      video: video,
      game: game,
      country: preview.country,
      language: preview.language,
      ageRating: preview.ageRating,
      audienceRating: preview.audienceRating,
      creators: [
        for (final creator in preview.creators)
          {
            'name': creator.name,
            if (creator.role != null) 'role': creator.role,
            if (creator.imageUrl != null) 'image_url': creator.imageUrl,
          },
      ],
      characters: preview.characters,
      storyArcs: preview.storyArcs,
      genres: preview.genres,
    );
  }

  /// Sends a PATCH correction for any fields the user changed from the preview.
  Future<void> applyIngestCorrections({
    required String kind,
    required String itemId,
    required LibraryMetadataItem preview,
    required LibraryMetadataItem edited,
  }) async {
    final corrections = <String, dynamic>{};
    if (edited.title != preview.title) corrections['title'] = edited.title;
    if (edited.titleExtension != preview.titleExtension) {
      corrections['title_extension'] = edited.titleExtension;
    }
    if (edited.sortKey != preview.sortKey) {
      corrections['sort_key'] = edited.sortKey;
    }
    if (edited.originalTitle != preview.originalTitle) {
      corrections['original_title'] = edited.originalTitle;
    }
    if (edited.localizedTitle != preview.localizedTitle) {
      corrections['localized_title'] = edited.localizedTitle;
    }
    if (!_sameStringList(edited.searchAliases, preview.searchAliases)) {
      corrections['search_aliases'] = edited.searchAliases;
    }
    if (edited.itemNumber != preview.itemNumber) {
      corrections['item_number'] = edited.itemNumber;
    }
    if (edited.synopsis != preview.synopsis) {
      corrections['synopsis'] = edited.synopsis;
    }
    if (edited.crossover != preview.crossover) {
      corrections['crossover'] = edited.crossover;
    }
    if (edited.plotSummary != preview.plotSummary) {
      corrections['plot_summary'] = edited.plotSummary;
    }
    if (edited.plotDescription != preview.plotDescription) {
      corrections['plot_description'] = edited.plotDescription;
    }
    if (edited.publisher != preview.publisher) {
      corrections['publisher'] = edited.publisher;
    }
    if (edited.releaseDate != preview.releaseDate) {
      corrections['release_date'] = edited.releaseDate?.toIso8601String();
    }
    if (edited.barcode != preview.barcode) {
      corrections['barcode'] = edited.barcode;
    }
    if (edited.variant != preview.variant) {
      corrections['variant_name'] = edited.variant;
    }
    if (edited.editionTitle != preview.editionTitle) {
      corrections['edition_title'] = edited.editionTitle;
    }
    if (edited.publishing?.pageCount != preview.publishing?.pageCount) {
      corrections['page_count'] = edited.publishing?.pageCount;
    }
    if (edited.publishing?.imprint != preview.publishing?.imprint) {
      corrections['imprint'] = edited.publishing?.imprint;
    }
    if (edited.publishing?.subtitle != preview.publishing?.subtitle) {
      corrections['subtitle'] = edited.publishing?.subtitle;
    }
    if (edited.publishing?.seriesGroup != preview.publishing?.seriesGroup) {
      corrections['series_group'] = edited.publishing?.seriesGroup;
    }
    if (edited.video?.runtimeMinutes != preview.video?.runtimeMinutes) {
      corrections['runtime_minutes'] = edited.video?.runtimeMinutes;
    }
    if (edited.physicalFormat != preview.physicalFormat) {
      corrections['physical_format'] = edited.physicalFormat;
    }
    if (edited.country != preview.country) {
      corrections['country'] = edited.country;
    }
    if (edited.language != preview.language) {
      corrections['language'] = edited.language;
    }
    if (edited.ageRating != preview.ageRating) {
      corrections['age_rating'] = edited.ageRating;
    }
    if (edited.audienceRating != preview.audienceRating) {
      corrections['audience_rating'] = edited.audienceRating;
    }
    if (!_sameStringList(edited.genres, preview.genres)) {
      corrections['genres'] = edited.genres;
    }
    if (!_sameStringList(edited.game?.platforms, preview.game?.platforms)) {
      corrections['platforms'] = edited.game?.platforms;
    }
    if (!_sameTracks(edited.music?.tracks, preview.music?.tracks)) {
      corrections['tracks'] = edited.music?.tracks;
    }
    if (!_sameCreators(edited.creators, preview.creators)) {
      corrections['creators'] = edited.creators;
    }
    if (!_sameStringList(edited.characters, preview.characters)) {
      corrections['characters'] = edited.characters;
    }
    if (!_sameStringList(edited.storyArcs, preview.storyArcs)) {
      corrections['story_arcs'] = edited.storyArcs;
    }
    if (edited.video?.color != preview.video?.color) {
      corrections['color'] = edited.video?.color;
    }
    if (edited.video?.nrDiscs != preview.video?.nrDiscs) {
      corrections['nr_discs'] = edited.video?.nrDiscs;
    }
    if (edited.video?.screenRatio != preview.video?.screenRatio) {
      corrections['screen_ratio'] = edited.video?.screenRatio;
    }
    if (edited.video?.audioTracks != preview.video?.audioTracks) {
      corrections['audio_tracks'] = edited.video?.audioTracks;
    }
    if (edited.video?.subtitles != preview.video?.subtitles) {
      corrections['subtitles'] = edited.video?.subtitles;
    }
    if (edited.video?.layers != preview.video?.layers) {
      corrections['layers'] = edited.video?.layers;
    }
    if (!_sameTrailerLinks(edited.trailerUrls, preview.trailerUrls)) {
      corrections['external_links'] = edited.trailerUrls;
    }
    if (edited.music?.catalogNumber != preview.music?.catalogNumber) {
      corrections['catalog_number'] = edited.music?.catalogNumber;
    }
    if (edited.music?.releaseStatus != preview.music?.releaseStatus) {
      corrections['release_status'] = edited.music?.releaseStatus;
    }
    if (edited.coverImageUrl != preview.coverImageUrl) {
      corrections['cover_image_url'] = edited.coverImageUrl;
    }
    if (edited.thumbnailImageUrl != preview.thumbnailImageUrl) {
      corrections['thumbnail_image_url'] = edited.thumbnailImageUrl;
    }
    if (corrections.isEmpty) return;
    await ref.read(apiClientProvider).adminUpdateCatalogItem(
          kind: kind,
          id: itemId,
          title: corrections['title'] as String?,
          titleExtension: corrections['title_extension'] as String?,
          sortKey: corrections['sort_key'] as String?,
          originalTitle: corrections['original_title'] as String?,
          localizedTitle: corrections['localized_title'] as String?,
          searchAliases: corrections.containsKey('search_aliases')
              ? edited.searchAliases
              : null,
          itemNumber: corrections['item_number'] as String?,
          synopsis: corrections['synopsis'] as String?,
          editionTitle: corrections['edition_title'] as String?,
          pageCount: corrections.containsKey('page_count')
              ? edited.publishing?.pageCount
              : null,
          publisher: corrections['publisher'] as String?,
          releaseDate: corrections.containsKey('release_date')
              ? edited.releaseDate
              : null,
          runtimeMinutes: corrections.containsKey('runtime_minutes')
              ? edited.video?.runtimeMinutes
              : null,
          imprint: corrections['imprint'] as String?,
          subtitle: corrections['subtitle'] as String?,
          seriesGroup: corrections['series_group'] as String?,
          country: corrections['country'] as String?,
          language: corrections['language'] as String?,
          ageRating: corrections['age_rating'] as String?,
          audienceRating: corrections['audience_rating'] as String?,
          genres: corrections.containsKey('genres') ? edited.genres : null,
          platforms: corrections.containsKey('platforms')
              ? edited.game?.platforms
              : null,
          tracks:
              corrections.containsKey('tracks') ? edited.music?.tracks : null,
          creators: corrections.containsKey('creators')
              ? _normalizeCreators(edited.creators)
              : null,
          characters:
              corrections.containsKey('characters') ? edited.characters : null,
          storyArcs:
              corrections.containsKey('story_arcs') ? edited.storyArcs : null,
          color: corrections['color'] as String?,
          nrDiscs: corrections.containsKey('nr_discs')
              ? edited.video?.nrDiscs
              : null,
          screenRatio: corrections['screen_ratio'] as String?,
          audioTracks: corrections['audio_tracks'] as String?,
          subtitles: corrections['subtitles'] as String?,
          layers: corrections['layers'] as String?,
          externalLinks: corrections.containsKey('external_links')
              ? edited.trailerUrls
              : null,
          crossover: corrections['crossover'] as String?,
          plotSummary: corrections['plot_summary'] as String?,
          plotDescription: corrections['plot_description'] as String?,
          catalogNumber: corrections['catalog_number'] as String?,
          releaseStatus: corrections['release_status'] as String?,
          barcode: corrections['barcode'] as String?,
          variantName: corrections['variant_name'] as String?,
          physicalFormat: corrections['physical_format'] as String?,
          coverImageUrl: corrections['cover_image_url'] as String?,
          thumbnailImageUrl: corrections['thumbnail_image_url'] as String?,
          explicitFields: corrections.keys.toSet(),
        );
  }

  bool _sameStringList(List<String>? a, List<String>? b) {
    final left = _normalizeStringList(a);
    final right = _normalizeStringList(b);
    if (left.length != right.length) {
      return false;
    }
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) {
        return false;
      }
    }
    return true;
  }

  List<String> _normalizeStringList(List<String>? values) {
    if (values == null) {
      return const <String>[];
    }
    final normalized = <String>[];
    for (final value in values) {
      final entry = value.trim();
      if (entry.isEmpty) {
        continue;
      }
      normalized.add(entry);
    }
    return normalized;
  }

  bool _sameCreators(
    List<Map<String, dynamic>>? a,
    List<Map<String, dynamic>>? b,
  ) {
    final left = _normalizeCreators(a);
    final right = _normalizeCreators(b);
    if (left.length != right.length) {
      return false;
    }
    for (var i = 0; i < left.length; i++) {
      final l = left[i];
      final r = right[i];
      if (l['name'] != r['name'] || l['role'] != r['role']) {
        return false;
      }
    }
    return true;
  }

  List<Map<String, dynamic>> _normalizeCreators(
      List<Map<String, dynamic>>? values) {
    if (values == null) {
      return const <Map<String, dynamic>>[];
    }
    final normalized = <Map<String, dynamic>>[];
    for (final raw in values) {
      final name = (raw['name']?.toString() ?? '').trim();
      if (name.isEmpty) {
        continue;
      }
      final role = raw['role']?.toString().trim();
      normalized.add({
        'name': name,
        if (role != null && role.isNotEmpty) 'role': role,
      });
    }
    return normalized;
  }

  bool _sameTrailerLinks(List<TrailerLink>? a, List<TrailerLink>? b) {
    final left = _normalizeTrailerLinks(a);
    final right = _normalizeTrailerLinks(b);
    if (left.length != right.length) {
      return false;
    }
    for (var i = 0; i < left.length; i++) {
      if (left[i].toString() != right[i].toString()) {
        return false;
      }
    }
    return true;
  }

  List<Map<String, dynamic>> _normalizeTrailerLinks(List<TrailerLink>? links) {
    if (links == null) {
      return const <Map<String, dynamic>>[];
    }
    return [
      for (final link in links)
        if (link.url.trim().isNotEmpty)
          {
            'url': link.url.trim(),
            if (link.source != null && link.source!.trim().isNotEmpty)
              'source': link.source!.trim(),
            if (link.title != null && link.title!.trim().isNotEmpty)
              'title': link.title!.trim(),
            if (link.kind.trim().isNotEmpty) 'kind': link.kind.trim(),
            if (link.description != null && link.description!.trim().isNotEmpty)
              'description': link.description!.trim(),
          },
    ];
  }

  bool _sameTracks(List<CatalogTrack>? a, List<CatalogTrack>? b) {
    final left = _normalizeTracks(a);
    final right = _normalizeTracks(b);
    if (left.length != right.length) {
      return false;
    }
    for (var i = 0; i < left.length; i++) {
      final l = left[i];
      final r = right[i];
      if (l['title'] != r['title'] ||
          l['position'] != r['position'] ||
          l['duration_seconds'] != r['duration_seconds'] ||
          l['artist'] != r['artist'] ||
          l['disc_number'] != r['disc_number']) {
        return false;
      }
    }
    return true;
  }

  List<Map<String, dynamic>> _normalizeTracks(List<CatalogTrack>? values) {
    if (values == null) {
      return const <Map<String, dynamic>>[];
    }
    final normalized = <Map<String, dynamic>>[];
    for (final track in values) {
      final title = track.title.trim();
      if (title.isEmpty) {
        continue;
      }
      normalized.add({
        'title': title,
        if (track.position != null) 'position': track.position,
        if (track.durationSeconds != null)
          'duration_seconds': track.durationSeconds,
        if (track.artist != null && track.artist!.trim().isNotEmpty)
          'artist': track.artist!.trim(),
        if (track.discNumber != null) 'disc_number': track.discNumber,
      });
    }
    return normalized;
  }

  LibraryMetadataItem metadataItemFromIngestResult(AdminMetadataItem item) {
    final primaryEdition = item.primaryEdition;
    final primaryVariant = item.primaryVariant;
    final releaseDate = primaryEdition?.releaseDate;
    return LibraryMetadataItem(
      id: item.id,
      kind: item.kind,
      title: item.title,
      itemNumber: item.itemNumber,
      synopsis: item.synopsis,
      coverImageUrl: primaryVariant?.coverImageUrl ?? item.displayCoverUrl,
      thumbnailImageUrl:
          primaryVariant?.thumbnailImageUrl ?? item.displayCoverUrl,
      editionTitle: primaryEdition?.title,
      physicalFormat: primaryEdition?.physicalFormat,
      physicalFormatLabel: primaryEdition?.physicalFormatLabel,
      publisher: primaryEdition?.publisher ?? item.publisher,
      releaseDate: releaseDate,
      releaseYear: releaseDate?.year ?? item.series?.volumeStartYear,
      barcode: primaryVariant?.barcode ?? item.barcode,
      variant: primaryVariant?.name,
      series: item.series,
      publishing: item.publishing,
    );
  }

  Future<void> proposeCandidate(ProviderCandidate candidate) async {
    if (_isAdding) {
      return;
    }
    var currentCandidate = candidate;
    LibraryEditSelection? result;
    while (mounted) {
      final visibleCandidates = _visibleProviderResults();
      final currentIndex = visibleCandidates.indexWhere(
        (entry) => entry.localCatalogId == currentCandidate.localCatalogId,
      );
      ProviderCandidate? navigateCandidate;
      result = await showLibraryEditDialog(
        context: context,
        request: LibraryEditDialogRequest(
          type: widget.type,
          item: proposalDraftFromCandidate(currentCandidate),
          ownedItem: null,
          accent: LibraryAccentScope.accentOf(context),
          physicalFormats: _currentPhysicalFormats(),
          onPrevious: currentIndex > 0
              ? () {
                  navigateCandidate = visibleCandidates[currentIndex - 1];
                  Navigator.of(context).pop();
                }
              : null,
          onNext:
              currentIndex >= 0 && currentIndex < visibleCandidates.length - 1
                  ? () {
                      navigateCandidate = visibleCandidates[currentIndex + 1];
                      Navigator.of(context).pop();
                    }
                  : null,
        ),
      );
      if (!mounted) {
        return;
      }
      if (navigateCandidate != null) {
        currentCandidate = navigateCandidate!;
        continue;
      }
      break;
    }
    if (result == null || !mounted) {
      return;
    }
    _rebuild(() {
      _isAdding = true;
      _error = null;
    });
    try {
      final proposalItem = result.item;
      await createAndRecordLibraryMetadataProposal(
        api: ref.read(apiClientProvider),
        type: widget.type,
        provider: currentCandidate.provider,
        providerItemId: currentCandidate.providerItemId,
        query: _providerQuery,
        title: proposalItem.title,
        summary: proposalItem.synopsis ?? currentCandidate.summary,
        imageUrl: proposalItem.displayCoverUrl,
        metadataPayload: proposalItem.toSyncPayload(),
        source: 'Add ${widget.type.pluralLabel} provider result',
      );
      if (!mounted) {
        return;
      }
      showAppToast(
        context,
        '${widget.type.singularLabel} metadata proposal sent for review.',
        tone: AppToastTone.success,
      );
      Navigator.of(context).pop(
        LibraryAddDialogResult(
          target: LibraryAddTarget.track,
          itemIds: [result.item.id],
        ),
      );
    } catch (error) {
      if (mounted) {
        showAppToast(
          context,
          _describeMetadataProposalError(error),
          tone: AppToastTone.error,
        );
      }
    } finally {
      if (mounted) {
        _rebuild(() => _isAdding = false);
      }
    }
  }

  Future<void> queueProviderIngest(ProviderCandidate candidate) async {
    if (_isQueueingIngest ||
        _queuedProviderIngests.containsKey(candidate.localCatalogId)) {
      return;
    }
    _rebuild(() {
      _isQueueingIngest = true;
      _error = null;
    });
    try {
      final job =
          await ref.read(apiClientProvider).adminCreateProviderIngestJob(
                provider: candidate.provider,
                providerItemId: candidate.providerItemId,
              );
      if (!mounted) {
        return;
      }
      _rebuild(() {
        _queuedProviderIngests[candidate.localCatalogId] =
            LibraryQueuedProviderIngest(id: job.id, status: job.status);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Queued ${candidate.title} ingest job ${job.id} (${job.status}).',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        if (await _clearRejectedMetadataSession(
          error,
          'Core ingest queue',
        )) {
          return;
        }
        final api = ref.read(apiClientProvider);
        _rebuild(
          () => _error =
              'Core ingest queue failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)} Admin access is required to queue canonical ingest jobs.',
        );
      }
    } finally {
      if (mounted) {
        _rebuild(() => _isQueueingIngest = false);
      }
    }
  }

  LibraryMetadataItem proposalDraftFromCandidate(ProviderCandidate candidate) {
    return LibraryMetadataItem(
      id: buildPreviewCatalogItemId(
        kind: widget.type.workspace.kind.apiValue,
        provider: candidate.provider,
        providerItemId: candidate.providerItemId,
      ),
      kind: widget.type.workspace.kind.apiValue,
      title: candidate.title,
      synopsis: candidate.summary,
      coverImageUrl: candidate.imageUrl,
      thumbnailImageUrl: candidate.imageUrl,
    );
  }

  String _describeMetadataProposalError(Object error) {
    if (error case DioException dioError) {
      final statusCode = dioError.response?.statusCode;
      if (statusCode != null) {
        return 'Couldn\'t send the metadata proposal. Server responded with $statusCode.';
      }
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        return 'Couldn\'t send the metadata proposal. The request timed out.';
      }
      return 'Couldn\'t send the metadata proposal right now. Try again.';
    }
    final text = error.toString().trim();
    if (text.startsWith('StateError: ')) {
      return text.substring('StateError: '.length);
    }
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }
    return 'Couldn\'t send the metadata proposal. $text';
  }
}
