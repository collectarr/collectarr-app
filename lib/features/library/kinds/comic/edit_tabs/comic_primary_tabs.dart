part of 'package:collectarr_app/features/library/kinds/comic/edit_panel.dart';

extension _ComicPrimaryTabs on ComicEditPanelState {
  Widget _buildMainTabBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _labelledSingleValuePickField(
                  'Series',
                  key: const ValueKey('edit-series'),
                  controller: seriesCtl,
                  options: [for (final entry in _seriesEntries) entry.title],
                  onChanged: _syncSelectedSeriesId,
                  onManage: _openSeriesPicker,
                  manageTooltip: 'Manage Series',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _labelledField('Barcode',
                            controller: barcodeCtl,
                            key: const ValueKey('edit-barcode'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildQuickChoiceField(
                      'Format',
                      controller: formatCtl,
                      key: const ValueKey('edit-format'),
                      suggestions: ComicEditPanelState._commonFormats,
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                _buildQuickChoiceField(
                  'Series Group',
                  controller: seriesGroupCtl,
                  key: const ValueKey('edit-seriesgroup'),
                  suggestions: [
                    widget.request.item.publishing?.seriesGroup ?? ''
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _labelledField('Issue No.',
                          controller: issueNumberCtl,
                          key: const ValueKey('edit-issuenr')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _labelledField('Variant',
                          controller: variantCtl,
                          key: const ValueKey('edit-variant')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 7,
                      child: _labelledField('Variant Description',
                          controller: variantDescCtl,
                          key: const ValueKey('edit-variant-desc')),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _labelledDateField('Cover Date',
                            controller: coverDateCtl,
                            key: const ValueKey('edit-coverdate'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _labelledDateField('Release Date',
                            controller: releaseDateCtl,
                            key: const ValueKey('edit-releasedate'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildQuickChoiceField(
                      'Publisher',
                      controller: publisherCtl,
                      key: const ValueKey('edit-publisher'),
                      suggestions: ComicEditPanelState._commonPublishers,
                    )),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildQuickChoiceField(
                      'Imprint',
                      controller: imprintCtl,
                      key: const ValueKey('edit-imprint'),
                      suggestions: ComicEditPanelState._commonImprints,
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTabBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _labelledSingleValuePickField(
                  'Crossover',
                  controller: crossoverCtl,
                  options: _crossoverOptions,
                  key: const ValueKey('edit-crossover'),
                  onManage: () => _manageDetailPickList(
                    listName: kCrossoverPickListName,
                    label: 'Crossover',
                  ),
                  manageTooltip: 'Manage Crossover',
                  hintText: 'Major crossover banner or event label',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _labelledMultiValuePickField(
                  'Story Arcs',
                  controller: storyArcsCtl,
                  options: _storyArcOptions,
                  key: const ValueKey('edit-storyarcs'),
                  onManage: () => _manageDetailPickList(
                    listName: kStoryArcPickListName,
                    label: 'Story Arcs',
                  ),
                  manageTooltip: 'Manage Story Arcs',
                  hintText: 'Comma separated',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _labelledField('Title',
                      controller: titleCtl, key: const ValueKey('edit-title'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _labelledField('Subtitle',
                      controller: subtitleCtl,
                      key: const ValueKey('edit-subtitle'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _labelledSingleValuePickField(
                  'Country',
                  controller: countryCtl,
                  options: _countryOptions,
                  key: const ValueKey('edit-country'),
                  onManage: () => _manageDetailPickList(
                    listName: kCountryPickListName,
                    label: 'Country',
                  ),
                  manageTooltip: 'Manage Country',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _labelledSingleValuePickField(
                  'Language',
                  controller: languageCtl,
                  options: _languageOptions,
                  key: const ValueKey('edit-language'),
                  onManage: () => _manageDetailPickList(
                    listName: kLanguagePickListName,
                    label: 'Language',
                  ),
                  manageTooltip: 'Manage Language',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _labelledSingleValuePickField(
                  'Age',
                  controller: ageCtl,
                  options: _ageOptions,
                  key: const ValueKey('edit-age'),
                  onManage: () => _manageDetailPickList(
                    listName: kAgeRatingPickListName,
                    label: 'Age',
                  ),
                  manageTooltip: 'Manage Age',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _labelledField('No. of Pages',
                    controller: pagesCtl, key: const ValueKey('edit-pages')),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 6,
                child: _labelledMultiValuePickField(
                  'Genres',
                  controller: genresCtl,
                  options: _genreOptions,
                  key: const ValueKey('edit-genres'),
                  onManage: () => _manageDetailPickList(
                    listName: kGenrePickListName,
                    label: 'Genres',
                  ),
                  manageTooltip: 'Manage Genres',
                  hintText: 'Comma separated',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueTabBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: _buildSectionCard(
                  'Grading & Market',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: _buildQuickChoiceField('Grade',
                                controller: gradeCtl,
                                suggestions: ComicEditPanelState._commonGrades,
                                key: const ValueKey('edit-grade')),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 5,
                            child: _buildRawSlabbedSegment(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 8,
                            child: _buildSectionCard(
                              'Market Tools',
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilledButton.icon(
                                    onPressed: () => launchEbaySearch(
                                      '${_buildMarketSearchQuery()} sold',
                                    ),
                                    icon:
                                        const Icon(Icons.shopping_bag_outlined),
                                    label: const Text('Sold Listings'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _openCovrPriceHome,
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('Open CovrPrice'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: _labelledField('My Value',
                                controller: currentValueCtl,
                                key: const ValueKey('edit-current-value')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSignedBySection(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: _buildSectionCard(
                  'Slab Details',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: _buildQuickChoiceField('Grading Company',
                                  controller: gradingCompanyCtl,
                                  suggestions:
                                      ComicEditPanelState._gradingCompanies,
                                  key: const ValueKey('edit-grading-company'))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _labelledField('Slab Certification Number',
                                  controller: certificationNumberCtl,
                                  key: const ValueKey(
                                      'edit-certification-number'))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _labelledField('Grader Notes',
                          controller: graderNotesCtl,
                          key: const ValueKey('edit-grader-notes'),
                          maxLines: 3),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            'Label Details',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: _buildQuickChoiceField('Label Type',
                      controller: labelTypeCtl,
                      suggestions: ComicEditPanelState._labelTypeOptions,
                      key: const ValueKey('edit-label-type')),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: _buildQuickChoiceField('Custom Label',
                      controller: customLabelCtl,
                      suggestions: ComicEditPanelState._customLabelOptions,
                      key: const ValueKey('edit-custom-label')),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _buildQuickChoiceField('Page Quality',
                      controller: pageQualityCtl,
                      suggestions: ComicEditPanelState._pageQualityOptions,
                      key: const ValueKey('edit-page-quality')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            'Key Issue',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildKeySeveritySection()),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: _labelledField('Key Reason',
                      controller: keyReasonCtl,
                      key: const ValueKey('edit-key-reason')),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: _labelledField('Key Category',
                      controller: keyCategoryCtl,
                      key: const ValueKey('edit-key-category')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSectionCard(
                  'Purchase',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _labelledField('Purchase Price',
                                  controller: purchasePriceCtl,
                                  key: const ValueKey('edit-purchase-price'))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _labelledDateField('Purchase Date',
                                  controller: purchaseDateCtl,
                                  key: const ValueKey('edit-purchase-date'))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildQuickChoiceField('Purchase Store',
                                  controller: purchaseStoreCtl,
                                  suggestions:
                                      ComicEditPanelState._purchaseStoreOptions,
                                  key: const ValueKey('edit-purchase-store'))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _labelledField('Cover Price',
                                  controller: coverPriceCtl,
                                  key: const ValueKey('edit-cover-price'))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSectionCard(
                  'Sale',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _labelledField('Sold Price',
                              controller: soldPriceCtl,
                              key: const ValueKey('edit-sold-price'))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _labelledDateField('Sold Date',
                              controller: soldDateCtl,
                              key: const ValueKey('edit-sold-date'))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _labelledField('Currency',
                              controller: purchaseCurrencyCtl,
                              key: const ValueKey('edit-purchase-currency'))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalTabBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildSectionCard(
              'Reading & Notes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildReadStatusSection()),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _labelledDateField('Read Date',
                              controller: readDateCtl,
                              key: const ValueKey('edit-read-date'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _labelledField('Notes',
                      controller: notesCtl,
                      key: const ValueKey('edit-notes'),
                      maxLines: 5),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSectionCard(
              'Ownership & Tags',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _labelledField('Owner',
                      controller: ownerCtl, key: const ValueKey('edit-owner')),
                  const SizedBox(height: 12),
                  _buildRatingSection(),
                  const SizedBox(height: 12),
                  _labelledField('Tags',
                      controller: tagsCtl, key: const ValueKey('edit-tags')),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: _labelledDateField('Bag/Board Date',
                        controller: bagBoardDateCtl,
                        key: const ValueKey('edit-bagboard-date')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
