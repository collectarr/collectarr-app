import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_scaffold.dart';
import 'package:flutter/material.dart';

/// Shared visual structure for kind-owned manual Add forms.
///
/// Uses the Edit dialog scaffold so manual Add and Edit share their header,
/// tab strip, form surface, positioning, and footer layout. Kind panes retain
/// their own identity fields, schema, and supporting state.
class LibraryAddManualPaneShell extends StatefulWidget {
  const LibraryAddManualPaneShell({
    super.key,
    required this.request,
    this.identityDetails,
    this.formContent,
    this.tabs,
  });

  final LibraryAddManualPaneRequest request;

  /// Optional kind-specific fields shown below the shared Catalog Item title.
  final Widget? identityDetails;
  final Widget? formContent;
  final List<LibraryAddManualPaneTab>? tabs;

  @override
  State<LibraryAddManualPaneShell> createState() =>
      _LibraryAddManualPaneShellState();
}

class _LibraryAddManualPaneShellState extends State<LibraryAddManualPaneShell>
    with SingleTickerProviderStateMixin {
  late final GlobalKey<FormState> _formKey;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _tabController = TabController(length: _tabCount(widget), vsync: this);
  }

  List<LibraryAddManualPaneTab> get _resolvedTabs {
    if (widget.tabs?.isNotEmpty ?? false) return widget.tabs!;
    assert(widget.formContent != null);
    return [
      LibraryAddManualPaneTab(
        label: 'Main',
        icon: Icons.edit_note_outlined,
        content: widget.formContent!,
      ),
    ];
  }

  @override
  void didUpdateWidget(covariant LibraryAddManualPaneShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_tabCount(oldWidget) == _tabCount(widget)) return;
    final previousIndex = _tabController.index;
    _tabController.dispose();
    _tabController = TabController(
      length: _tabCount(widget),
      initialIndex: previousIndex.clamp(0, _tabCount(widget) - 1).toInt(),
      vsync: this,
    );
  }

  int _tabCount(LibraryAddManualPaneShell shell) =>
      (shell.tabs?.isNotEmpty ?? false ? shell.tabs!.length : 1) +
      (shell.request.customFieldDefinitions.isNotEmpty ? 1 : 0) +
      1;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final tabs = [
      ..._resolvedTabs,
      if (request.customFieldDefinitions.isNotEmpty)
        LibraryAddManualPaneTab(
          label: 'Custom Fields',
          icon: Icons.edit_note_outlined,
          content: EditTabShell(
            children: [
              CustomFieldsEditSection(
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
            ],
          ),
        ),
      LibraryAddManualPaneTab(
        label: 'My Images',
        icon: Icons.photo_library_outlined,
        content: EditTabShell(
          children: [
            ItemImagesEditSection(
              images: request.itemImages,
              accent: request.accent,
              onChanged: request.onItemImagesChanged ?? (_) {},
            ),
          ],
        ),
      ),
    ];
    final badges = <Widget>[
      const LibraryAddResultBadge('main'),
      LibraryAddResultBadge('owned defaults', accent: request.accent),
      if (request.defaultLocationLabel != null)
        LibraryAddResultBadge(
          request.defaultLocationLabel!,
          accent: request.accent,
        ),
    ];
    final enteredTitle = request.manualDraft.catalogTitle.trim();
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
              if (index == 0)
                TextFormField(
                  initialValue: request.manualDraft.catalogTitle,
                  onChanged: (value) {
                    request.manualDraft.catalogTitle = value;
                    setState(() {});
                  },
                  decoration: const InputDecoration(labelText: 'Title'),
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
      onSave: request.onAddOwned,
      footerOverride: LibraryAddManualActionBar(
        request: request,
        formKey: _formKey,
      ),
    );
  }
}

/// One kind-owned tab displayed inside the shared manual Add dialog shell.
///
/// The shell owns tab layout and chrome; each kind owns tab contents.
final class LibraryAddManualPaneTab {
  const LibraryAddManualPaneTab({
    required this.label,
    required this.icon,
    required this.content,
  });

  final String label;
  final IconData icon;
  final Widget content;
}
