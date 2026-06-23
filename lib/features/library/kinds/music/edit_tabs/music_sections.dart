part of 'package:collectarr_app/features/library/kinds/music/edit_dialog.dart';

extension _MusicSections on _MusicLibraryEditDialogState {
  Widget _musicSectionFor(String id) {
    switch (id) {
      case 'music_release_identity':
        return EditSection(
          title: 'Release identity',
          accent: _accent,
          child: Column(
            children: [
              _denseFields([
                _field(
                  controller: _titleController,
                  label: 'Title',
                  validator: (value) =>
                      emptyToNull(value ?? '') == null ? 'Enter a title' : null,
                ),
                _field(controller: _artistController, label: 'Artist'),
                _field(controller: _sortKeyController, label: 'Sort title'),
              ]),
              const SizedBox(height: 10),
              _denseFields([
                _field(controller: _subtitleController, label: 'Subtitle'),
                _field(
                    controller: _publisherController,
                    label: widget.request.type.mediaFields.publisherLabel),
                _field(
                  controller: _editionTitleController,
                  label: widget.request.type.releaseFields.editionTitleLabel,
                ),
                _field(
                    controller: _variantController,
                    label: widget.request.type.releaseFields.variantLabel),
              ]),
            ],
          ),
        );
      case 'music_identifiers_release':
        return EditSection(
          title: 'Identifiers & release',
          accent: _accent,
          child: Column(
            children: [
              _denseFields([
                _field(
                    controller: _barcodeController,
                    label: widget.request.type.releaseFields.barcodeLabel),
                _field(
                    controller: _catalogNumberController,
                    label: 'Catalog number'),
                _field(
                  controller: _releaseDateController,
                  label: 'Release date',
                  hint: 'YYYY-MM-DD',
                  validator: optionalDateValidator,
                ),
                _field(
                  controller: _releaseYearController,
                  label: 'Release year',
                  validator: optionalIntValidator,
                ),
              ]),
              const SizedBox(height: 10),
              _denseFields([
                _field(
                  controller: _originalReleaseDateController,
                  label: 'Original release date',
                  hint: 'YYYY-MM-DD',
                  validator: optionalDateValidator,
                ),
                _field(
                  controller: _recordingDateController,
                  label: 'Recording date',
                  hint: 'YYYY-MM-DD',
                  validator: optionalDateValidator,
                ),
                _field(controller: _studioController, label: 'Studio'),
              ]),
              if (widget.request.type.releaseFields.showPhysicalFormat &&
                  widget.request.physicalFormats.isNotEmpty) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _physicalFormatId,
                  isExpanded: true,
                  dropdownColor: kEditPanelRaised,
                  borderRadius: kEditMenuBorderRadius,
                  decoration: const InputDecoration(labelText: 'Format'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('No specific format'),
                    ),
                    for (final format in widget.request.physicalFormats)
                      DropdownMenuItem<String>(
                        value: format.id,
                        child: Text(format.label),
                      ),
                  ],
                  onChanged: (value) {
                    _updateState(() {
                      _physicalFormatId = emptyToNull(value ?? '');
                    });
                  },
                ),
              ],
              const SizedBox(height: 10),
              _denseFields([
                _field(
                  controller: _releaseStatusController,
                  label: 'Release status',
                ),
                _field(controller: _countryController, label: 'Country'),
                _field(controller: _languageController, label: 'Language'),
              ]),
            ],
          ),
        );
      case 'music_genres':
        return EditSection(
          title: 'Genres',
          accent: _accent,
          child: _EditableChipField(
            key: const ValueKey('music-genres-chip-field'),
            label: 'Genres',
            values: _genreValues,
            suggestions: const [
              'Rock',
              'Metal',
              'Pop',
              'Jazz',
              'Classical',
              'Blues',
              'Folk',
              'Hip Hop',
              'Electronic',
              'Soundtrack',
            ],
            onChanged: (values) {
              _updateState(() {
                _genreValues = values;
                _genresController.text = values.join(', ');
              });
            },
          ),
        );
      case 'music_classical_metadata':
        return EditSection(
          title: 'Classical metadata',
          accent: _accent,
          child: Column(
            children: [
              _denseFields([
                _field(
                    controller: _compositionController, label: 'Composition'),
                _field(controller: _instrumentController, label: 'Instrument'),
              ]),
            ],
          ),
        );
      case 'music_format_audio_details':
        return EditSection(
          title: 'Format & audio',
          accent: _accent,
          child: Column(
            children: [
              _denseFields([
                _rpmField(),
                _field(controller: _sparsController, label: 'SPARS'),
                _field(controller: _vinylColorController, label: 'Vinyl color'),
                _field(
                    controller: _vinylWeightController, label: 'Vinyl weight'),
                _field(
                    controller: _mediaConditionController,
                    label: 'Media condition'),
                _field(controller: _packagingController, label: 'Packaging'),
                _field(controller: _boxSetController, label: 'Box set'),
                _field(controller: _extrasController, label: 'Extras'),
              ]),
              const SizedBox(height: 10),
              _EditableChipField(
                key: const ValueKey('music-sound-chip-field'),
                label: 'Sound',
                values: _soundValues,
                suggestions: const [
                  'Stereo',
                  'Mono',
                  'Dolby Digital',
                  'Dolby Atmos',
                  'DTS',
                  'Analog',
                ],
                onChanged: (values) {
                  _updateState(() {
                    _soundValues = values;
                    _soundTypeController.text = values.join(', ');
                  });
                },
              ),
              const SizedBox(height: 10),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  value: _isLive,
                  onChanged: (value) => _updateState(() => _isLive = value),
                  title: const Text('Live recording'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        );
      case 'music_composer':
        return EditSection(
          title: 'Composer',
          accent: _accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _serverSnapshotCompareSection(
                showCreatorsDiff: true,
                showDiscsDiff: true,
              ),
              const SizedBox(height: 10),
              _EditableNameListField(
                key: const ValueKey('music-composer-edit'),
                values: _composerCredits,
                onChanged: (values) =>
                    _updateState(() => _composerCredits = values),
                hintText: 'Add composer',
              ),
            ],
          ),
        );
      case 'music_conductor':
        return _editableRoleSection(
          title: 'Conductor',
          values: _conductorCredits,
          onChanged: (values) => _updateState(() => _conductorCredits = values),
          hintText: 'Add conductor',
        );
      case 'music_orchestra':
        return _editableRoleSection(
          title: 'Orchestra',
          values: _orchestraCredits,
          onChanged: (values) => _updateState(() => _orchestraCredits = values),
          hintText: 'Add orchestra',
        );
      case 'music_chorus':
        return _editableRoleSection(
          title: 'Chorus',
          values: _chorusCredits,
          onChanged: (values) => _updateState(() => _chorusCredits = values),
          hintText: 'Add chorus',
        );
      case 'music_track_listing':
        return EditSection(
          title: 'Track listing',
          accent: _accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _serverSnapshotCompareSection(
                showCreatorsDiff: true,
                showDiscsDiff: true,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final disc in _discNumbersFromTracks)
                          InputChip(
                            label: Text('Disc #$disc'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                            selected: disc == _selectedTrackDisc,
                            onSelected: (_) {
                              _updateState(() => _selectedTrackDisc = disc);
                            },
                            onDeleted: _discNumbersFromTracks.length > 1
                                ? () => _removeDiscDraft(disc)
                                : null,
                            deleteIcon: const Icon(Icons.close, size: 14),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _addDiscDraft,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Disc'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _tracksDiscMetaRow(_selectedTrackDisc),
              const SizedBox(height: 10),
              _trackSelectionToolbar(),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: kAppField,
                  border: Border.all(color: kEditDivider),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(width: 28),
                          SizedBox(width: 24),
                          SizedBox(width: 28),
                          Expanded(
                            flex: 10,
                            child: Text('Title',
                                style: TextStyle(color: kEditTextMuted)),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            flex: 7,
                            child: Text('Artist',
                                style: TextStyle(color: kEditTextMuted)),
                          ),
                          SizedBox(width: 8),
                          SizedBox(
                            width: 82,
                            child: Text('Length',
                                style: TextStyle(color: kEditTextMuted)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: kEditDivider),
                    if (_visibleTrackRows.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'No tracks for this disc yet.',
                          style: TextStyle(color: kEditTextMuted),
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _visibleTrackRows.length,
                        onReorderItem: _reorderVisibleTrackRows,
                        itemBuilder: (context, index) {
                          final row = _visibleTrackRows[index];
                          return Column(
                            key: ValueKey('track-row-${row.rowId}'),
                            children: [
                              _editableTrackRow(row, index),
                              if (index != _visibleTrackRows.length - 1)
                                const Divider(height: 1, color: kEditDivider),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _addTrackForSelectedDisc(header: true),
                    icon: const Icon(Icons.folder_outlined),
                    label: const Text('Add Header'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _addTrackForSelectedDisc,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Track'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ValueContextChip(
                    icon: Icons.queue_music_outlined,
                    label: 'Tracks',
                    value: '${_editableTrackRows.length}',
                  ),
                  ValueContextChip(
                    icon: Icons.schedule_outlined,
                    label: 'Length',
                    value: _trackDurationLabel(_buildSubmittedTracks()) ?? '—',
                  ),
                ],
              ),
            ],
          ),
        );
      case 'music_collection_or_tracking':
        if (_isOwned) {
          return EditSection(
            title: 'Collection',
            accent: _accent,
            child: Column(
              children: [
                if (widget.request.item.editions.isNotEmpty) ...[
                  _denseFields([
                    _editionSelectionField(),
                    _variantSelectionField(),
                  ]),
                  const SizedBox(height: 10),
                ],
                _denseFields([
                  SizedBox(
                    width: 140,
                    child: MediaRatingField(controller: _ratingController),
                  ),
                  SizedBox(
                    width: 180,
                    child: MediaTrackingStatusField(
                      profile: widget.request.type.trackingProfile,
                      value: _trackingController.text,
                      label: 'Tracking status',
                      onChanged: (value) {
                        _trackingController.text = value ?? '';
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                _denseFields([
                  _field(controller: _conditionController, label: 'Condition'),
                  _field(
                      controller: _gradeController, label: 'Media condition'),
                ]),
                const SizedBox(height: 10),
                _denseFields([
                  _field(
                    controller: _purchaseStoreController,
                    label: 'Purchase store',
                  ),
                  _field(
                    controller: _storageDeviceController,
                    label: 'Storage device',
                  ),
                  _field(controller: _storageSlotController, label: 'Slot'),
                ]),
                const SizedBox(height: 10),
                _denseFields([
                  _datePickerField(
                    label: 'Started',
                    value: _startedAt,
                    onChanged: (value) =>
                        _updateState(() => _startedAt = value),
                  ),
                  _datePickerField(
                    label: 'Finished',
                    value: _finishedAt,
                    onChanged: (value) =>
                        _updateState(() => _finishedAt = value),
                  ),
                ]),
                const SizedBox(height: 10),
                _denseFields([
                  _field(
                    controller: _timesCompletedController,
                    label: 'Times listened',
                    validator: optionalPositiveIntValidator,
                  ),
                  _field(
                    controller: _progressCurrentController,
                    label: 'Tracks heard',
                    validator: optionalPositiveIntValidator,
                  ),
                  _field(
                    controller: _progressTotalController,
                    label: 'Total tracks',
                    validator: optionalPositiveIntValidator,
                  ),
                ]),
                const SizedBox(height: 10),
                _denseFields([
                  _field(controller: _signedByController, label: 'Signed by'),
                  _field(controller: _tagsController, label: 'Tags'),
                ]),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _trackingNotesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Tracking notes',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          );
        }
        if (_hasTrackingContext) {
          return EditSection(
            title: 'Tracking',
            accent: _accent,
            child: Column(
              children: [
                if (widget.request.item.editions.isNotEmpty) ...[
                  _denseFields([
                    _editionSelectionField(),
                    _variantSelectionField(),
                  ]),
                  const SizedBox(height: 10),
                ],
                _denseFields([
                  SizedBox(
                    width: 140,
                    child: MediaRatingField(controller: _ratingController),
                  ),
                  SizedBox(
                    width: 180,
                    child: MediaTrackingStatusField(
                      profile: widget.request.type.trackingProfile,
                      value: _trackingController.text,
                      label: 'Tracking status',
                      onChanged: (value) {
                        _trackingController.text = value ?? '';
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                _denseFields([
                  _datePickerField(
                    label: 'Started',
                    value: _startedAt,
                    onChanged: (value) =>
                        _updateState(() => _startedAt = value),
                  ),
                  _datePickerField(
                    label: 'Finished',
                    value: _finishedAt,
                    onChanged: (value) =>
                        _updateState(() => _finishedAt = value),
                  ),
                ]),
                const SizedBox(height: 10),
                _denseFields([
                  _field(
                    controller: _timesCompletedController,
                    label: 'Times listened',
                    validator: optionalPositiveIntValidator,
                  ),
                  _field(
                    controller: _progressCurrentController,
                    label: 'Tracks heard',
                    validator: optionalPositiveIntValidator,
                  ),
                  _field(
                    controller: _progressTotalController,
                    label: 'Total tracks',
                    validator: optionalPositiveIntValidator,
                  ),
                ]),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _trackingNotesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Tracking notes',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          );
        }
        return EditSection(
          title: 'Personal fields',
          accent: _accent,
          child: const Text(
            'Open the edit dialog from an owned copy to populate collection-specific music fields like condition, rating, location and listening status.',
            style: TextStyle(color: kEditTextMuted),
          ),
        );
      case 'music_wishlist_reference':
        return EditSection(
          title: 'Wishlist',
          accent: _accent,
          child: Column(
            children: [
              _denseFields([
                _field(
                  controller: _wishlistPriceController,
                  label: 'Target price',
                  validator: optionalMoneyValidator,
                ),
                _field(
                  controller: _wishlistCurrencyController,
                  label: 'Currency',
                ),
              ]),
              const SizedBox(height: 10),
              TextFormField(
                controller: _wishlistNotesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Wishlist notes',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        );
      case 'music_purchase_value':
        return EditSection(
          title: 'Purchase & value',
          accent: _accent,
          child: Column(
            children: [
              _denseFields([
                _field(
                  controller: _priceController,
                  label: 'Price paid',
                  validator: optionalMoneyValidator,
                ),
                _field(controller: _currencyController, label: 'Currency'),
                _field(
                  controller: _sellPriceController,
                  label: 'Current / sell value',
                  validator: optionalMoneyValidator,
                ),
              ]),
              const SizedBox(height: 10),
              _denseFields([
                _datePickerField(
                  label: 'Purchase date',
                  value: parseDate(_purchaseDateController.text),
                  onChanged: (value) {
                    _updateState(() {
                      _purchaseDateController.text =
                          value == null ? '' : formatDate(value);
                    });
                  },
                ),
                _field(controller: _soldToController, label: 'Sold to'),
                _datePickerField(
                  label: 'Sold date',
                  value: _soldAt,
                  onChanged: (value) => _updateState(() => _soldAt = value),
                ),
              ]),
              const SizedBox(height: 10),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  value: _soldAt != null,
                  onChanged: (value) {
                    _updateState(() {
                      _soldAt = value ? DateTime.now() : null;
                    });
                  },
                  title: const Text('Mark as sold'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        );
      case 'music_profit_loss':
        if (!_isOwned || _sellPriceController.text.trim().isEmpty) {
          return const SizedBox.shrink();
        }
        return EditSection(
          title: 'Profit / Loss',
          accent: _accent,
          child: SoldSummaryPanel(
            pricePaidCents: parseMoneyCents(_priceController.text),
            sellPriceCents: parseMoneyCents(_sellPriceController.text),
            currency: _currencyController.text,
          ),
        );
      case 'music_custom_fields':
        return EditSection(
          title: 'Custom fields',
          accent: _accent,
          child: CustomFieldsEditSection(
            definitions: widget.request.customFieldDefinitions,
            values: _customFieldEdits,
            accent: _accent,
            onChanged: (values) => _customFieldEdits = values,
          ),
        );
      case 'music_primary_artist':
        return EditSection(
          title: 'Primary artist',
          accent: _accent,
          child: _field(
            controller: _artistController,
            label: 'Artist / display name',
          ),
        );
      case 'music_songwriter':
        return _editableRoleSection(
          title: 'Songwriter',
          values: _songwriterCredits,
          onChanged: (values) =>
              _updateState(() => _songwriterCredits = values),
          hintText: 'Add songwriter',
        );
      case 'music_producer':
        return _editableRoleSection(
          title: 'Producer',
          values: _producerCredits,
          onChanged: (values) => _updateState(() => _producerCredits = values),
          hintText: 'Add producer',
        );
      case 'music_engineer':
        return _editableRoleSection(
          title: 'Engineer',
          values: _engineerCredits,
          onChanged: (values) => _updateState(() => _engineerCredits = values),
          hintText: 'Add engineer',
        );
      case 'music_musician':
        return _editableMusicianRoleSection(
          title: 'Musician',
          values: _musicianCredits,
          onChanged: (values) => _updateState(() => _musicianCredits = values),
          hintName: 'Musician name',
          hintInstrument: 'Instrument',
        );
      case 'music_remote_cover_assets':
        return EditSection(
          title: 'Remote cover assets',
          accent: _accent,
          child: Column(
            children: [
              _field(controller: _coverController, label: 'Cover image URL'),
              const SizedBox(height: 10),
              _field(
                  controller: _thumbnailController,
                  label: 'Thumbnail image URL'),
            ],
          ),
        );
      case 'music_local_images':
        return EditSection(
          title: 'Local images',
          accent: _accent,
          child: ItemImagesEditSection(
            images: widget.request.itemImages,
            accent: _accent,
            onChanged: (edits) => _itemImageEdits = edits,
          ),
        );
      case 'music_album_notes':
        return EditSection(
          title: 'Album notes',
          accent: _accent,
          child: TextFormField(
            controller: _synopsisController,
            minLines: 6,
            maxLines: 12,
            decoration: const InputDecoration(
              labelText: 'Synopsis / album notes',
              alignLabelWithHint: true,
            ),
          ),
        );
      case 'music_personal_notes':
        return EditSection(
          title: 'Personal notes',
          accent: _accent,
          child: TextFormField(
            controller: _notesController,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Collection notes',
              alignLabelWithHint: true,
            ),
          ),
        );
      case 'music_identifiers':
        return EditSection(
          title: 'Identifiers',
          accent: _accent,
          child: _denseFields([
            _field(
                controller: _barcodeController,
                label: widget.request.type.releaseFields.barcodeLabel),
            _field(
                controller: _catalogNumberController, label: 'Catalog number'),
            _field(controller: _coverController, label: 'Front cover URL'),
            _field(controller: _thumbnailController, label: 'Thumbnail URL'),
          ]),
        );
      case 'music_metadata_source_notes':
        return EditSection(
          title: 'Metadata source notes',
          accent: _accent,
          child: const Text(
            'Provider-specific online links are not modeled separately in the current client yet. This tab keeps the CLZ-style surface for identifiers and remote asset references so the music edit flow stays consistent.',
            style: TextStyle(color: kEditTextMuted),
          ),
        );
      default:
        throw StateError('Unsupported music section: $id');
    }
  }
}
