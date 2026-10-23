import 'package:flutter_svg/flutter_svg.dart';
import 'package:collectarr_app/features/library/collections/library_collection_family.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/ui/app_chrome.dart';
import 'package:collectarr_app/ui/app_motion.dart';
import 'package:collectarr_app/ui/app_dialog.dart';

import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'app_shell_brand.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_icons.dart';

import 'app_navigation_model.dart';

// The reference's drawer entries are CSS 400 and its section titles CSS 700;
// the font registration already compensates Flutter's lighter rasterizing for
// each weight (see local-font-loading.md).
TextStyle _drawerTextStyle(Color color, {required bool section}) => TextStyle(
      fontFamily: appFontFamily,
      fontSize: 14,
      height: 20 / 14,
      letterSpacing: 0,
      fontWeight: section ? FontWeight.w700 : FontWeight.w400,
      color: color,
    );

Future<void> showAppNavigationDrawer({
  required BuildContext context,
  required LibraryKindRegistration type,
  required DrawerAction? selectedAction,
  required bool isAdmin,
  required Color accent,
  required bool animationsEnabled,
  required void Function(BuildContext, DrawerAction) onSelected,
  required void Function(BuildContext, LibraryKindRegistration) onAddFromCore,
}) =>
    // As in the reference menu, a click on the overlay closes the drawer;
    // it holds no edits, unlike modal panels.
    showAppDialog<void>(
      context: context,
      barrierDismissible: true,
      useSafeArea: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration:
          animationsEnabled && !MediaQuery.disableAnimationsOf(context)
              ? appNavigationSlideDuration
              : Duration.zero,
      builder: (dialogContext) => GestureDetector(
        onHorizontalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -300) {
            Navigator.of(dialogContext).pop();
          }
        },
        child: AppNavigationDrawer(
          type: type,
          selectedAction: selectedAction,
          isAdmin: isAdmin,
          accent: accent,
          onSelected: onSelected,
          onAddFromCore: onAddFromCore,
        ),
      ),
      transitionBuilder: (_, animation, __, child) => Align(
        alignment: Alignment.centerLeft,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
              .animate(animation),
          child: child,
        ),
      ),
    );

class AppNavigationDrawer extends StatefulWidget {
  const AppNavigationDrawer({
    super.key,
    required this.selectedAction,
    required this.isAdmin,
    required this.accent,
    required this.type,
    required this.onSelected,
    required this.onAddFromCore,
  });

  final DrawerAction? selectedAction;
  final bool isAdmin;
  final Color accent;
  final LibraryKindRegistration type;
  final void Function(BuildContext context, DrawerAction action) onSelected;

  /// Opens Add from Core for one kind of the open collection family.
  final void Function(BuildContext context, LibraryKindRegistration type)
      onAddFromCore;

  @override
  State<AppNavigationDrawer> createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends State<AppNavigationDrawer> {
  final _expanded = <AppDrawerSection, bool>{};

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final drawerBg = palette.isDark ? const Color(0xFF383838) : palette.surface;
    final sectionHeaderColor =
        (palette.isDark ? Colors.white : palette.textPrimary)
            .withValues(alpha: 0.4);

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: drawerBg,
      width: (MediaQuery.sizeOf(context).width * 0.86)
          .clamp(0.0, 320.0)
          .toDouble(),
      child: SafeArea(
        child: Column(
          children: [
            AnimatedLibraryChrome(
              accent: widget.accent,
              child: Material(
                key: const Key('drawer.header'),
                color: Colors.transparent,
                child: SizedBox(
                  height: drawerHeaderHeight,
                  width: double.infinity,
                  child: Row(children: [
                    SizedBox(
                      width: 44,
                      child: IconButton(
                        tooltip: 'Close navigation',
                        style: appChromeIconButtonStyle(context),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(AppIcons.menu,
                            size: 19, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                        child: AppShellBrand(
                      icon: widget.type.identity.icon,
                      kindTitle: widget.type.identity.title,
                      iconKey: const Key('drawer.kind-icon'),
                      titleKey: const Key('drawer.brand-title'),
                    )),
                  ]),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final section in AppDrawerSection.values)
                    if (appDrawerDestinations.any((destination) =>
                        destination.section == section &&
                        (!destination.adminOnly || widget.isAdmin))) ...[
                      if (section != AppDrawerSection.collection)
                        const _DrawerDivider(),
                      if (section.collapsible)
                        _DrawerCollapsibleSectionLabel(
                          section.label,
                          color: sectionHeaderColor,
                          isExpanded: _expanded[section] ?? false,
                          onTap: () => setState(() => _expanded[section] =
                              !(_expanded[section] ?? false)),
                        )
                      else
                        _DrawerSectionLabel(section.label,
                            color: sectionHeaderColor),
                      if (section.collapsible)
                        _DrawerCollapsibleSection(
                            isExpanded: _expanded[section] ?? false,
                            children: _sectionActions(context, section))
                      else
                        ..._sectionActions(context, section),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sectionActions(
          BuildContext context, AppDrawerSection section) =>
      [
        for (final destination in appDrawerDestinations)
          if (destination.section == section &&
              (!destination.adminOnly || widget.isAdmin))
            // As in the reference, every kind of a collection family, such as
            // Games, Hardware and Toys, has its own Add from Core entry.
            if (destination.action == DrawerAction.addFromCore)
              for (final type
                  in collectionFamilyKinds(widget.type.kind.apiValue))
                _action(context, destination,
                    label: 'Add ${type.identity.pluralLabel} from Core',
                    onTap: () => widget.onAddFromCore(context, type))
            else
              _action(context, destination),
      ];

  Widget _action(BuildContext context, AppDrawerDestination destination,
      {String? label, VoidCallback? onTap}) {
    final action = destination.action;
    label ??= switch (action) {
      DrawerAction.linkItems => 'Link ${widget.type.identity.pluralLabel}',
      _ => destination.label,
    };
    final icon = destination.icon;
    final key =
        destination.widgetKey == null ? null : Key(destination.widgetKey!);
    final palette = appPalette(context);
    final selected = action == widget.selectedAction;
    final itemColor = selected
        ? widget.accent
        : (palette.isDark ? Colors.white : palette.textPrimary);

    return Semantics(
      selected: selected,
      child: InkWell(
        key: key,
        onTap: onTap ?? () => widget.onSelected(context, action),
        mouseCursor: SystemMouseCursors.click,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: palette.isDark ? const Color(0x26FFFFFF) : null,
        child: Container(
          color: selected
              ? widget.accent.withValues(alpha: palette.isDark ? 0.2 : 0.1)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: 17.5,
                height: 20,
                child: Center(
                  child: destination.svgAsset != null
                      ? SvgPicture.asset(destination.svgAsset!,
                          width: 17.5,
                          height: 14,
                          colorFilter:
                              ColorFilter.mode(itemColor, BlendMode.srcIn))
                      : Icon(icon, size: 14, color: itemColor),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: _drawerTextStyle(itemColor, section: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  const _DrawerSectionLabel(this.label, {required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        label,
        style: _drawerTextStyle(color, section: true),
      ),
    );
  }
}

class _DrawerCollapsibleSectionLabel extends StatelessWidget {
  const _DrawerCollapsibleSectionLabel(
    this.label, {
    required this.color,
    required this.isExpanded,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      mouseCursor: SystemMouseCursors.click,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: _drawerTextStyle(color, section: true),
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: appDrawerChevronDuration,
              curve: Curves.linear,
              child: Icon(
                AppIcons.chevronDown,
                size: 11,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerCollapsibleSection extends StatelessWidget {
  const _DrawerCollapsibleSection({
    required this.isExpanded,
    required this.children,
  });

  final bool isExpanded;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: isExpanded ? 1 : 0),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : appDrawerCollapseDuration,
      curve: Curves.ease,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
      builder: (context, factor, child) => ClipRect(
        child: Align(
          heightFactor: factor,
          alignment: Alignment.topCenter,
          child: Offstage(
            offstage: factor == 0,
            child: IgnorePointer(ignoring: !isExpanded, child: child),
          ),
        ),
      ),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = appPalette(context).isDark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0x33000000) : const Color(0x1F000000),
            width: 1,
          ),
          bottom: BorderSide(
            color: isDark ? const Color(0x1AFFFFFF) : const Color(0x33FFFFFF),
            width: 1,
          ),
        ),
      ),
    );
  }
}
