import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:flutter/material.dart';

const Color _kClzPanel = Color(0xFF1D1D1D);
const Color _kClzPanelRaised = Color(0xFF2F2F2F);
const Color _kClzToolbar = Color(0xFF2B2B2B);
const Color _kClzAccent = Color(0xFF10A8D8);
const Color _kClzDivider = Color(0xFF4A4A4A);
const Color _kClzTextMuted = Color(0xFFB8B8B8);

class OwnedComicEditDialog extends StatefulWidget {
  const OwnedComicEditDialog({
    super.key,
    required this.item,
    required this.ownedItem,
    required this.conditions,
    required this.grades,
    required this.cover,
  });

  final CatalogItem item;
  final OwnedItem ownedItem;
  final List<String> conditions;
  final List<String> grades;
  final Widget cover;

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
  late String? _condition = widget.ownedItem.condition;
  late String? _grade = widget.ownedItem.grade;
  late DateTime? _purchaseDate = widget.ownedItem.purchaseDate;
  late String? _rawOrSlabbed = widget.ownedItem.rawOrSlabbed ?? 'Raw';
  late bool _keyComic = widget.ownedItem.keyComic;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this)
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
    _quantityController.addListener(_refreshFooter);
    _storageBoxController.addListener(_refreshFooter);
    _indexNumberController.addListener(_refreshFooter);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_refreshFooter);
    _storageBoxController.removeListener(_refreshFooter);
    _indexNumberController.removeListener(_refreshFooter);
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
        data: ThemeData.dark(useMaterial3: true).copyWith(
          visualDensity: VisualDensity.compact,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _kClzAccent,
            brightness: Brightness.dark,
            surface: _kClzPanel,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: _kClzPanel,
            surfaceTintColor: Colors.transparent,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFF101010),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            labelStyle: TextStyle(color: _kClzTextMuted),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: _kClzDivider),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _kClzDivider),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _kClzAccent),
            ),
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980, maxHeight: 760),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _kClzPanel,
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
                    color: _kClzPanel,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _editMainTab(),
                        _editDetailsTab(),
                        _editValueTab(),
                        _editPersonalTab(),
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
        border: Border(bottom: BorderSide(color: _kClzAccent)),
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
                    const _MiniBadge('Owned'),
                    if (_grade != null && _grade!.isNotEmpty)
                      _MiniBadge(_grade!),
                    if (_condition != null && _condition!.isNotEmpty)
                      _MiniBadge(_condition!),
                    _MiniBadge('Qty ${_quantityController.text}'),
                    if (_storageBoxController.text.trim().isNotEmpty)
                      _MiniBadge(_storageBoxController.text.trim()),
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
                        color: _kClzTextMuted,
                      ),
                ),
              ],
            ),
          ),
          if (widget.item.itemNumber != null)
            _IssuePill(label: '#${widget.item.itemNumber}'),
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
      color: _kClzPanelRaised,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: Colors.white,
        unselectedLabelColor: _kClzTextMuted,
        indicatorColor: _kClzAccent,
        dividerColor: _kClzDivider,
        labelPadding: const EdgeInsets.symmetric(horizontal: 11),
        tabs: const [
          _EditTab(icon: Icons.article, label: 'Main'),
          _EditTab(icon: Icons.search, label: 'Details'),
          _EditTab(icon: Icons.attach_money, label: 'Value'),
          _EditTab(icon: Icons.person, label: 'Personal'),
          _EditTab(icon: Icons.image, label: 'Cover'),
          _EditTab(icon: Icons.notes, label: 'Plot'),
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
          const _FooterReadonlyField(
            label: 'Collection Status',
            value: 'Owned',
            width: 150,
          ),
          const SizedBox(width: 8),
          _FooterReadonlyField(
            label: 'Tab',
            value: '$currentTab / $totalTabs',
            width: 72,
          ),
          const SizedBox(width: 8),
          _FooterTextField(
            label: 'Index',
            controller: _indexNumberController,
            width: 86,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(width: 8),
          _FooterTextField(
            label: 'Qty',
            controller: _quantityController,
            width: 92,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(width: 8),
          _FooterTextField(
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
                : _formatDate(_purchaseDate!),
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
        color: _kClzToolbar,
        border: Border(top: BorderSide(color: _kClzDivider)),
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
    return _EditTabShell(
      cover: widget.cover,
      children: [
        _EditSection(
          title: 'Comic',
          child: Column(
            children: [
              _EditGrid(
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
                        : _formatDate(widget.item.releaseDate!),
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
        _EditSection(
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
    return _EditTabShell(
      children: [
        _EditSection(
          title: 'Catalog Details',
          child: _EditGrid(
            children: [
              _readonlyField('Collectarr Item ID', widget.item.id, flex: 2),
              _readonlyField('Format', widget.item.kind),
              _readonlyField('Year', widget.item.releaseYear?.toString() ?? ''),
            ],
          ),
        ),
        _EditSection(
          title: 'Local Metadata Boundary',
          child: const Text(
            'Title, covers, barcode, release metadata, creators, and provider links come from Collectarr Core. Grade, value, notes, tags, storage, and progress stay local.',
            style: TextStyle(color: _kClzTextMuted),
          ),
        ),
      ],
    );
  }

  Widget _editValueTab() {
    return _EditTabShell(
      children: [
        _EditSection(
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
              const _ValueByGradePanel(),
            ],
          ),
        ),
        _EditSection(
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
    return _EditTabShell(
      children: [
        _EditSection(
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
        _EditSection(
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

  Widget _editCoverTab() {
    return _EditTabShell(
      children: [
        _EditSection(
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
                      _MiniBadge('Local cover cache'),
                      _MiniBadge('Core metadata'),
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
    return _EditTabShell(
      children: [
        _EditSection(
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
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && mounted) {
      setState(() => _purchaseDate = picked);
    }
  }

  void _submit() {
    final currency = _currencyController.text.trim().toUpperCase();
    Navigator.of(context).pop(
      OwnedComicEditSelection(
        condition: _condition,
        grade: _grade,
        purchaseDate: _purchaseDate,
        pricePaidCents: _parseMoneyCents(
          _priceController.text,
          fallback: widget.ownedItem.pricePaidCents,
        ),
        currency: currency.isEmpty ? null : currency,
        personalNotes: _emptyToNull(_notesController.text),
        quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
        storageBox: _emptyToNull(_storageBoxController.text),
        indexNumber: int.tryParse(_indexNumberController.text.trim()),
        coverPriceCents: _parseMoneyCents(
          _coverPriceController.text,
          fallback: widget.ownedItem.coverPriceCents,
        ),
        rawOrSlabbed: _rawOrSlabbed,
        gradingCompany: _emptyToNull(_gradingCompanyController.text),
        graderNotes: _emptyToNull(_graderNotesController.text),
        signedBy: _emptyToNull(_signedByController.text),
        keyComic: _keyComic,
        keyReason: _emptyToNull(_keyReasonController.text),
        rating: int.tryParse(_ratingController.text.trim()),
        readStatus: _emptyToNull(_readStatusController.text),
        tags: _emptyToNull(_tagsController.text),
      ),
    );
  }
}

class _EditTabShell extends StatelessWidget {
  const _EditTabShell({
    required this.children,
    this.cover,
  });

  final List<Widget> children;
  final Widget? cover;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = ListView(
          padding: const EdgeInsets.all(14),
          children: children,
        );
        if (cover == null || constraints.maxWidth < 720) {
          return content;
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 204,
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFF101010),
                border: Border(right: BorderSide(color: _kClzDivider)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(aspectRatio: 2 / 3, child: cover!),
                    ),
                  ),
                  if (constraints.maxHeight >= 360) ...[
                    const SizedBox(height: 10),
                    const _MiniBadge('Local item'),
                    const SizedBox(height: 8),
                    const Text(
                      'Personal fields stay on this device or your sync service.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _kClzTextMuted, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(child: content),
          ],
        );
      },
    );
  }
}

class _EditSection extends StatelessWidget {
  const _EditSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF202426),
        border: const Border(
          left: BorderSide(color: _kClzAccent, width: 2),
          top: BorderSide(color: Color(0xFF3D3D3D)),
          right: BorderSide(color: Color(0xFF3D3D3D)),
          bottom: BorderSide(color: Color(0xFF3D3D3D)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _kClzAccent,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 9),
          child,
        ],
      ),
    );
  }
}

class _EditTab extends StatelessWidget {
  const _EditTab({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17),
          const SizedBox(width: 5),
          Text(label),
        ],
      ),
    );
  }
}

class _EditGrid extends StatelessWidget {
  const _EditGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      rows.add(
        Row(
          children: [
            children[i],
            if (i + 1 < children.length) ...[
              const SizedBox(width: 8),
              children[i + 1],
            ],
          ],
        ),
      );
      if (i + 2 < children.length) {
        rows.add(const SizedBox(height: 8));
      }
    }
    return Column(children: rows);
  }
}

class _ValueByGradePanel extends StatelessWidget {
  const _ValueByGradePanel();

  @override
  Widget build(BuildContext context) {
    const values = [8, 12, 18, 26, 34, 44, 58, 74, 96, 130];
    return Container(
      height: 190,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        border: Border.all(color: _kClzDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Value by grade',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < values.length; i++) ...[
                  Expanded(
                    child: Tooltip(
                      message: '${(i + 1) * 1.0}',
                      child: Container(
                        height: values[i].toDouble(),
                        decoration: const BoxDecoration(
                          color: Color(0xFF7EDAF3),
                        ),
                      ),
                    ),
                  ),
                  if (i != values.length - 1) const SizedBox(width: 5),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Research integration placeholder',
            style: TextStyle(color: _kClzTextMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FooterReadonlyField extends StatelessWidget {
  const _FooterReadonlyField({
    required this.label,
    required this.value,
    required this.width,
  });

  final String label;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    final display = value.trim().isEmpty ? '-' : value.trim();
    return SizedBox(
      width: width,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF191919),
          border: Border.all(color: const Color(0xFF3D3D3D)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _kClzTextMuted, fontSize: 10),
              ),
              Text(
                display,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterTextField extends StatelessWidget {
  const _FooterTextField({
    required this.label,
    required this.controller,
    required this.width,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final double width;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 48,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0E81A6),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

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
}

class _IssuePill extends StatelessWidget {
  const _IssuePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _kClzAccent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

int? _parseMoneyCents(String value, {int? fallback}) {
  final normalized = value.trim().replaceAll(',', '.');
  if (normalized.isEmpty) {
    return null;
  }
  final parsed = double.tryParse(normalized);
  if (parsed == null) {
    return fallback;
  }
  return (parsed * 100).round();
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
