part of 'admin_page.dart';

class _MetadataCorrectionDialog extends StatefulWidget {
  const _MetadataCorrectionDialog({
    required this.item,
    required this.physicalFormats,
  });

  final AdminMetadataItem item;
  final List<PhysicalMediaFormat> physicalFormats;

  @override
  State<_MetadataCorrectionDialog> createState() =>
      _MetadataCorrectionDialogState();
}

class _MetadataCorrectionDialogState extends State<_MetadataCorrectionDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _originalTitleController;
  late final TextEditingController _localizedTitleController;
  late final TextEditingController _sortKeyController;
  late final TextEditingController _searchAliasesController;
  late final TextEditingController _titleExtensionController;
  late final TextEditingController _itemNumberController;
  late final TextEditingController _editionTitleController;
  late final TextEditingController _publisherController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _variantController;
  late final TextEditingController _pageCountController;
  late final TextEditingController _runtimeMinutesController;
  late final TextEditingController _colorController;
  late final TextEditingController _nrDiscsController;
  late final TextEditingController _screenRatioController;
  late final TextEditingController _audioTracksController;
  late final TextEditingController _subtitlesController;
  late final TextEditingController _layersController;
  late final TextEditingController _releaseDateController;
  late final TextEditingController _imprintController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _seriesGroupController;
  late final TextEditingController _countryController;
  late final TextEditingController _languageController;
  late final TextEditingController _ageRatingController;
  late final TextEditingController _audienceRatingController;
  late final TextEditingController _catalogNumberController;
  late final TextEditingController _releaseStatusController;
  late final TextEditingController _seriesTagsController;
  late final TextEditingController _coverController;
  late final TextEditingController _thumbnailController;
  late final TextEditingController _synopsisController;
  late final TextEditingController _crossoverController;
  late final TextEditingController _plotSummaryController;
  late final TextEditingController _plotDescriptionController;
  late final TextEditingController _genresController;
  late final TextEditingController _platformsController;
  late final TextEditingController _characterInputController;
  late final TextEditingController _storyArcInputController;
  late final TextEditingController _trailerUrlsController;
  late final TextEditingController _externalLinksController;
  late final List<String> _characters;
  late final List<String> _storyArcs;
  late final List<_EditableCreator> _creators;
  late final List<_EditableTrack> _tracks;
  late String _physicalFormatId;
  String? _error;

  @override
  void initState() {
    super.initState();
    final variant = widget.item.primaryVariant;
    final edition = widget.item.primaryEdition;
    _titleController = TextEditingController(text: widget.item.title);
    _originalTitleController = TextEditingController(
      text: widget.item.originalTitle ?? '',
    );
    _localizedTitleController = TextEditingController(
      text: widget.item.localizedTitle ?? '',
    );
    _sortKeyController = TextEditingController(text: widget.item.sortKey ?? '');
    _searchAliasesController = TextEditingController(
      text: widget.item.searchAliases.join(', '),
    );
    _titleExtensionController = TextEditingController(
      text: widget.item.titleExtension ?? '',
    );
    _itemNumberController =
        TextEditingController(text: widget.item.itemNumber ?? '');
    _editionTitleController = TextEditingController(text: edition?.title ?? '');
    _publisherController = TextEditingController(
        text: edition?.publisher ?? widget.item.publisher ?? '');
    _barcodeController = TextEditingController(
      text: widget.item.barcode ?? variant?.barcode ?? '',
    );
    _variantController = TextEditingController(text: variant?.name ?? '');
    _pageCountController = TextEditingController(
      text: widget.item.publishing?.pageCount?.toString() ?? '',
    );
    _runtimeMinutesController = TextEditingController(
      text: widget.item.video?.runtimeMinutes?.toString() ?? '',
    );
    _colorController =
        TextEditingController(text: widget.item.video?.color ?? '');
    _nrDiscsController = TextEditingController(
      text: widget.item.video?.nrDiscs?.toString() ?? '',
    );
    _screenRatioController = TextEditingController(
      text: widget.item.video?.screenRatio ?? '',
    );
    _audioTracksController = TextEditingController(
      text: widget.item.video?.audioTracks ?? '',
    );
    _subtitlesController = TextEditingController(
      text: widget.item.video?.subtitles ?? '',
    );
    _layersController = TextEditingController(
      text: widget.item.video?.layers ?? '',
    );
    _releaseDateController = TextEditingController(
      text: edition?.releaseDate == null
          ? ''
          : _formatDate(edition!.releaseDate!),
    );
    _imprintController = TextEditingController(
      text: widget.item.publishing?.imprint ?? '',
    );
    _subtitleController = TextEditingController(
      text: widget.item.publishing?.subtitle ?? '',
    );
    _seriesGroupController = TextEditingController(
      text: widget.item.publishing?.seriesGroup ?? '',
    );
    _countryController = TextEditingController(text: widget.item.country ?? '');
    _languageController =
        TextEditingController(text: widget.item.language ?? '');
    _ageRatingController =
        TextEditingController(text: widget.item.ageRating ?? '');
    _audienceRatingController = TextEditingController(
      text: widget.item.audienceRating ?? '',
    );
    _catalogNumberController = TextEditingController(
      text: widget.item.music?.catalogNumber ?? '',
    );
    _releaseStatusController = TextEditingController(
      text: widget.item.music?.releaseStatus ?? '',
    );
    _seriesTagsController = TextEditingController(
      text: _normalizedAdminTags(widget.item.series?.tags).join(', '),
    );
    _coverController =
        TextEditingController(text: variant?.coverImageUrl ?? '');
    _thumbnailController = TextEditingController(
      text: variant?.thumbnailImageUrl ?? '',
    );
    _synopsisController =
        TextEditingController(text: widget.item.synopsis ?? '');
    _crossoverController =
        TextEditingController(text: widget.item.crossover ?? '');
    _plotSummaryController =
        TextEditingController(text: widget.item.plotSummary ?? '');
    _plotDescriptionController =
        TextEditingController(text: widget.item.plotDescription ?? '');
    _genresController =
        TextEditingController(text: widget.item.genres.join(', '));
    _platformsController = TextEditingController(
      text: widget.item.platforms.join(', '),
    );
    _characterInputController = TextEditingController();
    _storyArcInputController = TextEditingController();
    _characters = List<String>.from(_relationNameList(widget.item.characters));
    _storyArcs = List<String>.from(_relationNameList(widget.item.storyArcs));
    _creators = [
      for (final creator in widget.item.creators)
        _EditableCreator.fromMap(creator),
    ];
    _tracks = [
      for (final track in (widget.item.music?.tracks ?? const <CatalogTrack>[]))
        _EditableTrack.fromTrack(track),
    ];
    _trailerUrlsController = TextEditingController(
      text: widget.item.trailerUrls.map((link) => link.url).join('\n'),
    );
    _externalLinksController = TextEditingController(
      text: widget.item.externalLinks.map((link) => link.url).join('\n'),
    );
    _physicalFormatId = edition?.physicalFormat ??
        physicalMediaFormatById(
          edition?.physicalFormatLabel ?? '',
          formats: widget.physicalFormats,
        )?.id ??
        '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _originalTitleController.dispose();
    _localizedTitleController.dispose();
    _sortKeyController.dispose();
    _searchAliasesController.dispose();
    _titleExtensionController.dispose();
    _itemNumberController.dispose();
    _editionTitleController.dispose();
    _publisherController.dispose();
    _barcodeController.dispose();
    _variantController.dispose();
    _pageCountController.dispose();
    _runtimeMinutesController.dispose();
    _colorController.dispose();
    _nrDiscsController.dispose();
    _screenRatioController.dispose();
    _audioTracksController.dispose();
    _subtitlesController.dispose();
    _layersController.dispose();
    _releaseDateController.dispose();
    _imprintController.dispose();
    _subtitleController.dispose();
    _seriesGroupController.dispose();
    _countryController.dispose();
    _languageController.dispose();
    _ageRatingController.dispose();
    _audienceRatingController.dispose();
    _catalogNumberController.dispose();
    _releaseStatusController.dispose();
    _seriesTagsController.dispose();
    _coverController.dispose();
    _thumbnailController.dispose();
    _synopsisController.dispose();
    _crossoverController.dispose();
    _plotSummaryController.dispose();
    _plotDescriptionController.dispose();
    _genresController.dispose();
    _platformsController.dispose();
    _characterInputController.dispose();
    _storyArcInputController.dispose();
    _trailerUrlsController.dispose();
    _externalLinksController.dispose();
    for (final creator in _creators) {
      creator.dispose();
    }
    for (final track in _tracks) {
      track.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      shape: _kAdminDialogShape,
      title: Text('Edit metadata: ${widget.item.displayTitle}'),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                _MessageRow(message: _error!, isError: true),
                const SizedBox(height: 12),
              ],
              _renderAdminScalarSection(SharedMetadataEditTab.item),
              _renderAdminScalarSection(SharedMetadataEditTab.publishing),
              _renderAdminScalarSection(SharedMetadataEditTab.technical),
              _renderAdminScalarSection(SharedMetadataEditTab.regional),
              if (widget.physicalFormats.isNotEmpty) _physicalFormatField(),
              _renderAdminScalarSection(SharedMetadataEditTab.artwork),
              _sectionLabel(SharedMetadataEditTab.relations.label),
              ..._adminScalarFieldsForTab(SharedMetadataEditTab.relations),
              _stringListEditor(
                label: 'Characters',
                values: _characters,
                inputController: _characterInputController,
                onAdd: _addCharacter,
                onRemove: _removeCharacterAt,
              ),
              _stringListEditor(
                label: 'Story arcs',
                values: _storyArcs,
                inputController: _storyArcInputController,
                onAdd: _addStoryArc,
                onRemove: _removeStoryArcAt,
              ),
              _creatorEditor(),
              _trackEditor(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save correction'),
        ),
      ],
    );
  }

  Widget _correctionField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? hintText,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MetadataCorrectionTextField(
        controller: controller,
        label: label,
        keyboardType: keyboardType,
        hintText: hintText,
        minLines: minLines,
        maxLines: maxLines,
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MetadataCorrectionSectionLabel(label: label),
    );
  }

  Widget _renderAdminScalarSection(SharedMetadataEditTab tab) {
    final fields = _adminScalarFieldsForTab(tab);
    if (fields.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(tab.label),
        ...fields,
      ],
    );
  }

  List<Widget> _adminScalarFieldsForTab(SharedMetadataEditTab tab) {
    return [
      for (final field in kAdminMetadataScalarFields.where((f) => f.tab == tab))
        _correctionField(
          _controllerForFieldKey(field.key),
          field.label,
          keyboardType: sharedFieldKeyboardType(field),
          hintText: field.hintText,
          minLines: field.minLines,
          maxLines: field.maxLines,
        ),
    ];
  }

  TextEditingController _controllerForFieldKey(String key) {
    return switch (key) {
      'title' => _titleController,
      'original_title' => _originalTitleController,
      'localized_title' => _localizedTitleController,
      'title_extension' => _titleExtensionController,
      'sort_key' => _sortKeyController,
      'search_aliases' => _searchAliasesController,
      'item_number' => _itemNumberController,
      'edition_title' => _editionTitleController,
      'release_date' => _releaseDateController,
      'publisher' => _publisherController,
      'imprint' => _imprintController,
      'subtitle' => _subtitleController,
      'series_group' => _seriesGroupController,
      'barcode' => _barcodeController,
      'variant_name' => _variantController,
      'page_count' => _pageCountController,
      'runtime_minutes' => _runtimeMinutesController,
      'color' => _colorController,
      'nr_discs' => _nrDiscsController,
      'screen_ratio' => _screenRatioController,
      'audio_tracks' => _audioTracksController,
      'subtitles' => _subtitlesController,
      'layers' => _layersController,
      'catalog_number' => _catalogNumberController,
      'release_status' => _releaseStatusController,
      'country' => _countryController,
      'language' => _languageController,
      'age_rating' => _ageRatingController,
      'audience_rating' => _audienceRatingController,
      'series_tags' => _seriesTagsController,
      'cover_image_url' => _coverController,
      'thumbnail_image_url' => _thumbnailController,
      'synopsis' => _synopsisController,
      'crossover' => _crossoverController,
      'plot_summary' => _plotSummaryController,
      'plot_description' => _plotDescriptionController,
      'genres' => _genresController,
      'platforms' => _platformsController,
      'trailer_urls' => _trailerUrlsController,
      'external_links' => _externalLinksController,
      _ => throw StateError('Unsupported admin metadata field key: $key'),
    };
  }

  Map<String, Object?>? _parseScalarFieldValues() {
    final values = <String, Object?>{};
    for (final field in kAdminMetadataScalarFields) {
      final raw = _controllerForFieldKey(field.key).text.trim();
      switch (field.valueType) {
        case SharedMetadataFieldValueType.text:
          values[field.key] = raw.isEmpty ? null : raw;
          break;
        case SharedMetadataFieldValueType.integer:
          if (raw.isEmpty) {
            values[field.key] = null;
            break;
          }
          final parsed = int.tryParse(raw);
          if (parsed == null) {
            setState(() {
              _error = '${field.label} must be a number.';
            });
            return null;
          }
          values[field.key] = parsed;
          break;
        case SharedMetadataFieldValueType.date:
          if (raw.isEmpty) {
            values[field.key] = null;
            break;
          }
          final parsed = DateTime.tryParse(raw);
          if (parsed == null) {
            setState(() {
              _error = '${field.label} must use YYYY-MM-DD.';
            });
            return null;
          }
          values[field.key] = parsed;
          break;
        case SharedMetadataFieldValueType.stringList:
          values[field.key] = _normalizedAdminTags(
            raw.split(',').map((value) => value.trim()).toList(),
          );
          break;
      }
    }
    return values;
  }

  Widget _stringListEditor({
    required String label,
    required List<String> values,
    required TextEditingController inputController,
    required VoidCallback onAdd,
    required ValueChanged<int> onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: MetadataCorrectionTextField(
                      controller: inputController,
                      label: label,
                      isDense: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Add $label',
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              if (values.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var index = 0; index < values.length; index++)
                      InputChip(
                        label: Text(values[index]),
                        onDeleted: () => onRemove(index),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _creatorEditor() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Creators',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add creator',
                    onPressed: _addCreator,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              if (_creators.isEmpty)
                const Text('No creators added yet.')
              else
                for (var index = 0; index < _creators.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: MetadataCorrectionTextField(
                            controller: _creators[index].nameController,
                            label: 'Creator name',
                            isDense: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MetadataCorrectionTextField(
                            controller: _creators[index].roleController,
                            label: 'Role',
                            isDense: true,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove creator',
                          onPressed: () => _removeCreatorAt(index),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trackEditor() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tracks',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add track',
                    onPressed: _addTrack,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              if (_tracks.isEmpty)
                const Text('No tracks added yet.')
              else
                for (var index = 0; index < _tracks.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MetadataCorrectionTextField(
                                controller: _tracks[index].titleController,
                                label: 'Track title',
                                isDense: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetadataCorrectionTextField(
                                controller: _tracks[index].artistController,
                                label: 'Artist',
                                isDense: true,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove track',
                              onPressed: () => _removeTrackAt(index),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: MetadataCorrectionTextField(
                                controller: _tracks[index].positionController,
                                label: 'Position',
                                keyboardType: TextInputType.number,
                                isDense: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetadataCorrectionTextField(
                                controller: _tracks[index].durationController,
                                label: 'Duration seconds',
                                keyboardType: TextInputType.number,
                                isDense: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetadataCorrectionTextField(
                                controller: _tracks[index].discController,
                                label: 'Disc',
                                keyboardType: TextInputType.number,
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _physicalFormatField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: _physicalFormatId,
        dropdownColor: appPalette(context).panelRaised,
        borderRadius: kAppMenuBorderRadius,
        decoration: const InputDecoration(
          labelText: 'Physical format',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem(value: '', child: Text('No format selected')),
          for (final format in widget.physicalFormats)
            DropdownMenuItem(value: format.id, child: Text(format.label)),
        ],
        onChanged: (value) {
          setState(() {
            _physicalFormatId = value ?? '';
          });
        },
      ),
    );
  }

  void _addCharacter() {
    final value = _characterInputController.text.trim();
    if (value.isEmpty) {
      return;
    }
    setState(() {
      _characters.add(value);
      _characterInputController.clear();
    });
  }

  void _removeCharacterAt(int index) {
    setState(() {
      _characters.removeAt(index);
    });
  }

  void _addStoryArc() {
    final value = _storyArcInputController.text.trim();
    if (value.isEmpty) {
      return;
    }
    setState(() {
      _storyArcs.add(value);
      _storyArcInputController.clear();
    });
  }

  void _removeStoryArcAt(int index) {
    setState(() {
      _storyArcs.removeAt(index);
    });
  }

  void _addCreator() {
    setState(() {
      _creators.add(_EditableCreator.empty());
    });
  }

  void _removeCreatorAt(int index) {
    setState(() {
      final creator = _creators.removeAt(index);
      creator.dispose();
    });
  }

  void _addTrack() {
    setState(() {
      _tracks.add(_EditableTrack.empty());
    });
  }

  void _removeTrackAt(int index) {
    setState(() {
      final track = _tracks.removeAt(index);
      track.dispose();
    });
  }

  List<Map<String, dynamic>>? _buildCreatorsPayload() {
    final creators = <Map<String, dynamic>>[];
    for (final creator in _creators) {
      final name = creator.nameController.text.trim();
      final role = creator.roleController.text.trim();
      if (name.isEmpty && role.isEmpty) {
        continue;
      }
      if (name.isEmpty) {
        setState(() {
          _error = 'Creator name is required when creator row is filled.';
        });
        return null;
      }
      creators.add({
        'name': name,
        if (role.isNotEmpty) 'role': role,
      });
    }
    return creators;
  }

  List<CatalogTrack>? _buildTracksPayload() {
    final tracks = <CatalogTrack>[];
    for (final track in _tracks) {
      final title = track.titleController.text.trim();
      final artist = track.artistController.text.trim();
      final positionText = track.positionController.text.trim();
      final durationText = track.durationController.text.trim();
      final discText = track.discController.text.trim();
      if (title.isEmpty &&
          artist.isEmpty &&
          positionText.isEmpty &&
          durationText.isEmpty &&
          discText.isEmpty) {
        continue;
      }
      if (title.isEmpty) {
        setState(() {
          _error = 'Track title is required when track row is filled.';
        });
        return null;
      }
      final position = positionText.isEmpty ? null : int.tryParse(positionText);
      if (positionText.isNotEmpty && position == null) {
        setState(() {
          _error = 'Track position must be a number.';
        });
        return null;
      }
      final duration = durationText.isEmpty ? null : int.tryParse(durationText);
      if (durationText.isNotEmpty && duration == null) {
        setState(() {
          _error = 'Track duration must be a number.';
        });
        return null;
      }
      final disc = discText.isEmpty ? null : int.tryParse(discText);
      if (discText.isNotEmpty && disc == null) {
        setState(() {
          _error = 'Track disc must be a number.';
        });
        return null;
      }
      tracks.add(
        CatalogTrack(
          title: title,
          artist: artist.isEmpty ? null : artist,
          position: position,
          durationSeconds: duration,
          discNumber: disc,
        ),
      );
    }
    return tracks;
  }

  Future<void> _submit() async {
    final scalarValues = _parseScalarFieldValues();
    if (scalarValues == null) {
      return;
    }
    if ((scalarValues['title'] as String?) == null) {
      setState(() {
        _error = 'Title is required.';
      });
      return;
    }
    final currentVariantName = widget.item.primaryVariant?.name.trim();
    final nextVariantName = scalarValues['variant_name'] as String?;
    if (currentVariantName != null &&
        currentVariantName.isNotEmpty &&
        nextVariantName == null) {
      setState(() {
        _error = 'Primary variant cannot be cleared yet.';
      });
      return;
    }
    final creators = _buildCreatorsPayload();
    if (creators == null) {
      return;
    }
    final tracks = _buildTracksPayload();
    if (tracks == null) {
      return;
    }
    List<TrailerLink> trailerUrls;
    List<TrailerLink> externalLinks;
    try {
      trailerUrls = _parseLinks(_trailerUrlsController.text, kind: 'trailer');
      externalLinks =
          _parseLinks(_externalLinksController.text, kind: 'external');
    } on FormatException catch (error) {
      setState(() {
        _error = error.message;
      });
      return;
    }
    final correction = _CatalogCorrection(
      title: scalarValues['title'] as String?,
      originalTitle: scalarValues['original_title'] as String?,
      localizedTitle: scalarValues['localized_title'] as String?,
      sortKey: scalarValues['sort_key'] as String?,
      searchAliases: scalarValues['search_aliases'] as List<String>?,
      titleExtension: scalarValues['title_extension'] as String?,
      itemNumber: scalarValues['item_number'] as String?,
      editionTitle: scalarValues['edition_title'] as String?,
      genres: scalarValues['genres'] as List<String>?,
      platforms: scalarValues['platforms'] as List<String>?,
      characters: _normalizedAdminTags(_characters),
      storyArcs: _normalizedAdminTags(_storyArcs),
      creators: creators,
      tracks: tracks,
      trailerUrls: trailerUrls,
      externalLinks: externalLinks,
      crossover: scalarValues['crossover'] as String?,
      plotSummary: scalarValues['plot_summary'] as String?,
      plotDescription: scalarValues['plot_description'] as String?,
      publisher: scalarValues['publisher'] as String?,
      imprint: scalarValues['imprint'] as String?,
      subtitle: scalarValues['subtitle'] as String?,
      seriesGroup: scalarValues['series_group'] as String?,
      barcode: scalarValues['barcode'] as String?,
      country: scalarValues['country'] as String?,
      language: scalarValues['language'] as String?,
      ageRating: scalarValues['age_rating'] as String?,
      audienceRating: scalarValues['audience_rating'] as String?,
      physicalFormat: widget.physicalFormats.isNotEmpty
          ? _emptyToNull(_physicalFormatId)
          : null,
      variantName: scalarValues['variant_name'] as String?,
      pageCount: scalarValues['page_count'] as int?,
      runtimeMinutes: scalarValues['runtime_minutes'] as int?,
      color: scalarValues['color'] as String?,
      nrDiscs: scalarValues['nr_discs'] as int?,
      screenRatio: scalarValues['screen_ratio'] as String?,
      audioTracks: scalarValues['audio_tracks'] as String?,
      subtitles: scalarValues['subtitles'] as String?,
      layers: scalarValues['layers'] as String?,
      releaseDate: scalarValues['release_date'] as DateTime?,
      catalogNumber: scalarValues['catalog_number'] as String?,
      releaseStatus: scalarValues['release_status'] as String?,
      seriesTags: scalarValues['series_tags'] as List<String>?,
      coverImageUrl: scalarValues['cover_image_url'] as String?,
      thumbnailImageUrl: scalarValues['thumbnail_image_url'] as String?,
      synopsis: scalarValues['synopsis'] as String?,
    );
    final changes = _correctionPreview(correction);
    if (changes.isEmpty) {
      setState(() {
        _error = 'Change at least one metadata field before saving.';
      });
      return;
    }
    final confirmed = await _confirmCorrectionPreview(changes);
    if (!mounted || !confirmed) {
      return;
    }
    Navigator.of(context).pop(correction);
  }

  Future<bool> _confirmCorrectionPreview(
    List<_CorrectionPreviewEntry> changes,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AccentAlertDialog(
            shape: _kAdminDialogShape,
            title: const Text('Preview metadata correction'),
            content: SizedBox(
              width: 620,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _DestructiveWarning(
                      icon: Icons.fact_check_outlined,
                      message:
                          'This edits canonical catalog metadata and affects every user who sees this item. Review the diff before saving.',
                    ),
                    const SizedBox(height: 12),
                    for (final change in changes)
                      _CorrectionPreviewRow(change: change),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Back to edit'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save correction'),
              ),
            ],
          ),
        ) ??
        false;
  }

  List<_CorrectionPreviewEntry> _correctionPreview(
    _CatalogCorrection correction,
  ) {
    final item = widget.item;
    final variant = item.primaryVariant;
    final changes = <_CorrectionPreviewEntry>[];
    void add(String label, Object? before, Object? after) {
      final beforeText = _previewValue(before);
      final afterText = _previewValue(after);
      if (beforeText == afterText) {
        return;
      }
      changes.add(
        _CorrectionPreviewEntry(
          label: label,
          before: beforeText,
          after: afterText,
        ),
      );
    }

    add('Title', item.title, correction.title);
    add('Original title', item.originalTitle, correction.originalTitle);
    add('Localized title', item.localizedTitle, correction.localizedTitle);
    add('Sort key', item.sortKey, correction.sortKey);
    add(
      'Search aliases',
      item.searchAliases.join(', '),
      _normalizedAdminTags(correction.searchAliases).join(', '),
    );
    add('Title extension', item.titleExtension, correction.titleExtension);
    add('Item number', item.itemNumber, correction.itemNumber);
    add('Edition title', item.primaryEdition?.title, correction.editionTitle);
    add('Publisher', item.primaryEdition?.publisher ?? item.publisher,
        correction.publisher);
    add('Imprint', item.publishing?.imprint, correction.imprint);
    add('Subtitle', item.publishing?.subtitle, correction.subtitle);
    add('Series group', item.publishing?.seriesGroup, correction.seriesGroup);
    add('Barcode', item.barcode ?? variant?.barcode, correction.barcode);
    add('Primary variant', variant?.name, correction.variantName);
    add('Page count', item.publishing?.pageCount, correction.pageCount);
    add('Runtime', item.video?.runtimeMinutes, correction.runtimeMinutes);
    add('Color', item.video?.color, correction.color);
    add('Number of discs', item.video?.nrDiscs, correction.nrDiscs);
    add('Screen ratio', item.video?.screenRatio, correction.screenRatio);
    add('Audio tracks', item.video?.audioTracks, correction.audioTracks);
    add('Subtitles', item.video?.subtitles, correction.subtitles);
    add('Layers', item.video?.layers, correction.layers);
    add('Release date', item.primaryEdition?.releaseDate,
        correction.releaseDate);
    add('Catalog number', item.music?.catalogNumber, correction.catalogNumber);
    add('Release status', item.music?.releaseStatus, correction.releaseStatus);
    add('Country', item.country, correction.country);
    add('Language', item.language, correction.language);
    add('Age rating', item.ageRating, correction.ageRating);
    add('Audience rating', item.audienceRating, correction.audienceRating);
    if (widget.physicalFormats.isNotEmpty) {
      add('Physical format', item.primaryEdition?.physicalFormat,
          correction.physicalFormat);
    }
    add('Cover URL', variant?.coverImageUrl, correction.coverImageUrl);
    add(
      'Thumbnail URL',
      variant?.thumbnailImageUrl,
      correction.thumbnailImageUrl,
    );
    add('Synopsis', item.synopsis, correction.synopsis);
    add('Crossover', item.crossover, correction.crossover);
    add('Plot summary', item.plotSummary, correction.plotSummary);
    add('Plot description', item.plotDescription, correction.plotDescription);
    add('Genres', item.genres.join(', '),
        _normalizedAdminTags(correction.genres).join(', '));
    add('Platforms', item.platforms.join(', '),
        _normalizedAdminTags(correction.platforms).join(', '));
    add(
      'Characters',
      _relationNameList(item.characters).join(', '),
      _normalizedAdminTags(correction.characters).join(', '),
    );
    add(
      'Story arcs',
      _relationNameList(item.storyArcs).join(', '),
      _normalizedAdminTags(correction.storyArcs).join(', '),
    );
    add(
      'Creators',
      _relationNameList(item.creators).join(', '),
      _relationNameList(correction.creators).join(', '),
    );
    add(
      'Tracks',
      item.music?.tracks.map((track) => track.title).join(', '),
      correction.tracks?.map((track) => track.title).join(', '),
    );
    add(
      'Trailer URLs',
      item.trailerUrls.map((link) => link.url).join('\n'),
      correction.trailerUrls?.map((link) => link.url).join('\n'),
    );
    add(
      'External links',
      item.externalLinks.map((link) => link.url).join('\n'),
      correction.externalLinks?.map((link) => link.url).join('\n'),
    );
    add(
      'Series tags',
      _normalizedAdminTags(item.series?.tags).join(', '),
      _normalizedAdminTags(correction.seriesTags).join(', '),
    );
    return changes;
  }

  String _previewValue(Object? value) {
    if (value == null) {
      return '(empty)';
    }
    if (value is DateTime) {
      return _formatDate(value);
    }
    final text = value.toString().trim();
    return text.isEmpty ? '(empty)' : text;
  }
}

List<TrailerLink> _parseLinks(String raw, {required String kind}) {
  final links = <TrailerLink>[];
  for (final line in raw.split('\n')) {
    final url = line.trim();
    if (url.isEmpty) {
      continue;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw FormatException(
          'Invalid URL in ${kind == 'trailer' ? 'Trailer URLs' : 'External links'}: $url');
    }
    links.add(TrailerLink(url: url, kind: kind));
  }
  return links;
}

class _EditableCreator {
  _EditableCreator({String? name, String? role})
      : nameController = TextEditingController(text: name ?? ''),
        roleController = TextEditingController(text: role ?? '');

  factory _EditableCreator.fromMap(Map<String, dynamic> json) {
    return _EditableCreator(
      name: _relationNameFromMap(json),
      role: json['role']?.toString(),
    );
  }

  factory _EditableCreator.empty() => _EditableCreator();

  final TextEditingController nameController;
  final TextEditingController roleController;

  void dispose() {
    nameController.dispose();
    roleController.dispose();
  }
}

class _EditableTrack {
  _EditableTrack({
    String? title,
    String? artist,
    String? position,
    String? duration,
    String? disc,
  })  : titleController = TextEditingController(text: title ?? ''),
        artistController = TextEditingController(text: artist ?? ''),
        positionController = TextEditingController(text: position ?? ''),
        durationController = TextEditingController(text: duration ?? ''),
        discController = TextEditingController(text: disc ?? '');

  factory _EditableTrack.fromTrack(CatalogTrack track) {
    return _EditableTrack(
      title: track.title,
      artist: track.artist,
      position: track.position?.toString(),
      duration: track.durationSeconds?.toString(),
      disc: track.discNumber?.toString(),
    );
  }

  factory _EditableTrack.empty() => _EditableTrack();

  final TextEditingController titleController;
  final TextEditingController artistController;
  final TextEditingController positionController;
  final TextEditingController durationController;
  final TextEditingController discController;

  void dispose() {
    titleController.dispose();
    artistController.dispose();
    positionController.dispose();
    durationController.dispose();
    discController.dispose();
  }
}

List<String> _relationNameList(List<Map<String, dynamic>>? entries) {
  return (entries ?? const <Map<String, dynamic>>[])
      .map(_relationNameFromMap)
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}

String _relationNameFromMap(Map<String, dynamic> entry) {
  for (final key in const ['name', 'title', 'label', 'value']) {
    final value = entry[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  for (final value in entry.values) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}

List<String> _normalizedAdminTags(List<String>? tags) {
  return (tags ?? const <String>[])
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}
