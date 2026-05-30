import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:flutter/material.dart';

class ComicEditPanel extends StatefulWidget {
  const ComicEditPanel({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  ComicEditPanelState createState() => ComicEditPanelState();
}

class ComicEditPanelState extends State<ComicEditPanel> {
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
  late final TextEditingController certificationNumberCtl;
  late final TextEditingController graderNotesCtl;
  late final TextEditingController signedByCtl;
  late final TextEditingController keyReasonCtl;
  late final TextEditingController statusCtl;
  late final TextEditingController ratingCtl;
  late final TextEditingController ownerCtl;
  late final TextEditingController readDateCtl;
  late final TextEditingController bagBoardDateCtl;
  late final TextEditingController tagsCtl;
  late final TextEditingController notesCtl;
  late final TextEditingController coverUrlCtl;
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
    coverDateCtl = TextEditingController();
    releaseDateCtl = TextEditingController(
      text: item.releaseDate == null ? '' : formatDate(item.releaseDate!),
    );
    publisherCtl = TextEditingController(text: item.publisher ?? '');
    imprintCtl = TextEditingController(text: publishing?.imprint ?? '');
    subtitleCtl = TextEditingController(text: item.titleExtension ?? '');
    storyArcsCtl =
        TextEditingController(text: item.storyArcs?.join(', ') ?? '');
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
    certificationNumberCtl =
        TextEditingController(text: owned?.certificationNumber ?? '');
    graderNotesCtl = TextEditingController(text: owned?.graderNotes ?? '');
    signedByCtl = TextEditingController(text: owned?.signedBy ?? '');
    keyReasonCtl = TextEditingController(text: owned?.keyReason ?? '');
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
    notesCtl = TextEditingController(
        text: tracking?.notes ?? owned?.personalNotes ?? '');
    coverUrlCtl = TextEditingController(
        text: item.coverImageUrl ?? item.thumbnailImageUrl ?? '');
    summaryCtl = TextEditingController(text: item.synopsis ?? '');
    descriptionCtl = TextEditingController(text: item.synopsis ?? '');
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
    certificationNumberCtl.dispose();
    graderNotesCtl.dispose();
    signedByCtl.dispose();
    keyReasonCtl.dispose();
    statusCtl.dispose();
    ratingCtl.dispose();
    ownerCtl.dispose();
    readDateCtl.dispose();
    bagBoardDateCtl.dispose();
    tagsCtl.dispose();
    notesCtl.dispose();
    coverUrlCtl.dispose();
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
    creators.add({
      'name': TextEditingController(),
      'role': TextEditingController(),
    });
    setState(() {});
  }

  void _removeCreator(int idx) {
    final creator = creators.removeAt(idx);
    creator['name']?.dispose();
    creator['role']?.dispose();
    setState(() {});
  }

  void _addCharacter() {
    characters.add(TextEditingController());
    setState(() {});
  }

  void _removeCharacter(int idx) {
    final character = characters.removeAt(idx);
    character.dispose();
    setState(() {});
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
                _labelledField('Series',
                    controller: seriesCtl, key: const ValueKey('edit-series')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: _labelledField('Barcode',
                            controller: barcodeCtl,
                            key: const ValueKey('edit-barcode'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _labelledField('Format',
                            controller: formatCtl,
                            key: const ValueKey('edit-format'))),
                  ],
                ),
                const SizedBox(height: 8),
                _labelledField('Series Group',
                    controller: seriesGroupCtl,
                    key: const ValueKey('edit-seriesgroup')),
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
                        child: _labelledField('Cover Date',
                            controller: coverDateCtl,
                            key: const ValueKey('edit-coverdate'),
                            hintText: 'YYYY-MM-DD')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _labelledField('Release Date',
                            controller: releaseDateCtl,
                            key: const ValueKey('edit-releasedate'),
                            hintText: 'YYYY-MM-DD')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _labelledField('Publisher',
                            controller: publisherCtl,
                            key: const ValueKey('edit-publisher'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _labelledField('Imprint',
                            controller: imprintCtl,
                            key: const ValueKey('edit-imprint'))),
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
                  child: _labelledField('Purchase Date',
                      controller: purchaseDateCtl,
                      key: const ValueKey('edit-purchase-date'),
                      hintText: 'YYYY-MM-DD')),
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
                  child: _labelledField('Grade',
                      controller: gradeCtl, key: const ValueKey('edit-grade'))),
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
                  child: _labelledField('Sold Date',
                      controller: soldDateCtl,
                      key: const ValueKey('edit-sold-date'),
                      hintText: 'YYYY-MM-DD')),
              const SizedBox(width: 8),
              Expanded(
                  child: _labelledField('Purchase Store',
                      controller: purchaseStoreCtl,
                      key: const ValueKey('edit-purchase-store'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _labelledField('Raw / Slabbed',
                      controller: rawOrSlabbedCtl,
                      key: const ValueKey('edit-raw-slabbed'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _labelledField('Grading Company',
                      controller: gradingCompanyCtl,
                      key: const ValueKey('edit-grading-company'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _labelledField('Label Type',
                      controller: labelTypeCtl,
                      key: const ValueKey('edit-label-type'))),
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
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Key issue'),
            value: _keyComic,
            onChanged: (value) => setState(() => _keyComic = value ?? false),
          ),
          if (_keyComic) ...[
            const SizedBox(height: 8),
            _labelledField('Key Reason',
                controller: keyReasonCtl,
                key: const ValueKey('edit-key-reason')),
          ],
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
            children: [
              Expanded(
                  child: _labelledField('Status',
                      controller: statusCtl,
                      key: const ValueKey('edit-status'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _labelledField('Rating',
                      controller: ratingCtl,
                      key: const ValueKey('edit-rating'))),
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
                  child: _labelledField('Read Date',
                      controller: readDateCtl,
                      key: const ValueKey('edit-read-date'),
                      hintText: 'YYYY-MM-DD')),
              const SizedBox(width: 8),
              Expanded(
                  child: _labelledField('Bag/Board Date',
                      controller: bagBoardDateCtl,
                      key: const ValueKey('edit-bagboard-date'),
                      hintText: 'YYYY-MM-DD')),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelledField('Front Cover URL',
              controller: coverUrlCtl, key: const ValueKey('edit-cover-url')),
          const SizedBox(height: 12),
          Text('Front Cover',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            width: 220,
            height: 320,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: coverUrl.isEmpty
                ? const Center(child: Text('No cover'))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Text('Preview unavailable')),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            'Back cover upload/crop tooling is still missing in the comic-specific dialog.',
            style: Theme.of(context).textTheme.bodySmall,
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
          for (var i = 0; i < creators.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: creators[i]['name'],
                          decoration: const InputDecoration(labelText: 'Name'),
                          key: ValueKey('edit-creator-$i-name'))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          controller: creators[i]['role'],
                          decoration: const InputDecoration(labelText: 'Role'),
                          key: ValueKey('edit-creator-$i-role'))),
                  IconButton(
                      onPressed: () => _removeCreator(i),
                      icon: const Icon(Icons.delete)),
                ],
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
          ElevatedButton.icon(
              onPressed: _addCharacter,
              icon: const Icon(Icons.add),
              label: const Text('Add Character')),
          const SizedBox(height: 8),
          for (var i = 0; i < characters.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: characters[i],
                          decoration:
                              const InputDecoration(labelText: 'Character'),
                          key: ValueKey('edit-character-$i'))),
                  IconButton(
                      onPressed: () => _removeCharacter(i),
                      icon: const Icon(Icons.delete)),
                ],
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
      'certificationNumber': certificationNumberCtl.text,
      'graderNotes': graderNotesCtl.text,
      'signedBy': signedByCtl.text,
      'keyComic': _keyComic,
      'keyReason': keyReasonCtl.text,
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
