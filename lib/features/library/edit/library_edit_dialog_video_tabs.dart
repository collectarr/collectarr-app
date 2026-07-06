part of 'library_edit_dialog.dart';

const _castRoleOptions = <String>[
  'Actor',
  'Voice',
  'Voice Actor',
  'Guest Star',
  'Cameo',
  'Narrator',
];

const _crewRoleOptions = <String>[
  'Director',
  'Writer',
  'Producer',
  'Executive Producer',
  'Composer',
  'Cinematographer',
  'Editor',
  'Production Designer',
  'Musician',
  'Screenplay',
  'Story',
  'Casting',
];

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
                _publisherField(label: 'Studios'),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: _runtimeController,
                  label: 'Runtime (min)',
                  validator: optionalIntValidator,
                ),
                _ageRatingPickField(),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _audienceRatingPickField(),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _countryPickField(),
                _languagePickField(),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                TagPickListField(
                  controller: _genresEditController,
                  options: _genreOptions,
                  label: 'Genres',
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _castTab() {
    return _buildCreditsTab(
      title: 'Cast',
      emptyMessage: 'No cast data yet.',
      addLabel: 'Add Cast',
      credits: _videoCastCredits,
      defaultRole: 'Actor',
      roleOptions: _castRoleOptions,
      addCredit: () => _mutateDialogState(
        () => _videoCastCredits.add(EditableVideoCredit.custom(role: 'Actor')),
      ),
    );
  }

  Widget _crewTab() {
    return _buildCreditsTab(
      title: 'Crew',
      emptyMessage: 'No crew data yet.',
      addLabel: 'Add Crew',
      credits: _videoCrewCredits,
      defaultRole: 'Director',
      roleOptions: _crewRoleOptions,
      addCredit: () => _mutateDialogState(
        () =>
            _videoCrewCredits.add(EditableVideoCredit.custom(role: 'Director')),
      ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EditSectionStateMessage(
                message:
                    'Read-only: disc contents are currently synced from provider/Core metadata.',
                icon: Icons.lock_outline,
              ),
              const SizedBox(height: 10),
              if (allDiscs.isEmpty)
                const EditSectionStateMessage(
                  message:
                      'No disc data available yet. Disc management will be enabled in a future update.',
                  icon: Icons.album_outlined,
                )
              else
                Column(
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
                  _packagingPickField(),
                ],
                flexes: const [1, 1],
                breakpoint: 720,
              ),
              const SizedBox(height: 10),
              _flexResponsiveFields(
                [
                  _distributorPickField(),
                  _field(
                    controller: _nrDiscsController,
                    label: 'Nr. of Discs',
                    validator: optionalIntValidator,
                  ),
                  _colorPickField(),
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
                  _ownerPickField(),
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
                    _conditionPickField(),
                    _gradePickField(),
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
                  LibraryCurrencyField(controller: _currencyController),
                ]),
                const SizedBox(height: 10),
                _responsiveFields([
                  _datePickerField(
                    label: 'Purchase date',
                    value: parseDate(_purchaseDateController.text),
                    onChanged: (picked) {
                      _mutateDialogState(() {
                        _purchaseDateController.text =
                            picked == null ? '' : formatDate(picked);
                      });
                    },
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

  Widget _readHistoryTab() {
    return EditTabShell(
      children: [
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
            seriesRef: CatalogEntityRef(
              kind: widget.type.workspace.kind.apiValue,
              entityType: CatalogEntityType.work,
              id: widget.item.id,
            ),
            kind: widget.type.workspace.kind.apiValue,
            accent: widget.accent,
          ),
        if (_showsEpisodeTrackingFields)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: VideoEpisodeRatingSection(
              itemId: widget.item.id,
              kind: widget.type.workspace.kind.apiValue,
              accent: widget.accent,
              trackingEntry: widget.trackingEntry?.copyWith(
                episodeRatings: _episodeRatings,
              ),
              onEpisodeRatingsChanged: (updated) {
                _mutateDialogState(() => _episodeRatings = updated);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCreditsTab({
    required String title,
    required String emptyMessage,
    required String addLabel,
    required List<EditableVideoCredit> credits,
    required String defaultRole,
    required List<String> roleOptions,
    required VoidCallback addCredit,
  }) {
    final stacked = MediaQuery.sizeOf(context).width < 760;
    return EditTabShell(
      children: [
        EditSection(
          title: title,
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: addCredit,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(addLabel),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (credits.isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    emptyMessage,
                    style: TextStyle(color: appPalette(context).textMuted),
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorderItem: (oldIndex, newIndex) {
                    _mutateDialogState(() {
                      final item = credits.removeAt(oldIndex);
                      credits.insert(newIndex, item);
                    });
                  },
                  itemCount: credits.length,
                  itemBuilder: (context, index) {
                    final credit = credits[index];
                    final currentRole = credit.roleController.text.trim();
                    final selectedRole = roleOptions.firstWhere(
                      (option) => option.toLowerCase() == currentRole.toLowerCase(),
                      orElse: () => currentRole.isEmpty ? defaultRole : currentRole,
                    );
                    final options = <String>[
                      selectedRole,
                      ...roleOptions.where(
                        (option) =>
                            option.toLowerCase() != selectedRole.toLowerCase(),
                      ),
                    ];
                    return Padding(
                      key: ValueKey(credit),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: EditablePersonCreditRow(
                        stacked: stacked,
                        dragHandle: ReorderableDragStartListener(
                          index: index,
                          child: Icon(
                            Icons.drag_handle,
                            color: appPalette(context).textMuted,
                          ),
                        ),
                        avatar: const CircleAvatar(
                          radius: 14,
                          child: Icon(Icons.person, size: 16),
                        ),
                        primaryField: DropdownButtonFormField<String>(
                          initialValue: selectedRole,
                          isExpanded: true,
                          items: [
                            for (final role in options)
                              DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            credit.roleController.text = value;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Role',
                            isDense: true,
                          ),
                        ),
                        secondaryField: TextFormField(
                          controller: credit.nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                          ),
                        ),
                        trailingActions: [
                          IconButton(
                            onPressed: () => _mutateDialogState(
                              () => credits.removeAt(index).dispose(),
                            ),
                            icon: const Icon(Icons.close, size: 18),
                            tooltip: 'Remove',
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
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
                _regionPickField(),
                _screenRatioPickField(),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _layersPickField(),
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
    final trailers = widget.item.trailerUrls
        .where((link) => link.isTrailerLink)
        .toList(growable: false);
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
          child: const EditSectionStateMessage(
            message:
                'Read-only: external links (TMDb, IMDb, etc.) are synced from provider/Core metadata. Editing will be available in a future update.',
            icon: Icons.lock_outline,
          ),
        ),
      ],
    );
  }
}
