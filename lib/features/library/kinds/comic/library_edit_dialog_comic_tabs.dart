part of '../../edit/library_edit_dialog.dart';

extension _LibraryEditRendererComicTabs on _LibraryEditRendererState {
  Widget _ownedComicDetailsTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Details',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveFields([
                _crossoverPickField(),
                _storyArcPickField(),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: _titleController,
                  label: 'Title',
                ),
                _field(
                  controller: _titleExtensionController,
                  label: 'Subtitle',
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _countryPickField(),
                _field(
                  controller: _languageController,
                  label: 'Language',
                ),
              ]),
              const SizedBox(height: 10),
              _flexResponsiveFields([
                _field(
                  controller: _ageRatingController,
                  label: 'Age',
                ),
                _field(
                  controller: _pageCountController,
                  label: 'No. of Pages',
                  validator: optionalIntValidator,
                ),
                _field(
                  controller: _genresEditController,
                  label: 'Genre',
                  hint: 'Comma-separated',
                ),
              ], flexes: const [
                3,
                3,
                6
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _comicCreatorsTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Creators',
          accent: widget.accent,
          child: Column(
            children: [
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => _mutateDialogState(
                      () => _comicCreators.add(_EditableComicCreator.custom()),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _addCatalogComicCreator,
                    icon: const Icon(Icons.person_search_outlined, size: 16),
                    label: const Text('Find in Catalog'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_comicCreators.isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Creators is empty',
                    style: TextStyle(color: appPalette(context).textMuted),
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorderItem: (oldIndex, newIndex) {
                    _mutateDialogState(() {
                      final item = _comicCreators.removeAt(oldIndex);
                      _comicCreators.insert(newIndex, item);
                    });
                  },
                  itemCount: _comicCreators.length,
                  itemBuilder: (context, index) {
                    final creator = _comicCreators[index];
                    final currentRole = creator.roleController.text.trim();
                    final roles = <String>[
                      if (currentRole.isNotEmpty &&
                          !_commonCreatorRoles.contains(currentRole))
                        currentRole,
                      ..._commonCreatorRoles,
                    ];
                    return Padding(
                      key: ValueKey(creator),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            child: Icon(
                              Icons.drag_handle,
                              color: appPalette(context).textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 180,
                            child: DropdownButtonFormField<String>(
                              initialValue:
                                  currentRole.isEmpty ? null : currentRole,
                              items: [
                                for (final role in roles)
                                  DropdownMenuItem(
                                      value: role, child: Text(role)),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                creator.roleController.text = value;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Role',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: creator.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _lookupComicCreatorForRow(index),
                            icon: const Icon(Icons.person_search, size: 18),
                            tooltip: 'Lookup',
                          ),
                          IconButton(
                            onPressed: () => _mutateDialogState(
                              () => _comicCreators.removeAt(index).dispose(),
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

  Widget _comicCharactersTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Characters',
          accent: widget.accent,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _comicCharacterDraftController,
                      decoration:
                          const InputDecoration(hintText: 'Character name'),
                      onSubmitted: (_) => _addComicCharacter(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _addComicCharacter,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _addCatalogComicCharacter,
                    icon: const Icon(Icons.person_search_outlined, size: 16),
                    label: const Text('Find in Catalog'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_comicCharacters.isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Characters is empty',
                    style: TextStyle(color: appPalette(context).textMuted),
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorderItem: (oldIndex, newIndex) {
                    _mutateDialogState(() {
                      final item = _comicCharacters.removeAt(oldIndex);
                      _comicCharacters.insert(newIndex, item);
                    });
                  },
                  itemCount: _comicCharacters.length,
                  itemBuilder: (context, index) {
                    final character = _comicCharacters[index];
                    return Padding(
                      key: ValueKey(character),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            child: Icon(
                              Icons.drag_handle,
                              color: appPalette(context).textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              controller: character.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Character',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: character.realNameController,
                              decoration: const InputDecoration(
                                labelText: 'Real name',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _mutateDialogState(
                              () => _comicCharacters.removeAt(index).dispose(),
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

  Widget _comicLinksTab() {
    final palette = appPalette(context);
    return EditTabShell(
      children: [
        EditSection(
          title: 'External Links',
          accent: widget.accent,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: palette.surfaceSubtle.withValues(alpha: 0.5),
                  border: Border.all(color: palette.divider),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: palette.divider),
                        ),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 48),
                          Expanded(
                            flex: 5,
                            child: Text(
                              'URL',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Description',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_comicLinks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'No links added yet',
                            style: TextStyle(color: palette.textMuted),
                          ),
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        onReorderItem: (oldIndex, newIndex) {
                          _mutateDialogState(() {
                            final item = _comicLinks.removeAt(oldIndex);
                            _comicLinks.insert(newIndex, item);
                          });
                        },
                        itemCount: _comicLinks.length,
                        itemBuilder: (context, index) {
                          final link = _comicLinks[index];
                          return Container(
                            key: ValueKey(link),
                            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: palette.divider),
                              ),
                            ),
                            child: Row(
                              children: [
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Icon(
                                    Icons.drag_handle,
                                    color: palette.textMuted,
                                  ),
                                ),
                                SizedBox(
                                  width: 28,
                                  child: Checkbox(
                                    value: false,
                                    onChanged: (value) {
                                      if (value != true) return;
                                      _mutateDialogState(() {
                                        final removed =
                                            _comicLinks.removeAt(index);
                                        removed['title']?.dispose();
                                        removed['url']?.dispose();
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: TextFormField(
                                    controller: link['url'],
                                    decoration: const InputDecoration(
                                      hintText: 'https://',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    controller: link['title'],
                                    decoration: const InputDecoration(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => _mutateDialogState(
                    () => _comicLinks.add(_createComicLinkControllers()),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Link'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ownedComicMainTab() {
    final editPresentation = _editPresentation;
    return EditTabShell(
      children: [
        _ownedComicMainOverviewCard(),
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
        EditSection(
          title: 'Storage & Notes',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_showPhysicalOwnedFields) ...[
                _responsiveFields([
                  _field(
                    controller: _ownerLabelController,
                    label: 'Owner',
                    hint: 'Name of the owner',
                  ),
                ]),
                const SizedBox(height: 10),
              ] else ...[
                Text(
                  'Digital copies do not expose physical storage fields.',
                  style: TextStyle(color: appPalette(context).textMuted),
                ),
                const SizedBox(height: 10),
              ],
              TagPickListField(
                controller: _tagsController,
                options: _tagOptions,
                label: 'Tags',
                hint: 'Comma-separated tags',
              ),
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
              _responsiveFields([
                _field(
                  controller: _storageDeviceController,
                  label: 'Storage device',
                ),
                _field(
                  controller: _storageSlotController,
                  label: 'Storage slot',
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
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                minLines: 4,
                maxLines: 7,
                decoration: const InputDecoration(
                  labelText: 'Personal notes',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ownedComicValueTab() {
    final editPresentation = _editPresentation;
    return EditTabShell(
      children: [
        EditSection(
          title: 'Value',
          accent: widget.accent,
          child: Column(
            children: [
              _responsiveFields([
                _field(controller: _gradeController, label: 'Grade'),
                _field(
                  controller: _conditionController,
                  label: 'Condition',
                ),
                _comicRawOrSlabbedField(),
                _field(
                  controller: _gradingCompanyController,
                  label: 'Grading company',
                ),
                _field(
                  controller: _certificationNumberController,
                  label: 'Certification number',
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(controller: _labelTypeController, label: 'Label type'),
                _field(controller: _signedByController, label: 'Signed by'),
                _pageQualityPickField(label: 'Page quality'),
                _field(
                  controller: _coverPriceController,
                  label: 'Cover price',
                  validator: optionalMoneyValidator,
                ),
              ]),
              const SizedBox(height: 10),
              TextFormField(
                controller: _graderNotesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Grader notes',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 10),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  value: _keyComic,
                  onChanged: (value) =>
                      _mutateDialogState(() => _keyComic = value),
                  title: Text(editPresentation.keyToggleLabel),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              if (_keyComic) ...[
                const SizedBox(height: 6),
                _responsiveFields([
                  _field(
                    controller: _keyReasonController,
                    label: editPresentation.keyReasonLabel,
                  ),
                  _keyCategoryPickField(label: 'Key category'),
                ]),
              ],
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: _priceController,
                  label: 'Price paid',
                  validator: optionalMoneyValidator,
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(controller: _currencyController, label: 'Currency'),
                _field(
                  controller: _marketValueController,
                  label: 'My value',
                  validator: optionalMoneyValidator,
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: _purchaseStoreController,
                  label: 'Purchase store',
                ),
                _datePickerField(
                  label: 'Purchase date',
                  value: parseDate(_purchaseDateController.text),
                  onChanged: (value) {
                    _mutateDialogState(() {
                      _purchaseDateController.text =
                          value == null ? '' : formatDate(value);
                    });
                  },
                ),
              ]),
              const SizedBox(height: 10),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  value: _soldAt != null,
                  onChanged: (value) {
                    _mutateDialogState(() {
                      _soldAt = value ? DateTime.now() : null;
                    });
                  },
                  title: const Text('Mark as sold'),
                  subtitle: _soldAt != null
                      ? Text(
                          'Sold on ${formatDate(_soldAt!)}',
                          style:
                              TextStyle(color: appPalette(context).textMuted),
                        )
                      : null,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (_soldAt != null) ...[
                const SizedBox(height: 12),
                _responsiveFields([
                  _field(
                    controller: _sellPriceController,
                    label: 'Price sold',
                    validator: optionalMoneyValidator,
                  ),
                  _datePickerField(
                    label: 'Sold date',
                    value: _soldAt,
                    onChanged: (value) =>
                        _mutateDialogState(() => _soldAt = value),
                  ),
                  _field(controller: _soldToController, label: 'Sold to'),
                ]),
                const SizedBox(height: 12),
                SoldSummaryPanel(
                  pricePaidCents: parseMoneyCents(_priceController.text),
                  sellPriceCents: parseMoneyCents(_sellPriceController.text),
                  currency: _currencyController.text,
                ),
              ],
              const SizedBox(height: 10),
              _datePickerField(
                label: 'Last bag & board date',
                value: _lastBagBoardDate,
                onChanged: (value) =>
                    _mutateDialogState(() => _lastBagBoardDate = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _comicRawOrSlabbedField() {
    final rawValue = _rawOrSlabbedController.text.trim().toLowerCase();
    final selected = rawValue == 'slabbed' ? 'slabbed' : 'raw';
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Raw / Slabbed'),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment<String>(value: 'raw', label: Text('Raw')),
          ButtonSegment<String>(value: 'slabbed', label: Text('Slabbed')),
        ],
        selected: {selected},
        showSelectedIcon: false,
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        onSelectionChanged: (selection) {
          _mutateDialogState(() {
            final value = selection.first;
            _rawOrSlabbedController.text =
                value == 'slabbed' ? 'Slabbed' : 'Raw';
          });
        },
      ),
    );
  }

  Widget _ownedComicPersonalTab() {
    final isRead = _trackingController.text.trim().toLowerCase() == 'read';
    return EditTabShell(
      children: [
        EditSection(
          title: 'Personal',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _flexResponsiveFields(
                [
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Read'),
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(value: false, label: Text('No')),
                        ButtonSegment<bool>(value: true, label: Text('Yes')),
                      ],
                      selected: {isRead},
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      onSelectionChanged: (selection) {
                        final selected = selection.first;
                        _mutateDialogState(() {
                          _trackingController.text = selected ? 'Read' : '';
                          if (!selected) {
                            _finishedAt = null;
                          }
                        });
                      },
                    ),
                  ),
                  _datePickerField(
                    label: 'Read Date',
                    value: _finishedAt,
                    onChanged: (value) => _mutateDialogState(() {
                      _finishedAt = value;
                      if (value != null) {
                        _trackingController.text = 'Read';
                      }
                    }),
                  ),
                  _ownerPickField(label: 'Owner'),
                ],
                flexes: const [4, 4, 8],
                breakpoint: 980,
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 980) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _notesController,
                          minLines: 6,
                          maxLines: 9,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        MediaRatingField(controller: _ratingController),
                        const SizedBox(height: 10),
                        _tagsDropdownField(label: 'Tags'),
                        const SizedBox(height: 10),
                        _datePickerField(
                          label: 'Bag/Board Date',
                          value: _lastBagBoardDate,
                          onChanged: (value) => _mutateDialogState(
                            () => _lastBagBoardDate = value,
                          ),
                        ),
                      ],
                    );
                  }
                  return SizedBox(
                    height: 248,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 8,
                          child: TextFormField(
                            controller: _notesController,
                            expands: true,
                            minLines: null,
                            maxLines: null,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              alignLabelWithHint: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 88,
                                child: MediaRatingField(
                                  controller: _ratingController,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _tagsDropdownField(label: 'Tags'),
                              const Spacer(),
                              _datePickerField(
                                label: 'Bag/Board Date',
                                value: _lastBagBoardDate,
                                onChanged: (value) => _mutateDialogState(
                                  () => _lastBagBoardDate = value,
                                ),
                              ),
                            ],
                          ),
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

  Widget _ownedComicMainOverviewCard() {
    final mediaFields = widget.type.mediaFields;
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: palette.gridCanvas,
        shape: Border(
          left: BorderSide(color: widget.accent, width: 2),
          top: BorderSide(color: palette.surfaceBright),
          right: BorderSide(color: palette.surfaceBright),
          bottom: BorderSide(color: palette.surfaceBright),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 920;
              final leftColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _seriesField(),
                  const SizedBox(height: 10),
                  _flexResponsiveFields(
                    [
                      _field(controller: _barcodeController, label: 'Barcode'),
                      _comicFormatField(),
                    ],
                    flexes: const [1, 1],
                    breakpoint: 520,
                  ),
                  if (mediaFields.showSeriesGroup) ...[
                    const SizedBox(height: 10),
                    _seriesGroupField(label: 'Series Group'),
                  ],
                ],
              );
              final rightColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _flexResponsiveFields(
                    [
                      _field(controller: _numberController, label: 'Issue No.'),
                      _field(controller: _variantController, label: 'Variant'),
                      _field(
                        controller: _editionTitleController,
                        label: 'Variant Description',
                      ),
                    ],
                    flexes: const [3, 2, 7],
                    breakpoint: 720,
                  ),
                  const SizedBox(height: 10),
                  _flexResponsiveFields(
                    [
                      _coverDatePartsField(),
                      _releaseDatePartsField(),
                    ],
                    flexes: const [1, 1],
                    breakpoint: 720,
                  ),
                  const SizedBox(height: 10),
                  _flexResponsiveFields(
                    [
                      _publisherField(),
                      if (mediaFields.showImprint) _imprintField(),
                    ],
                    flexes: [1, if (mediaFields.showImprint) 1],
                    breakpoint: 720,
                  ),
                ],
              );
              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leftColumn,
                    const SizedBox(height: 10),
                    rightColumn,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: leftColumn),
                  const SizedBox(width: 10),
                  Expanded(flex: 7, child: rightColumn),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _comicFormatField() {
    return _physicalFormatField(label: 'Format');
  }

  Widget _coverDatePartsField() {
    return _datePartsGroup(
      label: 'Cover Date',
      children: [
        _datePartField(
          key: const Key('comic-cover-date-year'),
          controller: _coverDateYearPartController,
          placeholder: 'YYYY',
          validator: optionalIntValidator,
          onChanged: (_) => _syncCoverDateFromParts(),
        ),
        _datePartField(
          key: const Key('comic-cover-date-month'),
          controller: _coverDateMonthPartController,
          placeholder: 'MM',
          validator: optionalIntValidator,
          onChanged: (_) => _syncCoverDateFromParts(),
        ),
        _datePartField(
          key: const Key('comic-cover-date-day'),
          controller: _coverDateDayPartController,
          placeholder: 'DD',
          validator: optionalIntValidator,
          onChanged: (_) => _syncCoverDateFromParts(),
        ),
      ],
    );
  }

  Widget _releaseDatePartsField() {
    return _datePartsGroup(
      label: 'Release Date',
      children: [
        _datePartField(
          key: const Key('comic-release-date-year'),
          controller: _releaseDateYearPartController,
          placeholder: 'YYYY',
          validator: optionalIntValidator,
          onChanged: (_) => _syncReleaseDateFromParts(),
        ),
        _datePartField(
          key: const Key('comic-release-date-month'),
          controller: _releaseDateMonthPartController,
          placeholder: 'MM',
          validator: optionalIntValidator,
          onChanged: (_) => _syncReleaseDateFromParts(),
        ),
        _datePartField(
          key: const Key('comic-release-date-day'),
          controller: _releaseDateDayPartController,
          placeholder: 'DD',
          validator: optionalIntValidator,
          onChanged: (_) => _syncReleaseDateFromParts(),
        ),
      ],
    );
  }

  Widget _datePartsGroup({
    required String label,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: appPalette(context).textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index != children.length - 1) const SizedBox(width: 6),
            ],
          ],
        ),
      ],
    );
  }

  Widget _datePartField({
    Key? key,
    TextEditingController? controller,
    required String placeholder,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      maxLength: placeholder.length,
      validator: validator,
      decoration: InputDecoration(
        counterText: '',
        hintText: placeholder,
      ),
    );
  }

  void _syncCoverDateFromParts() {
    final year = _coverDateYearPartController.text.trim();
    final month = _coverDateMonthPartController.text.trim();
    final day = _coverDateDayPartController.text.trim();
    if (year.isEmpty && month.isEmpty && day.isEmpty) {
      _coverDateController.text = '';
      return;
    }
    if (year.length != 4 || month.length != 2 || day.length != 2) {
      _coverDateController.text = '';
      return;
    }
    final parsed = DateTime.tryParse('$year-$month-$day');
    _coverDateController.text = parsed == null ? '' : formatDate(parsed);
  }

  void _syncReleaseDateFromParts() {
    final year = _releaseDateYearPartController.text.trim();
    final month = _releaseDateMonthPartController.text.trim();
    final day = _releaseDateDayPartController.text.trim();
    if (year.isEmpty && month.isEmpty && day.isEmpty) {
      _releaseDateController.text = '';
      return;
    }
    if (year.length != 4 || month.length != 2 || day.length != 2) {
      _releaseDateController.text = '';
      return;
    }
    final parsed = DateTime.tryParse('$year-$month-$day');
    _releaseDateController.text = parsed == null ? '' : formatDate(parsed);
  }

  Future<void> _addCatalogComicCreator() async {
    final api = ref.read(apiClientProvider);
    final creator = await _showComicLookupDialog(
      title: 'Find creator',
      searchHint: 'Search creators',
      search: (query) => api.searchCreators(query: query, limit: 24),
      titleForResult: (result) => result['name']?.toString() ?? 'Creator',
      subtitleForResult: (result) {
        final itemCount = (result['item_count'] as num?)?.toInt();
        final description = result['description']?.toString().trim();
        return [
          if (itemCount != null) '$itemCount credits',
          if (description != null && description.isNotEmpty) description,
        ].join(' · ');
      },
    );
    if (creator == null) return;
    _mutateDialogState(
      () => _comicCreators.add(_EditableComicCreator.fromLookupResult(creator)),
    );
  }

  Future<void> _lookupComicCreatorForRow(int index) async {
    if (index < 0 || index >= _comicCreators.length) return;
    final api = ref.read(apiClientProvider);
    final creator = await _showComicLookupDialog(
      title: 'Find creator',
      searchHint: 'Search creators',
      search: (query) => api.searchCreators(query: query, limit: 24),
      titleForResult: (result) => result['name']?.toString() ?? 'Creator',
      subtitleForResult: (result) {
        final itemCount = (result['item_count'] as num?)?.toInt();
        final description = result['description']?.toString().trim();
        return [
          if (itemCount != null) '$itemCount credits',
          if (description != null && description.isNotEmpty) description,
        ].join(' · ');
      },
    );
    if (creator == null) return;
    final role = creator['role']?.toString().trim().isNotEmpty == true
        ? creator['role']!.toString().trim()
        : creator['job']?.toString().trim().isNotEmpty == true
            ? creator['job']!.toString().trim()
            : '';
    _mutateDialogState(() {
      final current = _comicCreators[index];
      current.nameController.text = creator['name']?.toString() ?? '';
      if (role.isNotEmpty) {
        current.roleController.text = role;
      }
      current.metadata
        ..addAll(creator)
        ..['source_type'] = 'core';
    });
  }

  void _addComicCharacter() {
    final normalized = _comicCharacterDraftController.text.trim();
    if (normalized.isEmpty) return;
    final exists = _comicCharacters.any((character) =>
        character.nameController.text.trim().toLowerCase() ==
        normalized.toLowerCase());
    if (exists) {
      _comicCharacterDraftController.clear();
      return;
    }
    _mutateDialogState(() {
      _comicCharacters.add(_EditableComicCharacter.custom(normalized));
      _comicCharacterDraftController.clear();
    });
  }

  Future<void> _addCatalogComicCharacter() async {
    final api = ref.read(apiClientProvider);
    final character = await _showComicLookupDialog(
      title: 'Find character',
      searchHint: 'Search characters',
      search: (query) => api.searchCharacters(query: query, limit: 24),
      titleForResult: (result) => result['name']?.toString() ?? 'Character',
      subtitleForResult: (result) {
        final count = (result['appearance_count'] as num?)?.toInt();
        return count == null ? '' : '$count appearances';
      },
    );
    if (character == null) return;
    final normalized = character['name']?.toString().trim() ?? '';
    if (normalized.isEmpty) return;
    final exists = _comicCharacters.any((entry) =>
        entry.nameController.text.trim().toLowerCase() ==
        normalized.toLowerCase());
    if (exists) return;
    _mutateDialogState(
      () => _comicCharacters
          .add(_EditableComicCharacter.fromLookupResult(character)),
    );
  }

  Future<Map<String, dynamic>?> _showComicLookupDialog({
    required String title,
    required String searchHint,
    required Future<List<Map<String, dynamic>>> Function(String query) search,
    required String Function(Map<String, dynamic> result) titleForResult,
    required String Function(Map<String, dynamic> result) subtitleForResult,
  }) async {
    final searchController = TextEditingController();
    var results = const <Map<String, dynamic>>[];
    var isLoading = false;
    String? error;

    Future<void> runSearch(StateSetter setDialogState) async {
      setDialogState(() {
        isLoading = true;
        error = null;
      });
      try {
        final rows = await search(searchController.text.trim());
        setDialogState(() {
          results = rows;
          isLoading = false;
        });
      } catch (_) {
        setDialogState(() {
          error = 'Search failed. Try again.';
          isLoading = false;
        });
      }
    }

    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 620,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(hintText: searchHint),
                            onSubmitted: (_) => runSearch(setDialogState),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => runSearch(setDialogState),
                          child: const Text('Search'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      )
                    else if (error != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final result = results[index];
                            final subtitle = subtitleForResult(result);
                            return ListTile(
                              title: Text(titleForResult(result)),
                              subtitle:
                                  subtitle.isEmpty ? null : Text(subtitle),
                              onTap: () =>
                                  Navigator.of(dialogContext).pop(result),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
    searchController.dispose();
    return selected;
  }

  List<ResolvedComicEditImage> _resolvedEditImages() {
    return resolveComicEditImages(
      images: widget.itemImages,
      edits: _itemImageEdits,
    );
  }

  String _buildComicMarketSearchQuery() {
    return [
      widget.item.title,
      if (emptyToNull(_numberController.text) case final issue?) '#$issue',
      if (emptyToNull(_physicalFormatLabelController.text) case final format?)
        format,
      if (emptyToNull(_variantController.text) case final variant?) variant,
    ].join(' ').trim();
  }

  Widget _comicCoverTab() {
    final coverUrl = emptyToNull(_coverController.text) ??
        emptyToNull(_thumbnailController.text) ??
        widget.item.displayCoverUrl;
    final resolvedImages = _resolvedEditImages();
    final backCover = firstResolvedComicEditImageOfType(
      resolvedImages,
      'back_cover',
    );
    final frontAlt = firstResolvedComicEditImageOfType(
      resolvedImages,
      'front_cover',
    );
    final auxiliaryCount =
        resolvedImages.where((image) => image.imageType == 'auxiliary').length;
    return EditTabShell(
      children: [
        EditSection(
          title: 'Covers',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(controller: _coverController, label: 'Front Cover URL'),
              const SizedBox(height: 12),
              ComicCoverPreviewRow(
                coverUrl: coverUrl,
                frontCoverOverride: frontAlt,
                backCover: backCover,
              ),
            ],
          ),
        ),
        EditSection(
          title: 'Cover workflow',
          accent: widget.accent,
          child: ComicCoverWorkflowContent(
            imageCount: resolvedImages.length,
            auxiliaryCount: auxiliaryCount,
            bodyStyle: TextStyle(color: appPalette(context).textMuted),
            onManageImages: () => _openEditTab('photos'),
            onFindBetterCover: () =>
                launchEbaySearch(_buildComicMarketSearchQuery()),
          ),
        ),
      ],
    );
  }

  Widget _comicPhotosTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'My images workflow',
          accent: widget.accent,
          child: ComicPhotosWorkflowText(
            style: TextStyle(color: appPalette(context).textMuted),
          ),
        ),
        ItemImagesEditSection(
          images: widget.itemImages,
          accent: widget.accent,
          onChanged: (edits) => _itemImageEdits = edits,
        ),
      ],
    );
  }
}
