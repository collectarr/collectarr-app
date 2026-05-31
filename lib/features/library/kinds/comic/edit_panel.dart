import 'dart:convert';

import 'package:collectarr_app/features/collection/pick_list/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_tab_strip.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/series/series_registry_dialog.dart';
import 'package:collectarr_app/features/library/series/series_registry_repository.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ComicEditPanel extends ConsumerStatefulWidget {
  const ComicEditPanel({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  ComicEditPanelState createState() => ComicEditPanelState();
}

class ComicEditPanelState extends ConsumerState<ComicEditPanel> {
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
  final List<_EditableComicCreator> _creators = [];
  final List<_EditableComicCharacter> _characters = [];
  late final TextEditingController summaryCtl;
  late final TextEditingController descriptionCtl;
  final List<Map<String, TextEditingController>> links = [];

  late Map<String, String?> _customFieldValues;
  List<ItemImageEdit> _itemImageEdits = const [];
  bool _keyComic = false;
  List<SeriesRegistryEntry> _seriesEntries = const [];
  List<String> _crossoverOptions = const [];
  List<String> _storyArcOptions = const [];
  List<String> _countryOptions = const [];
  List<String> _languageOptions = const [];
  List<String> _ageOptions = const [];
  List<String> _genreOptions = const [];
  String? _selectedSeriesId;

  @override
  void initState() {
    super.initState();
    final item = widget.request.item;
    final owned = widget.request.ownedItem;
    final tracking = widget.request.trackingEntry;
    final publishing = item.publishing;
    _selectedSeriesId = item.series?.seriesId;

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
    final crossover = item.crossover?.trim();
    crossoverCtl = TextEditingController(
      text: crossover?.isNotEmpty == true ? crossover! : '',
    );
    storyArcsCtl = TextEditingController(
      text: (item.storyArcs ?? const <String>[]).join(', '),
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
    final decodedPlot = _decodePlotFields(
      item.plotSummary,
      item.plotDescription,
      item.synopsis,
    );
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
      _creators.add(_EditableComicCreator.fromMetadata(creator));
    }
    final characterDetails = item.characterDetails;
    if (characterDetails != null && characterDetails.isNotEmpty) {
      for (final character in characterDetails) {
        _characters.add(_EditableComicCharacter.fromMetadata(character));
      }
    } else {
      for (final character in item.characters ?? const <String>[]) {
        _characters.add(_EditableComicCharacter.custom(character));
      }
    }
    for (final link in item.trailerUrls) {
      links.add({
        'title': TextEditingController(text: link.title ?? link.source ?? ''),
        'url': TextEditingController(text: link.url),
      });
    }

    _loadSeriesOptions();
    _loadDetailPickListOptions();
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
    for (final creator in _creators) {
      creator.dispose();
    }
    for (final character in _characters) {
      character.dispose();
    }
    for (final link in links) {
      link['title']?.dispose();
      link['url']?.dispose();
    }
    super.dispose();
  }

  void _addCreator() {
    _creators.add(_EditableComicCreator.custom());
    setState(() {});
  }

  void _addCreatorWithRole(String role) {
    _creators.add(_EditableComicCreator.custom(role: role));
    setState(() {});
  }

  Future<void> _addCatalogCreator() async {
    final creator = await _showLookupDialog(
      title: 'Find creator',
      searchHint: 'Search creators',
      search: (query) => _lookupApi().searchCreators(query: query, limit: 24),
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
    if (creator == null) {
      return;
    }
    _creators.add(_EditableComicCreator.fromLookupResult(creator));
    setState(() {});
  }

  void _removeCreator(int idx) {
    final creator = _creators.removeAt(idx);
    creator.dispose();
    setState(() {});
  }

  void _addCharacter([String? value]) {
    final normalized = (value ?? characterDraftCtl.text).trim();
    if (normalized.isEmpty) {
      return;
    }
    final alreadyExists = _characters.any(
      (character) =>
          character.nameController.text.trim().toLowerCase() ==
          normalized.toLowerCase(),
    );
    if (alreadyExists) {
      characterDraftCtl.clear();
      return;
    }
    _characters.add(_EditableComicCharacter.custom(normalized));
    characterDraftCtl.clear();
    setState(() {});
  }

  Future<void> _addCatalogCharacter() async {
    final character = await _showLookupDialog(
      title: 'Find character',
      searchHint: 'Search characters',
      search: (query) => _lookupApi().searchCharacters(query: query, limit: 24),
      titleForResult: (result) => result['name']?.toString() ?? 'Character',
      subtitleForResult: (result) {
        final appearanceCount = (result['appearance_count'] as num?)?.toInt();
        final aliases = (result['aliases'] as List<dynamic>? ?? const [])
            .map((value) => value.toString().trim())
            .where((value) => value.isNotEmpty)
            .take(3)
            .toList(growable: false);
        return [
          if (appearanceCount != null) '$appearanceCount appearances',
          if (aliases.isNotEmpty) aliases.join(', '),
        ].join(' · ');
      },
    );
    if (character == null) {
      return;
    }
    final normalizedName = character['name']?.toString().trim() ?? '';
    if (normalizedName.isEmpty) {
      return;
    }
    final alreadyExists = _characters.any(
      (entry) =>
          entry.nameController.text.trim().toLowerCase() ==
          normalizedName.toLowerCase(),
    );
    if (alreadyExists) {
      return;
    }
    _characters.add(_EditableComicCharacter.fromLookupResult(character));
    setState(() {});
  }

  void _removeCharacter(int idx) {
    final character = _characters.removeAt(idx);
    character.dispose();
    setState(() {});
  }

  Future<void> _renameCharacter(int idx) async {
    final controller = TextEditingController(
      text: _characters[idx].nameController.text,
    );
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
    setState(() {
      _characters[idx].nameController.text = normalized;
      _characters[idx].markAsCustom();
    });
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

  Future<Map<String, dynamic>?> _showLookupDialog({
    required String title,
    required String searchHint,
    required Future<List<Map<String, dynamic>>> Function(String query) search,
    required String Function(Map<String, dynamic> result) titleForResult,
    required String Function(Map<String, dynamic> result) subtitleForResult,
  }) async {
    final searchCtl = TextEditingController();
    var results = const <Map<String, dynamic>>[];
    var isLoading = false;
    String? errorMessage;

    Future<void> runSearch(StateSetter setDialogState) async {
      setDialogState(() {
        isLoading = true;
        errorMessage = null;
      });
      try {
        final rows = await search(searchCtl.text.trim());
        setDialogState(() {
          results = rows;
          isLoading = false;
        });
      } catch (error) {
        setDialogState(() {
          errorMessage = error.toString();
          isLoading = false;
        });
      }
    }

    final selection = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 540,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchCtl,
                        decoration: InputDecoration(
                          labelText: searchHint,
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => runSearch(setDialogState),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => runSearch(setDialogState),
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Theme.of(dialogContext).colorScheme.error,
                    ),
                  )
                else if (results.isEmpty)
                  Text(
                    'Search the metadata catalog and add a result as a core entry.',
                    style: Theme.of(dialogContext).textTheme.bodySmall,
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (dialogContext, index) {
                        final result = results[index];
                        final subtitle = subtitleForResult(result).trim();
                        return ListTile(
                          title: Text(titleForResult(result)),
                          subtitle: subtitle.isEmpty
                              ? null
                              : Text(subtitle, maxLines: 2),
                          trailing: const Icon(Icons.add_circle_outline),
                          onTap: () => Navigator.of(dialogContext).pop(result),
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
        ),
      ),
    );
    searchCtl.dispose();
    return selection;
  }

  dynamic _lookupApi() {
    return ProviderScope.containerOf(context, listen: false)
        .read(apiClientProvider);
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

  Widget _labelledSingleValuePickField(
    String label, {
    required TextEditingController controller,
    required List<String> options,
    Key? key,
    ValueChanged<String?>? onChanged,
    VoidCallback? onManage,
    String? manageTooltip,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        SingleValuePickField(
          fieldKey: key,
          controller: controller,
          options: options,
          label: label,
          hint: hintText,
          onChanged: onChanged,
          onManage: onManage,
          manageTooltip: manageTooltip,
          showInlineLabel: false,
        ),
      ],
    );
  }

  Widget _labelledMultiValuePickField(
    String label, {
    required TextEditingController controller,
    required List<String> options,
    Key? key,
    VoidCallback? onManage,
    String? manageTooltip,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        _MultiValuePickField(
          fieldKey: key,
          controller: controller,
          options: options,
          label: label,
          hint: hintText,
          onManage: onManage,
          manageTooltip: manageTooltip,
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
    if (maxLines != 1) {
      return _labelledField(
        label,
        controller: controller,
        key: key,
        maxLines: maxLines,
        hintText: hintText,
      );
    }
    return SingleValuePickField(
      fieldKey: key,
      controller: controller,
      options: normalizedSuggestions,
      label: label,
      hint: hintText,
      onChanged: (_) => setState(() {}),
      showPickerListAction: normalizedSuggestions.isNotEmpty,
    );
  }

  Future<void> _loadSeriesOptions() async {
    final registry = SeriesRegistryRepository(ref.read(localDatabaseProvider));
    final entries = await registry.searchEntries(
      mediaKind: widget.request.type.workspace.kind.apiValue,
      selectedTitle: seriesCtl.text,
      selectedSeriesId: _selectedSeriesId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _seriesEntries = List<SeriesRegistryEntry>.from(entries);
    });
  }

  void _syncSelectedSeriesId(String? value) {
    final normalized = value?.trim();
    final matchingEntry = _seriesEntries.cast<SeriesRegistryEntry?>().firstWhere(
          (entry) =>
              entry != null &&
              entry.title.trim().toLowerCase() ==
                  (normalized?.toLowerCase() ?? ''),
          orElse: () => null,
        );
    setState(() {
      _selectedSeriesId = matchingEntry?.coreSeriesId;
    });
  }

  Future<void> _openSeriesPicker() async {
    final selected = await showSeriesPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      mediaKind: widget.request.type.workspace.kind.apiValue,
      selectedTitle: seriesCtl.text,
      selectedSeriesId: _selectedSeriesId,
    );
    if (!mounted || selected == null) {
      return;
    }
    _setControllerText(seriesCtl, selected.title);
    setState(() {
      _selectedSeriesId = selected.coreSeriesId;
    });
    await _loadSeriesOptions();
  }

  Future<void> _loadDetailPickListOptions() async {
    final mediaKind = widget.request.type.workspace.kind.apiValue;
    final db = ref.read(localDatabaseProvider);
    final results = await Future.wait<dynamic>([
      loadSingleValuePickListOptions(
        db,
        listName: kCrossoverPickListName,
        mediaKind: mediaKind,
        selectedValue: crossoverCtl.text,
      ),
      loadMultiValuePickListOptions(
        db,
        listName: kStoryArcPickListName,
        mediaKind: mediaKind,
        selectedValues: splitPickListValues(storyArcsCtl.text),
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kCountryPickListName,
        mediaKind: mediaKind,
        selectedValue: countryCtl.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kLanguagePickListName,
        mediaKind: mediaKind,
        selectedValue: languageCtl.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kAgeRatingPickListName,
        mediaKind: mediaKind,
        selectedValue: ageCtl.text,
      ),
      loadMultiValuePickListOptions(
        db,
        listName: kGenrePickListName,
        mediaKind: mediaKind,
        selectedValues: splitPickListValues(genresCtl.text),
      ),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _crossoverOptions = List<String>.from(results[0] as List<String>);
      _storyArcOptions = List<String>.from(results[1] as List<String>);
      _countryOptions = List<String>.from(results[2] as List<String>);
      _languageOptions = List<String>.from(results[3] as List<String>);
      _ageOptions = List<String>.from(results[4] as List<String>);
      _genreOptions = List<String>.from(results[5] as List<String>);
    });
  }

  Future<void> _manageDetailPickList({
    required String listName,
    required String label,
  }) async {
    await showPickListEditorDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      listName: listName,
      label: label,
      mediaKind: widget.request.type.workspace.kind.apiValue,
    );
    if (!mounted) {
      return;
    }
    await _loadDetailPickListOptions();
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

  (String, String) _decodePlotFields(
    String? summary,
    String? description,
    String? synopsis,
  ) {
    final normalizedSummary = summary?.trim() ?? '';
    final normalizedDescription = description?.trim() ?? '';
    if (normalizedSummary.isNotEmpty || normalizedDescription.isNotEmpty) {
      return (normalizedSummary, normalizedDescription);
    }
    return _decodePlotSynopsis(synopsis);
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
                      suggestions: _commonFormats,
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

  Widget _buildValueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
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
                              suggestions: _commonGrades,
                              key: const ValueKey('edit-grade')),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 5,
                          child: _buildQuickChoiceField('Raw / Slabbed',
                              controller: rawOrSlabbedCtl,
                              suggestions: _rawOrSlabbedOptions,
                              key: const ValueKey('edit-raw-slabbed')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
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
                                Wrap(
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
                    _labelledField('Signed by',
                        controller: signedByCtl,
                        key: const ValueKey('edit-signed-by')),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildQuickChoiceField('Grading Company',
                                controller: gradingCompanyCtl,
                                suggestions: _gradingCompanies,
                                key: const ValueKey('edit-grading-company'))),
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: _buildQuickChoiceField('Label Type',
                    controller: labelTypeCtl,
                    suggestions: _labelTypeOptions,
                    key: const ValueKey('edit-label-type')),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: _buildQuickChoiceField('Custom Label',
                    controller: customLabelCtl,
                    suggestions: _customLabelOptions,
                    key: const ValueKey('edit-custom-label')),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _buildQuickChoiceField('Page Quality',
                    controller: pageQualityCtl,
                    suggestions: _pageQualityOptions,
                    key: const ValueKey('edit-page-quality')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
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
          const SizedBox(height: 12),
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
              const SizedBox(width: 8),
              Expanded(
                  child: _buildQuickChoiceField('Purchase Store',
                      controller: purchaseStoreCtl,
                      suggestions: _purchaseStoreOptions,
                      key: const ValueKey('edit-purchase-store'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _labelledField('Cover Price',
                      controller: coverPriceCtl,
                      key: const ValueKey('edit-cover-price'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
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
              const SizedBox(width: 8),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
          const SizedBox(width: 12),
          Expanded(
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
        ],
      ),
    );
  }

  Widget _buildCustomFieldsTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Fields',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Edit user-defined metadata for this comic issue.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          CustomFieldsEditSection(
            definitions: widget.request.customFieldDefinitions,
            values: _customFieldValues,
            accent: widget.request.accent,
            onChanged: (values) => setState(() => _customFieldValues = values),
          ),
        ],
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _labelledField('Front Cover URL',
                    controller: coverUrlCtl,
                    key: const ValueKey('edit-cover-url')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
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
                        'Use the metadata cover for the primary front cover. Use My Images for front overrides, back covers, slab shots, signatures, and detail photos.',
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyImagesTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add your own images, set a caption, and choose the image type for signatures, slab shots, and detail photos.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ItemImagesEditSection(
            images: widget.request.itemImages,
            accent: widget.request.accent,
            onChanged: (edits) => setState(() => _itemImageEdits = edits),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorsTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FilledButton.icon(
                  onPressed: _addCreator,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Creator')),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _addCatalogCreator,
                icon: const Icon(Icons.manage_search_outlined),
                label: const Text('Find in Catalog'),
              ),
            ],
          ),
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
          if (_creators.isEmpty)
            Text(
              'No creators yet. Add the main credits here.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          for (var i = 0; i < _creators.length; i++)
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
                        const SizedBox(width: 8),
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(_creators[i].sourceLabel),
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
                                controller: _creators[i].nameController,
                                decoration:
                                    const InputDecoration(labelText: 'Name'),
                                key: ValueKey('edit-creator-$i-name'))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: TextField(
                                controller: _creators[i].roleController,
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
                                _creators[i].roleController.text = role;
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
          Text(
            'Add the main cast here. Core matches and manual entries are grouped together as editable chips.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
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
          OutlinedButton.icon(
            onPressed: _addCatalogCharacter,
            icon: const Icon(Icons.manage_search_outlined),
            label: const Text('Find in Catalog'),
          ),
          const SizedBox(height: 8),
          if (_characters.isEmpty)
            Text(
              'No characters yet. Add the main cast as quick chips.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _characters.length; i++)
                  InputChip(
                    key: ValueKey('edit-character-$i'),
                    avatar: Icon(
                      _characters[i].isCore
                          ? Icons.verified_outlined
                          : Icons.edit_outlined,
                      size: 18,
                    ),
                    label: Text(
                      '${_characters[i].nameController.text} · ${_characters[i].sourceLabel}',
                    ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Row(
            children: [
              FilledButton.icon(
                  onPressed: _addLink,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Link')),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < links.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
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
          LibraryEditMaterialTabBar(
            accent: widget.request.accent,
            tabs: const [
              Tab(child: EditTab(icon: Icons.book, label: 'Main')),
              Tab(child: EditTab(icon: Icons.search, label: 'Details')),
              Tab(child: EditTab(icon: Icons.attach_money, label: 'Value')),
              Tab(child: EditTab(icon: Icons.person, label: 'Personal')),
              Tab(child: EditTab(icon: Icons.edit, label: 'Custom Fields')),
              Tab(child: EditTab(icon: Icons.camera_alt, label: 'Covers')),
              Tab(child: EditTab(icon: Icons.image, label: 'My Images')),
              Tab(child: EditTab(icon: Icons.group, label: 'Creators')),
              Tab(child: EditTab(icon: Icons.face, label: 'Characters')),
              Tab(child: EditTab(icon: Icons.article, label: 'Plot')),
              Tab(child: EditTab(icon: Icons.link, label: 'Links')),
            ],
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
      'seriesId': _selectedSeriesId,
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
      'creators': _creators.map((creator) => creator.toMap()).toList(),
      'characters': _characters
          .map((character) => character.nameController.text)
          .toList(),
      'characterDetails':
          _characters.map((character) => character.toMap()).toList(),
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

class _EditableComicCreator {
  _EditableComicCreator({
    required this.nameController,
    required this.roleController,
    Map<String, dynamic>? metadata,
  }) : metadata = Map<String, dynamic>.from(metadata ?? const {});

  factory _EditableComicCreator.custom({String name = '', String role = ''}) {
    return _EditableComicCreator(
      nameController: TextEditingController(text: name),
      roleController: TextEditingController(text: role),
      metadata: const {'source_type': 'custom'},
    );
  }

  factory _EditableComicCreator.fromMetadata(Map<String, dynamic> metadata) {
    return _EditableComicCreator(
      nameController:
          TextEditingController(text: metadata['name']?.toString() ?? ''),
      roleController: TextEditingController(
        text: metadata['role']?.toString() ?? metadata['job']?.toString() ?? '',
      ),
      metadata: metadata,
    );
  }

  factory _EditableComicCreator.fromLookupResult(Map<String, dynamic> result) {
    return _EditableComicCreator(
      nameController:
          TextEditingController(text: result['name']?.toString() ?? ''),
      roleController: TextEditingController(),
      metadata: {
        ...result,
        'source_type': 'core',
      },
    );
  }

  final TextEditingController nameController;
  final TextEditingController roleController;
  final Map<String, dynamic> metadata;

  bool get isCore {
    final explicit = metadata['source_type']?.toString().trim().toLowerCase();
    if (explicit == 'core') {
      return true;
    }
    if (explicit == 'custom') {
      return false;
    }
    return metadata['id'] != null ||
        metadata['api_detail_url'] != null ||
        metadata['site_detail_url'] != null;
  }

  String get sourceLabel => isCore ? 'Core' : 'Custom';

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{
      ...metadata,
      'name': nameController.text.trim(),
      'role': roleController.text.trim(),
      'source_type': sourceLabel.toLowerCase(),
    };
    result.removeWhere(
      (key, value) =>
          value == null || (value is String && value.trim().isEmpty),
    );
    return result;
  }

  void dispose() {
    nameController.dispose();
    roleController.dispose();
  }
}

class _EditableComicCharacter {
  _EditableComicCharacter({
    required this.nameController,
    Map<String, dynamic>? metadata,
  }) : metadata = Map<String, dynamic>.from(metadata ?? const {});

  factory _EditableComicCharacter.custom(String name) {
    return _EditableComicCharacter(
      nameController: TextEditingController(text: name),
      metadata: const {'source_type': 'custom'},
    );
  }

  factory _EditableComicCharacter.fromMetadata(Map<String, dynamic> metadata) {
    return _EditableComicCharacter(
      nameController:
          TextEditingController(text: metadata['name']?.toString() ?? ''),
      metadata: metadata,
    );
  }

  factory _EditableComicCharacter.fromLookupResult(
      Map<String, dynamic> result) {
    return _EditableComicCharacter(
      nameController:
          TextEditingController(text: result['name']?.toString() ?? ''),
      metadata: {
        ...result,
        'source_type': 'core',
      },
    );
  }

  final TextEditingController nameController;
  final Map<String, dynamic> metadata;

  bool get isCore {
    final explicit = metadata['source_type']?.toString().trim().toLowerCase();
    if (explicit == 'core') {
      return true;
    }
    if (explicit == 'custom') {
      return false;
    }
    return metadata['id'] != null;
  }

  String get sourceLabel => isCore ? 'Core' : 'Custom';

  void markAsCustom() {
    metadata
      ..remove('id')
      ..remove('aliases')
      ..remove('image_url')
      ..remove('description')
      ..remove('first_appearance_item_id')
      ..remove('appearance_count')
      ..['source_type'] = 'custom';
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{
      ...metadata,
      'name': nameController.text.trim(),
      'source_type': sourceLabel.toLowerCase(),
    };
    result.removeWhere(
      (key, value) =>
          value == null || (value is String && value.trim().isEmpty),
    );
    return result;
  }

  void dispose() {
    nameController.dispose();
  }
}

class _MultiValuePickField extends StatefulWidget {
  const _MultiValuePickField({
    required this.controller,
    required this.options,
    required this.label,
    this.fieldKey,
    this.hint,
    this.onManage,
    this.manageTooltip,
  });

  final TextEditingController controller;
  final List<String> options;
  final String label;
  final Key? fieldKey;
  final String? hint;
  final VoidCallback? onManage;
  final String? manageTooltip;

  @override
  State<_MultiValuePickField> createState() => _MultiValuePickFieldState();
}

class _MultiValuePickFieldState extends State<_MultiValuePickField> {
  static const _suffixButtonExtent = 32.0;
  static const _suffixHorizontalPadding = 8.0;

  late final FocusNode _focusNode;
  final GlobalKey _fieldAnchorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  List<String> get _selectedValues => splitPickListValues(widget.controller.text);

  void _writeSelection(List<String> values) {
    final text = joinPickListValues(values) ?? '';
    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() {});
  }

  bool _containsSelection(List<String> values, String candidate) {
    final normalized = candidate.trim().toLowerCase();
    return values.any((value) => value.trim().toLowerCase() == normalized);
  }

  void _toggleValue(String option) {
    final current = List<String>.from(_selectedValues);
    if (_containsSelection(current, option)) {
      current.removeWhere(
        (value) => value.trim().toLowerCase() == option.trim().toLowerCase(),
      );
    } else {
      current.add(option);
    }
    _writeSelection(current);
    _focusNode.requestFocus();
  }

  Future<void> _openInlinePicker(List<String> options) async {
    if (options.isEmpty) {
      return;
    }
    final fieldBox =
        _fieldAnchorKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (fieldBox == null || overlayBox == null) {
      return;
    }
    final fieldOffset = fieldBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        fieldOffset.dx,
        fieldOffset.dy + fieldBox.size.height,
        overlayBox.size.width - fieldOffset.dx - fieldBox.size.width,
        overlayBox.size.height - fieldOffset.dy - fieldBox.size.height,
      ),
      constraints: BoxConstraints(
        minWidth: fieldBox.size.width,
        maxWidth: fieldBox.size.width,
        maxHeight: 280,
      ),
      items: [
        for (final option in options)
          PopupMenuItem<String>(
            value: option,
            child: Row(
              children: [
                Icon(
                  _containsSelection(_selectedValues, option)
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(option)),
              ],
            ),
          ),
      ],
    );
    if (!mounted || selected == null) {
      return;
    }
    _toggleValue(selected);
  }

  Widget _suffixAction({
    required String tooltip,
    required VoidCallback? onPressed,
    required IconData icon,
    bool showDivider = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDivider)
              Container(
                width: 1,
                height: 18,
                margin: const EdgeInsets.only(right: 4),
                color: Theme.of(context).dividerColor,
              ),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onPressed,
              child: SizedBox(
                width: _suffixButtonExtent,
                height: _suffixButtonExtent,
                child: Icon(icon, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final normalizedOptions = mergePickListValues(
      builtInValues: widget.options,
      selectedValues: _selectedValues,
    );
    final hasManageAction = widget.onManage != null;
    final actionCount = [
      if (normalizedOptions.isNotEmpty) true,
      if (hasManageAction) true,
    ].length;
    final suffixWidth =
        actionCount * _suffixButtonExtent + (_suffixHorizontalPadding * 2);
    return KeyedSubtree(
      key: _fieldAnchorKey,
      child: TextFormField(
        key: widget.fieldKey,
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.hint,
          suffixIconConstraints: BoxConstraints(
            minWidth: actionCount == 0 ? 0 : suffixWidth,
            maxWidth: actionCount == 0 ? 0 : suffixWidth,
            minHeight: 40,
          ),
          suffixIcon: actionCount == 0
              ? null
              : SizedBox(
                  width: suffixWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (normalizedOptions.isNotEmpty)
                        _suffixAction(
                          tooltip: 'Pick ${widget.label}',
                          onPressed: () => _openInlinePicker(normalizedOptions),
                          icon: Icons.arrow_drop_down,
                        ),
                      if (hasManageAction)
                        _suffixAction(
                          tooltip:
                              widget.manageTooltip ?? 'Manage ${widget.label}',
                          onPressed: widget.onManage,
                          icon: Icons.view_list_outlined,
                          showDivider: normalizedOptions.isNotEmpty,
                        ),
                    ],
                  ),
                ),
        ),
        onTap: () => setState(() {}),
        onChanged: (_) => setState(() {}),
      ),
    );
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
