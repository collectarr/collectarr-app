part of '../library_add_dialog.dart';

extension LibraryAddDefaultsControllerMixin on _LibraryAddDialogState {
  double _clampedResultsPaneWidth(double availableWidth) {
    final maxWidth = (availableWidth - _minPreviewPaneWidth)
        .clamp(_minResultsPaneWidth, _maxResultsPaneWidth)
        .toDouble();
    return _resultsPaneWidth.clamp(_minResultsPaneWidth, maxWidth).toDouble();
  }

  void _resizeResultsPane(double delta, double availableWidth) {
    setState(() {
      final maxWidth = (availableWidth - _minPreviewPaneWidth)
          .clamp(_minResultsPaneWidth, _maxResultsPaneWidth)
          .toDouble();
      _resultsPaneWidth =
          (_resultsPaneWidth + delta).clamp(_minResultsPaneWidth, maxWidth);
    });
  }

  Future<void> _loadAvailableLocations() async {
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _availableLocations = locations;
    });
  }

  LibraryAddLocalRerankHints _currentLocalRerankHints() {
    return LibraryAddLocalRerankHints(
      query: _queryController.text.trim(),
      series: _searchSeriesController.text.trim(),
      issueNumber: _searchNumberController.text.trim(),
      publisher: _searchPublisherController.text.trim(),
      year: int.tryParse(_searchYearController.text.trim()),
    );
  }

  Future<void> _loadPrefillDefaults() async {
    final defaults = await PrefillDefaults.load();
    if (!mounted) {
      return;
    }
    setState(() {
      if (defaults.condition?.trim().isNotEmpty == true) {
        _defaultCondition = defaults.condition!.trim();
      }
      if (defaults.grade?.trim().isNotEmpty == true) {
        _defaultGrade = defaults.grade!.trim();
      }
      _defaultReadStatus = defaults.readStatus;
      _defaultTags = defaults.tags;
      _defaultLocationId = defaults.locationId;
    });
    await _loadPickListOptions();
  }

  Future<void> _loadPickListOptions() async {
    final options = await loadConditionGradePickListOptions(
      ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      builtInConditions: widget.type.conditions,
      builtInGrades: widget.type.grades,
      selectedCondition: _defaultCondition,
      selectedGrade: _defaultGrade,
    );
    final tagOptions = await loadTagPickListOptions(
      ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      selectedTags: splitPickListValues(_defaultTags),
    );
    final db = ref.read(localDatabaseProvider);
    final vocabularyResults = await Future.wait<dynamic>([
      loadSingleValuePickListOptions(
        db,
        listName: kPublisherPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _publisherController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kImprintPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _imprintController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kSeriesGroupPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _seriesGroupController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kPhysicalFormatPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        builtInValues: [
          for (final format in _currentPhysicalFormats()) format.label,
        ],
        selectedValue: _physicalFormatLabelController.text,
      ),
      SeriesRegistryRepository(db).searchEntries(
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedTitle: _titleController.text,
        selectedSeriesId: _selectedManualSeriesId,
      ),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _conditionOptions = options.conditions;
      _gradeOptions = options.grades;
      _tagOptions = tagOptions;
      _publisherOptions =
          List<String>.from(vocabularyResults[0] as List<String>);
      _imprintOptions = List<String>.from(vocabularyResults[1] as List<String>);
      _seriesGroupOptions =
          List<String>.from(vocabularyResults[2] as List<String>);
      _physicalFormatOptions =
          List<String>.from(vocabularyResults[3] as List<String>);
      _manualSeriesEntries = List<SeriesRegistryEntry>.from(
        vocabularyResults[4] as List<SeriesRegistryEntry>,
      );
    });
  }

  Future<void> _manageSingleValuePickList({
    required String listName,
    required String label,
    List<String> builtInValues = const [],
  }) async {
    await showPickListEditorDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      listName: listName,
      label: label,
      mediaKind: widget.type.workspace.kind.apiValue,
      builtInValues: builtInValues,
    );
    if (!mounted) {
      return;
    }
    await _loadPickListOptions();
  }

  Future<void> _openManualSeriesPicker() async {
    final selected = await showSeriesPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      selectedTitle: _titleController.text,
      selectedSeriesId: _selectedManualSeriesId,
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      _selectedManualSeriesId = selected.coreSeriesId;
      _titleController.value = TextEditingValue(
        text: selected.title,
        selection: TextSelection.collapsed(offset: selected.title.length),
      );
    });
    await _loadPickListOptions();
  }

  void _setManualSeries(String? value) {
    final normalized = _emptyToNull(value ?? '');
    final match = _manualSeriesEntries.cast<SeriesRegistryEntry?>().firstWhere(
          (entry) =>
              entry != null &&
              entry.title.trim().toLowerCase() ==
                  (normalized?.toLowerCase() ?? ''),
          orElse: () => null,
        );
    setState(() {
      _selectedManualSeriesId = match?.coreSeriesId;
    });
  }

  List<String> get _manualPhysicalFormatOptions {
    return mergePickListValues(
      builtInValues: [
        for (final format in _currentPhysicalFormats()) format.label
      ],
      customValues: _physicalFormatOptions,
      selectedValues: [_physicalFormatLabelController.text],
    );
  }

  Future<void> _showDefaultTagsEditor() async {
    final controller = TextEditingController(text: _defaultTags ?? '');
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AccentAlertDialog(
          title: const Text('Owned default tags'),
          content: SizedBox(
            width: 440,
            child: TagPickListField(
              controller: controller,
              options: _tagOptions,
              label: 'Tags',
              hint: 'Comma-separated tags',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                joinPickListValues(splitPickListValues(controller.text)) ?? '',
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      );
      if (!mounted || result == null) {
        return;
      }
      setState(() {
        _defaultTags = result.isEmpty ? null : result;
      });
    } finally {
      controller.dispose();
    }
  }

  String? get _defaultLocationLabel =>
      locationPathForId(_availableLocations, _defaultLocationId);

  Future<void> _pickDefaultLocation() async {
    final result = await showLocationPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      currentLocationId: _defaultLocationId,
    );
    if (result == null) {
      return;
    }
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _defaultLocationId = result.isEmpty ? null : result;
      _availableLocations = locations;
    });
  }

  Future<void> _search() async {
    final searchLabels = libraryMediaSearchFieldLabels(widget.type);
    final query = _queryController.text.trim();
    if (query.isEmpty &&
        _searchSeriesController.text.trim().isEmpty &&
        _searchNumberController.text.trim().isEmpty &&
        _searchPublisherController.text.trim().isEmpty &&
        _searchYearController.text.trim().isEmpty) {
      setState(() => _error = searchLabels.emptySearchMessage);
      return;
    }
    final searchGeneration = ++_coreSearchGeneration;
    setState(() {
      _isSearching = true;
      _error = null;
      _providerResults = const [];
      _providerPreviews.clear();
      _searchedProvider = false;
    });
    final series = _searchSeriesController.text.trim();
    final issueNumber = _searchNumberController.text.trim();
    final publisher = _searchPublisherController.text.trim();
    final yearText = _searchYearController.text.trim();
    final year = yearText.isNotEmpty ? int.tryParse(yearText) : null;
    try {
      final api = ref.read(apiClientProvider);
      final searchResult = await runLibraryAddCoreSearch(
        api: api,
        type: widget.type,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        input: LibraryMetadataSearchInput(
          query: query.isNotEmpty ? query : null,
          series: series.isNotEmpty ? series : null,
          issueNumber: issueNumber.isNotEmpty ? issueNumber : null,
          publisher: publisher.isNotEmpty ? publisher : null,
          year: year,
          limit: 20,
        ),
        timeout: _coreSearchTimeout,
        rerankHints: _currentLocalRerankHints(),
        providerSearchAvailable:
            widget.type.supportedMetadataProviders.isNotEmpty,
      );
      if (mounted && searchGeneration == _coreSearchGeneration) {
        setState(() {
          _results = searchResult.items;
          _selectedResultId = null;
          _selectedProviderCandidateId = null;
          _resetReferenceSelection();
          _clearSelectionCaches();
        });
        _precacheMetadataCovers(searchResult.items);
      }
      if (mounted &&
          searchGeneration == _coreSearchGeneration &&
          searchResult.shouldSearchProvider) {
        await _searchProvider(
          queryOverride: query,
          bypassDebounce: true,
        );
      }
    } catch (error) {
      if (mounted && searchGeneration == _coreSearchGeneration) {
        if (await _clearRejectedMetadataSession(error, 'Core search')) {
          return;
        }
        final api = ref.read(apiClientProvider);
        setState(
          () => _error =
              'Core search failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)} Manual add still works.',
        );
      }
    } finally {
      if (mounted && searchGeneration == _coreSearchGeneration) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _onQueryChanged(String value) {
    final query = value.trim();
    if (query.length < 2) {
      _autocompleteTimer?.cancel();
      if (_showSuggestions) {
        setState(() {
          _suggestions = const [];
          _showSuggestions = false;
        });
      }
      return;
    }
    _autocompleteTimer?.cancel();
    _autocompleteTimer = Timer(_autocompleteDebounce, () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final api = ref.read(apiClientProvider);
      final filtered = await fetchLibraryAddSuggestions(
        api: api,
        type: widget.type,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        query: query,
        limit: _autocompleteLimit,
      );
      if (!mounted) return;
      setState(() {
        _suggestions = filtered;
        _showSuggestions = filtered.isNotEmpty;
      });
    } catch (_) {
      // Silently ignore autocomplete failures — the user can still press Search.
    }
  }

  void _selectSuggestion(LibraryMetadataItem item) {
    _queryController.text = item.title;
    setState(() {
      _showSuggestions = false;
      _suggestions = const [];
      _results = [item];
      _selectedResultId = item.id;
      _selectedProviderCandidateId = null;
      _resetReferenceSelection();
      _clearSelectionCaches();
    });
    _ensureSelectedResultLoaded(item.id);
    _ensureBundleReleasesLoaded(item.id);
  }

  void _dismissSuggestions() {
    if (_showSuggestions) {
      setState(() => _showSuggestions = false);
    }
  }

  Future<void> _scanCover() async {
    if (_isScanningCover) {
      return;
    }
    setState(() {
      _isScanningCover = true;
      _error = null;
    });
    try {
      final result = await widget.coverScanService.scanCover(
        context: context,
        type: widget.type,
      );
      if (!mounted || result == null) {
        return;
      }
      if (!result.hasAnyHint) {
        setState(() {
          _error = result.warnings.isEmpty
              ? 'Cover scan did not extract usable search hints yet.'
              : result.warnings.first;
          _coverScanPrefill = null;
        });
        return;
      }
      final query = (result.query ?? result.series ?? '').trim();
      setState(() {
        _mode = LibraryAddDialogMode.search;
        _queryController.text = query;
        _searchSeriesController.text = result.series?.trim() ?? '';
        _searchNumberController.text = result.issueNumber?.trim() ?? '';
        _searchPublisherController.text = result.publisher?.trim() ?? '';
        _searchYearController.text = result.year?.toString() ?? '';
        _showAdvancedSearch = result.showAdvancedFields;
        _coverScanPrefill = result;
        _results = const [];
        _providerResults = const [];
        _selectedResultId = null;
        _selectedProviderCandidateId = null;
        _resetReferenceSelection();
        _clearSelectionCaches();
        _providerPreviews.clear();
        _searchedProvider = false;
      });
      await _search();
    } finally {
      if (mounted) {
        setState(() => _isScanningCover = false);
      }
    }
  }

  Future<void> _lookupBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      setState(() => _error = 'Enter a barcode / UPC / ISBN.');
      return;
    }
    final searchGeneration = ++_coreSearchGeneration;
    setState(() {
      _isSearching = true;
      _error = null;
      _providerResults = const [];
      _providerPreviews.clear();
      _searchedProvider = false;
    });
    try {
      final api = ref.read(apiClientProvider);
      final lookupResult = await runLibraryAddBarcodeLookup(
        api: api,
        type: widget.type,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        barcode: barcode,
        timeout: _coreSearchTimeout,
        providerSearchAvailable:
            widget.type.supportedMetadataProviders.isNotEmpty,
      );
      if (mounted && searchGeneration == _coreSearchGeneration) {
        setState(() {
          _results = lookupResult.items;
          _selectedResultId = null;
          _selectedProviderCandidateId = null;
          _resetReferenceSelection();
          _clearSelectionCaches();
          _error = lookupResult.items.isEmpty &&
                  widget.type.supportedMetadataProviders.isEmpty
              ? 'No item found for barcode $barcode.'
              : null;
        });
        _precacheMetadataCovers(lookupResult.items);
      }
      if (mounted &&
          searchGeneration == _coreSearchGeneration &&
          lookupResult.shouldSearchProvider) {
        await _searchProvider(queryOverride: barcode);
      }
    } catch (error) {
      if (mounted && searchGeneration == _coreSearchGeneration) {
        if (await _clearRejectedMetadataSession(error, 'Barcode lookup')) {
          return;
        }
        final api = ref.read(apiClientProvider);
        setState(
          () => _error =
              'Barcode lookup failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)} Manual add keeps the scanned code.',
        );
      }
    } finally {
      if (mounted && searchGeneration == _coreSearchGeneration) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _addManual(LibraryAddTarget target) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Manual item needs a title.');
      return;
    }
    await _openManualEditor(target);
  }

  Future<void> _openManualEditor(LibraryAddTarget target) async {
    final draft = _buildManualDraftItem();
    final customFieldValuesForEdit = _manualCustomFieldValues.entries
        .map((e) => CustomFieldValue(
              id: 'local-${e.key}-${_uuid.v4()}',
              targetId: 'local-${e.key}',
              targetScope: CustomFieldTargetScope.ownedCopy,
              fieldDefinitionId: e.key,
              value: e.value,
              updatedAt: DateTime.now().toUtc(),
            ))
        .toList(growable: false);
    final result = await showLibraryEditDialog(
      context: context,
      request: LibraryEditDialogRequest(
        type: widget.type,
        item: draft,
        ownedItem: _manualDraftOwnedItem(draft, target),
        accent: LibraryAccentScope.accentOf(context),
        physicalFormats: _currentPhysicalFormats(),
        customFieldDefinitions: widget.customFieldDefinitions,
        customFieldValues: customFieldValuesForEdit,
        itemImages: _manualItemImages,
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    await _addItems(
      [result.item],
      target,
      defaults: const LibraryAddDefaults(),
      ownedDetailsByItemId: result.personal == null
          ? const <String, LibraryAddOwnedDetails>{}
          : {
              result.item.id: _ownedDetailsFromSelection(result),
            },
    );
  }

  LibraryMetadataItem _buildManualDraftItem() {
    TextEditingController ctl(String key, TextEditingController fallback) {
      final e = _manualKindSpecific[key];
      if (e is TextEditingController) return e;
      return fallback;
    }

    final year =
        int.tryParse(ctl('yearController', _yearController).text.trim());
    final coverUrl =
        _emptyToNull(ctl('coverController', _coverController).text);
    final releaseDate =
        parseDate(ctl('releaseDateController', _releaseDateController).text);
    final pageCount =
        parseInt(ctl('pageCountController', _pageCountController).text);
    final genres = ctl('genresEditController', _genresEditController)
        .text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    final creatorNames = ctl('creatorsController', _creatorsController)
        .text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    final creators = creatorNames.isEmpty
        ? null
        : [
            for (final n in creatorNames) {'name': n}
          ];
    final characterNames = ctl('charactersController', _charactersController)
        .text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    final characters = characterNames.isEmpty ? null : characterNames;
    final linkCandidates = ctl('linksController', _linksController)
        .text
        .split(RegExp(r'[\n,]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    final trailerUrls = linkCandidates.isEmpty
        ? const <TrailerLink>[]
        : [
            for (final u in linkCandidates)
              TrailerLink(url: u, isAutomatic: false)
          ];
    return LibraryMetadataItem(
      id: 'local-${widget.type.workspace.kind.apiValue}-${_uuid.v4()}',
      kind: widget.type.workspace.kind.apiValue,
      title: _titleController.text.trim(),
      itemNumber: _emptyToNull(ctl('numberController', _numberController).text),
      editionTitle: _emptyToNull(
          ctl('editionTitleController', _editionTitleController).text),
      physicalFormat: _physicalFormatId,
      physicalFormatLabel: _emptyToNull(_physicalFormatLabelController.text) ??
          _physicalFormatForId(_physicalFormatId)?.label,
      publisher:
          _emptyToNull(ctl('publisherController', _publisherController).text),
      releaseDate: releaseDate,
      releaseYear: year,
      barcode: _emptyToNull(ctl('barcodeController', _barcodeController).text),
      variant: _emptyToNull(ctl('variantController', _variantController).text),
      coverImageUrl: coverUrl,
      thumbnailImageUrl: coverUrl,
      synopsis:
          _emptyToNull(ctl('synopsisController', _synopsisController).text),
      genres: genres.isEmpty ? null : genres,
      creators: creators,
      characters: characters,
      trailerUrls: trailerUrls,
      country: _emptyToNull(ctl('countryController', _countryController).text),
      language:
          _emptyToNull(ctl('languageController', _languageController).text),
      ageRating:
          _emptyToNull(ctl('ageRatingController', _ageRatingController).text),
      series: widget.type.manualAddUsesTitleAsSeries
          ? CatalogSeriesDetails(
              seriesId: _selectedManualSeriesId,
              seriesTitle: _emptyToNull(_titleController.text),
            )
          : null,
      publishing: (pageCount != null ||
              _imprintController.text.trim().isNotEmpty ||
              _seriesGroupController.text.trim().isNotEmpty)
          ? CatalogPublishingDetails(
              pageCount: pageCount,
              imprint: _emptyToNull(
                  ctl('imprintController', _imprintController).text),
              seriesGroup: _emptyToNull(
                  ctl('seriesGroupController', _seriesGroupController).text),
            )
          : null,
    );
  }

  OwnedItem? _manualDraftOwnedItem(
    LibraryMetadataItem item,
    LibraryAddTarget target,
  ) {
    if (target != LibraryAddTarget.owned) {
      return null;
    }
    TextEditingController ctl(String key, TextEditingController fallback) {
      final e = _manualKindSpecific[key];
      if (e is TextEditingController) return e;
      return fallback;
    }

    String? ctlTextOrNull(String key, [TextEditingController? fallback]) {
      final e = _manualKindSpecific[key];
      final controller = e is TextEditingController ? e : fallback;
      final value = controller?.text.trim() ?? '';
      return value.isEmpty ? null : value;
    }

    final purchaseDate = parseDate(
            ctl('purchaseDateController', _purchaseDateController).text) ??
        _defaultPurchaseDate;
    final pricePaidCents =
        parseMoneyCents(ctl('purchasePriceController', _priceController).text);
    final coverPriceCents = parseMoneyCents(
        ctl('coverPriceController', _coverPriceController).text);
    final sellPriceCents =
        parseMoneyCents(ctl('soldPriceController', _sellPriceController).text);
    final soldAt = _soldAt;
    return OwnedItem(
      id: 'manual-owned-${_uuid.v4()}',
      catalogRef: CatalogEntityRef(
        kind: item.kind,
        entityType: CatalogEntityType.work,
        id: item.id,
      ),
      condition: _defaultCondition,
      grade: _defaultGrade,
      purchaseDate: purchaseDate,
      pricePaidCents: pricePaidCents,
      currency: null,
      personalNotes: ctl('personalNotesController', _personalNotesController)
              .text
              .trim()
              .isEmpty
          ? null
          : ctl('personalNotesController', _personalNotesController)
              .text
              .trim(),
      quantity: 1,
      coverPriceCents: coverPriceCents,
      rawOrSlabbed:
          ctlTextOrNull('rawOrSlabbedController', _rawOrSlabbedController),
      gradingCompany:
          ctlTextOrNull('gradingCompanyController', _gradingCompanyController),
      graderNotes:
          ctlTextOrNull('graderNotesController', _graderNotesController),
      signedBy: ctlTextOrNull('signedByController', _signedByController),
      labelType: ctlTextOrNull('labelTypeController', _labelTypeController),
      pageQuality: ctlTextOrNull('pageQualityController'),
      certificationNumber: ctlTextOrNull(
        'certificationNumberController',
        _certificationNumberController,
      ),
      updatedAt: DateTime.now().toUtc(),
      soldAt: soldAt,
      sellPriceCents: sellPriceCents,
      ownerLabel:
          ctl('ownerLabelController', _ownerLabelController).text.trim().isEmpty
              ? null
              : ctl('ownerLabelController', _ownerLabelController).text.trim(),
      locationId: _defaultLocationId,
      tags: ctl('tagsController', _tagsController).text.trim().isEmpty
          ? null
          : ctl('tagsController', _tagsController).text.trim(),
      purchaseStore: ctl('purchaseStoreController', _purchaseStoreController)
              .text
              .trim()
              .isEmpty
          ? null
          : ctl('purchaseStoreController', _purchaseStoreController)
              .text
              .trim(),
    );
  }

  LibraryAddOwnedDetails _ownedDetailsFromSelection(
    LibraryEditSelection selection,
  ) {
    final personal = selection.personal;
    if (personal == null) {
      return const LibraryAddOwnedDetails();
    }
    return LibraryAddOwnedDetails(
      editionId: personal.editionId,
      variantId: personal.variantId,
      condition: personal.condition,
      grade: personal.grade,
      purchaseDate: personal.purchaseDate,
      pricePaidCents: personal.pricePaidCents,
      currency: personal.currency,
      personalNotes: personal.personalNotes,
      quantity: personal.quantity,
      locationId: personal.locationId,
      coverPriceCents: personal.coverPriceCents,
      rawOrSlabbed: personal.rawOrSlabbed,
      gradingCompany: personal.gradingCompany,
      graderNotes: personal.graderNotes,
      signedBy: personal.signedBy,
      labelType: personal.labelType,
      certificationNumber: personal.certificationNumber,
      keyComic: personal.keyComic ?? false,
      keyReason: personal.keyReason,
      rating: selection.tracking?.rating,
      readStatus: selection.tracking?.readStatus,
      startedAt: selection.tracking?.startedAt,
      finishedAt: selection.tracking?.finishedAt,
      progressCurrent: selection.tracking?.progressCurrent,
      progressTotal: selection.tracking?.progressTotal,
      timesCompleted: selection.tracking?.timesCompleted,
      trackingNotes: selection.tracking?.notes,
      seasonNumber: selection.tracking?.seasonNumber,
      episodeNumber: selection.tracking?.episodeNumber,
      tags: personal.tags,
      soldAt: personal.soldAt,
      sellPriceCents: personal.sellPriceCents,
      soldTo: personal.soldTo,
    );
  }

  void _setPhysicalFormat(String? value) {
    final format = _physicalFormatForId(value);
    final previousFormat = _physicalFormatForId(_physicalFormatId);
    final shouldReplaceVariant = _variantController.text.trim().isEmpty ||
        previousFormat?.label == _variantController.text.trim();
    setState(() {
      _physicalFormatId = format?.id;
      _physicalFormatLabelController.text = format?.label ?? '';
      if (format != null && shouldReplaceVariant) {
        _variantController.text = format.label;
      }
    });
  }

  void _setPhysicalFormatLabel(String? value) {
    final normalized = _emptyToNull(value ?? '');
    final format = physicalMediaFormatByLabelOrId(
      normalized,
      formats: _currentPhysicalFormats(),
    );
    final previousFormat = _physicalFormatForId(_physicalFormatId);
    final shouldReplaceVariant = _variantController.text.trim().isEmpty ||
        previousFormat?.label == _variantController.text.trim();
    setState(() {
      _physicalFormatId = format?.id;
      if (format != null && shouldReplaceVariant) {
        _variantController.text = format.label;
      }
    });
  }

  PhysicalMediaFormat? _physicalFormatForId(String? id) {
    final normalized = _emptyToNull(id ?? '');
    if (normalized == null) {
      return null;
    }
    return physicalMediaFormatById(
      normalized,
      formats: _currentPhysicalFormats(),
    );
  }

  List<PhysicalMediaFormat> _currentPhysicalFormats() {
    return physicalMediaFormatsForKind(
      ref.read(mediaCatalogProvider).maybeWhen(
            data: (value) => value,
            orElse: () => fallbackMediaCatalog,
          ),
      widget.type.workspace.kind,
    );
  }

  Future<void> _searchProvider({
    String? queryOverride,
    bool bypassDebounce = false,
  }) async {
    final query = queryOverride?.trim().isNotEmpty == true
        ? queryOverride!.trim()
        : _providerQuery;
    if (query.isEmpty) {
      setState(() => _error = 'Enter a title, barcode, or keyword.');
      return;
    }
    final provider = _activeProvider;
    ++_providerSearchGeneration;
    final debounceDecision = evaluateLibraryAddProviderSearchDebounce(
      provider: provider,
      query: query,
      debounce: _providerSearchDebounce,
      now: DateTime.now(),
      previousSignature: _lastProviderSearchSignature,
      previousAt: _lastProviderSearchAt,
    );
    _lastProviderSearchSignature = debounceDecision.signature;
    _lastProviderSearchAt = debounceDecision.at;
    if (_isSearchingProvider ||
        (!bypassDebounce && debounceDecision.shouldSkip)) {
      return;
    }
    setState(() {
      _isSearchingProvider = true;
      _searchedProvider = true;
      _providerResults = const [];
      _providerPreviews.clear();
      _pendingProviderPreviewIds.clear();
      _selectedProviderCandidateId = null;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final kindsToSearch = _isVideoKind
          ? (_videoKindFilters.isEmpty
              ? _allVideoSearchKinds
              : _videoKindFilters
                  .map(_canonicalVideoSearchKind)
                  .toSet()
                  .toList())
          : <String>[];
      final seriesText = _searchSeriesController.text.trim().isNotEmpty
          ? _searchSeriesController.text.trim()
          : null;
      final issueText = _searchNumberController.text.trim().isNotEmpty
          ? _searchNumberController.text.trim()
          : null;
      final yearValue = _searchYearController.text.trim().isNotEmpty
          ? int.tryParse(_searchYearController.text.trim())
          : null;
      final rerankHints = _currentLocalRerankHints();

      List<ProviderCandidate> results;
      if (kindsToSearch.length > 1) {
        final futures = kindsToSearch.map((kind) async {
          try {
            return await runLibraryAddProviderSearch(
              api: api,
              type: widget.type,
              provider: provider,
              query: query,
              rerankHints: rerankHints,
              series: seriesText,
              issueNumber: issueText,
              year: yearValue,
              kindOverride: kind,
            );
          } catch (_) {
            return <ProviderCandidate>[];
          }
        });
        final allResults = await Future.wait(futures);
        results = allResults.expand((r) => r).toList();
      } else if (kindsToSearch.length == 1) {
        results = await runLibraryAddProviderSearch(
          api: api,
          type: widget.type,
          provider: provider,
          query: query,
          rerankHints: rerankHints,
          series: seriesText,
          issueNumber: issueText,
          year: yearValue,
          kindOverride: kindsToSearch.first,
        );
      } else {
        results = await runLibraryAddProviderSearch(
          api: api,
          type: widget.type,
          provider: provider,
          query: query,
          rerankHints: rerankHints,
          series: seriesText,
          issueNumber: issueText,
          year: yearValue,
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _providerResults = results;
        _selectedProviderCandidateId = null;
        _pendingProviderPreviewIds.clear();
      });
      _precacheProviderCandidateCovers(results);
    } catch (error) {
      if (mounted) {
        if (_isMissingBearerTokenError(error)) {
          setState(() => _error = null);
          return;
        }
        if (await _clearRejectedMetadataSession(error, 'Provider search')) {
          return;
        }
        final api = ref.read(apiClientProvider);
        setState(
          () => _error =
              'Provider search failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSearchingProvider = false);
      }
    }
  }

  Future<void> _ensureProviderPreviewLoaded(String candidateId) async {
    if (_providerPreviews.containsKey(candidateId) ||
        _pendingProviderPreviewIds.contains(candidateId)) {
      return;
    }
    ProviderCandidate? candidate;
    for (final value in _providerResults) {
      if (value.localCatalogId == candidateId) {
        candidate = value;
        break;
      }
    }
    if (candidate == null || candidate.isStub) {
      return;
    }
    final searchGeneration = _providerSearchGeneration;
    setState(() {
      _pendingProviderPreviewIds.add(candidateId);
    });
    try {
      final api = ref.read(apiClientProvider);
      final preview = await api.providerPreview(
        provider: candidate.provider,
        providerItemId: candidate.providerItemId,
      );
      if (!mounted || searchGeneration != _providerSearchGeneration) {
        return;
      }
      setState(() {
        _providerPreviews[candidateId] = preview;
        _pendingProviderPreviewIds.remove(candidateId);
      });
      _precacheProviderPreviewCovers([preview]);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message:
            'Failed to load provider preview for ${candidate.provider}:${candidate.providerItemId}.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || searchGeneration != _providerSearchGeneration) {
        return;
      }
      setState(() {
        _pendingProviderPreviewIds.remove(candidateId);
      });
    }
  }

  Future<void> _ensureSelectedResultLoaded(String itemId) async {
    if (_hydratedResults.containsKey(itemId) ||
        _pendingHydratedResultIds.contains(itemId)) {
      return;
    }
    LibraryMetadataItem? selected;
    for (final item in _results) {
      if (item.id == itemId) {
        selected = item;
        break;
      }
    }
    if (selected == null) {
      return;
    }
    final searchGeneration = _coreSearchGeneration;
    setState(() {
      _pendingHydratedResultIds.add(itemId);
    });
    try {
      final hydrated = await ref
          .read(apiClientProvider)
          .getTypedMetadataItem(
            kind: selected.kind,
            id: itemId,
          )
          .then((dto) {
        final sourceSelection = selected!;
        final raw = <String, dynamic>{
          ...dto.raw,
          'id': dto.id,
          'title': dto.title,
          'kind': dto.kind,
          if (!dto.raw.containsKey('editions') &&
              sourceSelection.editions.isNotEmpty)
            'editions': [
              for (final edition in sourceSelection.editions) edition.toJson(),
            ],
          if (!dto.raw.containsKey('track_count') &&
              sourceSelection.music?.trackCount != null)
            'track_count': sourceSelection.music!.trackCount,
          if (!dto.raw.containsKey('tracks') &&
              (sourceSelection.music?.tracks.isNotEmpty ?? false))
            'tracks': [
              for (final track in sourceSelection.music!.tracks) track.toJson(),
            ],
        };
        return CatalogItem.fromJson(raw);
      });
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      final hydratedItem = LibraryMetadataItem.fromCatalogItem(hydrated);
      final mergedItem = hydratedItem.copyWith(
        editions: hydratedItem.editions.isNotEmpty
            ? hydratedItem.editions
            : selected.editions,
        coverImageUrl: hydratedItem.displayCoverUrl != null
            ? hydratedItem.coverImageUrl
            : selected.coverImageUrl,
        thumbnailImageUrl: hydratedItem.displayCoverUrl != null
            ? hydratedItem.thumbnailImageUrl
            : selected.thumbnailImageUrl ?? selected.coverImageUrl,
      );
      setState(() {
        _hydratedResults[itemId] = mergedItem;
        _pendingHydratedResultIds.remove(itemId);
      });
      _precacheMetadataCovers([mergedItem]);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message: 'Failed to hydrate add-result metadata for item $itemId.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _pendingHydratedResultIds.remove(itemId);
      });
    }
  }

  Future<void> _ensureBundleReleasesLoaded(String itemId) async {
    if (_bundleReleasesByItemId.containsKey(itemId) ||
        _pendingBundleReleaseItemIds.contains(itemId)) {
      return;
    }
    final searchGeneration = _coreSearchGeneration;
    setState(() {
      _pendingBundleReleaseItemIds.add(itemId);
    });
    try {
      final bundleReleases =
          await ref.read(apiClientProvider).getItemBundleReleases(itemId);
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      final firstBundleId = _selectedBundleReleaseId ??
          (bundleReleases.isNotEmpty ? bundleReleases.first.id : null);
      setState(() {
        _bundleReleasesByItemId[itemId] = bundleReleases;
        _pendingBundleReleaseItemIds.remove(itemId);
        if (_referenceType == LibraryAddReferenceType.bundleRelease) {
          _selectedBundleReleaseId = firstBundleId;
        }
      });
      if (_referenceType == LibraryAddReferenceType.bundleRelease &&
          firstBundleId != null) {
        unawaited(_ensureBundleReleaseDetailLoaded(firstBundleId));
      }
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message: 'Failed to load bundle releases for $itemId.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _bundleReleasesByItemId[itemId] = const <BundleReleaseSummary>[];
        _pendingBundleReleaseItemIds.remove(itemId);
      });
    }
  }

  Future<void> _ensureBundleReleaseDetailLoaded(String bundleReleaseId) async {
    if (_bundleReleaseDetailsById.containsKey(bundleReleaseId) ||
        _pendingBundleReleaseDetailIds.contains(bundleReleaseId)) {
      return;
    }
    final searchGeneration = _coreSearchGeneration;
    setState(() {
      _pendingBundleReleaseDetailIds.add(bundleReleaseId);
    });
    try {
      final bundleRelease =
          await ref.read(apiClientProvider).getBundleRelease(bundleReleaseId);
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _bundleReleaseDetailsById[bundleReleaseId] = bundleRelease;
        _pendingBundleReleaseDetailIds.remove(bundleReleaseId);
      });
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message: 'Failed to load bundle release detail for $bundleReleaseId.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _pendingBundleReleaseDetailIds.remove(bundleReleaseId);
      });
    }
  }

  void _precacheMetadataCovers(List<LibraryMetadataItem> items) {
    unawaited(
      _precacheCoverUrls([
        for (final item in items) item.coverImageUrl,
        for (final item in items) item.thumbnailImageUrl,
      ]),
    );
  }

  void _precacheProviderCandidateCovers(List<ProviderCandidate> candidates) {
    unawaited(
      _precacheCoverUrls([
        for (final candidate in candidates) candidate.imageUrl,
      ]),
    );
  }

  void _precacheProviderPreviewCovers(Iterable<AdminProviderPreview> previews) {
    unawaited(
      _precacheCoverUrls([
        for (final preview in previews) preview.coverImageUrl,
      ]),
    );
  }

  Future<void> _precacheCoverUrls(Iterable<String?> urls) async {
    if (!mounted) {
      return;
    }
    return;
  }

  bool _isMissingBearerTokenError(Object error) {
    if (error is! DioException) {
      return false;
    }
    if (error.response?.statusCode != 401) {
      return false;
    }
    final data = error.response?.data;
    if (data is! Map) {
      return false;
    }
    final code = data['code']?.toString().trim();
    return code == 'missing_bearer_token';
  }

  Future<bool> _clearRejectedMetadataSession(
    Object error,
    String action,
  ) async {
    final cleared =
        await ref.read(authControllerProvider.notifier).clearSessionIfRejected(
              error,
            );
    if (!cleared) {
      return false;
    }
    if (!mounted) {
      return true;
    }
    setState(() {
      _isSearching = false;
      _isSearchingProvider = false;
      _isAdding = false;
      _isQueueingIngest = false;
      _error = 'Saved metadata session was cleared after $action was rejected. '
          'Retry the action. Sign in again only if you need authenticated tools.';
    });
    return true;
  }

  String get _activeProvider {
    final providers = widget.type.supportedMetadataProviders;
    for (final provider in providers) {
      if (provider.id == _selectedProvider) {
        return provider.id;
      }
    }
    return widget.type.defaultSupportedMetadataProvider;
  }

  LibraryMetadataItem? get _selectedResult {
    final id = _selectedResultId;
    if (id == null) {
      return null;
    }
    final hydrated = _hydratedResults[id];
    if (hydrated != null) {
      return hydrated;
    }
    for (final item in _results) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  BundleReleaseDetail? get _selectedBundleReleaseDetail {
    final bundleReleaseId = _selectedBundleReleaseId;
    if (bundleReleaseId == null) {
      return null;
    }
    return _bundleReleaseDetailsById[bundleReleaseId];
  }

  LibraryAddEditionSelection? _selectedEditionSelectionForItem(
    LibraryMetadataItem item,
  ) {
    final edition = _previewEditionForItem(item, _selectedReferenceEditionId);
    if (edition == null) {
      return null;
    }
    final variant = _selectedVariantForEdition(
      edition,
      _selectedReferenceVariantId,
    );
    return LibraryAddEditionSelection(
      editionId: edition.id,
      variantId: variant?.id,
    );
  }

  ProviderCandidate? get _selectedProviderCandidate {
    final id = _selectedProviderCandidateId;
    if (id == null) {
      return null;
    }
    for (final candidate in _providerResults) {
      if (candidate.localCatalogId == id) {
        return candidate;
      }
    }
    return null;
  }

  String get _providerQuery {
    return buildLibraryAddProviderQuery([
      _queryController.text,
      _searchSeriesController.text,
      _searchNumberController.text,
      _searchPublisherController.text,
      _searchYearController.text,
      _barcodeController.text,
    ]);
  }

  Future<List<LibraryMetadataItem>> _resolveCoreItemsForAdd(
    List<LibraryMetadataItem> items,
  ) async {
    if (items.isEmpty) {
      return const <LibraryMetadataItem>[];
    }
    final api = ref.read(apiClientProvider);
    final resolved = await Future.wait(
      items.map((item) async {
        final hydrated = _hydratedResults[item.id];
        if (hydrated != null) {
          return hydrated;
        }
        if (item.id.startsWith('local-') ||
            item.id.startsWith('preview-') ||
            item.id.startsWith('provider:')) {
          return item;
        }
        try {
          final full = await api
              .getTypedMetadataItem(
                kind: item.kind,
                id: item.id,
              )
              .then(
                (dto) => CatalogItem.fromJson({
                  ...dto.raw,
                  'id': dto.id,
                  'title': dto.title,
                  'kind': dto.kind,
                }),
              );
          var fullItem = LibraryMetadataItem.fromCatalogItem(full);
          if (fullItem.editions.isEmpty && item.editions.isNotEmpty) {
            fullItem = fullItem.copyWith(editions: item.editions);
          }
          final fallbackMusic = item.music;
          final currentMusic = fullItem.music;
          if (fallbackMusic != null && currentMusic != null) {
            final mergedMusic = MusicCatalogDetails(
              trackCount: currentMusic.trackCount ?? fallbackMusic.trackCount,
              tracks: currentMusic.tracks.isNotEmpty
                  ? currentMusic.tracks
                  : fallbackMusic.tracks,
              discs: currentMusic.discs.isNotEmpty
                  ? currentMusic.discs
                  : fallbackMusic.discs,
              catalogNumber:
                  currentMusic.catalogNumber ?? fallbackMusic.catalogNumber,
              releaseStatus:
                  currentMusic.releaseStatus ?? fallbackMusic.releaseStatus,
              originalReleaseDate: currentMusic.originalReleaseDate ??
                  fallbackMusic.originalReleaseDate,
              recordingDate:
                  currentMusic.recordingDate ?? fallbackMusic.recordingDate,
              studio: currentMusic.studio ?? fallbackMusic.studio,
              rpm: currentMusic.rpm ?? fallbackMusic.rpm,
              spars: currentMusic.spars ?? fallbackMusic.spars,
              soundType: currentMusic.soundType ?? fallbackMusic.soundType,
              vinylColor: currentMusic.vinylColor ?? fallbackMusic.vinylColor,
              vinylWeight:
                  currentMusic.vinylWeight ?? fallbackMusic.vinylWeight,
              mediaCondition:
                  currentMusic.mediaCondition ?? fallbackMusic.mediaCondition,
              instrument: currentMusic.instrument ?? fallbackMusic.instrument,
              isLive: currentMusic.isLive ?? fallbackMusic.isLive,
              composition:
                  currentMusic.composition ?? fallbackMusic.composition,
            );
            if (mergedMusic.hasData) {
              fullItem = fullItem.copyWith(music: mergedMusic);
            }
          } else if (currentMusic == null && fallbackMusic != null) {
            fullItem = fullItem.copyWith(music: fallbackMusic);
          }
          final hasCover = fullItem.displayCoverUrl != null;
          return hasCover
              ? fullItem
              : fullItem.copyWith(
                  coverImageUrl: item.coverImageUrl,
                  thumbnailImageUrl:
                      item.thumbnailImageUrl ?? item.coverImageUrl,
                );
        } catch (error, stackTrace) {
          logRecoverableError(
            source: 'library_add',
            message:
                'Falling back to lightweight add payload for ${item.kind}:${item.id}.',
            error: error,
            stackTrace: stackTrace,
          );
          return item;
        }
      }),
    );
    return resolved;
  }

  Future<void> _addItems(
    List<LibraryMetadataItem> items,
    LibraryAddTarget target, {
    LibraryAddReferenceType referenceType = LibraryAddReferenceType.media,
    LibraryAddDefaults? defaults,
    Map<String, LibraryAddOwnedDetails> ownedDetailsByItemId =
        const <String, LibraryAddOwnedDetails>{},
    Map<String, LibraryAddEditionSelection> editionSelectionsByItemId =
        const <String, LibraryAddEditionSelection>{},
    Map<String, String> bundleReleaseIdsByItemId = const <String, String>{},
  }) async {
    if (items.isEmpty || _isAdding) {
      return;
    }
    setState(() {
      _isAdding = true;
      _error = null;
    });
    try {
      await addLibraryItemsToTarget(
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        mutations: ref.read(collectionMutationsProvider),
        items: items,
        target: target,
        referenceType: referenceType,
        defaults: defaults ??
            LibraryAddDefaults(
              condition: _defaultCondition,
              grade: _defaultGrade,
              purchaseDate: _defaultPurchaseDate,
              locationId: _defaultLocationId,
              readStatus: _defaultReadStatus,
              tags: _defaultTags,
            ),
        ownedDetailsByItemId: ownedDetailsByItemId,
        editionSelectionsByItemId: editionSelectionsByItemId,
        bundleReleaseIdsByItemId: bundleReleaseIdsByItemId,
      );
      if (mounted) {
        Navigator.of(context).pop(
          LibraryAddDialogResult(
            target: target,
            itemIds: [for (final item in items) item.id],
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Add failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }
}




