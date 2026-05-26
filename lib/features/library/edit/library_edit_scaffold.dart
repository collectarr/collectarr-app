import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryEditDialogScaffold extends StatelessWidget {
  const LibraryEditDialogScaffold({
    super.key,
    required this.formKey,
    required this.accent,
    required this.icon,
    required this.title,
    required this.badges,
    required this.tabController,
    required this.tabs,
    required this.views,
    required this.onClose,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final Color accent;
  final IconData icon;
  final String title;
  final List<Widget> badges;
  final TabController tabController;
  final List<Widget> tabs;
  final List<Widget> views;
  final VoidCallback onClose;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: editDialogTheme(seedColor: accent),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960, maxHeight: 740),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: kEditPanel,
              border: Border.all(color: kEditDivider),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xCC000000),
                  blurRadius: 22,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _LibraryEditTitleBar(
                    accent: accent,
                    icon: icon,
                    title: title,
                    badges: badges,
                    onClose: onClose,
                  ),
                  ColoredBox(
                    color: kEditPanelRaised,
                    child: TabBar(
                      controller: tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: Colors.white,
                      unselectedLabelColor: kEditTextMuted,
                      indicatorColor: accent,
                      dividerColor: kEditDivider,
                      labelPadding:
                          const EdgeInsets.symmetric(horizontal: 11),
                      tabs: tabs,
                    ),
                  ),
                  Expanded(
                    child: ColoredBox(
                      color: kEditPanel,
                      child: TabBarView(
                        controller: tabController,
                        children: views,
                      ),
                    ),
                  ),
                  _LibraryEditFooter(
                    onSave: onSave,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryEditTitleBar extends StatelessWidget {
  const _LibraryEditTitleBar({
    required this.accent,
    required this.icon,
    required this.title,
    required this.badges,
    required this.onClose,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final List<Widget> badges;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kAppSurface, kAppSurfaceDim],
        ),
        border: Border(bottom: BorderSide(color: accent)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: badges,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _LibraryEditFooter extends StatelessWidget {
  const _LibraryEditFooter({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: kEditToolbar,
        border: Border(top: BorderSide(color: kEditDivider)),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: onSave,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save'),
        ),
      ),
    );
  }
}