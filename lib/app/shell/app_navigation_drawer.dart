import 'package:collectarr_app/state/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:collectarr_app/features/library/collections/family.dart';
import 'package:collectarr_app/features/library/config/kind_style.dart';
import 'package:collectarr_app/ui/app_motion.dart';
import 'package:collectarr_app/ui/app_dialog.dart';

import 'package:collectarr_app/features/library/kind_registry.dart';
import 'app_shell_brand.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/app_dark_chrome.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  VoidCallback? onOpenAccount,
  required LibraryKindRegistration type,
  required DrawerAction? selectedAction,
  required bool isAdmin,
  required Color accent,
  required bool animationsEnabled,
  required void Function(BuildContext, DrawerAction) onSelected,
  required void Function(BuildContext, LibraryKindRegistration) onAddFromCore,
  required void Function(BuildContext, LibraryKindRegistration) onAddManually,
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
        // The reference keeps its menu dark in the light skin too.
        child: AppDarkChrome(
          accent: accent,
          child: AppNavigationDrawer(
            onOpenAccount: onOpenAccount,
            type: type,
            selectedAction: selectedAction,
            isAdmin: isAdmin,
            accent: accent,
            onSelected: onSelected,
            onAddFromCore: onAddFromCore,
            onAddManually: onAddManually,
          ),
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
    this.onOpenAccount,
    required this.selectedAction,
    required this.isAdmin,
    required this.accent,
    required this.type,
    required this.onSelected,
    required this.onAddFromCore,
    required this.onAddManually,
  });

  final VoidCallback? onOpenAccount;
  final DrawerAction? selectedAction;
  final bool isAdmin;
  final Color accent;
  final LibraryKindRegistration type;
  final void Function(BuildContext context, DrawerAction action) onSelected;

  /// Opens Add from Core for one kind of the open collection family.
  final void Function(BuildContext context, LibraryKindRegistration type)
      onAddFromCore;
  final void Function(BuildContext context, LibraryKindRegistration type)
      onAddManually;

  @override
  State<AppNavigationDrawer> createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends State<AppNavigationDrawer> {
  final _expanded = <AppDrawerSection, bool>{};

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final drawerBg = palette.sidebar;
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
                  height: appPresentationPlatform.isNativeMobile ? 76 : 64,
                  width: double.infinity,
                  child: _DrawerBrandHeader(type: widget.type),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (widget.onOpenAccount != null)
                    _MobileAccountSection(onOpen: () {
                      Navigator.of(context).pop();
                      WidgetsBinding.instance.addPostFrameCallback(
                          (_) => widget.onOpenAccount?.call());
                    }),
                  for (final section in AppDrawerSection.values)
                    if (appDrawerDestinations.any((destination) =>
                        destination.section == section &&
                        (!destination.nativeOnly ||
                            appPresentationPlatform.isNativeMobile) &&
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
              (!destination.nativeOnly ||
                  appPresentationPlatform.isNativeMobile) &&
              (!destination.adminOnly || widget.isAdmin))
            // As in the reference, every kind of a collection family, such as
            // Games, Hardware and Toys, has its own Add from Core entry.
            if (destination.action == DrawerAction.addFromCore)
              for (final type
                  in collectionFamilyKinds(widget.type.kind.apiValue))
                _action(context, destination,
                    label: 'Add ${type.identity.pluralLabel} from Core',
                    onTap: () => widget.onAddFromCore(context, type))
            else if (destination.action == DrawerAction.addManually)
              for (final type
                  in collectionFamilyKinds(widget.type.kind.apiValue))
                _action(context, destination,
                    label: 'Add ${type.identity.pluralLabel} Manually',
                    onTap: () => widget.onAddManually(context, type))
            else if (destination.action == DrawerAction.missingItems) ...[
              if (libraryToolbarForKind(widget.type.kind)?.missingReport !=
                  null)
                _action(context, destination,
                    label: 'Missing ${widget.type.identity.pluralLabel}'),
            ] else
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

class _DrawerBrandHeader extends StatefulWidget {
  const _DrawerBrandHeader({required this.type});

  final LibraryKindRegistration type;

  @override
  State<_DrawerBrandHeader> createState() => _DrawerBrandHeaderState();
}

class _DrawerBrandHeaderState extends State<_DrawerBrandHeader> {
  late final Future<String> _version = PackageInfo.fromPlatform().then(
    (info) => info.version.trim(),
  );

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 8, 5),
        child: Row(children: [
          Image.asset(
            AppIcons.appLogoPng,
            key: const Key('drawer.app-logo'),
            width: 38,
            height: 38,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppShellBrand(
                      icon: widget.type.identity.icon,
                      kindTitle: widget.type.identity.title,
                      iconKey: const Key('drawer.kind-icon'),
                      titleKey: const Key('drawer.brand-title'),
                      showIcon: false,
                    ),
                  ),
                ),
                FutureBuilder<String>(
                  future: _version,
                  builder: (context, snapshot) => Text(
                    snapshot.hasData && snapshot.data!.isNotEmpty
                        ? 'v${snapshot.data}'
                        : '',
                    key: const Key('drawer.version'),
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ]),
      );
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

class _MobileAccountSection extends ConsumerWidget {
  const _MobileAccountSection({required this.onOpen});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return Material(
      color: appPalette(context).utilityAction.withValues(alpha: .12),
      child: ListTile(
        key: const Key('drawer.account'),
        title: const Text('Collectarr Account:',
            style: TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
            auth.isAuthenticated ? auth.email ?? 'Signed in' : 'Not signed in'),
        trailing: const Icon(Icons.person_outline),
        onTap: onOpen,
      ),
    );
  }
}
