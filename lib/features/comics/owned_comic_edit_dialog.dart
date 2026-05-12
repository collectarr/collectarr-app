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
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: Theme.of(context).dialogTheme.copyWith(
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
          constraints: const BoxConstraints(maxWidth: 860, maxHeight: 720),
          child: Column(
            children: [
              _titleBar(context),
              _tabs(),
              Expanded(
                child: ColoredBox(
                  color: colorScheme.surfaceContainerLowest,
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
    );
  }

  Widget _titleBar(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: _kClzToolbar,
      child: Row(
        children: [
          const Icon(Icons.edit_note, color: _kClzAccent),
          const SizedBox(width: 10),
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
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  widget.item.itemNumber == null
                      ? 'Personal local copy'
                      : 'Issue #${widget.item.itemNumber} - local copy',
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
        labelColor: Colors.white,
        unselectedLabelColor: _kClzTextMuted,
        indicatorColor: _kClzAccent,
        dividerColor: _kClzDivider,
        tabs: const [
          Tab(icon: Icon(Icons.article), text: 'Main'),
          Tab(icon: Icon(Icons.search), text: 'Details'),
          Tab(icon: Icon(Icons.attach_money), text: 'Value'),
          Tab(icon: Icon(Icons.person), text: 'Personal'),
          Tab(icon: Icon(Icons.image), text: 'Cover'),
          Tab(icon: Icon(Icons.notes), text: 'Plot'),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: _tabController.index == 0 ? null : _previousTab,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous'),
          ),
          OutlinedButton.icon(
            onPressed: _tabController.index == _tabController.length - 1
                ? null
                : _nextTab,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
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
      ),
    );
  }

  Widget _editMainTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextFormField(
          initialValue: widget.item.title,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Series',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: widget.item.itemNumber ?? '',
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Issue No.',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue:
                    widget.conditions.contains(_condition) ? _condition : null,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final option in widget.conditions)
                    DropdownMenuItem(value: option, child: Text(option)),
                ],
                onChanged: (value) => setState(() => _condition = value),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: widget.grades.contains(_grade) ? _grade : null,
                decoration: const InputDecoration(
                  labelText: 'Grade',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final option in widget.grades)
                    DropdownMenuItem(value: option, child: Text(option)),
                ],
                onChanged: (value) => setState(() => _grade = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          minLines: 5,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'Personal notes',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _editDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextFormField(
          initialValue: widget.item.id,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Collectarr Item ID',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: widget.item.kind,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Format',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _editValueTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
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
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: TextField(
                controller: _currencyController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _coverPriceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Cover price',
                  prefixText: r'$ ',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _gradingCompanyController,
                decoration: const InputDecoration(
                  labelText: 'Grading company',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _graderNotesController,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Grader notes',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _editPersonalTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            SizedBox(
              width: 140,
              child: TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _storageBoxController,
                decoration: const InputDecoration(
                  labelText: 'Storage box',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 140,
              child: TextField(
                controller: _indexNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Index',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Raw', label: Text('Raw')),
                  ButtonSegment(value: 'Slabbed', label: Text('Slabbed')),
                ],
                selected: {_rawOrSlabbed ?? 'Raw'},
                onSelectionChanged: (selection) =>
                    setState(() => _rawOrSlabbed = selection.first),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _signedByController,
                decoration: const InputDecoration(
                  labelText: 'Signed by',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: MediaRatingField(controller: _ratingController),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: _keyComic,
          onChanged: (value) => setState(() => _keyComic = value),
          title: const Text('Key comic'),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _keyReasonController,
          decoration: const InputDecoration(
            labelText: 'Key reason',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
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
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _editCoverTab() {
    return Center(
      child: SizedBox(
        width: 220,
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: widget.cover,
        ),
      ),
    );
  }

  Widget _editPlotTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          widget.item.synopsis ?? 'No plot metadata available yet.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
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
