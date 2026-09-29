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
    required this.formContent,
  });

  final LibraryAddManualPaneRequest request;
  final String title;
  final String subtitle;
  final Widget identity;
  final Widget formContent;

  @override
  State<LibraryAddManualPaneShell> createState() =>
      _LibraryAddManualPaneShellState();
}

class _LibraryAddManualPaneShellState extends State<LibraryAddManualPaneShell>
    with SingleTickerProviderStateMixin {
  late final GlobalKey<FormState> _formKey;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _tabController = TabController(length: 1, vsync: this);
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
        EditTab(icon: Icons.edit_note_outlined, label: 'Main'),
      ],
      views: [
        EditTabShell(
          children: [
            if (subtitle.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            if (subtitle.isNotEmpty) const SizedBox(height: 12),
            widget.identity,
            const SizedBox(height: 10),
            widget.formContent,
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
