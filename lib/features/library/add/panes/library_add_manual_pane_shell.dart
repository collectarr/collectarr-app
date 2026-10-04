import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_personal_tab.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_scaffold.dart';
import 'package:flutter/material.dart';

/// Shared visual structure for kind-entry manual Add forms.
///
/// Uses the Edit dialog scaffold so manual Add and Edit share their header,
/// tab strip, form surface, positioning, and footer layout. Kind panes retain
/// their own identity fields, schema, and supporting state.
class LibraryAddManualPaneShell extends StatefulWidget {
  const LibraryAddManualPaneShell({
    super.key,
    required this.request,
    required this.tabs,
    this.identityDetails,
    this.showCatalogTitleField = true,
  }) : assert(tabs.length > 0);

  final LibraryAddManualPaneRequest request;

  /// Optional kind-specific fields shown below the shared Catalog Item title.
  final Widget? identityDetails;
  final bool showCatalogTitleField;
  final List<LibraryAddManualPaneTab> tabs;

  @override
  State<LibraryAddManualPaneShell> createState() =>
      _LibraryAddManualPaneShellState();
}

class _LibraryAddManualPaneShellState extends State<LibraryAddManualPaneShell>
    with SingleTickerProviderStateMixin {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _catalogTitleController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _catalogTitleController = TextEditingController(
      text: widget.request.manualDraft.catalogTitle,
    )..addListener(_handleCatalogTitleChanged);
    _tabController = TabController(length: _tabCount(widget), vsync: this);
  }

  void _handleCatalogTitleChanged() {
    widget.request.manualDraft.catalogTitle = _catalogTitleController.text;
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant LibraryAddManualPaneShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.request.manualDraft, widget.request.manualDraft)) {
      _catalogTitleController.removeListener(_handleCatalogTitleChanged);
      _catalogTitleController.text = widget.request.manualDraft.catalogTitle;
      _catalogTitleController.addListener(_handleCatalogTitleChanged);
    }
    if (_tabCount(oldWidget) == _tabCount(widget)) return;
    final previousIndex = _tabController.index;
    _tabController.dispose();
    _tabController = TabController(
      length: _tabCount(widget),
      initialIndex: previousIndex.clamp(0, _tabCount(widget) - 1).toInt(),
      vsync: this,
    );
  }

  List<LibraryAddManualPaneTab> _tabsFor(
    LibraryAddManualPaneShell shell,
  ) {
    final request = shell.request;
    final tabs = [...shell.tabs];
    if (!tabs.any((tab) => tab.id == 'personal')) {
      tabs.add(
        LibraryAddManualPaneTab(
          id: 'personal',
          label: 'Personal',
          icon: Icons.person_outline,
          content: LibraryAddManualPersonalTab(request: request),
        ),
      );
    }
    if (request.customFieldDefinitions.isNotEmpty) {
      tabs.add(
        LibraryAddManualPaneTab(
          id: 'custom_fields',
          label: 'Custom Fields',
          icon: Icons.edit_note_outlined,
          content: CustomFieldsEditSection(
            definitions: request.customFieldDefinitions,
            values: request.customFieldValues,
            accent: request.accent,
            mediaKind: request.kind.apiValue,
            onChanged: (values) =>
                request.onCustomFieldValuesChanged?.call(values),
            onCustomValueChanged: (fieldId, value) {
              request.onVocabularyValueChanged?.call(
                fieldId: 'customField:$fieldId',
                listName: 'customField:$fieldId',
                value: value,
              );
            },
          ),
        ),
      );
    }
    tabs.add(
      LibraryAddManualPaneTab(
        id: 'my_images',
        label: 'My Images',
        icon: Icons.photo_library_outlined,
        content: ItemImagesEditSection(
          images: request.itemImages,
          accent: request.accent,
          onChanged: request.onItemImagesChanged ?? (_) {},
        ),
      ),
    );
    return tabs;
  }

  int _tabCount(LibraryAddManualPaneShell shell) => _tabsFor(shell).length;

  @override
  void dispose() {
    _tabController.dispose();
    _catalogTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final tabs = _tabsFor(widget);
    final badges = <Widget>[
      if (request.defaultLocationLabel != null)
        LibraryAddResultBadge(
          request.defaultLocationLabel!,
          accent: request.accent,
        ),
    ];
    final enteredTitle = _catalogTitleController.text.trim();
    final headerTitle = enteredTitle.isEmpty
        ? 'Add ${request.type.identity.singularLabel}'
        : enteredTitle;

    return LibraryEditDialogScaffold(
      formKey: _formKey,
      accent: request.accent,
      icon: request.type.identity.icon,
      title: headerTitle,
      badges: badges,
      tabController: _tabController,
      tabs: [
        for (final tab in tabs) EditTab(icon: tab.icon, label: tab.label),
      ],
      views: [
        for (var index = 0; index < tabs.length; index++)
          EditTabShell(
            children: [
              if (index == 0 && widget.showCatalogTitleField)
                LibraryEditTextField(
                  controller: _catalogTitleController,
                  label: 'Title',
                  validator: (value) =>
                      value?.trim().isNotEmpty == true ? null : 'Enter a title',
                ),
              if (index == 0 && widget.identityDetails != null) ...[
                const SizedBox(height: 10),
                widget.identityDetails!,
              ],
              if (index == 0) const SizedBox(height: 12),
              tabs[index].content,
            ],
          ),
      ],
      allowTabReorder: true,
      tabOrderKey: 'library_add_manual_tabs_${request.kind.apiValue}_v1',
      onClose: () => Navigator.of(context).pop(),
      onCancel: () => Navigator.of(context).pop(),
      onSave: request.onAddEntry,
      footerOverride: LibraryAddManualActionBar(
        request: request,
        formKey: _formKey,
      ),
    );
  }
}

/// One kind-entry tab displayed inside the shared manual Add dialog shell.
///
/// The shell owns tab layout and chrome; each kind owns tab contents.
final class LibraryAddManualPaneTab {
  const LibraryAddManualPaneTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.content,
  });

  factory LibraryAddManualPaneTab.main({required Widget content}) =>
      LibraryAddManualPaneTab(
        id: 'main',
        label: 'Main',
        icon: Icons.edit_note_outlined,
        content: content,
      );

  final String id;
  final String label;
  final IconData icon;
  final Widget content;
}
