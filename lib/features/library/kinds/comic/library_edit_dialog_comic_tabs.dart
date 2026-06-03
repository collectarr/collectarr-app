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
                _field(
                  controller: _titleExtensionController,
                  label: 'Subtitle',
                ),
                _field(
                  controller: _countryController,
                  label: 'Country',
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: _languageController,
                  label: 'Language',
                ),
                _field(
                  controller: _ageRatingController,
                  label: 'Age',
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: _pageCountController,
                  label: 'No. of Pages',
                  validator: optionalIntValidator,
                ),
                _field(
                  controller: _genresEditController,
                  label: 'Genres',
                  hint: 'Comma-separated',
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: _crossoverController,
                  label: 'Crossover',
                ),
                _field(
                  controller: _storyArcsController,
                  label: 'Story Arcs',
                  hint: 'Comma-separated',
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ownedComicMainTab() {
    final editPresentation = _editPresentation;
    return EditTabShell(
      cover: _comicCoverPreview(),
      children: [
        _ownedComicMainOverviewCard(),
        EditSection(
          title: 'Personal',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    label: 'Read',
                    onChanged: (value) {
                      _trackingController.text = value ?? '';
                    },
                  ),
                ),
                _field(
                  controller: _quantityController,
                  label: 'Quantity',
                  validator: positiveIntValidator,
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _readOnlyField(
                  label: 'Index',
                  value: widget.ownedItem?.indexNumber?.toString() ?? '—',
                ),
                _readOnlyField(
                  label: 'Added date',
                  value: _formatTimestamp(widget.ownedItem?.createdAt),
                ),
                _readOnlyField(
                  label: 'Modified date',
                  value: _formatTimestamp(widget.ownedItem?.updatedAt),
                ),
              ]),
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
        EditSection(
          title: 'Value',
          accent: widget.accent,
          child: Column(
            children: [
              _responsiveFields([
                _field(
                  controller: _coverPriceController,
                  label: 'Cover price',
                  validator: optionalMoneyValidator,
                ),
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
                  label: 'Current value',
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
              _collectionStatusField(label: 'Collection status'),
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
        if (editPresentation.showsOwnedGradingSection)
          EditSection(
            title: editPresentation.ownedGradingSectionTitle,
            accent: widget.accent,
            child: Column(
              children: [
                _responsiveFields([
                  _field(controller: _conditionController, label: 'Condition'),
                  _field(controller: _gradeController, label: 'Grade'),
                ]),
                const SizedBox(height: 10),
                _responsiveFields([
                  _field(
                    controller: _rawOrSlabbedController,
                    label: 'Raw / Slabbed',
                  ),
                  _field(
                    controller: _gradingCompanyController,
                    label: 'Grading company',
                  ),
                ]),
                const SizedBox(height: 10),
                _responsiveFields([
                  _field(controller: _labelTypeController, label: 'Label type'),
                  _field(
                    controller: _certificationNumberController,
                    label: 'Certification number',
                  ),
                ]),
                const SizedBox(height: 10),
                _field(
                  controller: _graderNotesController,
                  label: 'Grader notes',
                ),
                const SizedBox(height: 10),
                _field(controller: _signedByController, label: 'Signed by'),
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
                  _field(
                    controller: _keyReasonController,
                    label: editPresentation.keyReasonLabel,
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
                  _locationField(label: 'Location'),
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
        EditSection(
          title: 'Sale',
          accent: widget.accent,
          child: Column(
            children: [
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
                          style: TextStyle(color: appPalette(context).textMuted),
                        )
                      : null,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (_soldAt != null) ...[
                const SizedBox(height: 12),
                _datePickerField(
                  label: 'Sold date',
                  value: _soldAt,
                  onChanged: (value) => _mutateDialogState(() => _soldAt = value),
                ),
                const SizedBox(height: 12),
                _responsiveFields([
                  _field(
                    controller: _sellPriceController,
                    label: 'Sell price',
                    validator: optionalMoneyValidator,
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

  Widget _readOnlyField({
    required String label,
    required String value,
  }) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  String _formatTimestamp(DateTime? value) {
    if (value == null) {
      return '—';
    }
    final local = value.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${months[local.month - 1]} ${local.day}, ${local.year} $hour:$minute';
  }

  Widget _comicCoverPreview() {
    final coverUrl = widget.item.displayCoverUrl ??
        emptyToNull(_thumbnailController.text) ??
        emptyToNull(_coverController.text);
    if (coverUrl == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: appPalette(context).field,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Icon(
            Icons.auto_stories,
            color: appPalette(context).textMuted,
            size: 42,
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return DecoratedBox(
            decoration: BoxDecoration(color: appPalette(context).field),
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: appPalette(context).textMuted,
                size: 42,
              ),
            ),
          );
        },
      ),
    );
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