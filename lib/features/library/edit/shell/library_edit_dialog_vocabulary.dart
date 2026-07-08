part of 'library_edit_dialog.dart';

extension _LibraryEditVocabulary on _LibraryEditRendererState {
  Future<void> _loadAvailableLocations() async {
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    _mutateDialogState(() => _availableLocations = locations);
  }

  Future<void> _loadCatalogVocabularyOptions() async {
    final db = ref.read(localDatabaseProvider);
    final seriesRegistry = SeriesRegistryRepository(db);
    final results = await Future.wait<dynamic>([
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
          for (final format in _effectivePhysicalFormats) format.label,
        ],
        selectedValue: _physicalFormatLabelController.text,
      ),
      loadConditionGradePickListOptions(
        db,
        mediaKind: widget.type.workspace.kind.apiValue,
        builtInConditions: const ['Near Mint', 'Very Fine', 'Fine', 'Good'],
        builtInGrades: const ['9.8', '9.6', '9.4', '9.2', '9.0', '8.5'],
        selectedCondition: _conditionController.text,
        selectedGrade: _gradeController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kCountryPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _countryController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kLanguagePickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _languageController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kAgeRatingPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _ageRatingController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kAudienceRatingPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _audienceRatingController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kRegionPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _regionController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kPackagingPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _packagingController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kDistributorPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _distributorController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kScreenRatioPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _screenRatioController.text,
      ),
      loadMultiValuePickListOptions(
        db,
        listName: kAudioTrackPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValues:
            splitPickListValues(_videoEdit.audioTracksController.text),
      ),
      loadMultiValuePickListOptions(
        db,
        listName: kSubtitlePickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValues:
            splitPickListValues(_videoEdit.subtitlesController.text),
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kLayersPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _videoEdit.layersController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kColorPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _videoEdit.colorController.text,
      ),
      loadMultiValuePickListOptions(
        db,
        listName: kGamePlatformPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValues: splitPickListValues(_gameEdit.platformsController.text),
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kCrossoverPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _crossoverController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kStoryArcPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _storyArcsController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kPageQualityPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        builtInValues: const [
          'White',
          'Off-White to White',
          'Cream to Off-White',
          'Brittle',
        ],
        selectedValue: _pageQualityController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kKeyCategoryPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        builtInValues: const [
          'First appearance',
          'First issue',
          'Origin',
          'Death',
          'Cameo',
          'Classic cover',
        ],
        selectedValue: _keyCategoryController.text,
      ),
      db.customSelect(
        '''
SELECT DISTINCT owner_label
FROM owned_items_cache
WHERE owner_label IS NOT NULL
  AND TRIM(owner_label) <> ''
ORDER BY owner_label COLLATE NOCASE
''',
      ).get(),
      seriesRegistry.searchEntries(
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedTitle: _titleController.text,
        selectedSeriesId: _selectedSeriesId,
      ),
    ]);
    if (!mounted) {
      return;
    }
    _mutateDialogState(() {
      _publisherOptions = List<String>.from(results[0] as List<String>);
      _imprintOptions = List<String>.from(results[1] as List<String>);
      _seriesGroupOptions = List<String>.from(results[2] as List<String>);
      _physicalFormatOptions = List<String>.from(results[3] as List<String>);
      final conditionGrade = results[4] as PickListConditionGradeOptions;
      _conditionOptions = conditionGrade.conditions;
      _gradeOptions = conditionGrade.grades;
      _countryOptions = List<String>.from(results[5] as List<String>);
      _languageOptions = List<String>.from(results[6] as List<String>);
      _ageRatingOptions = List<String>.from(results[7] as List<String>);
      _audienceRatingOptions = List<String>.from(results[8] as List<String>);
      _regionOptions = List<String>.from(results[9] as List<String>);
      _packagingOptions = List<String>.from(results[10] as List<String>);
      _distributorOptions = List<String>.from(results[11] as List<String>);
      _screenRatioOptions = List<String>.from(results[12] as List<String>);
      _audioTrackOptions = List<String>.from(results[13] as List<String>);
      _subtitleOptions = List<String>.from(results[14] as List<String>);
      _layersOptions = List<String>.from(results[15] as List<String>);
      _colorOptions = List<String>.from(results[16] as List<String>);
      _gameEdit.platformOptions =
          List<String>.from(results[17] as List<String>);
      _crossoverOptions = List<String>.from(results[18] as List<String>);
      _storyArcOptions = List<String>.from(results[19] as List<String>);
      _pageQualityOptions = List<String>.from(results[20] as List<String>);
      _keyCategoryOptions = List<String>.from(results[21] as List<String>);
      _ownerOptions = [
        for (final row in (results[22] as List<QueryRow>))
          row.read<String>('owner_label'),
      ];
      _seriesEntries = List<SeriesRegistryEntry>.from(
        results[23] as List<SeriesRegistryEntry>,
      );
    });
    await _loadGenreOptions();
  }

  Future<void> _loadTagOptions() async {
    final tagOptions = await loadTagPickListOptions(
      ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      selectedTags: splitPickListValues(_tagsController.text),
    );
    if (!mounted) {
      return;
    }
    _mutateDialogState(() => _tagOptions = tagOptions);
  }

  Future<void> _loadGenreOptions() async {
    final genreOptions = await loadMultiValuePickListOptions(
      ref.read(localDatabaseProvider),
      listName: kGenrePickListName,
      mediaKind: widget.type.workspace.kind.apiValue,
      selectedValues: splitPickListValues(_genresEditController.text),
    );
    if (!mounted) {
      return;
    }
    _mutateDialogState(() => _genreOptions = genreOptions);
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
    await _loadCatalogVocabularyOptions();
  }

  Future<void> _openSeriesPicker() async {
    final selected = await showSeriesPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      selectedTitle: _seriesTitleController.text,
      selectedSeriesId: _selectedSeriesId,
    );
    if (!mounted || selected == null) {
      return;
    }
    _mutateDialogState(() {
      _selectedSeriesId = selected.coreSeriesId;
      _titleController.value = TextEditingValue(
        text: selected.title,
        selection: TextSelection.collapsed(offset: selected.title.length),
      );
    });
    await _loadCatalogVocabularyOptions();
  }
}
