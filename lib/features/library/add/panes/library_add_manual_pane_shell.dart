import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_personal_tab.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/schema/library_form_schema.dart';
import 'package:collectarr_app/features/library/schema/library_form_schema_validation.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec_renderer.dart';
import 'package:collectarr_app/features/library/schema/library_schema_text_controller_store.dart';
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
  }) : assert(tabs.length > 0);

  final LibraryAddManualPaneRequest request;

  /// Optional kind-specific identity controls shown before the active tab.
  final Widget? identityDetails;
  final List<LibraryAddManualPaneTab> tabs;

  @override
  State<LibraryAddManualPaneShell> createState() =>
      _LibraryAddManualPaneShellState();
}

class _LibraryAddManualPaneShellState extends State<LibraryAddManualPaneShell>
    with SingleTickerProviderStateMixin {
  late final GlobalKey<FormState> _formKey;
  late TabController _tabController;
  final Map<String, FocusNode> _fieldFocusNodes = {};

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _tabController = TabController(length: _tabCount(widget), vsync: this);
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

  String? _validateAllTabs(BuildContext validationContext) {
    final controllers = LibrarySchemaTextControllerScope.maybeOf(
      validationContext,
    );
    if (controllers == null) {
      throw StateError(
          'Manual Add validation requires the dialog controller scope.');
    }
    final tabs = _tabsFor(widget);
    for (var index = 0; index < tabs.length; index++) {
      final issue = tabs[index].validate?.call(controllers);
      if (issue == null) continue;
      if (_tabController.index != index) _tabController.index = index;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tabController.index == index) {
          _formKey.currentState?.validate();
          final fieldId = issue.fieldId;
          if (fieldId != null) {
            final node = _fieldFocusNodes['${tabs[index].id}::$fieldId'];
            node?.requestFocus();
            final targetContext = node?.context;
            if (targetContext != null) {
              Scrollable.ensureVisible(
                targetContext,
                alignment: 0.25,
                duration: Duration.zero,
              );
            }
          }
        }
      });
      ScaffoldMessenger.of(validationContext).showSnackBar(
        SnackBar(content: Text(issue.message)),
      );
      return issue.message;
    }
    return null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final node in _fieldFocusNodes.values) {
      node.dispose();
    }
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
      tabIds: [for (final tab in tabs) tab.id],
      views: [
        for (var index = 0; index < tabs.length; index++)
          EditTabShell(
            children: [
              LibrarySchemaFieldFocusScope(
                tabId: tabs[index].id,
                nodes: _fieldFocusNodes,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (index == 0 && widget.identityDetails != null) ...[
                      widget.identityDetails!,
                      const SizedBox(height: 12),
                    ],
                    tabs[index].content,
                  ],
                ),
              ),
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
        validateAdditionalFields: _validateAllTabs,
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
    this.validate,
  });

  static LibraryAddManualPaneTab fromForm<TDraft>({
    required String id,
    required String label,
    required IconData icon,
    required LibraryFormSchema<TDraft> schema,
    required TDraft draft,
    required Widget content,
    bool validateSchema = false,
  }) =>
      LibraryAddManualPaneTab(
        id: id,
        label: label,
        icon: icon,
        content: content,
        validate: (controllers) => firstLibraryFormValidationIssue(
          schema: schema,
          draft: draft,
          controllers: controllers,
          validateSchema: validateSchema,
        ),
      );

  static LibraryAddManualPaneTab fromSchema<TDraft>({
    required String id,
    required String label,
    required IconData icon,
    required LibraryFormSchema<TDraft> schema,
    required TDraft draft,
    required String mediaKind,
    LibraryVocabularyValueChanged? onVocabularyValueChanged,
    LibraryVocabularyValuesChanged? onVocabularyValuesChanged,
    VoidCallback? onChanged,
    bool validateSchema = false,
  }) =>
      LibraryAddManualPaneTab.fromForm(
        id: id,
        label: label,
        icon: icon,
        schema: schema,
        draft: draft,
        validateSchema: validateSchema,
        content: LibraryFieldSpecRenderer<TDraft>.embedded(
          schema: schema,
          draft: draft,
          mediaKind: mediaKind,
          onVocabularyValueChanged: onVocabularyValueChanged,
          onVocabularyValuesChanged: onVocabularyValuesChanged,
          onChanged: onChanged,
        ),
      );

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
  final LibraryFormValidationIssue? Function(
    LibrarySchemaTextControllerStore controllers,
  )? validate;
}
