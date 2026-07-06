part of 'package:collectarr_app/features/library/kinds/book/edit_dialog.dart';

extension _BookSections on _BookLibraryEditDialogState {
  Widget _bookSectionFor(String id) {
    switch (id) {
      case 'book_details':
        return EditSection(
          title: 'Main',
          accent: _accent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 960;
              if (stacked) {
                return Column(
                  children: [
                    _field(
                      controller: _titleController,
                      label: 'Title',
                      validator: (value) => emptyToNull(value ?? '') == null
                          ? 'Enter a title'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _field(controller: _sortKeyController, label: 'Sort title'),
                    const SizedBox(height: 10),
                    _field(controller: _subtitleController, label: 'Subtitle'),
                    const SizedBox(height: 10),
                    EditTokenListField(
                      controller: _authorController,
                      label: 'Author',
                      hint: 'Add author',
                    ),
                    const SizedBox(height: 10),
                    _responsiveFields([
                      _field(
                          controller: _seriesTitleController, label: 'Series'),
                      _field(controller: _numberController, label: 'Issue'),
                      _field(
                        controller: _volumeNumberController,
                        label: 'Volume',
                        validator: optionalNumberValidator,
                      ),
                    ]),
                    const SizedBox(height: 10),
                    _field(
                      controller: _editionTitleController,
                      label: 'Box set',
                    ),
                    const SizedBox(height: 10),
                    TagPickListField(
                      controller: _genresController,
                      options: _genreOptions,
                      label: 'Genres',
                      hint: 'Select genres',
                    ),
                    const SizedBox(height: 10),
                    EditTokenListField(
                      controller: _subjectsController,
                      label: 'Subject',
                      hint: 'Add subject',
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _field(
                          controller: _titleController,
                          label: 'Title',
                          validator: (value) => emptyToNull(value ?? '') == null
                              ? 'Enter a title'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        _field(
                          controller: _sortKeyController,
                          label: 'Sort title',
                        ),
                        const SizedBox(height: 10),
                        _field(
                            controller: _subtitleController, label: 'Subtitle'),
                        const SizedBox(height: 10),
                        _responsiveFields([
                          _field(
                            controller: _seriesTitleController,
                            label: 'Series',
                          ),
                          _field(controller: _numberController, label: 'Issue'),
                          _field(
                            controller: _volumeNumberController,
                            label: 'Volume',
                            validator: optionalNumberValidator,
                          ),
                        ]),
                        const SizedBox(height: 10),
                        _field(
                          controller: _editionTitleController,
                          label: 'Box set',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        EditTokenListField(
                          controller: _authorController,
                          label: 'Author',
                          hint: 'Add author',
                        ),
                        const SizedBox(height: 10),
                        TagPickListField(
                          controller: _genresController,
                          options: _genreOptions,
                          label: 'Genres',
                          hint: 'Select genres',
                        ),
                        const SizedBox(height: 10),
                        EditTokenListField(
                          controller: _subjectsController,
                          label: 'Subject',
                          hint: 'Add subject',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      case 'book_credits':
        return EditSection(
          title: 'Credits',
          accent: _accent,
          child: Column(
            children: [
              EditTokenListField(
                controller: _authorController,
                label: 'Author',
                hint: 'Add author',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _editorController,
                label: 'Editor',
                hint: 'Add editor',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _illustratorController,
                label: 'Illustrator',
                hint: 'Add illustrator',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _coverArtistController,
                label: 'Cover artist',
                hint: 'Add cover artist',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _photographerController,
                label: 'Photographer',
                hint: 'Add photographer',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _forewordAuthorController,
                label: 'Foreword author',
                hint: 'Add foreword author',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _translatorController,
                label: 'Translator',
                hint: 'Add translator',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _ghostWriterController,
                label: 'Ghost writer',
                hint: 'Add ghost writer',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _narratorController,
                label: 'Narrator',
                hint: 'Add narrator',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _charactersController,
                label: 'Characters',
                hint: 'Add character',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _storyArcsController,
                label: 'Story arcs',
                hint: 'Add story arc',
              ),
              const SizedBox(height: 10),
              EditTokenListField(
                controller: _seriesTagsController,
                label: 'Series tags',
                hint: 'Add tag',
              ),
            ],
          ),
        );
      case 'book_contents':
        return EditSection(
          title: 'Edition & publication details',
          accent: _accent,
          child: Column(
            children: [
              _denseFields([
                _field(controller: _seriesTitleController, label: 'Series'),
                _field(controller: _volumeNameController, label: 'Volume'),
                _field(
                  controller: _volumeNumberController,
                  label: 'Volume number',
                  validator: optionalNumberValidator,
                ),
                _field(
                  controller: _editionTitleController,
                  label: 'Box set / edition title',
                ),
                _field(controller: _barcodeController, label: 'ISBN'),
                _field(controller: _variantController, label: 'Format'),
                _field(
                  controller: _publisherController,
                  label: _type.mediaFields.publisherLabel,
                ),
                _field(
                  controller: _pageCountController,
                  label: 'Page count',
                  validator: optionalIntValidator,
                ),
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
                _field(controller: _countryController, label: 'Country'),
                _field(controller: _languageController, label: 'Language'),
                _field(
                  controller: _publicationPlaceController,
                  label: 'Publication place',
                ),
                _field(controller: _paperTypeController, label: 'Paper type'),
                _field(controller: _printedByController, label: 'Printed by'),
                _field(
                  controller: _originalPublisherController,
                  label: 'Original publisher',
                ),
                _field(
                  controller: _originalPublicationPlaceController,
                  label: 'Original publication place',
                ),
                _field(
                  controller: _originalCountryController,
                  label: 'Original country',
                ),
                _field(
                  controller: _originalLanguageController,
                  label: 'Original language',
                ),
              ], wideColumns: 2, ultraWideColumns: 3),
              const SizedBox(height: 10),
              _responsiveFields([
                _datePickerField(
                  label: 'Original publication date',
                  value: _originalPublicationDate,
                  onChanged: (value) =>
                      _updateState(() => _originalPublicationDate = value),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: SwitchListTile(
                    value: _firstEdition,
                    onChanged: (value) =>
                        _updateState(() => _firstEdition = value),
                    title: const Text('First edition'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                Material(
                  type: MaterialType.transparency,
                  child: SwitchListTile(
                    value: _dustJacket,
                    onChanged: (value) =>
                        _updateState(() => _dustJacket = value),
                    title: const Text('Dust jacket'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                _field(
                  controller: _dustJacketConditionController,
                  label: 'Dust jacket condition',
                ),
              ]),
              const SizedBox(height: 10),
              Material(
                type: MaterialType.transparency,
                child: SwitchListTile(
                  value: _audiobookAbridged,
                  onChanged: (value) =>
                      _updateState(() => _audiobookAbridged = value),
                  title: const Text('Audiobook abridged'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        );
      case 'book_plot':
        return EditSection(
          title: 'Plot',
          accent: _accent,
          child: TextFormField(
            controller: _synopsisController,
            minLines: 6,
            maxLines: 12,
            decoration: const InputDecoration(
              labelText: 'Plot / synopsis',
              alignLabelWithHint: true,
            ),
          ),
        );
      case 'book_notes':
        return EditSection(
          title: 'Notes',
          accent: _accent,
          child: TextFormField(
            controller: _notesController,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Personal notes',
              alignLabelWithHint: true,
            ),
          ),
        );
      case 'book_cover_sources':
        return EditSection(
          title: 'Cover sources',
          accent: _accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catalog cover links stay here. Local front/back cover scans are stored separately and drive the preview when available.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kEditTextMuted,
                    ),
              ),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(controller: _coverController, label: 'Cover image URL'),
                _field(
                  controller: _thumbnailController,
                  label: 'Thumbnail image URL',
                ),
              ]),
            ],
          ),
        );
      case 'book_identifiers_links':
        return EditSection(
          title: 'Links',
          accent: _accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Manage website links (Goodreads, Amazon, publisher pages, etc.).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kEditTextMuted,
                    ),
              ),
              const SizedBox(height: 10),
              if (_externalLinkEdits.isEmpty)
                const EditSectionStateMessage(
                  message: 'No links yet. Add one below.',
                  icon: Icons.link_off_outlined,
                )
              else
                Column(
                  children: [
                    for (var index = 0;
                        index < _externalLinkEdits.length;
                        index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildExternalLinkRow(index),
                      ),
                  ],
                ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _addExternalLink,
                  icon: const Icon(Icons.add_link),
                  label: const Text('Add Link'),
                ),
              ),
            ],
          ),
        );
      case 'book_read_history':
        return EditSection(
          title: 'Read history',
          accent: _accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Track your progress with reading status, rating and timeline.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kEditTextMuted,
                    ),
              ),
              const SizedBox(height: 10),
              _responsiveFields([
                SizedBox(
                  width: 180,
                  child: MediaTrackingStatusField(
                    profile: _type.trackingProfile,
                    value: _trackingController.text,
                    label: 'Reading status',
                    onChanged: (value) {
                      _trackingController.text = value ?? '';
                    },
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: MediaRatingField(controller: _ratingController),
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _datePickerField(
                  label: 'Start date',
                  value: _startedAt,
                  onChanged: (value) => _updateState(() => _startedAt = value),
                ),
                _datePickerField(
                  label: 'End date',
                  value: _finishedAt,
                  onChanged: (value) => _updateState(() => _finishedAt = value),
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: _progressCurrentController,
                  label: 'Pages read',
                  validator: optionalIntValidator,
                ),
                _field(
                  controller: _progressTotalController,
                  label: 'Total pages',
                  validator: optionalIntValidator,
                ),
                _field(
                  controller: _timesCompletedController,
                  label: 'Times completed',
                  validator: optionalIntValidator,
                ),
              ]),
            ],
          ),
        );
      case 'book_value':
        return EditSection(
          title: 'Value',
          accent: _accent,
          child: Column(
            children: [
              _responsiveFields([
                _field(
                  controller: _priceController,
                  label: 'Purchase price',
                  validator: optionalMoneyValidator,
                ),
                LibraryCurrencyField(controller: _currencyController),
                _field(
                  controller: _sellPriceController,
                  label: 'Sold price',
                  validator: optionalMoneyValidator,
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(controller: _soldToController, label: 'Sold to'),
                _datePickerField(
                  label: 'Sold date',
                  value: _soldAt,
                  onChanged: (value) => _updateState(() => _soldAt = value),
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: _purchaseStoreController,
                  label: 'Purchase store',
                ),
                _field(
                  controller: _marketValueController,
                  label: 'Estimated market value',
                  validator: optionalMoneyValidator,
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _datePickerField(
                  label: 'Last bag & board date',
                  value: _lastBagBoardDate,
                  onChanged: (value) =>
                      _updateState(() => _lastBagBoardDate = value),
                ),
              ]),
              if (parseMoneyCents(_priceController.text) != null ||
                  parseMoneyCents(_sellPriceController.text) != null) ...[
                const SizedBox(height: 12),
                SoldSummaryPanel(
                  pricePaidCents: parseMoneyCents(_priceController.text),
                  sellPriceCents: parseMoneyCents(_sellPriceController.text),
                  currency: _currencyController.text,
                ),
              ],
            ],
          ),
        );
      case 'book_custom_fields':
        return CustomFieldsEditSection(
          definitions: widget.request.customFieldDefinitions,
          values: _customFieldEdits,
          accent: _accent,
          onChanged: (values) => _customFieldEdits = values,
        );
      case 'book_personal_tracking':
        return EditSection(
          title: _isOwned ? 'Storage & Tracking' : 'Tracking',
          accent: _accent,
          child: Column(
            children: [
              if (_bookEditions.isNotEmpty) ...[
                _responsiveFields([
                  _editionSelectionField(),
                  _variantSelectionField(),
                ]),
                const SizedBox(height: 10),
              ],
              _responsiveFields([
                if (_isOwned)
                  _field(
                    controller: _ownerLabelController,
                    label: 'Owner',
                  ),
                if (_isOwned)
                  _field(
                    controller: _signedByController,
                    label: 'Signed by',
                  ),
              ]),
              if (_isOwned) ...[
                const SizedBox(height: 10),
                TagPickListField(
                  controller: _tagsController,
                  options: _tagOptions,
                  label: 'Tags',
                  hint: 'Comma-separated tags',
                ),
              ],
            ],
          ),
        );
      case 'book_collection_notes':
        return EditSection(
          title: 'Collection notes',
          accent: _accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveFields([
                _field(controller: _conditionController, label: 'Condition'),
                _field(controller: _gradeController, label: 'Grade'),
              ]),
            ],
          ),
        );
      case 'book_collection_fields_info':
        return EditSection(
          title: 'Collection fields',
          accent: _accent,
          child: const Text(
            'Storage, quantity, value and personal ownership notes stay unavailable until you add a physical copy. Tracking progress is editable here.',
            style: TextStyle(color: kEditTextMuted),
          ),
        );
      case 'book_wishlist_reference':
        return EditSection(
          title: 'Wishlist',
          accent: _accent,
          child: Column(
            children: [
              _responsiveFields([
                _field(
                  controller: _wishlistPriceController,
                  label: 'Target price',
                  validator: optionalMoneyValidator,
                ),
                LibraryCurrencyField(controller: _wishlistCurrencyController),
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
      case 'book_photos':
        return ItemImagesEditSection(
          images: widget.request.itemImages,
          accent: _accent,
          onChanged: (edits) => _itemImageEdits = edits,
        );
      default:
        throw StateError('Unsupported book section: $id');
    }
  }
}
