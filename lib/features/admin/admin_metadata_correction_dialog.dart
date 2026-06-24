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
  late final Map<String, TextEditingController> _scalarControllers;
  late final TextEditingController _characterInputController;
  late final TextEditingController _storyArcInputController;
  late final List<String> _characters;
  late final List<String> _storyArcs;
  late final List<_EditableCreator> _creators;
  late final List<_EditableTrack> _tracks;
  late String _physicalFormatId;
  String? _error;

  @override
  void initState() {
    super.initState();
    final edition = widget.item.primaryEdition;
    _scalarControllers = {
      for (final field in kAdminMetadataScalarFields)
        field.key: TextEditingController(text: _initialScalarText(field.key)),
    };
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
    _physicalFormatId = edition?.physicalFormat ??
        physicalMediaFormatById(
          edition?.physicalFormatLabel ?? '',
          formats: widget.physicalFormats,
        )?.id ??
        '';
  }

  @override
  void dispose() {
    for (final controller in _scalarControllers.values) {
      controller.dispose();
    }
    _characterInputController.dispose();
    _storyArcInputController.dispose();
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
    final controller = _scalarControllers[key];
    if (controller == null) {
      throw StateError('Unsupported admin metadata field key: $key');
    }
    return controller;
  }

  String _initialScalarText(String key) {
    final value = _previewScalarBeforeValue(widget.item, key);
    if (value == null) {
      return '';
    }
    if (value is DateTime) {
      return _formatDate(value);
    }
    if (value is List<TrailerLink>) {
      return value.map((link) => link.url).join('\n');
    }
    if (value is List<String>) {
      return value.join(', ');
    }
    return value.toString();
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
      trailerUrls = _parseLinks(_controllerForFieldKey('trailer_urls').text,
          kind: 'trailer');
      externalLinks = _parseLinks(_controllerForFieldKey('external_links').text,
          kind: 'external');
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

    for (final field in kAdminMetadataScalarFields) {
      if (_isComplexPreviewField(field.key)) {
        continue;
      }
      final before = _previewScalarBeforeValue(item, field.key);
      final after = _previewScalarAfterValue(correction, field.key);
      add(
        field.label,
        _previewComparableValue(before, field.valueType),
        _previewComparableValue(after, field.valueType),
      );
    }
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

  bool _isComplexPreviewField(String key) {
    return switch (key) {
      'trailer_urls' || 'external_links' || 'genres' || 'platforms' => true,
      _ => false,
    };
  }

  Object? _previewScalarBeforeValue(AdminMetadataItem item, String key) {
    final edition = item.primaryEdition;
    final variant = item.primaryVariant;
    return switch (key) {
      'title' => item.title,
      'original_title' => item.originalTitle,
      'localized_title' => item.localizedTitle,
      'sort_key' => item.sortKey,
      'search_aliases' => item.searchAliases,
      'title_extension' => item.titleExtension,
      'item_number' => item.itemNumber,
      'edition_title' => edition?.title,
      'release_date' => edition?.releaseDate,
      'publisher' => edition?.publisher ?? item.publisher,
      'imprint' => item.publishing?.imprint,
      'subtitle' => item.publishing?.subtitle,
      'series_group' => item.publishing?.seriesGroup,
      'barcode' => item.barcode ?? variant?.barcode,
      'variant_name' => variant?.name,
      'page_count' => item.publishing?.pageCount,
      'runtime_minutes' => item.video?.runtimeMinutes,
      'color' => item.video?.color,
      'nr_discs' => item.video?.nrDiscs,
      'screen_ratio' => item.video?.screenRatio,
      'audio_tracks' => item.video?.audioTracks,
      'subtitles' => item.video?.subtitles,
      'layers' => item.video?.layers,
      'catalog_number' => item.music?.catalogNumber,
      'release_status' => item.music?.releaseStatus,
      'country' => item.country,
      'language' => item.language,
      'age_rating' => item.ageRating,
      'audience_rating' => item.audienceRating,
      'series_tags' => _normalizedAdminTags(item.series?.tags),
      'cover_image_url' => variant?.coverImageUrl,
      'thumbnail_image_url' => variant?.thumbnailImageUrl,
      'synopsis' => item.synopsis,
      'crossover' => item.crossover,
      'plot_summary' => item.plotSummary,
      'plot_description' => item.plotDescription,
      'genres' => item.genres,
      'platforms' => item.platforms,
      'trailer_urls' => item.trailerUrls,
      'external_links' => item.externalLinks,
      _ => null,
    };
  }

  Object? _previewScalarAfterValue(_CatalogCorrection correction, String key) {
    return switch (key) {
      'title' => correction.title,
      'original_title' => correction.originalTitle,
      'localized_title' => correction.localizedTitle,
      'sort_key' => correction.sortKey,
      'search_aliases' => correction.searchAliases,
      'title_extension' => correction.titleExtension,
      'item_number' => correction.itemNumber,
      'edition_title' => correction.editionTitle,
      'release_date' => correction.releaseDate,
      'publisher' => correction.publisher,
      'imprint' => correction.imprint,
      'subtitle' => correction.subtitle,
      'series_group' => correction.seriesGroup,
      'barcode' => correction.barcode,
      'variant_name' => correction.variantName,
      'page_count' => correction.pageCount,
      'runtime_minutes' => correction.runtimeMinutes,
      'color' => correction.color,
      'nr_discs' => correction.nrDiscs,
      'screen_ratio' => correction.screenRatio,
      'audio_tracks' => correction.audioTracks,
      'subtitles' => correction.subtitles,
      'layers' => correction.layers,
      'catalog_number' => correction.catalogNumber,
      'release_status' => correction.releaseStatus,
      'country' => correction.country,
      'language' => correction.language,
      'age_rating' => correction.ageRating,
      'audience_rating' => correction.audienceRating,
      'series_tags' => correction.seriesTags,
      'cover_image_url' => correction.coverImageUrl,
      'thumbnail_image_url' => correction.thumbnailImageUrl,
      'synopsis' => correction.synopsis,
      'crossover' => correction.crossover,
      'plot_summary' => correction.plotSummary,
      'plot_description' => correction.plotDescription,
      'genres' => correction.genres,
      'platforms' => correction.platforms,
      _ => null,
    };
  }

  Object? _previewComparableValue(
    Object? value,
    SharedMetadataFieldValueType type,
  ) {
    return switch (type) {
      SharedMetadataFieldValueType.stringList =>
        _normalizedAdminTags((value as List<String>?) ?? const []).join(', '),
      _ => value,
    };
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
