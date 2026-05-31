part of 'library_edit_dialog.dart';

const _libraryEditCastRoles = {
  'actor',
  'voice',
  'voice actor',
  'guest star',
  'cameo',
  'narrator',
};

extension _LibraryEditRendererVideoTabs on _LibraryEditRendererState {
  Widget _videoMediaTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Main',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveFields([
                _field(
                  controller: _titleController,
                  label: 'Title',
                  validator: (value) =>
                      emptyToNull(value ?? '') == null ? 'Enter a title' : null,
                ),
                _field(controller: _sortKeyController, label: 'Sort title'),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                    controller: _titleExtensionController,
                    label: 'Title extension',
                    hint: 'e.g. Collector\'s Edition, Director\'s Cut'),
                _field(
                    controller: _originalTitleController,
                    label: 'Original title'),
              ]),
              if (widget.item.series != null) ...[
                const SizedBox(height: 10),
                _responsiveFields([
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Series',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      widget.item.series!.seriesTitle ?? '—',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ]),
              ],
              const SizedBox(height: 10),
              _responsiveFields([
                _releaseDatePartsField(),
                _field(controller: _publisherController, label: 'Studios'),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: _runtimeController,
                  label: 'Runtime (min)',
                  validator: optionalIntValidator,
                ),
                _field(
                    controller: _audienceRatingController,
                    label: 'Audience rating'),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(controller: _countryController, label: 'Country'),
                _field(controller: _languageController, label: 'Language'),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                    controller: _genresEditController,
                    label: 'Genres',
                    hint: 'Comma-separated'),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _castTab() {
    final creators = widget.item.creators;
    final castEntries = creators?.where((c) {
      final role = c['role']?.toString().trim().toLowerCase() ?? '';
      return role.isEmpty ||
          _libraryEditCastRoles.any((tag) => role.contains(tag));
    }).toList();
    final hasCast = castEntries != null && castEntries.isNotEmpty;
    return EditTabShell(
      children: [
        EditSection(
          title: 'Cast',
          accent: widget.accent,
          child: hasCast
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final credit in castEntries)
                      if (credit['name']?.toString().trim().isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(Icons.person,
                                  size: 16,
                                  color: appPalette(context).textMuted),
                              const SizedBox(width: 8),
                              Text(
                                credit['name'].toString().trim(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              if (credit['role']
                                      ?.toString()
                                      .trim()
                                      .isNotEmpty ==
                                  true) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '— ${credit['role']}',
                                  style: TextStyle(
                                      color: appPalette(context).textMuted),
                                ),
                              ],
                            ],
                          ),
                        ),
                  ],
                )
              : Text(
                  'No cast data available.',
                  style: TextStyle(color: appPalette(context).textMuted),
                ),
        ),
      ],
    );
  }

  Widget _crewTab() {
    final creators = widget.item.creators;
    final crewEntries = creators?.where((c) {
      final role = c['role']?.toString().trim().toLowerCase() ?? '';
      return role.isNotEmpty &&
          !_libraryEditCastRoles.any((tag) => role.contains(tag));
    }).toList();
    final hasCrew = crewEntries != null && crewEntries.isNotEmpty;
    return EditTabShell(
      children: [
        EditSection(
          title: 'Crew',
          accent: widget.accent,
          child: hasCrew
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final credit in crewEntries)
                      if (credit['name']?.toString().trim().isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(Icons.person,
                                  size: 16,
                                  color: appPalette(context).textMuted),
                              const SizedBox(width: 8),
                              Text(
                                credit['name'].toString().trim(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              if (credit['role']
                                      ?.toString()
                                      .trim()
                                      .isNotEmpty ==
                                  true) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '— ${credit['role']}',
                                  style: TextStyle(
                                      color: appPalette(context).textMuted),
                                ),
                              ],
                            ],
                          ),
                        ),
                  ],
                )
              : Text(
                  'No crew data available.',
                  style: TextStyle(color: appPalette(context).textMuted),
                ),
        ),
      ],
    );
  }

  Widget _discsTab() {
    final editions = widget.item.editions;
    final allDiscs = <(String, CatalogDisc)>[];
    for (final edition in editions) {
      for (final disc in edition.discs) {
        allDiscs.add((edition.title, disc));
      }
    }
    return EditTabShell(
      children: [
        EditSection(
          title: 'Disc contents',
          accent: widget.accent,
          child: allDiscs.isEmpty
              ? Text(
                  'No disc data available yet. Disc management will be enabled in a future update.',
                  style: TextStyle(color: appPalette(context).textMuted),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (editionTitle, disc) in allDiscs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(Icons.album,
                                size: 16, color: appPalette(context).textMuted),
                            const SizedBox(width: 8),
                            Text(
                              disc.discName ?? 'Disc ${disc.discNumber}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            if (disc.discFormat != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                '(${disc.discFormat})',
                                style: TextStyle(
                                    color: appPalette(context).textMuted),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              editionTitle,
                              style: TextStyle(
                                color: appPalette(context).textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _editionTab() {
    final releaseFields = widget.type.releaseFields;
    final editPresentation = _editPresentation;
    return EditTabShell(
      children: [
        EditSection(
          title: 'Edition',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveFields([
                _field(
                    controller: _editionTitleController,
                    label: releaseFields.editionTitleLabel),
                _field(
                    controller: _variantController,
                    label: releaseFields.variantLabel),
                _field(
                    controller: _barcodeController,
                    label: releaseFields.barcodeLabel),
              ]),
              if (releaseFields.showPhysicalFormat &&
                  widget.physicalFormats.isNotEmpty) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _physicalFormatId ?? '',
                  isExpanded: true,
                  dropdownColor: appPalette(context).panelRaised,
                  borderRadius: kEditMenuBorderRadius,
                  decoration: const InputDecoration(
                    labelText: 'Physical format',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('No specific format'),
                    ),
                    for (final format in widget.physicalFormats)
                      DropdownMenuItem<String>(
                        value: format.id,
                        child: Text(format.label),
                      ),
                  ],
                  onChanged: (value) {
                    final normalized = emptyToNull(value ?? '');
                    final format = _physicalFormatForId(normalized);
                    final previousFormat =
                        _physicalFormatForId(_physicalFormatId);
                    final variant = _variantController.text.trim();
                    final shouldReplaceVariant =
                        variant.isEmpty || previousFormat?.label == variant;
                    _mutateDialogState(() {
                      _physicalFormatId = format?.id;
                      if (format != null && shouldReplaceVariant) {
                        _variantController.text = format.label;
                      }
                    });
                  },
                ),
              ],
            ],
          ),
        ),
        EditSection(
          title: 'Packaging & set',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _flexResponsiveFields(
                [
                  _field(
                    controller: _boxSetNameController,
                    label: 'Box set',
                    hint: 'Name of the box set this disc belongs to',
                  ),
                  _field(
                    controller: _packagingController,
                    label: 'Packaging',
                    hint: 'e.g. Keep Case, Steelbook, Digibook',
                  ),
                ],
                flexes: const [1, 1],
                breakpoint: 720,
              ),
              const SizedBox(height: 10),
              _flexResponsiveFields(
                [
                  _field(
                    controller: _distributorController,
                    label: 'Distributor',
                  ),
                  _field(
                    controller: _nrDiscsController,
                    label: 'Nr. of Discs',
                    validator: optionalIntValidator,
                  ),
                  _field(
                    controller: _colorController,
                    label: 'Color',
                    hint: 'B&W, Color, or Both',
                  ),
                ],
                flexes: const [3, 2, 2],
                breakpoint: 820,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _featuresController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Features',
                  hintText: 'Disc features, special editions, bonus content...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        if (editPresentation.showsOwnershipReferenceSection)
          EditSection(
            title: editPresentation.ownershipReferenceTitle,
            accent: widget.accent,
            child: Column(
              children: [
                _ownershipAnchorSelectionField(),
                if (_selectedOwnedAnchorType ==
                        PersonalItemAnchorType.edition.apiValue ||
                    _selectedOwnedAnchorType ==
                        PersonalItemAnchorType.variant.apiValue) ...[
                  const SizedBox(height: 10),
                  _responsiveFields([
                    _editionSelectionField(),
                    if (_selectedOwnedAnchorType ==
                        PersonalItemAnchorType.variant.apiValue)
                      _variantSelectionField(),
                  ]),
                ],
                if (_selectedOwnedAnchorType ==
                    PersonalItemAnchorType.bundleRelease.apiValue) ...[
                  const SizedBox(height: 10),
                  _bundleReleaseSelectionField(
                    fieldKey: const Key('library-edit-owned-bundle-field'),
                    label: editPresentation.ownedBundleLabel,
                    selectedBundleReleaseId: _selectedBundleReleaseId,
                    onChanged: (value) {
                      _mutateDialogState(() {
                        _selectedBundleReleaseId =
                            normalizeLibrarySelectionId(value);
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _videoPersonalTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: _isOwned
              ? 'Ownership'
              : _hasWishlistContext
                  ? 'Personal'
                  : 'Tracking',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_showPhysicalOwnedFields) ...[
                _responsiveFields([
                  _locationField(),
                  _field(
                    controller: _ownerLabelController,
                    label: 'Owner',
                    hint: 'Name of the owner',
                  ),
                ]),
                const SizedBox(height: 10),
                _responsiveFields([
                  TextFormField(
                    controller: _storageDeviceController,
                    decoration: const InputDecoration(
                      labelText: 'Storage Device',
                      hintText: 'e.g. DVD Shelf, Blu-ray Cabinet',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  TextFormField(
                    controller: _storageSlotController,
                    decoration: const InputDecoration(
                      labelText: 'Storage Slot',
                      hintText: 'e.g. Row 3, Slot 5',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
              ] else if (_isOwned) ...[
                Text(
                  'Digital copies do not expose physical storage fields.',
                  style: TextStyle(color: appPalette(context).textMuted),
                ),
                const SizedBox(height: 10),
              ],
              if (_isOwned) ...[
                TagPickListField(
                  controller: _tagsController,
                  options: _tagOptions,
                  label: 'Tags',
                  hint: 'Comma-separated tags',
                ),
                const SizedBox(height: 10),
                _responsiveFields([
                  if (_showPhysicalOwnedFields) ...[
                    _field(controller: _conditionController, label: 'Condition'),
                    _field(controller: _gradeController, label: 'Grade'),
                  ],
                  _field(
                    controller: _quantityController,
                    label: 'Quantity',
                    validator: positiveIntValidator,
                  ),
                ]),
              ],
            ],
          ),
        ),
        EditSection(
          title: 'Watch history',
          accent: widget.accent,
          child: Column(
            children: [
              if (_isTrackingOnly && widget.item.editions.isNotEmpty) ...[
                _responsiveFields([
                  _trackingEditionSelectionField(),
                  _trackingVariantSelectionField(),
                ]),
                const SizedBox(height: 10),
              ],
              _responsiveFields([
                SizedBox(
                  width: 120,
                  child: MediaRatingField(controller: _ratingController),
                ),
                SizedBox(
                  width: 180,
                  child: MediaTrackingStatusField(
                    profile: widget.type.trackingProfile,
                    value: _trackingController.text,
                    label: 'Tracking status',
                    onChanged: (value) {
                      _trackingController.text = value ?? '';
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields(
                buildTrackingProgressFieldWidgets(
                  progressCurrentController: _progressCurrentController,
                  progressTotalController: _progressTotalController,
                  timesCompletedController: _timesCompletedController,
                  buildField: (controller, label) => _field(
                    controller: controller,
                    label: label,
                    validator: optionalIntValidator,
                  ),
                ),
              ),
              if (_showsEpisodeTrackingFields) ...[
                const SizedBox(height: 10),
                _responsiveFields(
                  buildTrackingEpisodeFieldWidgets(
                    seasonNumberController: _seasonNumberController,
                    episodeNumberController: _episodeNumberController,
                    buildField: (controller, label) => _field(
                      controller: controller,
                      label: label,
                      validator: optionalIntValidator,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _responsiveFields([
                _datePickerField(
                  label: 'Started',
                  value: _startedAt,
                  onChanged: (v) => _mutateDialogState(() => _startedAt = v),
                ),
                _datePickerField(
                  label: 'Finished',
                  value: _finishedAt,
                  onChanged: (v) => _mutateDialogState(() => _finishedAt = v),
                ),
              ]),
              const SizedBox(height: 10),
              TextFormField(
                controller: _trackingNotesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Tracking notes',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        if (_showsEpisodeTrackingFields)
          VideoSeasonTrackingSection(
            itemId: widget.item.id,
            accent: widget.accent,
          ),
        if (_showsEpisodeTrackingFields)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: VideoEpisodeRatingSection(
              itemId: widget.item.id,
              accent: widget.accent,
              trackingEntry: widget.trackingEntry?.copyWith(
                episodeRatings: _episodeRatings,
              ),
              onEpisodeRatingsChanged: (updated) {
                _mutateDialogState(() => _episodeRatings = updated);
              },
            ),
          ),
        if (_hasWishlistContext)
          EditSection(
            title: 'Wishlist reference',
            accent: widget.accent,
            child: Column(
              children: [
                _wishlistAnchorSelectionField(),
                if (_selectedWishlistAnchorType ==
                        PersonalItemAnchorType.edition.apiValue ||
                    _selectedWishlistAnchorType ==
                        PersonalItemAnchorType.variant.apiValue) ...[
                  const SizedBox(height: 10),
                  _responsiveFields([
                    _wishlistEditionSelectionField(),
                    if (_selectedWishlistAnchorType ==
                        PersonalItemAnchorType.variant.apiValue)
                      _wishlistVariantSelectionField(),
                  ]),
                ],
                if (_selectedWishlistAnchorType ==
                    PersonalItemAnchorType.bundleRelease.apiValue) ...[
                  const SizedBox(height: 10),
                  _bundleReleaseSelectionField(
                    fieldKey: const Key('library-edit-wishlist-bundle-field'),
                    label: 'Wishlist bundle',
                    selectedBundleReleaseId: _selectedWishlistBundleReleaseId,
                    onChanged: (value) {
                      _mutateDialogState(() {
                        _selectedWishlistBundleReleaseId =
                            normalizeLibrarySelectionId(value);
                      });
                    },
                  ),
                ],
                const SizedBox(height: 10),
                _responsiveFields([
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
          ),
        if (_isOwned && !_hasValueTab)
          EditSection(
            title: 'Purchase & value',
            accent: widget.accent,
            child: Column(
              children: [
                _responsiveFields([
                  _field(
                    controller: _priceController,
                    label: 'Purchase price',
                    validator: optionalMoneyValidator,
                  ),
                  _field(controller: _currencyController, label: 'Currency'),
                ]),
                const SizedBox(height: 10),
                _responsiveFields([
                  _field(
                    controller: _purchaseDateController,
                    label: 'Purchase date',
                    hint: 'YYYY-MM-DD',
                    validator: optionalDateValidator,
                  ),
                  _field(
                    controller: _purchaseStoreController,
                    label: 'Purchase store',
                  ),
                ]),
                const SizedBox(height: 10),
                _responsiveFields([
                  _field(
                    controller: _marketValueController,
                    label: 'Current value',
                    validator: optionalMoneyValidator,
                  ),
                ]),
              ],
            ),
          ),
        if (_isOwned)
          EditSection(
            title: 'Notes',
            accent: widget.accent,
            child: TextFormField(
              controller: _notesController,
              minLines: 5,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Personal notes',
                alignLabelWithHint: true,
              ),
            ),
          )
        else if (!_hasWishlistContext)
          EditSection(
            title: 'Collection fields',
            accent: widget.accent,
            child: Text(
              'Storage, value, quantity and personal notes are only available once the item has an owned copy. Tracking progress stays editable here.',
              style: TextStyle(color: appPalette(context).textMuted),
            ),
          ),
      ],
    );
  }

  Widget _specsTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Video specifications',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveFields([
                _field(
                  controller: _regionController,
                  label: 'Region',
                  hint: 'e.g. A, B, C (Blu-ray) or 1-6 (DVD)',
                ),
                _field(
                  controller: _screenRatioController,
                  label: 'Screen Ratio',
                  hint: 'e.g. 2.39:1, 1.85:1, 16:9',
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: _layersController,
                  label: 'Layers',
                  hint: 'e.g. Single, Dual',
                ),
              ]),
            ],
          ),
        ),
        EditSection(
          title: 'HDR',
          accent: widget.accent,
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final format in const [
                'HDR10',
                'HDR10+',
                'Dolby Vision',
                'HLG',
              ])
                FilterChip(
                  label: Text(format),
                  selected: _hdrFormats.contains(format),
                  onSelected: (selected) {
                    _mutateDialogState(() {
                      if (selected) {
                        _hdrFormats.add(format);
                      } else {
                        _hdrFormats.remove(format);
                      }
                    });
                  },
                ),
            ],
          ),
        ),
        EditSection(
          title: 'Audio & Subtitles',
          accent: widget.accent,
          child: Column(
            children: [
              TextFormField(
                controller: _audioTracksController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Audio Tracks',
                  hintText:
                      'One per line, e.g.\nEnglish DTS-HD MA 7.1\nFrench DD 5.1',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subtitlesController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Subtitles',
                  hintText: 'One per line, e.g.\nEnglish\nFrench\nSpanish',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _linksTab() {
    final trailers = widget.item.trailerUrls;
    return EditTabShell(
      children: [
        if (trailers.isNotEmpty)
          EditSection(
            title: 'YouTube Trailers',
            accent: widget.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final trailer in trailers) ...[
                  InkWell(
                    onTap: () => _launchUrl(trailer.url),
                    child: Row(
                      children: [
                        const Icon(Icons.play_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trailer.title ?? trailer.url,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (trailer.source != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            trailer.source!,
                            style: TextStyle(
                              color: appPalette(context).textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        EditSection(
          title: 'External Links',
          accent: widget.accent,
          child: Text(
            'External links (TMDb, IMDb, etc.) will be available in a future update.',
            style: TextStyle(color: appPalette(context).textMuted),
          ),
        ),
      ],
    );
  }
}