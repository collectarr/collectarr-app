import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:flutter/material.dart';

class OwnedComicEditDialog extends StatefulWidget {
  const OwnedComicEditDialog({
    super.key,
    required this.item,
    required this.ownedItem,
    required this.conditions,
    required this.grades,
    required this.cover,
    this.customFieldDefinitions = const [],
    this.customFieldValues = const [],
    this.itemImages = const [],
  });

  final CatalogItem item;
  final OwnedItem ownedItem;
  final List<String> conditions;
  final List<String> grades;
  final Widget cover;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final List<CustomFieldValue> customFieldValues;
  final List<ItemImage> itemImages;

  @override
  State<OwnedComicEditDialog> createState() => _OwnedComicEditDialogState();
}

class _OwnedComicEditDialogState extends State<OwnedComicEditDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _notesController;
  late final TextEditingController _quantityController;
  late final TextEditingController _storageBoxController;
  late final TextEditingController _indexNumberController;
  late final TextEditingController _coverPriceController;
  late final TextEditingController _gradingCompanyController;
  late final TextEditingController _graderNotesController;
  late final TextEditingController _signedByController;
  late final TextEditingController _keyReasonController;
  late final TextEditingController _ratingController;
  late final TextEditingController _readStatusController;
  late final TextEditingController _tagsController;
  late final TextEditingController _sellPriceController;
  late final TextEditingController _soldToController;
  late String? _condition = widget.ownedItem.condition;
  late String? _grade = widget.ownedItem.grade;
  late DateTime? _purchaseDate = widget.ownedItem.purchaseDate;
  late String? _rawOrSlabbed = widget.ownedItem.rawOrSlabbed ?? 'Raw';
  late bool _keyComic = widget.ownedItem.keyComic;
  late DateTime? _soldAt = widget.ownedItem.soldAt;
  Map<String, String?> _customFieldEdits = {};
  List<ItemImageEdit> _itemImageEdits = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    _priceController = TextEditingController(
      text: widget.ownedItem.pricePaidCents == null
          ? ''
          : (widget.ownedItem.pricePaidCents! / 100).toStringAsFixed(2),
    );
    _currencyController =
        TextEditingController(text: widget.ownedItem.currency ?? 'USD');
    _notesController =
        TextEditingController(text: widget.ownedItem.personalNotes ?? '');
    _quantityController =
        TextEditingController(text: widget.ownedItem.quantity.toString());
    _storageBoxController =
        TextEditingController(text: widget.ownedItem.storageBox ?? '');
    _indexNumberController = TextEditingController(
      text: widget.ownedItem.indexNumber?.toString() ?? '',
    );
    _coverPriceController = TextEditingController(
      text: widget.ownedItem.coverPriceCents == null
          ? ''
          : (widget.ownedItem.coverPriceCents! / 100).toStringAsFixed(2),
    );
    _gradingCompanyController =
        TextEditingController(text: widget.ownedItem.gradingCompany ?? '');
    _graderNotesController =
        TextEditingController(text: widget.ownedItem.graderNotes ?? '');
    _signedByController =
        TextEditingController(text: widget.ownedItem.signedBy ?? '');
    _keyReasonController =
        TextEditingController(text: widget.ownedItem.keyReason ?? '');
    _ratingController =
        TextEditingController(text: widget.ownedItem.rating?.toString() ?? '');
    _readStatusController =
        TextEditingController(text: widget.ownedItem.readStatus ?? '');
    _tagsController = TextEditingController(text: widget.ownedItem.tags ?? '');
    _sellPriceController = TextEditingController(
      text: widget.ownedItem.sellPriceCents == null
          ? ''
          : (widget.ownedItem.sellPriceCents! / 100).toStringAsFixed(2),
    );
    _soldToController =
        TextEditingController(text: widget.ownedItem.soldTo ?? '');
    _customFieldEdits = {
      for (final v in widget.customFieldValues) v.fieldDefinitionId: v.value,
    };
    _quantityController.addListener(_refreshFooter);
    _storageBoxController.addListener(_refreshFooter);
    _indexNumberController.addListener(_refreshFooter);
    _priceController.addListener(_refreshFooter);
    _coverPriceController.addListener(_refreshFooter);
    _currencyController.addListener(_refreshFooter);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_refreshFooter);
    _storageBoxController.removeListener(_refreshFooter);
    _indexNumberController.removeListener(_refreshFooter);
    _priceController.removeListener(_refreshFooter);
    _coverPriceController.removeListener(_refreshFooter);
    _currencyController.removeListener(_refreshFooter);
    _tabController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    _storageBoxController.dispose();
    _indexNumberController.dispose();
    _coverPriceController.dispose();
    _gradingCompanyController.dispose();
    _graderNotesController.dispose();
    _signedByController.dispose();
    _keyReasonController.dispose();
    _ratingController.dispose();
    _readStatusController.dispose();
    _tagsController.dispose();
    _sellPriceController.dispose();
    _soldToController.dispose();
    super.dispose();
  }

  void _refreshFooter() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: editDialogTheme(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980, maxHeight: 760),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: kEditPanel,
              border: Border.all(color: const Color(0xFF666666)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xCC000000),
                  blurRadius: 22,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                _titleBar(context),
                _tabs(),
                Expanded(
                  child: ColoredBox(
                    color: kEditPanel,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _editMainTab(),
                        _editDetailsTab(),
                        _editValueTab(),
                        _editPersonalTab(),
                        _editSoldTab(),
                        _editCustomFieldsTab(),
                        _editPhotosTab(),
                        _editCoverTab(),
                        _editPlotTab(),
                      ],
                    ),
                  ),
                ),
                _footer(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleBar(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF343434), Color(0xFF161616)],
        ),
        border: Border(bottom: BorderSide(color: kEditAccent)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0x884DBBD5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xAA000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRect(child: widget.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit - ${widget.item.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const EditMiniBadge('Owned'),
                    if (_soldAt != null) const EditMiniBadge('Sold'),
                    if (_grade != null && _grade!.isNotEmpty)
                      EditMiniBadge(_grade!),
                    if (_condition != null && _condition!.isNotEmpty)
                      EditMiniBadge(_condition!),
                    EditMiniBadge('Qty ${_quantityController.text}'),
                    if (_storageBoxController.text.trim().isNotEmpty)
                      EditMiniBadge(_storageBoxController.text.trim()),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    if (widget.item.itemNumber != null)
                      'Issue #${widget.item.itemNumber}',
                    'local personal copy',
                    if (widget.item.barcode != null) widget.item.barcode,
                  ].whereType<String>().join(' | '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: kEditTextMuted,
                      ),
                ),
              ],
            ),
          ),
          if (widget.item.itemNumber != null)
            IssuePill(label: '#${widget.item.itemNumber}'),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return ColoredBox(
      color: kEditPanelRaised,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: Colors.white,
        unselectedLabelColor: kEditTextMuted,
        indicatorColor: kEditAccent,
        dividerColor: kEditDivider,
        labelPadding: const EdgeInsets.symmetric(horizontal: 11),
        tabs: const [
          EditTab(icon: Icons.article, label: 'Main'),
          EditTab(icon: Icons.search, label: 'Details'),
          EditTab(icon: Icons.attach_money, label: 'Value'),
          EditTab(icon: Icons.person, label: 'Personal'),
          EditTab(icon: Icons.sell, label: 'Sold'),
          EditTab(icon: Icons.tune, label: 'Custom'),
          EditTab(icon: Icons.photo_library, label: 'Photos'),
          EditTab(icon: Icons.image, label: 'Cover'),
          EditTab(icon: Icons.notes, label: 'Plot'),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    final currentTab = _tabController.index + 1;
    final totalTabs = _tabController.length;
    final summary = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const FooterReadonlyField(
            label: 'Collection Status',
            value: 'Owned',
            width: 150,
          ),
          const SizedBox(width: 8),
          FooterReadonlyField(
            label: 'Tab',
            value: '$currentTab / $totalTabs',
            width: 72,
          ),
          const SizedBox(width: 8),
          FooterTextField(
            label: 'Index',
            controller: _indexNumberController,
            width: 86,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(width: 8),
          FooterTextField(
            label: 'Qty',
            controller: _quantityController,
            width: 92,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(width: 8),
          FooterTextField(
            label: 'Box',
            controller: _storageBoxController,
            width: 180,
          ),
        ],
      ),
    );
    final actions = Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        Tooltip(
          message: 'Previous tab',
          child: OutlinedButton.icon(
            onPressed: _tabController.index == 0 ? null : _previousTab,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous'),
          ),
        ),
        Tooltip(
          message: 'Next tab',
          child: OutlinedButton.icon(
            onPressed: _tabController.index == _tabController.length - 1
                ? null
                : _nextTab,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _pickPurchaseDate,
          icon: const Icon(Icons.event),
          label: Text(
            _purchaseDate == null
                ? 'Set purchase date'
                : formatDate(_purchaseDate!),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('OK'),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
      decoration: const BoxDecoration(
        color: kEditToolbar,
        border: Border(top: BorderSide(color: kEditDivider)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 850) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                summary,
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: summary),
              actions,
            ],
          );
        },
      ),
    );
  }

  Widget _editMainTab() {
    return EditTabShell(
      cover: widget.cover,
      children: [
        EditSection(
          title: 'Comic',
          child: Column(
            children: [
              EditGrid(
                children: [
                  _readonlyField('Series', widget.item.title, flex: 2),
                  _readonlyField('Issue No.', widget.item.itemNumber ?? ''),
                  _readonlyField('Variant', widget.item.variant ?? ''),
                  _readonlyField('Publisher', widget.item.publisher ?? ''),
                  _readonlyField('Barcode', widget.item.barcode ?? ''),
                  _readonlyField(
                    'Release Date',
                    widget.item.releaseDate == null
                        ? ''
                        : formatDate(widget.item.releaseDate!),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: widget.conditions.contains(_condition)
                          ? _condition
                          : null,
                      decoration: const InputDecoration(labelText: 'Condition'),
                      items: [
                        for (final option in widget.conditions)
                          DropdownMenuItem(value: option, child: Text(option)),
                      ],
                      onChanged: (value) => setState(() => _condition = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue:
                          widget.grades.contains(_grade) ? _grade : null,
                      decoration: const InputDecoration(labelText: 'Grade'),
                      items: [
                        for (final option in widget.grades)
                          DropdownMenuItem(value: option, child: Text(option)),
                      ],
                      onChanged: (value) => setState(() => _grade = value),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        EditSection(
          title: 'Notes',
          child: TextField(
            controller: _notesController,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Personal notes',
              alignLabelWithHint: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _editDetailsTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Catalog Details',
          child: EditGrid(
            children: [
              _readonlyField('Collectarr Item ID', widget.item.id, flex: 2),
              _readonlyField('Format', widget.item.kind),
              _readonlyField('Year', widget.item.releaseYear?.toString() ?? ''),
            ],
          ),
        ),
        EditSection(
          title: 'Local Metadata Boundary',
          child: const Text(
            'Title, covers, barcode, release metadata, creators, and provider links come from Collectarr Core. Grade, value, notes, tags, storage, and progress stay local.',
            style: TextStyle(color: kEditTextMuted),
          ),
        ),
      ],
    );
  }

  Widget _editValueTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Value',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Purchase price',
                        prefixText: r'$ ',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _currencyController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'Currency'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _coverPriceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Cover price',
                        prefixText: r'$ ',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ValueByGradePanel(
                item: widget.item,
                grade: _grade,
                pricePaidCents: parseMoneyCents(
                  _priceController.text,
                  fallback: widget.ownedItem.pricePaidCents,
                ),
                coverPriceCents: parseMoneyCents(
                  _coverPriceController.text,
                  fallback: widget.ownedItem.coverPriceCents,
                ),
                currency: _currencyController.text,
              ),
            ],
          ),
        ),
        EditSection(
          title: 'Grading',
          child: Column(
            children: [
              TextField(
                controller: _gradingCompanyController,
                decoration: const InputDecoration(labelText: 'Grading company'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _graderNotesController,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Grader notes',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _editPersonalTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Personal',
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _storageBoxController,
                      decoration:
                          const InputDecoration(labelText: 'Storage box'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _indexNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Index'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'Raw', label: Text('Raw')),
                        ButtonSegment(
                          value: 'Slabbed',
                          label: Text('Slabbed'),
                        ),
                      ],
                      selected: {_rawOrSlabbed ?? 'Raw'},
                      onSelectionChanged: (selection) =>
                          setState(() => _rawOrSlabbed = selection.first),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MediaTrackingStatusField(
                      profile: comicsLibraryConfig.trackingProfile,
                      value: _readStatusController.text,
                      label: 'Read status',
                      onChanged: (value) {
                        _readStatusController.text = value ?? '';
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: MediaRatingField(controller: _ratingController),
                  ),
                ],
              ),
            ],
          ),
        ),
        EditSection(
          title: 'Flags & Tags',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _signedByController,
                      decoration: const InputDecoration(labelText: 'Signed by'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 180,
                    child: SwitchListTile(
                      value: _keyComic,
                      onChanged: (value) => setState(() => _keyComic = value),
                      title: const Text('Key comic'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _keyReasonController,
                decoration: const InputDecoration(labelText: 'Key reason'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _editSoldTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Sold Status',
          child: Column(
            children: [
              SwitchListTile(
                value: _soldAt != null,
                onChanged: (value) {
                  setState(() {
                    _soldAt = value ? DateTime.now() : null;
                  });
                },
                title: const Text('Mark as sold'),
                subtitle: _soldAt != null
                    ? Text(
                        'Sold on ${formatDate(_soldAt!)}',
                        style: const TextStyle(color: kEditTextMuted),
                      )
                    : null,
                contentPadding: EdgeInsets.zero,
              ),
              if (_soldAt != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickSoldDate,
                  icon: const Icon(Icons.event),
                  label: Text('Sold date: ${formatDate(_soldAt!)}'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _sellPriceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Sell price',
                          prefixText: r'$ ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _soldToController,
                        decoration:
                            const InputDecoration(labelText: 'Sold to'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (_soldAt != null)
          EditSection(
            title: 'Profit / Loss',
            child: SoldSummaryPanel(
              pricePaidCents: parseMoneyCents(
                _priceController.text,
                fallback: widget.ownedItem.pricePaidCents,
              ),
              sellPriceCents: parseMoneyCents(
                _sellPriceController.text,
                fallback: widget.ownedItem.sellPriceCents,
              ),
              currency: _currencyController.text,
            ),
          ),
      ],
    );
  }

  Widget _editCustomFieldsTab() {
    return EditTabShell(
      children: [
        CustomFieldsEditSection(
          definitions: widget.customFieldDefinitions,
          values: _customFieldEdits,
          accent: kEditAccent,
          onChanged: (values) => _customFieldEdits = values,
        ),
      ],
    );
  }

  Widget _editPhotosTab() {
    return EditTabShell(
      children: [
        ItemImagesEditSection(
          images: widget.itemImages,
          accent: kEditAccent,
          onChanged: (edits) => _itemImageEdits = edits,
        ),
      ],
    );
  }

  Widget _editCoverTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Cover',
          child: Center(
            child: SizedBox(
              width: 260,
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 2 / 3,
                    child: widget.cover,
                  ),
                  const SizedBox(height: 12),
                  const Wrap(
                    spacing: 8,
                    children: [
                      EditMiniBadge('Local cover cache'),
                      EditMiniBadge('Core metadata'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _editPlotTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Plot',
          child: Text(
            widget.item.synopsis ?? 'No plot metadata available yet.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _readonlyField(String label, String value, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  void _previousTab() {
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
    }
  }

  void _nextTab() {
    if (_tabController.index < _tabController.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  Future<void> _pickPurchaseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null && mounted) {
      setState(() => _purchaseDate = picked);
    }
  }

  Future<void> _pickSoldDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _soldAt ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null && mounted) {
      setState(() => _soldAt = picked);
    }
  }

  void _submit() {
    final currency = _currencyController.text.trim().toUpperCase();
    Navigator.of(context).pop(
      OwnedComicEditSelection(
        condition: _condition,
        grade: _grade,
        purchaseDate: _purchaseDate,
        pricePaidCents: parseMoneyCents(
          _priceController.text,
          fallback: widget.ownedItem.pricePaidCents,
        ),
        currency: currency.isEmpty ? null : currency,
        personalNotes: emptyToNull(_notesController.text),
        quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
        storageBox: emptyToNull(_storageBoxController.text),
        indexNumber: int.tryParse(_indexNumberController.text.trim()),
        coverPriceCents: parseMoneyCents(
          _coverPriceController.text,
          fallback: widget.ownedItem.coverPriceCents,
        ),
        rawOrSlabbed: _rawOrSlabbed,
        gradingCompany: emptyToNull(_gradingCompanyController.text),
        graderNotes: emptyToNull(_graderNotesController.text),
        signedBy: emptyToNull(_signedByController.text),
        keyComic: _keyComic,
        keyReason: emptyToNull(_keyReasonController.text),
        rating: int.tryParse(_ratingController.text.trim()),
        readStatus: emptyToNull(_readStatusController.text),
        tags: emptyToNull(_tagsController.text),
        soldAt: _soldAt,
        sellPriceCents: parseMoneyCents(
          _sellPriceController.text,
          fallback: widget.ownedItem.sellPriceCents,
        ),
        soldTo: emptyToNull(_soldToController.text),
        customFieldEdits: _customFieldEdits,
        itemImageEdits: _itemImageEdits,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Comics-specific: value-by-grade chart panel
// ---------------------------------------------------------------------------

class _ValueByGradePanel extends StatelessWidget {
  const _ValueByGradePanel({
    required this.item,
    required this.grade,
    required this.pricePaidCents,
    required this.coverPriceCents,
    required this.currency,
  });

  final CatalogItem item;
  final String? grade;
  final int? pricePaidCents;
  final int? coverPriceCents;
  final String currency;

  @override
  Widget build(BuildContext context) {
    const chartValues = [8, 12, 18, 26, 34, 44, 58, 74, 96, 130];
    const chartMaxValue = 130;
    const chartHeight = 90.0;
    final normalizedCurrency = currency.trim().toUpperCase();
    final releaseDate = item.releaseDate;
    return Container(
      constraints: const BoxConstraints(minHeight: 210),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        border: Border.all(color: kEditDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Value by grade',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < chartValues.length; i++) ...[
                  Expanded(
                    child: Tooltip(
                      message: '${(i + 1) * 1.0}',
                      child: Container(
                        height: chartValues[i] / chartMaxValue * chartHeight,
                        decoration: const BoxDecoration(color: kEditChartBar),
                      ),
                    ),
                  ),
                  if (i != chartValues.length - 1) const SizedBox(width: 5),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ValueContextChip(
                icon: Icons.workspace_premium_outlined,
                label: 'Grade',
                value: _displayValue(grade, fallback: 'Ungraded'),
              ),
              ValueContextChip(
                icon: Icons.payments_outlined,
                label: 'Paid',
                value: _formatMoney(pricePaidCents, normalizedCurrency),
              ),
              ValueContextChip(
                icon: Icons.local_offer_outlined,
                label: 'Cover',
                value: _formatMoney(coverPriceCents, normalizedCurrency),
              ),
              ValueContextChip(
                icon: Icons.trending_up,
                label: 'Paid vs cover',
                value: _formatPaidVsCover(pricePaidCents, coverPriceCents),
              ),
              ValueContextChip(
                icon: Icons.business_outlined,
                label: 'Publisher',
                value: _displayValue(item.publisher),
              ),
              ValueContextChip(
                icon: Icons.calendar_month_outlined,
                label: 'Release',
                value: releaseDate == null
                    ? _displayValue(item.releaseYear?.toString())
                    : formatDate(releaseDate),
              ),
              ValueContextChip(
                icon: Icons.qr_code_2,
                label: 'Barcode',
                value: _displayValue(item.barcode),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data class returned by the dialog
// ---------------------------------------------------------------------------

class OwnedComicEditSelection {
  const OwnedComicEditSelection({
    required this.condition,
    required this.grade,
    required this.purchaseDate,
    required this.pricePaidCents,
    required this.currency,
    required this.personalNotes,
    required this.quantity,
    required this.storageBox,
    required this.indexNumber,
    required this.coverPriceCents,
    required this.rawOrSlabbed,
    required this.gradingCompany,
    required this.graderNotes,
    required this.signedBy,
    required this.keyComic,
    required this.keyReason,
    required this.rating,
    required this.readStatus,
    required this.tags,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
    this.customFieldEdits = const {},
    this.itemImageEdits = const [],
  });

  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int quantity;
  final String? storageBox;
  final int? indexNumber;
  final int? coverPriceCents;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final bool keyComic;
  final String? keyReason;
  final int? rating;
  final String? readStatus;
  final String? tags;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;
  final Map<String, String?> customFieldEdits;
  final List<ItemImageEdit> itemImageEdits;
}

// ---------------------------------------------------------------------------
// Comics-specific format helpers
// ---------------------------------------------------------------------------

String _displayValue(String? value, {String fallback = '-'}) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? fallback : normalized;
}

String _formatMoney(int? cents, String currency) {
  if (cents == null) return '-';
  final normalizedCurrency = currency.trim().isEmpty ? 'USD' : currency.trim();
  final prefix = _currencyPrefix(normalizedCurrency);
  final absolute = cents.abs();
  final whole = absolute ~/ 100;
  final fraction = (absolute % 100).toString().padLeft(2, '0');
  final sign = cents < 0 ? '-' : '';
  return '$sign$prefix$whole.$fraction';
}

String _currencyPrefix(String currency) {
  return switch (currency.trim().toUpperCase()) {
    'USD' => r'$',
    'EUR' => 'EUR ',
    'GBP' => 'GBP ',
    _ => '${currency.trim().toUpperCase()} ',
  };
}

String _formatPaidVsCover(int? paidCents, int? coverCents) {
  if (paidCents == null || coverCents == null || coverCents == 0) return '-';
  final percent = ((paidCents - coverCents) * 100 / coverCents).round();
  if (percent == 0) return 'at cover';
  return percent > 0 ? '+$percent%' : '$percent%';
}
