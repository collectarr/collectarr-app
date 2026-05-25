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
    this.footerLabel,
    this.footerFields = const <Widget>[],
    required this.onPrevious,
    required this.onNext,
    required this.onCancel,
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
  final String? footerLabel;
  final List<Widget> footerFields;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onCancel;
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
                    onClose: onCancel,
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
                    footerLabel: footerLabel,
                    tabController: tabController,
                    footerFields: footerFields,
                    onPrevious: onPrevious,
                    onNext: onNext,
                    onCancel: onCancel,
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
  const _LibraryEditFooter({
    required this.footerLabel,
    required this.tabController,
    required this.footerFields,
    required this.onPrevious,
    required this.onNext,
    required this.onCancel,
    required this.onSave,
  });

  final String? footerLabel;
  final TabController tabController;
  final List<Widget> footerFields;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final metaChildren = <Widget>[
      if (footerLabel != null)
        Text(
          footerLabel!,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: kEditTextMuted,
                fontWeight: FontWeight.w800,
              ),
        ),
      ...footerFields,
    ];
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        final currentTab = tabController.index + 1;
        final totalTabs = tabController.length;
        final actions = Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            FooterReadonlyField(
              label: 'Tab',
              value: '$currentTab / $totalTabs',
              width: 72,
            ),
            Tooltip(
              message: 'Previous tab',
              child: OutlinedButton.icon(
                onPressed: currentTab <= 1 ? null : onPrevious,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Previous'),
              ),
            ),
            Tooltip(
              message: 'Next tab',
              child: OutlinedButton.icon(
                onPressed: currentTab >= totalTabs ? null : onNext,
                icon: const Icon(Icons.chevron_right),
                label: const Text('Next'),
              ),
            ),
            TextButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),
          ],
        );
        final meta = Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: metaChildren,
        );
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: kEditToolbar,
            border: Border(top: BorderSide(color: kEditDivider)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (metaChildren.isNotEmpty) meta,
                    if (metaChildren.isNotEmpty) const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: actions,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  if (metaChildren.isNotEmpty)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: meta,
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: actions,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}