import 'dart:async';
import 'dart:io';

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_editor_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/metadata/metadata_diff_panel.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/edit/library_edit_tab_strip.dart';
import 'package:collectarr_app/features/library/edit/text_controller_group.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_edit_image_sections.dart';
import 'package:collectarr_app/features/library/series/series_registry_dialog.dart';
import 'package:collectarr_app/features/library/series/series_registry_repository.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ComicEditPanel extends ConsumerStatefulWidget {
  const ComicEditPanel({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  ComicEditPanelState createState() => ComicEditPanelState();
}

class ComicEditPanelState extends ConsumerState<ComicEditPanel>
    with SingleTickerProviderStateMixin {
  static const String _tabOrderPreferenceKey = 'edit_tab_order_comic';
  static const List<Tab> _tabs = [
    Tab(child: EditTab(icon: Icons.search, label: 'Details')),
    Tab(child: EditTab(icon: Icons.book, label: 'Main')),
    Tab(child: EditTab(icon: Icons.attach_money, label: 'Value')),
    Tab(child: EditTab(icon: Icons.person, label: 'Personal')),
    Tab(child: EditTab(icon: Icons.edit, label: 'Custom Fields')),
    Tab(child: EditTab(icon: Icons.camera_alt, label: 'Covers')),
    Tab(child: EditTab(icon: Icons.image, label: 'My Images')),
    Tab(child: EditTab(icon: Icons.group, label: 'Creators')),
    Tab(child: EditTab(icon: Icons.face, label: 'Characters')),
    Tab(child: EditTab(icon: Icons.article, label: 'Plot')),
    Tab(child: EditTab(icon: Icons.link, label: 'Links')),
  ];

  static const List<String> _commonCreatorRoles = <String>[
    'Writer',
    'Artist',
    'Cover Artist',
    'Cover Penciller',
    'Cover Painter',
    'Cover Inker',
    'Cover Colorist',
    'Cover Separator',
    'Penciller',
    'Inker',
    'Colorist',
    'Painter',
    'Letterer',
    'Separator',
    'Layouts',
    'Translator',
    'Plotter',
    'Scripter',
    'Editor',
    'Editor in Chief',
  ];

  static const List<String> _collectionStatusOptions = <String>[
    'In Collection',
    'For Sale',
    'On Wish List',
    'On Order',
    'Sold',
    'Not in Collection',
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

  final TextControllerGroup _textControllers = TextControllerGroup();

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
  late final TextEditingController backCoverUrlCtl;
  late final TextEditingController collectionStatusCtl;
  late final TextEditingController indexNumberCtl;
  late final TextEditingController quantityCtl;
  late final TextEditingController locationCtl;
  late final TextEditingController characterDraftCtl;
  final List<_EditableComicCreator> _creators = [];
  final List<_EditableComicCharacter> _characters = [];
  final List<String> _signedByEntries = [];
  bool _isFetchingServerSnapshot = false;
  String? _serverSnapshotError;
  CatalogItem? _serverSnapshotItem;
  bool _didAutoOpenMetadataCompare = false;
  late final TextEditingController summaryCtl;
  late final TextEditingController descriptionCtl;
  final List<Map<String, TextEditingController>> links = [];
  late final TabController _tabController;
  late List<int> _tabOrder;

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

  TextEditingController _createController([String text = '']) {
    return _textControllers.create(text: text);
  }

  Map<String, TextEditingController> _createLinkControllers({
    String title = '',
    String url = '',
  }) {
    return {
      'title': _createController(title),
      'url': _createController(url),
    };
  }

  void _disposeLinkControllers(Map<String, TextEditingController> link) {
    _textControllers.disposeController(link['title']);
    _textControllers.disposeController(link['url']);
  }

  void _trackCreatorControllers(_EditableComicCreator creator) {
    _textControllers.track(creator.nameController);
    _textControllers.track(creator.roleController);
  }

  void _disposeCreator(_EditableComicCreator creator) {
    _textControllers.disposeController(creator.nameController);
    _textControllers.disposeController(creator.roleController);
  }

  void _trackCharacterControllers(_EditableComicCharacter character) {
    _textControllers.track(character.nameController);
    _textControllers.track(character.realNameController);
  }

  void _disposeCharacter(_EditableComicCharacter character) {
    _textControllers.disposeController(character.nameController);
    _textControllers.disposeController(character.realNameController);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabOrder = List<int>.generate(_tabs.length, (index) => index);
    final item = widget.request.item;
    final owned = widget.request.ownedItem;
    final tracking = widget.request.trackingEntry;
    final publishing = item.publishing;
    _selectedSeriesId = item.series?.seriesId;

    titleCtl = _createController(item.title);
    seriesCtl = _createController(item.series?.seriesTitle ?? '');
    barcodeCtl = _createController(item.barcode ?? '');
    formatCtl = _createController(item.physicalFormatLabel ?? '');
    seriesGroupCtl = _createController(publishing?.seriesGroup ?? '');
    issueNumberCtl = _createController(item.itemNumber ?? '');
    variantCtl = _createController(item.variant ?? '');
    variantDescCtl = _createController(item.editionTitle ?? '');
    coverDateCtl = _createController(
      item.coverDate == null ? '' : formatDate(item.coverDate!),
    );
    releaseDateCtl = _createController(
      item.releaseDate == null ? '' : formatDate(item.releaseDate!),
    );
    publisherCtl = _createController(item.publisher ?? '');
    imprintCtl = _createController(publishing?.imprint ?? '');
    subtitleCtl = _createController(item.titleExtension ?? '');
    final crossover = item.crossover?.trim();
    crossoverCtl =
        _createController(crossover?.isNotEmpty == true ? crossover! : '');
    storyArcsCtl =
        _createController((item.storyArcs ?? const <String>[]).join(', '));
    countryCtl = _createController(item.country ?? '');
    languageCtl = _createController(item.language ?? '');
    ageCtl = _createController(item.ageRating ?? '');
    pagesCtl = _createController(publishing?.pageCount?.toString() ?? '');
    genresCtl = _createController(item.genres?.join(', ') ?? '');
    purchasePriceCtl = _createController(
      owned?.pricePaidCents == null
          ? ''
          : (owned!.pricePaidCents! / 100).toStringAsFixed(2),
    );
    purchaseCurrencyCtl = _createController(owned?.currency ?? '');
    purchaseDateCtl = _createController(
      owned?.purchaseDate == null ? '' : formatDate(owned!.purchaseDate!),
    );
    currentValueCtl = _createController(
      owned?.marketValueCents == null
          ? ''
          : (owned!.marketValueCents! / 100).toStringAsFixed(2),
    );
    gradeCtl = _createController(owned?.grade ?? '');
    coverPriceCtl = _createController(
      owned?.coverPriceCents == null
          ? ''
          : (owned!.coverPriceCents! / 100).toStringAsFixed(2),
    );
    soldPriceCtl = _createController(
      owned?.sellPriceCents == null
          ? ''
          : (owned!.sellPriceCents! / 100).toStringAsFixed(2),
    );
    soldDateCtl = _createController(
      owned?.soldAt == null ? '' : formatDate(owned!.soldAt!),
    );
    purchaseStoreCtl = _createController(owned?.purchaseStore ?? '');
    rawOrSlabbedCtl = _createController(owned?.rawOrSlabbed ?? '');
    gradingCompanyCtl = _createController(owned?.gradingCompany ?? '');
    labelTypeCtl = _createController(owned?.labelType ?? '');
    customLabelCtl = _createController(owned?.customLabel ?? '');
    pageQualityCtl = _createController(owned?.pageQuality ?? '');
    certificationNumberCtl =
        _createController(owned?.certificationNumber ?? '');
    graderNotesCtl = _createController(owned?.graderNotes ?? '');
    signedByCtl = _createController(owned?.signedBy ?? '');
    keyReasonCtl = _createController(owned?.keyReason ?? '');
    keyCategoryCtl = _createController(owned?.keyCategory ?? '');
    keySeverityCtl = _createController(owned?.keySeverity ?? '');
    statusCtl = _createController(
      tracking?.statusStorageValue ?? owned?.readStatus ?? '',
    );
    ratingCtl = _createController(
      tracking?.rating?.toString() ?? owned?.rating?.toString() ?? '',
    );
    ownerCtl = _createController(owned?.ownerLabel ?? '');
    readDateCtl = _createController(
      tracking?.finishedAt == null && owned?.finishedAt == null
          ? ''
          : formatDate(tracking?.finishedAt ?? owned!.finishedAt!),
    );
    bagBoardDateCtl = _createController(
      owned?.lastBagBoardDate == null
          ? ''
          : formatDate(owned!.lastBagBoardDate!),
    );
    tagsCtl = _createController(owned?.tags ?? '');
    notesCtl = _createController(owned?.personalNotes ?? '');
    coverUrlCtl =
        _createController(item.coverImageUrl ?? item.thumbnailImageUrl ?? '');
    backCoverUrlCtl = _createController('');
    collectionStatusCtl =
        _createController(owned?.collectionStatus ?? 'In Collection');

    indexNumberCtl = _createController(
      owned?.indexNumber?.toString() ?? '',
    );
    quantityCtl = _createController(
      (owned?.quantity ?? 1).toString(),
    );
    locationCtl = _createController(owned?.storageDevice ?? '');
    characterDraftCtl = _createController();
    final decodedPlot = _decodePlotFields(
      item.plotSummary,
      item.plotDescription,
      item.synopsis,
    );
    final combinedPlot = [decodedPlot.$1, decodedPlot.$2]
        .where((s) => s.isNotEmpty)
        .join('\n\n');
    summaryCtl = _createController(combinedPlot);
    descriptionCtl = _createController('');
    _keyComic = owned?.keyComic ?? false;
    _customFieldValues = {
      for (final definition in widget.request.customFieldDefinitions)
        definition.id: widget.request.customFieldValues
            .where((value) => value.fieldDefinitionId == definition.id)
            .map((value) => value.value)
            .firstOrNull,
    };

    for (final creator in item.creators ?? const <Map<String, dynamic>>[]) {
      final editableCreator = _EditableComicCreator.fromMetadata(creator);
      _trackCreatorControllers(editableCreator);
      _creators.add(editableCreator);
    }
    final characterDetails = item.characterDetails;
    if (characterDetails != null && characterDetails.isNotEmpty) {
      for (final character in characterDetails) {
        final editableCharacter =
            _EditableComicCharacter.fromMetadata(character);
        _trackCharacterControllers(editableCharacter);
        _characters.add(editableCharacter);
      }
    } else {
      for (final character in item.characters ?? const <String>[]) {
        final editableCharacter = _EditableComicCharacter.custom(character);
        _trackCharacterControllers(editableCharacter);
        _characters.add(editableCharacter);
      }
    }
    final signedByText = (owned?.signedBy ?? '').trim();
    if (signedByText.isNotEmpty) {
      _signedByEntries.addAll(
        signedByText.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty),
      );
    }
    for (final link in item.trailerUrls) {
      links.add(
        _createLinkControllers(
          title: link.title ?? link.source ?? '',
          url: link.url,
        ),
      );
    }

    _loadSeriesOptions();
    _loadDetailPickListOptions();
    _loadSavedTabOrder();
  }

  Future<void> _loadSavedTabOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_tabOrderPreferenceKey);
      if (saved == null || saved.length != _tabs.length) {
        return;
      }
      final parsed = saved.map(int.tryParse).toList();
      if (parsed.contains(null)) {
        return;
      }
      final order = parsed.cast<int>();
      final sorted = List<int>.from(order)..sort();
      final isPermutation = sorted.length == _tabs.length &&
          sorted.indexed.every((entry) => entry.$1 == entry.$2);
      if (!isPermutation || !mounted) {
        return;
      }
      setState(() {
        _tabOrder = order;
      });
    } finally {
      _autoOpenMetadataCompareIfRequested();
    }
  }

  void _autoOpenMetadataCompareIfRequested() {
    if (_didAutoOpenMetadataCompare ||
        !widget.request.openMetadataCompareOnOpen ||
        !mounted) {
      return;
    }
    _didAutoOpenMetadataCompare = true;
    final creatorsTabIndex = _tabOrder.indexOf(7);
    if (creatorsTabIndex >= 0) {
      _tabController.animateTo(creatorsTabIndex);
    }
    unawaited(_compareWithServerSnapshot());
  }

  Future<void> _saveTabOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _tabOrderPreferenceKey,
      _tabOrder.map((index) => index.toString()).toList(),
    );
  }

  void _onReorderTab(int oldIndex, int newIndex) {
    final currentTab = _tabController.index < _tabOrder.length
        ? _tabOrder[_tabController.index]
        : null;
    setState(() {
      final moved = _tabOrder.removeAt(oldIndex);
      _tabOrder.insert(newIndex, moved);
    });
    unawaited(_saveTabOrder());
    if (currentTab == null) {
      return;
    }
    final nextIndex = _tabOrder.indexOf(currentTab);
    if (nextIndex >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _tabController.animateTo(nextIndex);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textControllers.dispose();
    super.dispose();
  }

  void _addCreator() {
    final creator = _EditableComicCreator.custom();
    _trackCreatorControllers(creator);
    _creators.add(creator);
    setState(() {});
  }

  void _addCreatorWithRole(String role) {
    final creator = _EditableComicCreator.custom(role: role);
    _trackCreatorControllers(creator);
    _creators.add(creator);
    setState(() {});
  }

  Future<void> _addCatalogCreator() async {
    final api = ref.read(apiClientProvider);
    final creator = await _showLookupDialog(
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
    if (creator == null) {
      return;
    }
    final editableCreator = _EditableComicCreator.fromLookupResult(creator);
    _trackCreatorControllers(editableCreator);
    _creators.add(editableCreator);
    setState(() {});
  }

  void _removeCreator(int idx) {
    final creator = _creators.removeAt(idx);
    _disposeCreator(creator);
    setState(() {});
  }

  void _reorderCreator(int oldIndex, int newIndex) {
    final item = _creators.removeAt(oldIndex);
    _creators.insert(newIndex, item);
    setState(() {});
  }

  Future<void> _lookupCreatorForRow(int idx) async {
    final api = ref.read(apiClientProvider);
    final result = await _showLookupDialog(
      title: 'Find creator',
      searchHint: 'Search creators',
      search: (query) => api.searchCreators(query: query, limit: 24),
      titleForResult: (r) => r['name']?.toString() ?? 'Creator',
      subtitleForResult: (r) {
        final count = (r['item_count'] as num?)?.toInt();
        final desc = r['description']?.toString().trim();
        return [
          if (count != null) '$count credits',
          if (desc != null && desc.isNotEmpty) desc,
        ].join(' · ');
      },
    );
    if (result == null || !mounted) return;
    final role = result['role']?.toString().trim().isNotEmpty == true
        ? result['role']!.toString().trim()
        : result['job']?.toString().trim().isNotEmpty == true
            ? result['job']!.toString().trim()
            : '';
    setState(() {
      _creators[idx].nameController.text = result['name']?.toString() ?? '';
      if (role.isNotEmpty) {
        _creators[idx].roleController.text = role;
      }
      _creators[idx].metadata
        ..addAll(result)
        ..['source_type'] = 'core';
    });
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
    final character = _EditableComicCharacter.custom(normalized);
    _trackCharacterControllers(character);
    _characters.add(character);
    characterDraftCtl.clear();
    setState(() {});
  }

  Future<void> _addCatalogCharacter() async {
    final api = ref.read(apiClientProvider);
    final character = await _showLookupDialog(
      title: 'Find character',
      searchHint: 'Search characters',
      search: (query) => api.searchCharacters(query: query, limit: 24),
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
    final editableCharacter =
        _EditableComicCharacter.fromLookupResult(character);
    _trackCharacterControllers(editableCharacter);
    _characters.add(editableCharacter);
    setState(() {});
  }

  void _removeCharacter(int idx) {
    final character = _characters.removeAt(idx);
    _disposeCharacter(character);
    setState(() {});
  }

  void _reorderCharacter(int oldIndex, int newIndex) {
    final item = _characters.removeAt(oldIndex);
    _characters.insert(newIndex, item);
    setState(() {});
  }

  void _addLink() {
    links.add(_createLinkControllers());
    setState(() {});
  }

  void _removeLink(int idx) {
    final link = links.removeAt(idx);
    _disposeLinkControllers(link);
    setState(() {});
  }

  void _reorderLink(int oldIndex, int newIndex) {
    final item = links.removeAt(oldIndex);
    links.insert(newIndex, item);
    setState(() {});
  }

  Future<void> _pickCoverImage(TextEditingController controller) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
    );
    if (file == null || !mounted) return;
    controller.text = File(file.path).uri.toString();
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
        builder: (dialogContext, setDialogState) => AccentAlertDialog(
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

  Future<void> _compareWithServerSnapshot() async {
    if (_isFetchingServerSnapshot) {
      return;
    }
    setState(() {
      _isFetchingServerSnapshot = true;
      _serverSnapshotError = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final serverItem = await api.getMetadataItem(
        kind: widget.request.item.kind,
        id: widget.request.item.id,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _serverSnapshotItem = serverItem;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _serverSnapshotError = _metadataCompareErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingServerSnapshot = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _serverCreators {
    return _serverSnapshotItem?.creators ?? const <Map<String, dynamic>>[];
  }

  String _metadataCompareErrorMessage(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 422) {
        return 'Server rejected this compare request (422). '
            'This item likely has an unsupported metadata id format.';
      }
      final body = error.response?.data;
      if (body is Map<String, dynamic>) {
        final detail = body['detail']?.toString().trim();
        if (detail != null && detail.isNotEmpty) {
          return 'Could not load server metadata: $detail';
        }
      }
      if (statusCode != null) {
        return 'Could not load server metadata (HTTP $statusCode).';
      }
    }
    return 'Could not load the current metadata snapshot from the server.';
  }

  List<Map<String, dynamic>> get _serverCharacters {
    final details = _serverSnapshotItem?.characterDetails;
    if (details != null && details.isNotEmpty) {
      return details;
    }

    return [
      for (final name in _serverSnapshotItem?.characters ?? const <String>[])
        <String, dynamic>{'name': name}
    ];
  }

  String _diffText(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? '—' : normalized;
  }

  String _diffDate(DateTime? value) {
    return value == null ? '—' : formatDate(value);
  }

  String _diffList(Iterable<String>? values) {
    if (values == null) {
      return '—';
    }
    final normalized = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (normalized.isEmpty) {
      return '—';
    }
    return normalized.join(', ');
  }

  List<MetadataDiffEntry> _comicMetadataDiffEntries(CatalogItem serverItem) {
    return [
      MetadataDiffEntry(
        label: 'Title',
        localValue: _diffText(titleCtl.text),
        serverValue: _diffText(serverItem.title),
      ),
      MetadataDiffEntry(
        label: 'Series',
        localValue: _diffText(seriesCtl.text),
        serverValue: _diffText(serverItem.series?.seriesTitle),
      ),
      MetadataDiffEntry(
        label: 'Issue number',
        localValue: _diffText(issueNumberCtl.text),
        serverValue: _diffText(serverItem.itemNumber),
      ),
      MetadataDiffEntry(
        label: 'Variant',
        localValue: _diffText(variantCtl.text),
        serverValue: _diffText(serverItem.variant),
      ),
      MetadataDiffEntry(
        label: 'Edition / variant title',
        localValue: _diffText(variantDescCtl.text),
        serverValue: _diffText(serverItem.editionTitle),
      ),
      MetadataDiffEntry(
        label: 'Format',
        localValue: _diffText(formatCtl.text),
        serverValue: _diffText(serverItem.physicalFormatLabel),
      ),
      MetadataDiffEntry(
        label: 'Publisher',
        localValue: _diffText(publisherCtl.text),
        serverValue: _diffText(serverItem.publisher),
      ),
      MetadataDiffEntry(
        label: 'Imprint',
        localValue: _diffText(imprintCtl.text),
        serverValue: _diffText(serverItem.publishing?.imprint),
      ),
      MetadataDiffEntry(
        label: 'Cover date',
        localValue: _diffText(coverDateCtl.text),
        serverValue: _diffDate(serverItem.coverDate),
      ),
      MetadataDiffEntry(
        label: 'Release date',
        localValue: _diffText(releaseDateCtl.text),
        serverValue: _diffDate(serverItem.releaseDate),
      ),
      MetadataDiffEntry(
        label: 'Country',
        localValue: _diffText(countryCtl.text),
        serverValue: _diffText(serverItem.country),
      ),
      MetadataDiffEntry(
        label: 'Language',
        localValue: _diffText(languageCtl.text),
        serverValue: _diffText(serverItem.language),
      ),
      MetadataDiffEntry(
        label: 'Age rating',
        localValue: _diffText(ageCtl.text),
        serverValue: _diffText(serverItem.ageRating),
      ),
      MetadataDiffEntry(
        label: 'Page count',
        localValue: _diffText(pagesCtl.text),
        serverValue: _diffText(serverItem.publishing?.pageCount?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Genres',
        localValue: _diffText(genresCtl.text),
        serverValue: _diffList(serverItem.genres),
      ),
      MetadataDiffEntry(
        label: 'Story arcs',
        localValue: _diffText(storyArcsCtl.text),
        serverValue: _diffList(serverItem.storyArcs),
      ),
      MetadataDiffEntry(
        label: 'Crossover',
        localValue: _diffText(crossoverCtl.text),
        serverValue: _diffText(serverItem.crossover),
      ),
      MetadataDiffEntry(
        label: 'Barcode',
        localValue: _diffText(barcodeCtl.text),
        serverValue: _diffText(serverItem.barcode),
      ),
      MetadataDiffEntry(
        label: 'Plot summary',
        localValue: _diffText(summaryCtl.text),
        serverValue: _diffText(serverItem.plotSummary),
      ),
    ];
  }

  Widget _buildServerSnapshotDiffSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed:
              _isFetchingServerSnapshot ? null : _compareWithServerSnapshot,
          icon: _isFetchingServerSnapshot
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.compare_arrows, size: 16),
          label: const Text('Compare full item with server'),
        ),
        if (_serverSnapshotError != null) ...[
          const SizedBox(height: 6),
          Text(
            _serverSnapshotError!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.redAccent),
          ),
        ],
        if (_serverSnapshotItem != null) ...[
          const SizedBox(height: 8),
          MetadataDiffPanel(
            title: 'Metadata fields diff (Local vs Server)',
            entries: _comicMetadataDiffEntries(_serverSnapshotItem!),
            emptyText: 'No field-level differences found.',
          ),
          const SizedBox(height: 8),
          MetadataDiffPanel(
            title: 'Creators diff (Local vs Server)',
            entries: [
              for (var index = 0;
                  index <
                      (_creators.length > _serverCreators.length
                          ? _creators.length
                          : _serverCreators.length);
                  index++)
                MetadataDiffEntry(
                  label: 'Creator #${index + 1}',
                  localValue: _creatorText(
                    index < _creators.length ? _creators[index].toMap() : null,
                  ),
                  serverValue: _creatorText(
                    index < _serverCreators.length
                        ? _serverCreators[index]
                        : null,
                  ),
                  onAccept: index < _serverCreators.length
                      ? () => _applyServerCreatorAt(index)
                      : null,
                ),
            ],
            onAcceptAll:
                _serverCreators.isEmpty ? null : _applyAllServerCreators,
          ),
          const SizedBox(height: 8),
          MetadataDiffPanel(
            title: 'Characters diff (Local vs Server)',
            entries: [
              for (var index = 0;
                  index <
                      (_characters.length > _serverCharacters.length
                          ? _characters.length
                          : _serverCharacters.length);
                  index++)
                MetadataDiffEntry(
                  label: 'Character #${index + 1}',
                  localValue: _characterText(
                    index < _characters.length
                        ? _characters[index].toMap()
                        : null,
                  ),
                  serverValue: _characterText(
                    index < _serverCharacters.length
                        ? _serverCharacters[index]
                        : null,
                  ),
                  onAccept: index < _serverCharacters.length
                      ? () => _applyServerCharacterAt(index)
                      : null,
                ),
            ],
            onAcceptAll:
                _serverCharacters.isEmpty ? null : _applyAllServerCharacters,
          ),
        ],
      ],
    );
  }

  String _creatorText(Map<String, dynamic>? value) {
    if (value == null) {
      return '';
    }
    final role = value['role']?.toString().trim();
    final name = value['name']?.toString().trim();
    if (name == null || name.isEmpty) {
      return role ?? '';
    }
    if (role == null || role.isEmpty) {
      return name;
    }
    return '$role - $name';
  }

  String _characterText(Map<String, dynamic>? value) {
    if (value == null) {
      return '';
    }
    final name = value['name']?.toString().trim();
    final realName = value['real_name']?.toString().trim();
    if (name == null || name.isEmpty) {
      return realName ?? '';
    }
    if (realName == null || realName.isEmpty) {
      return name;
    }
    return '$name ($realName)';
  }

  void _applyServerCreatorAt(int index) {
    if (index < 0 || index >= _serverCreators.length) {
      return;
    }
    final next = _EditableComicCreator.fromMetadata(
      Map<String, dynamic>.from(_serverCreators[index])
        ..['source_type'] = 'core',
    );
    _trackCreatorControllers(next);
    setState(() {
      if (index < _creators.length) {
        final existing = _creators[index];
        _creators[index] = next;
        _disposeCreator(existing);
      } else {
        _creators.add(next);
      }
    });
  }

  void _applyAllServerCreators() {
    final incoming = [
      for (final creator in _serverCreators)
        _EditableComicCreator.fromMetadata(
          Map<String, dynamic>.from(creator)..['source_type'] = 'core',
        ),
    ];
    for (final creator in incoming) {
      _trackCreatorControllers(creator);
    }
    setState(() {
      for (final creator in _creators) {
        _disposeCreator(creator);
      }
      _creators
        ..clear()
        ..addAll(incoming);
    });
  }

  void _applyServerCharacterAt(int index) {
    if (index < 0 || index >= _serverCharacters.length) {
      return;
    }
    final next = _EditableComicCharacter.fromMetadata(
      Map<String, dynamic>.from(_serverCharacters[index])
        ..['source_type'] = 'core',
    );
    _trackCharacterControllers(next);
    setState(() {
      if (index < _characters.length) {
        final existing = _characters[index];
        _characters[index] = next;
        _disposeCharacter(existing);
      } else {
        _characters.add(next);
      }
    });
  }

  void _applyAllServerCharacters() {
    final incoming = [
      for (final character in _serverCharacters)
        _EditableComicCharacter.fromMetadata(
          Map<String, dynamic>.from(character)..['source_type'] = 'core',
        ),
    ];
    for (final character in incoming) {
      _trackCharacterControllers(character);
    }
    setState(() {
      for (final character in _characters) {
        _disposeCharacter(character);
      }
      _characters
        ..clear()
        ..addAll(incoming);
    });
  }

  Widget _labelledField(
    String label, {
    TextEditingController? controller,
    Key? key,
    int maxLines = 1,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      key: key,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
      ),
    );
  }

  Widget _labelledDateField(
    String label, {
    required TextEditingController controller,
    Key? key,
  }) {
    return _StructuredDateField(
      controller: controller,
      fieldKey: key,
      label: label,
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
    return SingleValuePickField(
      fieldKey: key,
      controller: controller,
      options: options,
      label: label,
      hint: hintText,
      onChanged: onChanged,
      onManage: onManage,
      manageTooltip: manageTooltip,
      showInlineLabel: true,
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
    return _MultiValuePickField(
      fieldKey: key,
      controller: controller,
      options: options,
      label: label,
      hint: hintText,
      onManage: onManage,
      manageTooltip: manageTooltip,
    );
  }

  Widget _buildSectionCard(
    String title, {
    required Widget child,
    String? description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final hint = Theme.of(context).hintColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: hint,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: hint,
                  ),
            ),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
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
    final matchingEntry =
        _seriesEntries.cast<SeriesRegistryEntry?>().firstWhere(
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

  Widget _buildRawSlabbedSegment() {
    final current = _rawOrSlabbedOptions.contains(rawOrSlabbedCtl.text.trim())
        ? rawOrSlabbedCtl.text.trim()
        : 'Raw';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Raw / Slabbed',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(value: 'Raw', label: Text('Raw')),
            ButtonSegment<String>(value: 'Slabbed', label: Text('Slabbed')),
            ButtonSegment<String>(
                value: 'Raw + Signed', label: Text('Raw + Signed')),
          ],
          selected: {current},
          onSelectionChanged: (selection) {
            _setControllerText(rawOrSlabbedCtl, selection.firstOrNull ?? 'Raw');
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildSignedBySection() {
    final draftCtl = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Signed by', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        for (var i = 0; i < _signedByEntries.length; i++)
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.drag_handle,
                    size: 18, color: Theme.of(context).hintColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _signedByEntries[i],
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    setState(() => _signedByEntries.removeAt(i));
                  },
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Remove',
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: draftCtl,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Add signer name',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (value) {
                  final name = value.trim();
                  if (name.isNotEmpty) {
                    setState(() => _signedByEntries.add(name));
                    draftCtl.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () {
                final name = draftCtl.text.trim();
                if (name.isNotEmpty) {
                  setState(() => _signedByEntries.add(name));
                  draftCtl.clear();
                }
              },
              tooltip: 'Add',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadStatusSection() {
    final currentStatus = _statusOptions.contains(statusCtl.text.trim())
        ? statusCtl.text.trim()
        : 'Unread';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Read', style: const TextStyle(fontWeight: FontWeight.w700)),
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
                                suggestions: _commonGrades,
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
                                  suggestions: _gradingCompanies,
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
                                  suggestions: _purchaseStoreOptions,
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

  Widget _buildPersonalTab() {
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
    final backCoverUrl = backCoverUrlCtl.text.trim();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Front cover column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Front Cover',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _coverAction(
                      icon: Icons.search,
                      label: 'Find Online',
                      onPressed: () =>
                          launchEbaySearch(_buildMarketSearchQuery()),
                    ),
                    _coverAction(
                      icon: Icons.upload_outlined,
                      label: 'Upload',
                      onPressed: () => _pickCoverImage(coverUrlCtl),
                    ),
                    _coverAction(
                      icon: Icons.delete_outline,
                      label: 'Remove',
                      onPressed: coverUrl.isEmpty
                          ? null
                          : () {
                              coverUrlCtl.clear();
                              setState(() {});
                            },
                    ),
                    _coverAction(
                      icon: Icons.restore,
                      label: 'Restore',
                      onPressed:
                          (widget.request.item.coverImageUrl ?? '').isEmpty
                              ? null
                              : () {
                                  _setControllerText(
                                    coverUrlCtl,
                                    widget.request.item.coverImageUrl ?? '',
                                  );
                                  setState(() {});
                                },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _coverPreview(coverUrl),
                const SizedBox(height: 8),
                TextField(
                  controller: coverUrlCtl,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    labelText: 'Cover URL',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  key: const ValueKey('edit-cover-url'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Back cover column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Back Cover',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _coverAction(
                      icon: Icons.upload_outlined,
                      label: 'Upload',
                      onPressed: () => _pickCoverImage(backCoverUrlCtl),
                    ),
                    _coverAction(
                      icon: Icons.delete_outline,
                      label: 'Remove',
                      onPressed: backCoverUrl.isEmpty
                          ? null
                          : () {
                              backCoverUrlCtl.clear();
                              setState(() {});
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _coverPreview(backCoverUrl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverPreview(String url) {
    final isFileUri = url.startsWith('file://');
    return AspectRatio(
      aspectRatio: 0.65,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: url.isNotEmpty
            ? (isFileUri
                ? Image.file(File.fromUri(Uri.parse(url)),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image_outlined, size: 48)))
                : Image.network(url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image_outlined, size: 48))))
            : Center(
                child: Icon(Icons.image_outlined,
                    size: 48, color: Theme.of(context).hintColor)),
      ),
    );
  }

  Widget _coverAction({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        textStyle: const TextStyle(fontSize: 12),
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(icon, size: 14),
      label: Text(label),
    );
  }

  Widget _buildMyImagesTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ComicPhotosWorkflowText(
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FilledButton.icon(
                onPressed: _addCreator,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: _addCatalogCreator,
                icon: const Icon(Icons.person_search_outlined, size: 16),
                label: const Text('Find in Catalog'),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                tooltip: 'Add by role',
                itemBuilder: (_) => [
                  for (final role in _commonCreatorRoles)
                    PopupMenuItem(
                      value: role,
                      height: kLibraryToolbarPopupItemHeight,
                      child: Text(role),
                    ),
                ],
                onSelected: _addCreatorWithRole,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildServerSnapshotDiffSection(),
          if (_creators.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Creators is empty',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
              ),
            ),
          if (_creators.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorderItem: _reorderCreator,
              itemCount: _creators.length,
              buildDefaultDragHandles: false,
              proxyDecorator: (child, _, __) => Material(
                elevation: 2,
                child: child,
              ),
              itemBuilder: (context, i) => Container(
                key: ValueKey(_creators[i]),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: i,
                      child: Icon(Icons.drag_handle,
                          size: 20, color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 140,
                      child: Builder(
                        builder: (context) {
                          final currentRole =
                              _creators[i].roleController.text.trim();
                          final roles = <String>[
                            if (currentRole.isNotEmpty &&
                                !_commonCreatorRoles.contains(currentRole))
                              currentRole,
                            ..._commonCreatorRoles,
                          ];
                          return DropdownButtonFormField<String>(
                            initialValue:
                                currentRole.isEmpty ? null : currentRole,
                            isDense: true,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              hintText: 'Job',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 12),
                            items: [
                              for (final role in roles)
                                DropdownMenuItem(
                                    value: role, child: Text(role)),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                _creators[i].roleController.text = v;
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _creators[i].nameController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Name',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_search, size: 18),
                      onPressed: () => _lookupCreatorForRow(i),
                      tooltip: 'Lookup',
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => _removeCreator(i),
                      tooltip: 'Remove',
                      visualDensity: VisualDensity.compact,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: characterDraftCtl,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Character name',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addCharacter(),
                ),
              ),
              const SizedBox(width: 6),
              FilledButton.icon(
                onPressed: _addCharacter,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: _addCatalogCharacter,
                icon: const Icon(Icons.person_search_outlined, size: 16),
                label: const Text('Find in Catalog'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildServerSnapshotDiffSection(),
          if (_characters.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Characters is empty',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
              ),
            ),
          if (_characters.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorderItem: _reorderCharacter,
              itemCount: _characters.length,
              buildDefaultDragHandles: false,
              proxyDecorator: (child, _, __) => Material(
                elevation: 2,
                child: child,
              ),
              itemBuilder: (context, i) => Container(
                key: ValueKey(_characters[i]),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: i,
                      child: Icon(Icons.drag_handle,
                          size: 20, color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _characters[i].nameController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Character name',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _characters[i].realNameController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Real name',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => _removeCharacter(i),
                      tooltip: 'Remove',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
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
          Expanded(
            child: TextField(
              controller: summaryCtl,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Plot / Synopsis',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(),
              ),
              key: const ValueKey('edit-plot'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                const SizedBox(width: 28),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text('Title',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: Text('URL',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),
          if (links.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No links added yet',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
              ),
            ),
          if (links.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorderItem: _reorderLink,
              itemCount: links.length,
              buildDefaultDragHandles: false,
              proxyDecorator: (child, _, __) => Material(
                elevation: 2,
                child: child,
              ),
              itemBuilder: (context, i) => Container(
                key: ValueKey(links[i]),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Theme.of(context).dividerColor),
                    right: BorderSide(color: Theme.of(context).dividerColor),
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: i,
                      child: Icon(Icons.drag_handle,
                          size: 20, color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: links[i]['title'],
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Link title',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: links[i]['url'],
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'https://',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => _removeLink(i),
                      tooltip: 'Remove',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _addLink,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Link'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final views = <Widget>[
      _buildDetailsTab(),
      _buildMainTab(context),
      _buildValueTab(),
      _buildPersonalTab(),
      _buildCustomFieldsTab(),
      _buildCoversTab(),
      _buildMyImagesTab(),
      _buildCreatorsTab(),
      _buildCharactersTab(),
      _buildPlotTab(),
      _buildLinksTab(),
    ];
    return Column(
      children: [
        LibraryEditMaterialTabBar(
          accent: widget.request.accent,
          tabController: _tabController,
          allowReorder: true,
          onReorderItem: _onReorderTab,
          tabs: [for (final index in _tabOrder) _tabs[index]],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [for (final index in _tabOrder) views[index]],
          ),
        ),
        _buildPreFooter(context),
      ],
    );
  }

  Widget _buildPreFooter(BuildContext context) {
    final currentStatus =
        _collectionStatusOptions.contains(collectionStatusCtl.text.trim())
            ? collectionStatusCtl.text.trim()
            : 'In Collection';
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: _preFooterDropdown(
              context,
              label: 'Collection Status',
              value: currentStatus,
              options: _collectionStatusOptions,
              onChanged: (v) {
                _setControllerText(collectionStatusCtl, v);
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _preFooterField(
              label: 'Index',
              controller: indexNumberCtl,
              key: const ValueKey('edit-index-number'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _preFooterField(
              label: 'Quantity',
              controller: quantityCtl,
              key: const ValueKey('edit-quantity'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: _preFooterField(
              label: 'Location',
              controller: locationCtl,
              key: const ValueKey('edit-storage-box'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _preFooterDropdown(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: value,
          isDense: true,
          isExpanded: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 13),
          items: [
            for (final opt in options)
              DropdownMenuItem(value: opt, child: Text(opt)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }

  Widget _preFooterField({
    required String label,
    required TextEditingController controller,
    required ValueKey<String> key,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          key: key,
        ),
      ],
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
      'signedBy': _signedByEntries.join(', '),
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
      'collectionStatus': collectionStatusCtl.text,
      'indexNumber': indexNumberCtl.text,
      'quantity': quantityCtl.text,
      'location': locationCtl.text,
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
    final role = result['role']?.toString().trim().isNotEmpty == true
        ? result['role']!.toString().trim()
        : result['job']?.toString().trim().isNotEmpty == true
            ? result['job']!.toString().trim()
            : '';
    return _EditableComicCreator(
      nameController:
          TextEditingController(text: result['name']?.toString() ?? ''),
      roleController: TextEditingController(text: role),
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
    required this.realNameController,
    Map<String, dynamic>? metadata,
  }) : metadata = Map<String, dynamic>.from(metadata ?? const {});

  factory _EditableComicCharacter.custom(String name) {
    return _EditableComicCharacter(
      nameController: TextEditingController(text: name),
      realNameController: TextEditingController(),
      metadata: const {'source_type': 'custom'},
    );
  }

  factory _EditableComicCharacter.fromMetadata(Map<String, dynamic> metadata) {
    return _EditableComicCharacter(
      nameController:
          TextEditingController(text: metadata['name']?.toString() ?? ''),
      realNameController:
          TextEditingController(text: metadata['real_name']?.toString() ?? ''),
      metadata: metadata,
    );
  }

  factory _EditableComicCharacter.fromLookupResult(
      Map<String, dynamic> result) {
    return _EditableComicCharacter(
      nameController:
          TextEditingController(text: result['name']?.toString() ?? ''),
      realNameController:
          TextEditingController(text: result['real_name']?.toString() ?? ''),
      metadata: {
        ...result,
        'source_type': 'core',
      },
    );
  }

  final TextEditingController nameController;
  final TextEditingController realNameController;
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
      'real_name': realNameController.text.trim(),
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
    realNameController.dispose();
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

  List<String> get _selectedValues =>
      splitPickListValues(widget.controller.text);

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
    final fieldOffset =
        fieldBox.localToGlobal(Offset.zero, ancestor: overlayBox);
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
