part of 'library_add_dialog.dart';

class _ManualPane extends StatefulWidget {
  const _ManualPane({
    required this.request,
  });

  final LibraryAddManualPaneRequest request;

  @override
  State<_ManualPane> createState() => _ManualPaneState();
}

class _ManualPaneState extends State<_ManualPane> {
  static const _tabs = [
    EditTab(icon: Icons.book, label: 'Main'),
    EditTab(icon: Icons.search, label: 'Details'),
    EditTab(icon: Icons.monetization_on, label: 'Value'),
    EditTab(icon: Icons.person, label: 'Personal'),
    EditTab(icon: Icons.edit, label: 'Custom Fields'),
    EditTab(icon: Icons.camera_alt, label: 'Covers'),
    EditTab(icon: Icons.image, label: 'My Images'),
    EditTab(icon: Icons.people, label: 'Creators'),
    EditTab(icon: Icons.people_outline, label: 'Characters'),
    EditTab(icon: Icons.description, label: 'Plot'),
    EditTab(icon: Icons.link, label: 'Links'),
  ];

  final _fallbackPurchasePriceController = TextEditingController();
  final _fallbackPurchaseDateController = TextEditingController();
  final _fallbackCoverPriceController = TextEditingController();
  final _fallbackSoldPriceController = TextEditingController();
  final _fallbackOwnerLabelController = TextEditingController();
  final _fallbackPersonalNotesController = TextEditingController();
  final _fallbackLinksController = TextEditingController();

  TextEditingController _kindSpecificController(
    String key,
    TextEditingController fallback,
  ) {
    final controller = widget.request.kindSpecific[key];
    return controller is TextEditingController ? controller : fallback;
  }

  @override
  void dispose() {
    _fallbackPurchasePriceController.dispose();
    _fallbackPurchaseDateController.dispose();
    _fallbackCoverPriceController.dispose();
    _fallbackSoldPriceController.dispose();
    _fallbackOwnerLabelController.dispose();
    _fallbackPersonalNotesController.dispose();
    _fallbackLinksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final type = widget.request.type;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border(left: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DefaultTabController(
          length: _tabs.length,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: palette.canvas,
                child: TabBar(
                  isScrollable: true,
                  tabs: _tabs,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.canvas,
                    border: Border.all(color: palette.divider),
                  ),
                  child: TabBarView(
                    children: [
                      // Main
                      ListView(
                        padding: const EdgeInsets.all(10),
                        children: [
                          _ManualSectionHeader(
                            icon: type.workspace.icon,
                            label: 'Manual ${type.singularLabel}',
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: widget.request.titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              prefixIcon: Icon(Icons.title),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: widget.request.numberController,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                      labelText: widget.request.type.mediaFields
                                          .numberLabel),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: widget.request.yearController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  textAlign: TextAlign.center,
                                  decoration:
                                      const InputDecoration(labelText: 'Year'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SingleValuePickField(
                            controller: widget.request.publisherController,
                            options: widget.request.publisherOptions,
                            label:
                                widget.request.type.mediaFields.publisherLabel,
                            onManage: widget.request.onManagePublishers,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: widget.request.variantController,
                            decoration: InputDecoration(
                              labelText: widget
                                  .request.type.releaseFields.variantLabel,
                              prefixIcon: const Icon(
                                  Icons.auto_awesome_motion_outlined),
                            ),
                          ),
                          if (widget.request.physicalFormats.isNotEmpty ||
                              widget.request.physicalFormatOptions.isNotEmpty ||
                              widget.request.physicalFormatLabelController.text
                                  .trim()
                                  .isNotEmpty) ...[
                            const SizedBox(height: 8),
                            SingleValuePickField(
                              controller:
                                  widget.request.physicalFormatLabelController,
                              options: widget.request.physicalFormatOptions,
                              label: 'Physical format',
                              onChanged:
                                  widget.request.onPhysicalFormatLabelChanged,
                              onManage: widget.request.onManagePhysicalFormats,
                            ),
                          ],
                          const SizedBox(height: 8),
                          TextField(
                            controller: widget.request.barcodeController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: widget
                                  .request.type.releaseFields.barcodeLabel,
                              prefixIcon: const Icon(Icons.qr_code_2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: widget.request.coverController,
                            decoration: const InputDecoration(
                              labelText: 'Cover image URL',
                              prefixIcon: Icon(Icons.image_outlined),
                            ),
                          ),
                        ],
                      ),

                      // Details
                      ListView(
                        padding: const EdgeInsets.all(10),
                        children: [
                          EditSection(
                            title: 'Details',
                            accent: widget.request.accent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller:
                                      widget.request.editionTitleController,
                                  decoration: const InputDecoration(
                                      labelText: 'Edition Title'),
                                ),
                                const SizedBox(height: 8),
                                Row(children: [
                                  Expanded(
                                    child: ValueListenableBuilder<
                                        TextEditingValue>(
                                      valueListenable:
                                          widget.request.releaseDateController,
                                      builder: (context, value, _) {
                                        return LibraryDateFieldButton(
                                          label: 'Release date',
                                          value: parseDate(value.text),
                                          onChanged: (picked) {
                                            widget.request.releaseDateController
                                                    .text =
                                                picked == null
                                                    ? ''
                                                    : formatDate(picked);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller:
                                          widget.request.pageCountController,
                                      decoration: const InputDecoration(
                                          labelText: 'Page Count'),
                                    ),
                                  ),
                                ]),
                                const SizedBox(height: 8),
                                SingleValuePickField(
                                  controller: widget.request.imprintController,
                                  options: widget.request.imprintOptions,
                                  label: 'Imprint',
                                  onManage: widget.request.onManageImprints,
                                ),
                                const SizedBox(height: 8),
                                SingleValuePickField(
                                  controller:
                                      widget.request.seriesGroupController,
                                  options: widget.request.seriesGroupOptions,
                                  label: 'Series Group',
                                  onManage: widget.request.onManageSeriesGroups,
                                ),
                                const SizedBox(height: 8),
                                Row(children: [
                                  Expanded(
                                      child: TextField(
                                          controller:
                                              widget.request.countryController,
                                          decoration: const InputDecoration(
                                              labelText: 'Country'))),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: TextField(
                                          controller:
                                              widget.request.languageController,
                                          decoration: const InputDecoration(
                                              labelText: 'Language'))),
                                ]),
                                const SizedBox(height: 8),
                                TextField(
                                    controller:
                                        widget.request.ageRatingController,
                                    decoration: const InputDecoration(
                                        labelText: 'Age Rating')),
                                const SizedBox(height: 8),
                                TagPickListField(
                                    controller:
                                        widget.request.genresEditController,
                                    options: const [],
                                    label: 'Genres'),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Value
                      ListView(padding: const EdgeInsets.all(10), children: [
                        EditSection(
                          title: 'Value & Pricing',
                          accent: widget.request.accent,
                          child: Column(children: [
                            Row(children: [
                              Expanded(
                                  child: TextField(
                                      controller: _kindSpecificController(
                                        'purchasePriceController',
                                        _fallbackPurchasePriceController,
                                      ),
                                      decoration: const InputDecoration(
                                          labelText: 'Purchase Price'))),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: TextField(
                                      controller: _kindSpecificController(
                                        'purchaseDateController',
                                        _fallbackPurchaseDateController,
                                      ),
                                      decoration: const InputDecoration(
                                          labelText: 'Purchase Date'))),
                            ]),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(
                                  child: TextField(
                                      controller: _kindSpecificController(
                                        'coverPriceController',
                                        _fallbackCoverPriceController,
                                      ),
                                      decoration: const InputDecoration(
                                          labelText: 'Cover Price'))),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: TextField(
                                      controller: _kindSpecificController(
                                        'soldPriceController',
                                        _fallbackSoldPriceController,
                                      ),
                                      decoration: const InputDecoration(
                                          labelText: 'Sold Price'))),
                            ]),
                          ]),
                        )
                      ]),

                      // Personal
                      ListView(padding: const EdgeInsets.all(10), children: [
                        EditSection(
                          title: 'Personal',
                          accent: widget.request.accent,
                          child: Column(children: [
                            Row(children: [
                              Expanded(
                                  child: TextField(
                                      controller: _kindSpecificController(
                                        'ownerLabelController',
                                        _fallbackOwnerLabelController,
                                      ),
                                      decoration: const InputDecoration(
                                          labelText: 'Owner'))),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: TextField(
                                      controller: widget.request.tagsController,
                                      decoration: const InputDecoration(
                                          labelText: 'Tags'))),
                            ]),
                            const SizedBox(height: 8),
                            TextField(
                                controller: _kindSpecificController(
                                  'personalNotesController',
                                  _fallbackPersonalNotesController,
                                ),
                                decoration:
                                    const InputDecoration(labelText: 'Notes'),
                                maxLines: 4),
                          ]),
                        )
                      ]),

                      // Custom Fields
                      ListView(padding: const EdgeInsets.all(10), children: [
                        CustomFieldsEditSection(
                          definitions: widget.request.customFieldDefinitions,
                          values: widget.request.customFieldValues,
                          accent: widget.request.accent,
                          onChanged: widget.request.onCustomFieldValuesChanged,
                        )
                      ]),

                      // Covers
                      ListView(padding: const EdgeInsets.all(10), children: [
                        EditSection(
                          title: 'Covers',
                          accent: widget.request.accent,
                          child: Column(children: [
                            TextField(
                                controller: widget.request.coverController,
                                decoration: const InputDecoration(
                                    labelText: 'Front cover URL')),
                            const SizedBox(height: 8),
                            TextField(
                                controller: widget.request.backCoverController,
                                decoration: const InputDecoration(
                                    labelText: 'Back cover URL')),
                          ]),
                        )
                      ]),

                      // My Images
                      ListView(padding: const EdgeInsets.all(10), children: [
                        ItemImagesEditSection(
                            images: widget.request.itemImages,
                            accent: widget.request.accent,
                            onChanged: widget.request.onItemImagesChanged),
                      ]),

                      // Creators (placeholder simple tag field)
                      ListView(padding: const EdgeInsets.all(10), children: [
                        EditSection(
                            title: 'Creators',
                            accent: widget.request.accent,
                            child: Column(
                              children: [
                                const EditSectionStateMessage(
                                  message:
                                      'Name-only in manual mode. Creator roles/images are read-only and are populated by provider/Core ingest.',
                                  icon: Icons.lock_outline,
                                ),
                                const SizedBox(height: 10),
                                TagPickListField(
                                    controller:
                                        widget.request.creatorsController,
                                    options: const [],
                                    label: 'Creators'),
                              ],
                            )),
                      ]),

                      // Characters (placeholder)
                      ListView(padding: const EdgeInsets.all(10), children: [
                        EditSection(
                            title: 'Characters',
                            accent: widget.request.accent,
                            child: Column(
                              children: [
                                const EditSectionStateMessage(
                                  message:
                                      'Name-only in manual mode. Character metadata beyond name is read-only and comes from provider/Core ingest.',
                                  icon: Icons.lock_outline,
                                ),
                                const SizedBox(height: 10),
                                TagPickListField(
                                    controller:
                                        widget.request.charactersController,
                                    options: const [],
                                    label: 'Characters'),
                              ],
                            )),
                      ]),
                      // Plot
                      ListView(padding: const EdgeInsets.all(10), children: [
                        EditSection(
                            title: 'Plot',
                            accent: widget.request.accent,
                            child: TextField(
                                controller: widget.request.synopsisController,
                                maxLines: 6,
                                decoration: const InputDecoration(
                                    labelText: 'Synopsis'))),
                      ]),

                      // Links
                      ListView(padding: const EdgeInsets.all(10), children: [
                        EditSection(
                            title: 'Links',
                            accent: widget.request.accent,
                            child: Column(
                              children: [
                                const EditSectionStateMessage(
                                  message:
                                      'Manual mode saves URL-only links. Link source/title/description is read-only and available via provider/Core ingest.',
                                  icon: Icons.lock_outline,
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                    controller: _kindSpecificController(
                                      'linksController',
                                      _fallbackLinksController,
                                    ),
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                        labelText: 'Links (one per line)')),
                              ],
                            )),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.panel,
                  border: Border.all(color: palette.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          LibraryAddResultBadge('manual'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Start a local ${type.singularLabel.toLowerCase()} draft, then review full details',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.request.isAdding
                                  ? null
                                  : widget.request.onAddTrack,
                              style: libraryAddOutlinedButtonStyle(),
                              icon: const Icon(Icons.visibility_outlined,
                                  size: 18),
                              label: Text(
                                LibraryAddCopy.addToTargetLabel(
                                    count: 1,
                                    type: widget.request.type,
                                    target: LibraryAddTarget.track),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.request.isAdding
                                  ? null
                                  : widget.request.onAddWishlist,
                              style: libraryAddOutlinedButtonStyle(),
                              icon: const Icon(Icons.star_outline, size: 18),
                              label: Text(
                                LibraryAddCopy.addToTargetLabel(
                                    count: 1,
                                    type: widget.request.type,
                                    target: LibraryAddTarget.wishlist),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: widget.request.isAdding
                                  ? null
                                  : widget.request.onAddOwned,
                              style: libraryAddFilledButtonStyle(),
                              icon: widget.request.isAdding
                                  ? const SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Icon(Icons.inventory_2_outlined,
                                      size: 18),
                              label: Text(
                                LibraryAddCopy.addToTargetLabel(
                                    count: 1,
                                    type: widget.request.type,
                                    target: LibraryAddTarget.owned),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManualSectionHeader extends StatelessWidget {
  const _ManualSectionHeader({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: palette.accent),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
