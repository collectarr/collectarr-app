import 'package:flutter/material.dart';

class ComicEditPanel extends StatefulWidget {
  const ComicEditPanel({Key? key}) : super(key: key);

  @override
  State<ComicEditPanel> createState() => _ComicEditPanelState();
}

class _ComicEditPanelState extends State<ComicEditPanel> with TickerProviderStateMixin {
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
  // Details
  late final TextEditingController yearCtl;
  late final TextEditingController isbnCtl;
  late final TextEditingController languageCtl;
  late final TextEditingController pagesCtl;
  late final TextEditingController bindingCtl;
  // Value
  late final TextEditingController purchasePriceCtl;
  late final TextEditingController purchaseCurrencyCtl;
  late final TextEditingController purchaseDateCtl;
  late final TextEditingController currentValueCtl;
  late final TextEditingController gradeCtl;
  // Personal
  late final TextEditingController statusCtl;
  late final TextEditingController ratingCtl;
  late final TextEditingController locationCtl;
  late final TextEditingController tagsCtl;
  // Custom fields (UDFs)
  final List<Map<String, TextEditingController>> udfs = [];
  // Covers / Images
  late final TextEditingController coverUrlCtl;
  // Creators
  final List<Map<String, TextEditingController>> creators = [];
  // Characters
  final List<TextEditingController> characters = [];
  // Plot
  late final TextEditingController summaryCtl;
  late final TextEditingController descriptionCtl;
  // Links
  final List<Map<String, TextEditingController>> links = [];

  @override
  void initState() {
    super.initState();
    seriesCtl = TextEditingController();
    barcodeCtl = TextEditingController();
    formatCtl = TextEditingController();
    seriesGroupCtl = TextEditingController();
    issueNumberCtl = TextEditingController();
    variantCtl = TextEditingController();
    variantDescCtl = TextEditingController();
    coverDateCtl = TextEditingController();
    releaseDateCtl = TextEditingController();
    publisherCtl = TextEditingController();
    imprintCtl = TextEditingController();
    yearCtl = TextEditingController();
    isbnCtl = TextEditingController();
    languageCtl = TextEditingController();
    pagesCtl = TextEditingController();
    bindingCtl = TextEditingController();
    purchasePriceCtl = TextEditingController();
    purchaseCurrencyCtl = TextEditingController();
    purchaseDateCtl = TextEditingController();
    currentValueCtl = TextEditingController();
    gradeCtl = TextEditingController();
    statusCtl = TextEditingController();
    ratingCtl = TextEditingController();
    locationCtl = TextEditingController();
    tagsCtl = TextEditingController();
    coverUrlCtl = TextEditingController();
    summaryCtl = TextEditingController();
    descriptionCtl = TextEditingController();
  }

  @override
  void dispose() {
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
    yearCtl.dispose();
    isbnCtl.dispose();
    languageCtl.dispose();
    pagesCtl.dispose();
    bindingCtl.dispose();
    purchasePriceCtl.dispose();
    purchaseCurrencyCtl.dispose();
    purchaseDateCtl.dispose();
    currentValueCtl.dispose();
    gradeCtl.dispose();
    statusCtl.dispose();
    ratingCtl.dispose();
    locationCtl.dispose();
    tagsCtl.dispose();
    coverUrlCtl.dispose();
    summaryCtl.dispose();
    descriptionCtl.dispose();
    for (final e in udfs) {
      e['name']?.dispose();
      e['value']?.dispose();
    }
    for (final c in creators) {
      c['name']?.dispose();
      c['role']?.dispose();
    }
    for (final ch in characters) {
      ch.dispose();
    }
    for (final l in links) {
      l['title']?.dispose();
      l['url']?.dispose();
    }
    super.dispose();
  }

  void _addUdf() {
    udfs.add({
      'name': TextEditingController(),
      'value': TextEditingController(),
    });
    setState(() {});
  }

  void _removeUdf(int idx) {
    final e = udfs.removeAt(idx);
    e['name']?.dispose();
    e['value']?.dispose();
    setState(() {});
  }

  void _addCreator() {
    creators.add({
      'name': TextEditingController(),
      'role': TextEditingController(),
    });
    setState(() {});
  }

  void _removeCreator(int idx) {
    final e = creators.removeAt(idx);
    e['name']?.dispose();
    e['role']?.dispose();
    setState(() {});
  }

  void _addCharacter() {
    characters.add(TextEditingController());
    setState(() {});
  }

  void _removeCharacter(int idx) {
    final c = characters.removeAt(idx);
    c.dispose();
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
    final e = links.removeAt(idx);
    e['title']?.dispose();
    e['url']?.dispose();
    setState(() {});
  }

  Widget _buildMainTab(BuildContext ctx) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _labelledField('Series', controller: seriesCtl, key: const ValueKey('edit-series')),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _labelledField('Barcode', controller: barcodeCtl, key: const ValueKey('edit-barcode'))),
                        const SizedBox(width: 8),
                        Expanded(child: _labelledField('Format', controller: formatCtl, key: const ValueKey('edit-format'))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _labelledField('Series Group', controller: seriesGroupCtl, key: const ValueKey('edit-seriesgroup')),
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
                        Expanded(flex: 3, child: _labelledField('Issue No.', controller: issueNumberCtl, key: const ValueKey('edit-issuenr'))),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: _labelledField('Variant', controller: variantCtl, key: const ValueKey('edit-variant'))),
                        const SizedBox(width: 8),
                        Expanded(flex: 7, child: _labelledField('Variant Description', controller: variantDescCtl, key: const ValueKey('edit-variant-desc'))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _labelledField('Cover Date', controller: coverDateCtl, key: const ValueKey('edit-coverdate'))),
                        const SizedBox(width: 8),
                        Expanded(child: _labelledField('Release Date', controller: releaseDateCtl, key: const ValueKey('edit-releasedate'))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _labelledField('Publisher', controller: publisherCtl, key: const ValueKey('edit-publisher'))),
                        const SizedBox(width: 8),
                        Expanded(child: _labelledField('Imprint', controller: imprintCtl, key: const ValueKey('edit-imprint'))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _labelledField(String label, {TextEditingController? controller, Key? key}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(controller: controller, key: key),
      ],
    );
  }

  Widget _buildSimpleList(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...children,
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
              Expanded(child: _labelledField('Year', controller: yearCtl, key: const ValueKey('edit-year'))),
              const SizedBox(width: 8),
              Expanded(child: _labelledField('ISBN', controller: isbnCtl, key: const ValueKey('edit-isbn'))),
              const SizedBox(width: 8),
              Expanded(child: _labelledField('Language', controller: languageCtl, key: const ValueKey('edit-language'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _labelledField('Pages', controller: pagesCtl, key: const ValueKey('edit-pages'))),
              const SizedBox(width: 8),
              Expanded(child: _labelledField('Binding', controller: bindingCtl, key: const ValueKey('edit-binding'))),
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
        children: [
          Row(
            children: [
              Expanded(child: _labelledField('Purchase Price', controller: purchasePriceCtl, key: const ValueKey('edit-purchase-price'))),
              const SizedBox(width: 8),
              Expanded(child: _labelledField('Currency', controller: purchaseCurrencyCtl, key: const ValueKey('edit-purchase-currency'))),
              const SizedBox(width: 8),
              Expanded(child: _labelledField('Purchase Date', controller: purchaseDateCtl, key: const ValueKey('edit-purchase-date'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _labelledField('Current Value', controller: currentValueCtl, key: const ValueKey('edit-current-value'))),
              const SizedBox(width: 8),
              Expanded(child: _labelledField('Grade', controller: gradeCtl, key: const ValueKey('edit-grade'))),
            ],
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
            children: [
              Expanded(child: _labelledField('Status', controller: statusCtl, key: const ValueKey('edit-status'))),
              const SizedBox(width: 8),
              Expanded(child: _labelledField('Rating', controller: ratingCtl, key: const ValueKey('edit-rating'))),
              const SizedBox(width: 8),
              Expanded(child: _labelledField('Location', controller: locationCtl, key: const ValueKey('edit-location'))),
            ],
          ),
          const SizedBox(height: 12),
          _labelledField('Tags', controller: tagsCtl, key: const ValueKey('edit-tags')),
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
          ElevatedButton.icon(onPressed: _addUdf, icon: const Icon(Icons.add), label: const Text('Add Field')),
          const SizedBox(height: 8),
          for (var i = 0; i < udfs.length; i++)
            Row(
              children: [
                Expanded(child: TextField(controller: udfs[i]['name'], decoration: InputDecoration(labelText: 'Name', hintText: 'Field name'), key: ValueKey('edit-udf-${i}-name'))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: udfs[i]['value'], decoration: InputDecoration(labelText: 'Value'), key: ValueKey('edit-udf-${i}-value'))),
                IconButton(onPressed: () => _removeUdf(i), icon: const Icon(Icons.delete)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCoversTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: coverUrlCtl, decoration: const InputDecoration(labelText: 'Cover URL'), key: ValueKey('edit-cover-url'))),
              const SizedBox(width: 8),
              ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.search), label: const Text('Find Online')),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Front Cover', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(height: 140, color: Colors.black12),
        ],
      ),
    );
  }

  Widget _buildMyImagesTab() {
    return _buildSimpleList('My Images', [const Text('My Images placeholder')]);
  }

  Widget _buildCreatorsTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(onPressed: _addCreator, icon: const Icon(Icons.add), label: const Text('Add Creator')),
          const SizedBox(height: 8),
          for (var i = 0; i < creators.length; i++)
            Row(
              children: [
                Expanded(child: TextField(controller: creators[i]['name'], decoration: const InputDecoration(labelText: 'Name'), key: ValueKey('edit-creator-${i}-name'))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: creators[i]['role'], decoration: const InputDecoration(labelText: 'Role'), key: ValueKey('edit-creator-${i}-role'))),
                IconButton(onPressed: () => _removeCreator(i), icon: const Icon(Icons.delete)),
              ],
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
          ElevatedButton.icon(onPressed: _addCharacter, icon: const Icon(Icons.add), label: const Text('Add Character')),
          const SizedBox(height: 8),
          for (var i = 0; i < characters.length; i++)
            Row(
              children: [
                Expanded(child: TextField(controller: characters[i], decoration: const InputDecoration(labelText: 'Character'), key: ValueKey('edit-character-${i}'))),
                IconButton(onPressed: () => _removeCharacter(i), icon: const Icon(Icons.delete)),
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
          _labelledField('Summary', controller: summaryCtl, key: const ValueKey('edit-summary')),
          const SizedBox(height: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextField(controller: descriptionCtl, key: const ValueKey('edit-description'), maxLines: 6),
          ]),
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
          ElevatedButton.icon(onPressed: _addLink, icon: const Icon(Icons.add), label: const Text('Add Link')),
          const SizedBox(height: 8),
          for (var i = 0; i < links.length; i++)
            Row(
              children: [
                Expanded(child: TextField(controller: links[i]['title'], decoration: const InputDecoration(labelText: 'Title'), key: ValueKey('edit-link-${i}-title'))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: links[i]['url'], decoration: const InputDecoration(labelText: 'URL'), key: ValueKey('edit-link-${i}-url'))),
                IconButton(onPressed: () => _removeLink(i), icon: const Icon(Icons.delete)),
              ],
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
      'year': yearCtl.text,
      'isbn': isbnCtl.text,
      'language': languageCtl.text,
      'pages': pagesCtl.text,
      'binding': bindingCtl.text,
      'purchasePrice': purchasePriceCtl.text,
      'purchaseCurrency': purchaseCurrencyCtl.text,
      'purchaseDate': purchaseDateCtl.text,
      'currentValue': currentValueCtl.text,
      'grade': gradeCtl.text,
      'status': statusCtl.text,
      'rating': ratingCtl.text,
      'location': locationCtl.text,
      'tags': tagsCtl.text,
      'udfs': udfs
          .map((e) => {'name': e['name']?.text ?? '', 'value': e['value']?.text ?? ''})
          .toList(),
      'coverUrl': coverUrlCtl.text,
      'creators': creators
          .map((c) => {'name': c['name']?.text ?? '', 'role': c['role']?.text ?? ''})
          .toList(),
      'characters': characters.map((c) => c.text).toList(),
      'summary': summaryCtl.text,
      'description': descriptionCtl.text,
      'links': links
          .map((l) => {'title': l['title']?.text ?? '', 'url': l['url']?.text ?? ''})
          .toList(),
    };
  }
}
