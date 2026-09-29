import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
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
    required this.title,
    required this.subtitle,
    required this.identity,
    this.formContent,
    this.tabs,
  });

  final LibraryAddManualPaneRequest request;
  final String title;
  final String subtitle;
  final Widget identity;
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
    _tabController = TabController(length: _resolvedTabs.length, vsync: this);
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
    if ((oldWidget.tabs?.length ?? 1) == _resolvedTabs.length) return;
    final previousIndex = _tabController.index;
    _tabController.dispose();
    _tabController = TabController(
      length: _resolvedTabs.length,
      initialIndex: previousIndex.clamp(0, _resolvedTabs.length - 1).toInt(),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final subtitle = widget.subtitle.trim();
    final tabs = _resolvedTabs;
    final badges = <Widget>[
      const LibraryAddResultBadge('main'),
      LibraryAddResultBadge('owned defaults', accent: request.accent),
      if (request.defaultLocationLabel != null)
        LibraryAddResultBadge(
          request.defaultLocationLabel!,
          accent: request.accent,
        ),
    ];

    return LibraryEditDialogScaffold(
      formKey: _formKey,
      accent: request.accent,
      icon: request.type.identity.icon,
      title: widget.title,
      badges: badges,
      tabController: _tabController,
      tabs: [
        for (final tab in tabs) EditTab(icon: tab.icon, label: tab.label),
      ],
      views: [
        for (var index = 0; index < tabs.length; index++)
          EditTabShell(
            children: [
              if (index == 0 && subtitle.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              if (index == 0 && subtitle.isNotEmpty) const SizedBox(height: 12),
              if (index == 0) ...[
                widget.identity,
                const SizedBox(height: 10),
              ],
              tabs[index].content,
            ],
          ),
      ],
      allowTabReorder: false,
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
