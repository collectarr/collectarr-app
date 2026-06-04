part of 'library_add_dialog.dart';

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
    if (edited.itemNumber != preview.itemNumber) {
      corrections['item_number'] = edited.itemNumber;
    }
    if (edited.synopsis != preview.synopsis) {
      corrections['synopsis'] = edited.synopsis;
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
    if (edited.publishing?.seriesGroup != preview.publishing?.seriesGroup) {
      corrections['series_group'] = edited.publishing?.seriesGroup;
    }
    if (edited.physicalFormat != preview.physicalFormat) {
      corrections['physical_format'] = edited.physicalFormat;
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
          imprint: corrections['imprint'] as String?,
          seriesGroup: corrections['series_group'] as String?,
          barcode: corrections['barcode'] as String?,
          variantName: corrections['variant_name'] as String?,
          physicalFormat: corrections['physical_format'] as String?,
          coverImageUrl: corrections['cover_image_url'] as String?,
          thumbnailImageUrl: corrections['thumbnail_image_url'] as String?,
          explicitFields: corrections.keys.toSet(),
        );
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
        metadataPayload: proposalItem.toCatalogItem().toSyncPayload(),
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
