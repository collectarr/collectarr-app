import 'dart:convert';

import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ComicEditPanel extends StatefulWidget {
  const ComicEditPanel({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  ComicEditPanelState createState() => ComicEditPanelState();
}

class ComicEditPanelState extends State<ComicEditPanel> {
  static const List<String> _commonCreatorRoles = <String>[
    'Writer',
    'Artist',
    'Cover',
    'Penciller',
    'Inker',
    'Colorist',
    'Letterer',
    'Editor',
  ];

  static const List<String> _commonFormats = <String>[
    'Single Issue',
    'Trade Paperback',
    'Hardcover',
    'Omnibus',
    'Graphic Novel',
    'Deluxe Edition',
  ];

  static const List<String> _commonPublishers = <String>[
    'Marvel',
    'DC',
    'Image',
    'Dark Horse',
    'BOOM! Studios',
    'IDW',
  ];

  static const List<String> _commonImprints = <String>[
    'Skybound',
    'Vertigo',
    'Black Label',
    'Icon',
    'Epic',
  ];

  static const List<String> _commonGrades = <String>[
    '10.0',
    '9.8',
    '9.6',
    '9.4',
    '9.2',
    '9.0',
    '8.5',
    '8.0',
    '7.5',
  ];

  static const List<String> _rawOrSlabbedOptions = <String>[
    'Raw',
    'Slabbed',
    'Raw + Signed',
  ];

  static const List<String> _gradingCompanies = <String>[
    'CGC',
    'CBCS',
    'PGX',
  ];

  static const List<String> _labelTypeOptions = <String>[
    'Universal',
    'Signature Series',
    'Qualified',
    'Restored',
    'Verified',
  ];

  static const List<String> _customLabelOptions = <String>[
    'Blue',
    'Yellow',
    'Red',
    'Green',
    'Silver',
  ];

  static const List<String> _pageQualityOptions = <String>[
    'White Pages',
    'Off-White to White Pages',
    'Cream to Off-White Pages',
    'Brittle Pages',
  ];

  static const List<String> _purchaseStoreOptions = <String>[
    'LCS',
    'Convention',
    'eBay',
    'Whatnot',
    'Online shop',
  ];

  static const List<String> _statusOptions = <String>[
    'Unread',
    'Reading',
    'Finished',
  ];

  static const List<String> _keySeverityOptions = <String>[
    'Minor',
    'Major',
  ];

  static const String _crossoverPrefix = 'Crossover: ';

  late final TextEditingController titleCtl;
  late final TextEditingController seriesCtl;
  late final TextEditingController barcodeCtl;
  late final TextEditingController formatCtl;
  late final TextEditingController seriesGroupCtl;
  late final TextEditingController issueNumberCtl;
  late final TextEditingController variantCtl;
  late final TextEditingController variantDescCtl;
  late final TextEditingController coverDateCtl;
  late final TextEditingController releaseDateCtl;
  late final TextEditingController publisherCtl;
  late final TextEditingController imprintCtl;
  late final TextEditingController subtitleCtl;
  late final TextEditingController crossoverCtl;
  late final TextEditingController storyArcsCtl;
  late final TextEditingController countryCtl;
  late final TextEditingController languageCtl;
  late final TextEditingController ageCtl;
  late final TextEditingController pagesCtl;
  late final TextEditingController genresCtl;
  late final TextEditingController purchasePriceCtl;
  late final TextEditingController purchaseCurrencyCtl;
  late final TextEditingController purchaseDateCtl;
  late final TextEditingController currentValueCtl;
  late final TextEditingController gradeCtl;
  late final TextEditingController coverPriceCtl;
  late final TextEditingController soldPriceCtl;
  late final TextEditingController soldDateCtl;
  late final TextEditingController purchaseStoreCtl;
  late final TextEditingController rawOrSlabbedCtl;
  late final TextEditingController gradingCompanyCtl;
  late final TextEditingController labelTypeCtl;
  late final TextEditingController customLabelCtl;
  late final TextEditingController pageQualityCtl;
  late final TextEditingController certificationNumberCtl;
  late final TextEditingController graderNotesCtl;
  late final TextEditingController signedByCtl;
  late final TextEditingController keyReasonCtl;
  late final TextEditingController keyCategoryCtl;
  late final TextEditingController keySeverityCtl;
  late final TextEditingController statusCtl;
  late final TextEditingController ratingCtl;
  late final TextEditingController ownerCtl;
  late final TextEditingController readDateCtl;
  late final TextEditingController bagBoardDateCtl;
  late final TextEditingController tagsCtl;
  late final TextEditingController notesCtl;
  late final TextEditingController coverUrlCtl;
  late final TextEditingController characterDraftCtl;
  final List<Map<String, TextEditingController>> creators = [];
  final List<TextEditingController> characters = [];
  late final TextEditingController summaryCtl;
  late final TextEditingController descriptionCtl;
  final List<Map<String, TextEditingController>> links = [];

  late Map<String, String?> _customFieldValues;
  List<ItemImageEdit> _itemImageEdits = const [];
  bool _keyComic = false;

  @override
  void initState() {
    super.initState();
    final item = widget.request.item;
    final owned = widget.request.ownedItem;
    final tracking = widget.request.trackingEntry;
    final publishing = item.publishing;

    titleCtl = TextEditingController(text: item.title);
    seriesCtl = TextEditingController(text: item.series?.seriesTitle ?? '');
    barcodeCtl = TextEditingController(text: item.barcode ?? '');
    formatCtl = TextEditingController(text: item.physicalFormatLabel ?? '');
    seriesGroupCtl = TextEditingController(text: publishing?.seriesGroup ?? '');
    issueNumberCtl = TextEditingController(text: item.itemNumber ?? '');
    variantCtl = TextEditingController(text: item.variant ?? '');
    variantDescCtl = TextEditingController(text: item.editionTitle ?? '');
    coverDateCtl = TextEditingController(
      text: item.coverDate == null ? '' : formatDate(item.coverDate!),
    );
    releaseDateCtl = TextEditingController(
      text: item.releaseDate == null ? '' : formatDate(item.releaseDate!),
    );
    publisherCtl = TextEditingController(text: item.publisher ?? '');
    imprintCtl = TextEditingController(text: publishing?.imprint ?? '');
    subtitleCtl = TextEditingController(text: item.titleExtension ?? '');
    final crossover = (item.storyArcs ?? const <String>[])
        .where((value) => value.startsWith(_crossoverPrefix))
        .map((value) => value.substring(_crossoverPrefix.length).trim())
        .firstOrNull;
    crossoverCtl = TextEditingController(text: crossover ?? '');
    storyArcsCtl = TextEditingController(
      text: (item.storyArcs ?? const <String>[])
          .where((value) => !value.startsWith(_crossoverPrefix))
          .join(', '),
    );
    countryCtl = TextEditingController(text: item.country ?? '');
    languageCtl = TextEditingController(text: item.language ?? '');
    ageCtl = TextEditingController(text: item.ageRating ?? '');
    pagesCtl =
        TextEditingController(text: publishing?.pageCount?.toString() ?? '');
    genresCtl = TextEditingController(text: item.genres?.join(', ') ?? '');
    purchasePriceCtl = TextEditingController(
      text: owned?.pricePaidCents == null
          ? ''
          : (owned!.pricePaidCents! / 100).toStringAsFixed(2),
    );
    purchaseCurrencyCtl = TextEditingController(text: owned?.currency ?? '');
    purchaseDateCtl = TextEditingController(
      text: owned?.purchaseDate == null ? '' : formatDate(owned!.purchaseDate!),
    );
    currentValueCtl = TextEditingController(
      text: owned?.marketValueCents == null
          ? ''
          : (owned!.marketValueCents! / 100).toStringAsFixed(2),
    );
    gradeCtl = TextEditingController(text: owned?.grade ?? '');
    coverPriceCtl = TextEditingController(
      text: owned?.coverPriceCents == null
          ? ''
          : (owned!.coverPriceCents! / 100).toStringAsFixed(2),
    );
    soldPriceCtl = TextEditingController(
      text: owned?.sellPriceCents == null
          ? ''
          : (owned!.sellPriceCents! / 100).toStringAsFixed(2),
    );
    soldDateCtl = TextEditingController(
      text: owned?.soldAt == null ? '' : formatDate(owned!.soldAt!),
    );
    purchaseStoreCtl = TextEditingController(text: owned?.purchaseStore ?? '');
    rawOrSlabbedCtl = TextEditingController(text: owned?.rawOrSlabbed ?? '');
    gradingCompanyCtl =
        TextEditingController(text: owned?.gradingCompany ?? '');
    labelTypeCtl = TextEditingController(text: owned?.labelType ?? '');
    customLabelCtl = TextEditingController(text: owned?.customLabel ?? '');
    pageQualityCtl = TextEditingController(text: owned?.pageQuality ?? '');
    certificationNumberCtl =
        TextEditingController(text: owned?.certificationNumber ?? '');
    graderNotesCtl = TextEditingController(text: owned?.graderNotes ?? '');
    signedByCtl = TextEditingController(text: owned?.signedBy ?? '');
    keyReasonCtl = TextEditingController(text: owned?.keyReason ?? '');
    keyCategoryCtl = TextEditingController(text: owned?.keyCategory ?? '');
    keySeverityCtl = TextEditingController(text: owned?.keySeverity ?? '');
    statusCtl = TextEditingController(
        text: tracking?.statusStorageValue ?? owned?.readStatus ?? '');
    ratingCtl = TextEditingController(
      text: tracking?.rating?.toString() ?? owned?.rating?.toString() ?? '',
    );
    ownerCtl = TextEditingController(text: owned?.ownerLabel ?? '');
    readDateCtl = TextEditingController(
      text: tracking?.finishedAt == null && owned?.finishedAt == null
          ? ''
          : formatDate(tracking?.finishedAt ?? owned!.finishedAt!),
    );
    bagBoardDateCtl = TextEditingController(
      text: owned?.lastBagBoardDate == null
          ? ''
          : formatDate(owned!.lastBagBoardDate!),
    );
    tagsCtl = TextEditingController(text: owned?.tags ?? '');
    notesCtl = TextEditingController(text: owned?.personalNotes ?? '');
    coverUrlCtl = TextEditingController(
        text: item.coverImageUrl ?? item.thumbnailImageUrl ?? '');
    characterDraftCtl = TextEditingController();
    final decodedPlot = _decodePlotSynopsis(item.synopsis);
    summaryCtl = TextEditingController(text: decodedPlot.$1);
    descriptionCtl = TextEditingController(text: decodedPlot.$2);
    _keyComic = owned?.keyComic ?? false;
    _customFieldValues = {
      for (final definition in widget.request.customFieldDefinitions)
        definition.id: widget.request.customFieldValues
            .where((value) => value.fieldDefinitionId == definition.id)
            .map((value) => value.value)
            .firstOrNull,
    };

    for (final creator in item.creators ?? const <Map<String, dynamic>>[]) {
      creators.add({
        'name': TextEditingController(text: creator['name']?.toString() ?? ''),
        'role': TextEditingController(
          text: creator['role']?.toString() ?? creator['job']?.toString() ?? '',
        ),
      });
    }
    for (final character in item.characters ?? const <String>[]) {
      characters.add(TextEditingController(text: character));
    }
    for (final link in item.trailerUrls) {
      links.add({
        'title': TextEditingController(text: link.title ?? link.source ?? ''),
        'url': TextEditingController(text: link.url),
      });
    }
  }

  @override
  void dispose() {
    titleCtl.dispose();
    seriesCtl.dispose();
    barcodeCtl.dispose();
    formatCtl.dispose();
    seriesGroupCtl.dispose();
    issueNumberCtl.dispose();
    variantCtl.dispose();
    variantDescCtl.dispose();
    coverDateCtl.dispose();
    releaseDateCtl.dispose();
    publisherCtl.dispose();
    imprintCtl.dispose();
    subtitleCtl.dispose();
    crossoverCtl.dispose();
    storyArcsCtl.dispose();
    countryCtl.dispose();
    languageCtl.dispose();
    ageCtl.dispose();
    pagesCtl.dispose();
    genresCtl.dispose();
    purchasePriceCtl.dispose();
    purchaseCurrencyCtl.dispose();
    purchaseDateCtl.dispose();
    currentValueCtl.dispose();
    gradeCtl.dispose();
    coverPriceCtl.dispose();
    soldPriceCtl.dispose();
    soldDateCtl.dispose();
    purchaseStoreCtl.dispose();
    rawOrSlabbedCtl.dispose();
    gradingCompanyCtl.dispose();
    labelTypeCtl.dispose();
    customLabelCtl.dispose();
    pageQualityCtl.dispose();
    certificationNumberCtl.dispose();
    graderNotesCtl.dispose();
    signedByCtl.dispose();
    keyReasonCtl.dispose();
    keyCategoryCtl.dispose();
    keySeverityCtl.dispose();
    statusCtl.dispose();
    ratingCtl.dispose();
    ownerCtl.dispose();
    readDateCtl.dispose();
    bagBoardDateCtl.dispose();
    tagsCtl.dispose();
    notesCtl.dispose();
    coverUrlCtl.dispose();
    characterDraftCtl.dispose();
    summaryCtl.dispose();
    descriptionCtl.dispose();
    for (final creator in creators) {
      creator['name']?.dispose();
      creator['role']?.dispose();
    }
    for (final character in characters) {
      character.dispose();
    }
    for (final link in links) {
      link['title']?.dispose();
      link['url']?.dispose();
    }
    super.dispose();
  }

  void _addCreator() {
    creators.add(_newCreatorControllers());
    setState(() {});
  }

  void _addCreatorWithRole(String role) {
    creators.add(_newCreatorControllers(role: role));
    setState(() {});
  }

  void _removeCreator(int idx) {
    final creator = creators.removeAt(idx);
    creator['name']?.dispose();
    creator['role']?.dispose();
    setState(() {});
  }

  void _addCharacter([String? value]) {
    final normalized = (value ?? characterDraftCtl.text).trim();
    if (normalized.isEmpty) {
      return;
    }
    final alreadyExists = characters.any(
      (controller) =>
          controller.text.trim().toLowerCase() == normalized.toLowerCase(),
    );
    if (alreadyExists) {
      characterDraftCtl.clear();
      return;
    }
    characters.add(TextEditingController(text: normalized));
    characterDraftCtl.clear();
    setState(() {});
  }

  void _removeCharacter(int idx) {
    final character = characters.removeAt(idx);
    character.dispose();
    setState(() {});
  }

  Future<void> _renameCharacter(int idx) async {
    final controller = TextEditingController(text: characters[idx].text);
    final renamed = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename character'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Character',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (renamed == null) {
      return;
    }
    final normalized = renamed.trim();
    if (normalized.isEmpty) {
      return;
    }
    setState(() => characters[idx].text = normalized);
  }

  Map<String, TextEditingController> _newCreatorControllers({
    String name = '',
    String role = '',
  }) {
    return {
      'name': TextEditingController(text: name),
      'role': TextEditingController(text: role),
    };
  }

  void _addLink() {
    links.add({
      'title': TextEditingController(),
      'url': TextEditingController(),
    });
    setState(() {});
  }

  void _removeLink(int idx) {
    final link = links.removeAt(idx);
    link['title']?.dispose();
    link['url']?.dispose();
    setState(() {});
  }

  Widget _labelledField(
    String label, {
    TextEditingController? controller,
    Key? key,
    int maxLines = 1,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          key: key,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hintText),
        ),
      ],
    );
  }

  Widget _labelledDateField(
    String label, {
    required TextEditingController controller,
    Key? key,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        _StructuredDateField(
          controller: controller,
          fieldKey: key,
          label: label,
        ),
      ],
    );
  }

  Widget _buildQuickChoiceField(
    String label, {
    required TextEditingController controller,
    required List<String> suggestions,
    Key? key,
    int maxLines = 1,
    String? hintText,
  }) {
    final normalizedSuggestions = suggestions
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelledField(
          label,
          controller: controller,
          key: key,
          maxLines: maxLines,
          hintText: hintText,
        ),
        if (normalizedSuggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final suggestion in normalizedSuggestions)
                ActionChip(
                  label: Text(suggestion),
                  onPressed: () {
                    _setControllerText(controller, suggestion);
                    setState(() {});
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }

  void _setControllerText(TextEditingController controller, String value) {
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  Widget _buildReadStatusSection() {
    final currentStatus = _statusOptions.contains(statusCtl.text.trim())
        ? statusCtl.text.trim()
        : 'Unread';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Read Status',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(
              value: 'Unread',
              label: Text('Unread', key: ValueKey('edit-status-unread')),
            ),
            ButtonSegment<String>(
              value: 'Reading',
              label: Text('Reading', key: ValueKey('edit-status-reading')),
            ),
            ButtonSegment<String>(
              value: 'Finished',
              label: Text('Finished', key: ValueKey('edit-status-finished')),
            ),
          ],
          selected: {currentStatus},
          onSelectionChanged: (selection) {
            final value = selection.firstOrNull ?? 'Unread';
            _setControllerText(statusCtl, value);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    final rating = int.tryParse(ratingCtl.text.trim())?.clamp(0, 10) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Rating', style: TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            if (rating > 0)
              TextButton(
                onPressed: () {
                  _setControllerText(ratingCtl, '');
                  setState(() {});
                },
                child: const Text('Clear'),
              ),
          ],
        ),
        Slider(
          key: const ValueKey('edit-rating-slider'),
          value: rating.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          label: rating == 0 ? 'Not rated' : '$rating / 10',
          onChanged: (value) {
            final normalized = value.round();
            _setControllerText(
              ratingCtl,
              normalized == 0 ? '' : normalized.toString(),
            );
            setState(() {});
          },
        ),
        Text(
          rating == 0 ? 'Not rated' : '$rating / 10',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var value = 1; value <= 10; value++)
              ActionChip(
                key: ValueKey('edit-rating-choice-$value'),
                label: Text('$value'),
                onPressed: () {
                  _setControllerText(ratingCtl, value.toString());
                  setState(() {});
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeySeveritySection() {
    final currentSeverity = !_keyComic
        ? 'No'
        : (_keySeverityOptions.contains(keySeverityCtl.text.trim())
            ? keySeverityCtl.text.trim()
            : 'Major');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Issue Severity',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(
              value: 'No',
              label: Text('No', key: ValueKey('edit-key-no')),
            ),
            ButtonSegment<String>(
              value: 'Minor',
              label: Text('Minor', key: ValueKey('edit-key-minor')),
            ),
            ButtonSegment<String>(
              value: 'Major',
              label: Text('Major', key: ValueKey('edit-key-major')),
            ),
          ],
          selected: {currentSeverity},
          onSelectionChanged: (selection) {
            final value = selection.firstOrNull ?? 'No';
            if (value == 'No') {
              _keyComic = false;
              _setControllerText(keySeverityCtl, '');
            } else {
              _keyComic = true;
              _setControllerText(keySeverityCtl, value);
            }
            setState(() {});
          },
        ),
      ],
    );
  }

  (String, String) _decodePlotSynopsis(String? value) {
    final synopsis = value?.trim() ?? '';
    if (synopsis.isEmpty) {
      return ('', '');
    }
    final parts = synopsis.split(RegExp(r'\r?\n\r?\n'));
    if (parts.length <= 1) {
      return (synopsis, '');
    }
    return (parts.first.trim(), parts.skip(1).join('\n\n').trim());
  }

  String _buildMarketSearchQuery() {
    final series = seriesCtl.text.trim();
    final title = titleCtl.text.trim();
    final issue = issueNumberCtl.text.trim();
    final variant = variantCtl.text.trim();
    return [
      if (series.isNotEmpty) series else title,
      if (issue.isNotEmpty) '#$issue',
      if (variant.isNotEmpty) variant,
    ].join(' ').trim();
  }

  Future<void> _openCovrPriceHome() async {
    final uri = Uri.parse('https://covrprice.com');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Ignore platform URL failures.
    }
  }

  List<_ResolvedComicImage> _resolvedImages() {
    final existing = {
      for (final image in widget.request.itemImages) image.id: image
    };
    final editsById = {
      for (final edit in _itemImageEdits) edit.id: edit,
    };
    final images = <_ResolvedComicImage>[];
    for (final image in widget.request.itemImages) {
      final edit = editsById[image.id];
      if (edit?.deleted == true) {
        continue;
      }
      images.add(
        _ResolvedComicImage(
          id: image.id,
          imageData: edit?.imageData ?? image.imageData,
          imageType: edit?.imageType ?? image.imageType,
          caption: edit?.caption ?? image.caption,
          sortOrder: edit?.sortOrder ?? image.sortOrder,
        ),
      );
    }
    for (final edit in _itemImageEdits) {
      if (existing.containsKey(edit.id) ||
          edit.deleted ||
          edit.imageData == null) {
        continue;
      }
      images.add(
        _ResolvedComicImage(
          id: edit.id,
          imageData: edit.imageData!,
          imageType: edit.imageType,
          caption: edit.caption,
          sortOrder: edit.sortOrder,
        ),
      );
    }
    images.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return images;
  }

  _ResolvedComicImage? _firstImageOfType(String type) {
    return _resolvedImages()
        .where((image) => image.imageType == type)
        .firstOrNull;
  }

  Widget _buildImagePreviewCard(
    String title, {
    String? networkUrl,
    String? imageData,
    String emptyLabel = 'No image',
  }) {
    Widget child;
    if (imageData != null && imageData.isNotEmpty) {
      try {
        child = Image.memory(
          base64Decode(imageData),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(child: Text(emptyLabel)),
        );
      } catch (_) {
        child = Center(child: Text(emptyLabel));
      }
    } else if (networkUrl != null && networkUrl.isNotEmpty) {
      child = Image.network(
        networkUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(child: Text(emptyLabel)),
      );
    } else {
      child = Center(child: Text(emptyLabel));
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildMainTab(BuildContext context) {
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
                _buildQuickChoiceField(
                  'Series',
                  controller: seriesCtl,
                  key: const ValueKey('edit-series'),
                  suggestions: [
                    widget.request.item.series?.seriesTitle ?? '',
                    widget.request.item.title,
                  ],
                ),
                const SizedBox(height: 8),
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
                      suggestions: _commonFormats,
                    )),
                  ],
                ),
                const SizedBox(height: 8),
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
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: _labelledField('Issue No.',
                            controller: issueNumberCtl,
                            key: const ValueKey('edit-issuenr'))),
                    const SizedBox(width: 8),
                    Expanded(
                        flex: 2,
                        child: _labelledField('Variant',
                            controller: variantCtl,
                            key: const ValueKey('edit-variant'))),
                    const SizedBox(width: 8),
                    Expanded(
                        flex: 7,
                        child: _labelledField('Variant Description',
                            controller: variantDescCtl,
                            key: const ValueKey('edit-variant-desc'))),
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
                      suggestions: _commonPublishers,
                    )),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildQuickChoiceField(
                      'Imprint',
                      controller: imprintCtl,
                      key: const ValueKey('edit-imprint'),
                      suggestions: _commonImprints,
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

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  child: _labelledField('Country',
                      controller: countryCtl,
                      key: const ValueKey('edit-country'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _labelledField('Language',
                      controller: languageCtl,
                      key: const ValueKey('edit-language'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _labelledField('Age',
                      controller: ageCtl, key: const ValueKey('edit-age'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _labelledField('No. of Pages',
                      controller: pagesCtl, key: const ValueKey('edit-pages'))),
            ],
          ),
          const SizedBox(height: 12),
          _labelledField('Crossover',
              controller: crossoverCtl,
              key: const ValueKey('edit-crossover'),
              hintText: 'Saved as a tagged story arc for now'),
          const SizedBox(height: 12),
          _labelledField('Story Arcs',
              controller: storyArcsCtl,
              key: const ValueKey('edit-storyarcs'),
              hintText: 'Comma separated'),
          const SizedBox(height: 12),
          _labelledField('Genres',
              controller: genresCtl,
              key: const ValueKey('edit-genres'),
              hintText: 'Comma separated'),
        ],
      ),
    );
  }

  Widget _buildValueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _labelledField('Purchase Price',
                      controller: purchasePriceCtl,
                      key: const ValueKey('edit-purchase-price'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _labelledField('Currency',
                      controller: purchaseCurrencyCtl,
                      key: const ValueKey('edit-purchase-currency'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _labelledDateField('Purchase Date',
                      controller: purchaseDateCtl,
                      key: const ValueKey('edit-purchase-date'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _labelledField('My Value',
                      controller: currentValueCtl,
                      key: const ValueKey('edit-current-value'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildQuickChoiceField('Grade',
                      controller: gradeCtl,
                      suggestions: _commonGrades,
                      key: const ValueKey('edit-grade'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _labelledField('Cover Price',
                      controller: coverPriceCtl,
                      key: const ValueKey('edit-cover-price'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
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
                  child: _buildQuickChoiceField('Purchase Store',
                      controller: purchaseStoreCtl,
                      suggestions: _purchaseStoreOptions,
                      key: const ValueKey('edit-purchase-store'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildQuickChoiceField('Raw / Slabbed',
                      controller: rawOrSlabbedCtl,
                      suggestions: _rawOrSlabbedOptions,
                      key: const ValueKey('edit-raw-slabbed'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildQuickChoiceField('Grading Company',
                      controller: gradingCompanyCtl,
                      suggestions: _gradingCompanies,
                      key: const ValueKey('edit-grading-company'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildQuickChoiceField('Label Type',
                      controller: labelTypeCtl,
                      suggestions: _labelTypeOptions,
                      key: const ValueKey('edit-label-type'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildQuickChoiceField('Custom Label',
                      controller: customLabelCtl,
                      suggestions: _customLabelOptions,
                      key: const ValueKey('edit-custom-label'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildQuickChoiceField('Page Quality',
                      controller: pageQualityCtl,
                      suggestions: _pageQualityOptions,
                      key: const ValueKey('edit-page-quality'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _labelledField('Certification Number',
                      controller: certificationNumberCtl,
                      key: const ValueKey('edit-certification-number'))),
            ],
          ),
          const SizedBox(height: 12),
          _labelledField('Grader Notes',
              controller: graderNotesCtl,
              key: const ValueKey('edit-grader-notes'),
              maxLines: 3),
          const SizedBox(height: 12),
          _labelledField('Signed by',
              controller: signedByCtl, key: const ValueKey('edit-signed-by')),
          const SizedBox(height: 12),
          _buildKeySeveritySection(),
          if (_keyComic) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _labelledField('Key Category',
                        controller: keyCategoryCtl,
                        key: const ValueKey('edit-key-category'))),
                const SizedBox(width: 8),
                Expanded(
                    child: _labelledField('Key Severity',
                        controller: keySeverityCtl,
                        key: const ValueKey('edit-key-severity'))),
              ],
            ),
            const SizedBox(height: 12),
            _labelledField('Key Reason',
                controller: keyReasonCtl,
                key: const ValueKey('edit-key-reason')),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Market Tools',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jump to sold listings or external price references while editing your grading and value notes.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => launchEbaySearch(
                        '${_buildMarketSearchQuery()} sold',
                      ),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Sold Listings'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _openCovrPriceHome,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open CovrPrice'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildReadStatusSection()),
              const SizedBox(width: 8),
              Expanded(child: _buildRatingSection()),
              const SizedBox(width: 8),
              Expanded(
                  child: _labelledField('Owner',
                      controller: ownerCtl, key: const ValueKey('edit-owner'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _labelledDateField('Read Date',
                      controller: readDateCtl,
                      key: const ValueKey('edit-read-date'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _labelledDateField('Bag/Board Date',
                      controller: bagBoardDateCtl,
                      key: const ValueKey('edit-bagboard-date'))),
            ],
          ),
          const SizedBox(height: 12),
          _labelledField('Tags',
              controller: tagsCtl, key: const ValueKey('edit-tags')),
          const SizedBox(height: 12),
          _labelledField('Notes',
              controller: notesCtl,
              key: const ValueKey('edit-notes'),
              maxLines: 5),
        ],
      ),
    );
  }

  Widget _buildCustomFieldsTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: CustomFieldsEditSection(
        definitions: widget.request.customFieldDefinitions,
        values: _customFieldValues,
        accent: widget.request.accent,
        onChanged: (values) => setState(() => _customFieldValues = values),
      ),
    );
  }

  Widget _buildCoversTab() {
    final coverUrl = coverUrlCtl.text.trim();
    final resolvedImages = _resolvedImages();
    final imageCount = resolvedImages.length;
    final backCover = _firstImageOfType('back_cover');
    final frontAlt = _firstImageOfType('front_cover');
    final auxiliaryCount =
        resolvedImages.where((image) => image.imageType == 'auxiliary').length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelledField('Front Cover URL',
              controller: coverUrlCtl, key: const ValueKey('edit-cover-url')),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePreviewCard(
                'Front Cover',
                networkUrl: coverUrl,
                imageData: frontAlt?.imageData,
                emptyLabel: 'No front cover',
              ),
              const SizedBox(width: 12),
              _buildImagePreviewCard(
                'Back Cover',
                imageData: backCover?.imageData,
                emptyLabel: 'No back cover',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cover workflow',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use the metadata cover above for the primary front cover. Use My Images to assign front cover overrides, back covers, slab shots, signatures, and detail photos.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Attached personal images: $imageCount total, $auxiliaryCount auxiliary.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          DefaultTabController.of(context).animateTo(6),
                      icon: const Icon(Icons.collections_outlined),
                      label: const Text('Manage My Images'),
                    ),
                    FilledButton.icon(
                      onPressed: () =>
                          launchEbaySearch(_buildMarketSearchQuery()),
                      icon: const Icon(Icons.search),
                      label: const Text('Find Better Cover'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyImagesTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ItemImagesEditSection(
        images: widget.request.itemImages,
        accent: widget.request.accent,
        onChanged: (edits) => setState(() => _itemImageEdits = edits),
      ),
    );
  }

  Widget _buildCreatorsTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
              onPressed: _addCreator,
              icon: const Icon(Icons.add),
              label: const Text('Add Creator')),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final role in _commonCreatorRoles)
                ActionChip(
                  label: Text('Add $role'),
                  onPressed: () => _addCreatorWithRole(role),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (creators.isEmpty)
            Text(
              'No creators yet. Add the main credits here.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          for (var i = 0; i < creators.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Creator ${i + 1}',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        IconButton(
                            onPressed: () => _removeCreator(i),
                            icon: const Icon(Icons.delete_outline)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: TextField(
                                controller: creators[i]['name'],
                                decoration:
                                    const InputDecoration(labelText: 'Name'),
                                key: ValueKey('edit-creator-$i-name'))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: TextField(
                                controller: creators[i]['role'],
                                decoration:
                                    const InputDecoration(labelText: 'Role'),
                                key: ValueKey('edit-creator-$i-role'))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final role in _commonCreatorRoles)
                            ActionChip(
                              label: Text(role),
                              onPressed: () {
                                creators[i]['role']?.text = role;
                                setState(() {});
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCharactersTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: characterDraftCtl,
                  decoration: const InputDecoration(
                    labelText: 'Add character',
                    hintText: 'Name',
                  ),
                  onSubmitted: (_) => _addCharacter(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                  onPressed: _addCharacter,
                  icon: const Icon(Icons.add),
                  label: const Text('Add')),
            ],
          ),
          const SizedBox(height: 8),
          if (characters.isEmpty)
            Text(
              'No characters yet. Add the main cast as quick chips.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < characters.length; i++)
                  InputChip(
                    key: ValueKey('edit-character-$i'),
                    label: Text(characters[i].text),
                    onPressed: () => _renameCharacter(i),
                    onDeleted: () => _removeCharacter(i),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPlotTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _labelledField('Summary',
              controller: summaryCtl,
              key: const ValueKey('edit-summary'),
              maxLines: 3),
          const SizedBox(height: 12),
          _labelledField('Description',
              controller: descriptionCtl,
              key: const ValueKey('edit-description'),
              maxLines: 6),
        ],
      ),
    );
  }

  Widget _buildLinksTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
              onPressed: _addLink,
              icon: const Icon(Icons.add),
              label: const Text('Add Link')),
          const SizedBox(height: 8),
          for (var i = 0; i < links.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: links[i]['title'],
                          decoration: const InputDecoration(labelText: 'Title'),
                          key: ValueKey('edit-link-$i-title'))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          controller: links[i]['url'],
                          decoration: const InputDecoration(labelText: 'URL'),
                          key: ValueKey('edit-link-$i-url'))),
                  IconButton(
                      onPressed: () => _removeLink(i),
                      icon: const Icon(Icons.delete)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 11,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).cardColor,
            child: TabBar(
              isScrollable: true,
              tabs: const [
                Tab(icon: Icon(Icons.book), text: 'Main'),
                Tab(icon: Icon(Icons.search), text: 'Details'),
                Tab(icon: Icon(Icons.attach_money), text: 'Value'),
                Tab(icon: Icon(Icons.person), text: 'Personal'),
                Tab(icon: Icon(Icons.edit), text: 'Custom Fields'),
                Tab(icon: Icon(Icons.camera_alt), text: 'Covers'),
                Tab(icon: Icon(Icons.image), text: 'My Images'),
                Tab(icon: Icon(Icons.group), text: 'Creators'),
                Tab(icon: Icon(Icons.face), text: 'Characters'),
                Tab(icon: Icon(Icons.article), text: 'Plot'),
                Tab(icon: Icon(Icons.link), text: 'Links'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMainTab(context),
                _buildDetailsTab(),
                _buildValueTab(),
                _buildPersonalTab(),
                _buildCustomFieldsTab(),
                _buildCoversTab(),
                _buildMyImagesTab(),
                _buildCreatorsTab(),
                _buildCharactersTab(),
                _buildPlotTab(),
                _buildLinksTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': titleCtl.text,
      'series': seriesCtl.text,
      'barcode': barcodeCtl.text,
      'format': formatCtl.text,
      'seriesGroup': seriesGroupCtl.text,
      'issueNumber': issueNumberCtl.text,
      'variant': variantCtl.text,
      'variantDescription': variantDescCtl.text,
      'coverDate': coverDateCtl.text,
      'releaseDate': releaseDateCtl.text,
      'publisher': publisherCtl.text,
      'imprint': imprintCtl.text,
      'subtitle': subtitleCtl.text,
      'crossover': crossoverCtl.text,
      'storyArcs': storyArcsCtl.text,
      'country': countryCtl.text,
      'language': languageCtl.text,
      'age': ageCtl.text,
      'pages': pagesCtl.text,
      'genres': genresCtl.text,
      'purchasePrice': purchasePriceCtl.text,
      'purchaseCurrency': purchaseCurrencyCtl.text,
      'purchaseDate': purchaseDateCtl.text,
      'currentValue': currentValueCtl.text,
      'grade': gradeCtl.text,
      'coverPrice': coverPriceCtl.text,
      'soldPrice': soldPriceCtl.text,
      'soldDate': soldDateCtl.text,
      'purchaseStore': purchaseStoreCtl.text,
      'rawOrSlabbed': rawOrSlabbedCtl.text,
      'gradingCompany': gradingCompanyCtl.text,
      'labelType': labelTypeCtl.text,
      'customLabel': customLabelCtl.text,
      'pageQuality': pageQualityCtl.text,
      'certificationNumber': certificationNumberCtl.text,
      'graderNotes': graderNotesCtl.text,
      'signedBy': signedByCtl.text,
      'keyComic': _keyComic,
      'keyReason': keyReasonCtl.text,
      'keyCategory': keyCategoryCtl.text,
      'keySeverity': keySeverityCtl.text,
      'status': statusCtl.text,
      'rating': ratingCtl.text,
      'owner': ownerCtl.text,
      'readDate': readDateCtl.text,
      'bagBoardDate': bagBoardDateCtl.text,
      'tags': tagsCtl.text,
      'notes': notesCtl.text,
      'customFieldEdits': _customFieldValues,
      'coverUrl': coverUrlCtl.text,
      'creators': creators
          .map((creator) => <String, dynamic>{
                'name': creator['name']?.text ?? '',
                'role': creator['role']?.text ?? ''
              })
          .toList(),
      'characters': characters.map((character) => character.text).toList(),
      'summary': summaryCtl.text,
      'description': descriptionCtl.text,
      'links': links
          .map((link) => <String, dynamic>{
                'title': link['title']?.text ?? '',
                'url': link['url']?.text ?? ''
              })
          .toList(),
      'itemImageEdits': _itemImageEdits,
    };
  }
}

class _StructuredDateField extends StatefulWidget {
  const _StructuredDateField({
    required this.controller,
    required this.label,
    this.fieldKey,
  });

  final TextEditingController controller;
  final String label;
  final Key? fieldKey;

  @override
  State<_StructuredDateField> createState() => _StructuredDateFieldState();
}

class _StructuredDateFieldState extends State<_StructuredDateField> {
  late final TextEditingController _yearCtl;
  late final TextEditingController _monthCtl;
  late final TextEditingController _dayCtl;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    final parsed = _splitDate(widget.controller.text);
    _yearCtl = TextEditingController(text: parsed.$1);
    _monthCtl = TextEditingController(text: parsed.$2);
    _dayCtl = TextEditingController(text: parsed.$3);
    widget.controller.addListener(_syncFromMainController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromMainController);
    _yearCtl.dispose();
    _monthCtl.dispose();
    _dayCtl.dispose();
    super.dispose();
  }

  void _syncFromMainController() {
    if (_syncing) {
      return;
    }
    final parsed = _splitDate(widget.controller.text);
    if (_yearCtl.text == parsed.$1 &&
        _monthCtl.text == parsed.$2 &&
        _dayCtl.text == parsed.$3) {
      return;
    }
    _yearCtl.text = parsed.$1;
    _monthCtl.text = parsed.$2;
    _dayCtl.text = parsed.$3;
  }

  static (String, String, String) _splitDate(String value) {
    final parts = value.trim().split('-');
    if (parts.length != 3) {
      return ('', '', '');
    }
    return (parts[0], parts[1], parts[2]);
  }

  void _writeBack() {
    _syncing = true;
    final year = _yearCtl.text.trim();
    final month = _monthCtl.text.trim();
    final day = _dayCtl.text.trim();
    final value =
        year.isEmpty && month.isEmpty && day.isEmpty ? '' : '$year-$month-$day';
    widget.controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _syncing = false;
  }

  Future<void> _pickDate() async {
    final initialDate = _tryParseDate(widget.controller.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: widget.label,
    );
    if (picked == null || !mounted) {
      return;
    }
    _yearCtl.text = picked.year.toString().padLeft(4, '0');
    _monthCtl.text = picked.month.toString().padLeft(2, '0');
    _dayCtl.text = picked.day.toString().padLeft(2, '0');
    _writeBack();
    setState(() {});
  }

  DateTime? _tryParseDate(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return DateTime.tryParse(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final keyPrefix = widget.fieldKey is ValueKey<String>
        ? (widget.fieldKey as ValueKey<String>).value
        : null;
    return Row(
      key: widget.fieldKey,
      children: [
        Expanded(
          flex: 4,
          child: TextField(
            key: keyPrefix == null ? null : ValueKey('$keyPrefix-year'),
            controller: _yearCtl,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(
              counterText: '',
              hintText: 'YYYY',
            ),
            onChanged: (_) => _writeBack(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: TextField(
            key: keyPrefix == null ? null : ValueKey('$keyPrefix-month'),
            controller: _monthCtl,
            keyboardType: TextInputType.number,
            maxLength: 2,
            decoration: const InputDecoration(
              counterText: '',
              hintText: 'MM',
            ),
            onChanged: (_) => _writeBack(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: TextField(
            key: keyPrefix == null ? null : ValueKey('$keyPrefix-day'),
            controller: _dayCtl,
            keyboardType: TextInputType.number,
            maxLength: 2,
            decoration: const InputDecoration(
              counterText: '',
              hintText: 'DD',
            ),
            onChanged: (_) => _writeBack(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Pick date',
          onPressed: _pickDate,
          icon: const Icon(Icons.calendar_today_outlined),
        ),
      ],
    );
  }
}

class _ResolvedComicImage {
  const _ResolvedComicImage({
    required this.id,
    required this.imageData,
    required this.imageType,
    required this.caption,
    required this.sortOrder,
  });

  final String id;
  final String imageData;
  final String imageType;
  final String? caption;
  final int sortOrder;
}
