part of '../library_add_dialog.dart';

extension _LibraryAddDialogPrefill on _LibraryAddDialogState {
  Future<void> _loadAvailableLocations() async {
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    _rebuild(() {
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
    _rebuild(() {
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
    _rebuild(() {
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
    _rebuild(() {
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
    _rebuild(() {
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
      _rebuild(() {
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
    _rebuild(() {
      _defaultLocationId = result.isEmpty ? null : result;
      _availableLocations = locations;
    });
  }
}
