import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collectarr_app/ui/adaptive/native_system_chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';

/// A native mobile page with one header and slots shared by library workflows.
class MobilePage extends StatelessWidget {
  const MobilePage(
      {super.key,
      this.title,
      this.titleWidget,
      required this.onBack,
      required this.headerColor,
      required this.backgroundColor,
      required this.body,
      this.actions,
      this.canGoBack = true,
      this.contextBar,
      this.contextBarBottomPadding = 6,
      this.footer,
      this.systemBarColor,
      this.overlay});

  final String? title;
  final Widget? titleWidget;
  final bool canGoBack;
  final VoidCallback onBack;
  final Color headerColor;
  final Color backgroundColor;
  final Widget body;
  final List<Widget>? actions;
  final Widget? contextBar;
  final double contextBarBottomPadding;
  final Widget? footer;
  final Widget? overlay;

  /// Optional kind-specific dark color for the system status bar.
  final Color? systemBarColor;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: nativeSystemUiStyle(
        accent: headerColor,
        darkAccent: systemBarColor,
        palette: appPalette(context),
      ),
      child: IconButtonTheme(
          data: IconButtonThemeData(
              style: IconButton.styleFrom(backgroundColor: Colors.transparent)),
          child: Scaffold(
            backgroundColor: backgroundColor,
            appBar: MobilePageHeader(
                title: title,
                titleWidget: titleWidget,
                onBack: onBack,
                color: headerColor,
                systemBarColor: systemBarColor,
                canGoBack: canGoBack,
                actions: actions),
            body: SafeArea(
                top: false,
                child: Stack(children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (contextBar != null)
                          DecoratedBox(
                            decoration: BoxDecoration(color: headerColor),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: contextBarBottomPadding),
                              child: contextBar!,
                            ),
                          ),
                        Expanded(child: body),
                        if (footer != null) footer!,
                      ]),
                  if (overlay != null) Positioned.fill(child: overlay!),
                ])),
          )));
}

/// Header styling is scoped to native chrome, so desktop button fills and
/// title colors do not leak into mobile pages or recolor their form controls.
class MobilePageHeader extends StatelessWidget implements PreferredSizeWidget {
  const MobilePageHeader(
      {super.key,
      this.title,
      this.titleWidget,
      required this.onBack,
      required this.color,
      this.systemBarColor,
      this.actions,
      this.canGoBack = true});
  final String? title;
  final Widget? titleWidget;
  final VoidCallback onBack;
  final Color color;
  final Color? systemBarColor;
  final List<Widget>? actions;
  final bool canGoBack;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) => IconButtonTheme(
        data: IconButtonThemeData(
            style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white38,
        )),
        child: AppBar(
          systemOverlayStyle: nativeSystemUiStyle(
            accent: color,
            darkAccent: systemBarColor,
            palette: appPalette(context),
          ),
          backgroundColor: color,
          flexibleSpace: Stack(children: [
            NativeStatusBarBackground(
                color: systemBarColor ?? Color.lerp(color, Colors.black, .32)!)
          ]),
          foregroundColor: Colors.white,
          titleTextStyle: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.white, fontSize: 20),
          leading: canGoBack
              ? BackButton(onPressed: onBack)
              : const IconButton(
                  tooltip: 'Back',
                  onPressed: null,
                  icon: Icon(Icons.arrow_back)),
          titleSpacing: titleWidget != null ? 0 : null,
          title: titleWidget ??
              Text(title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: actions,
        ),
      );
}

/// Touch-sized segmented tabs, scrolling when text or tab count needs room.
class MobileTabStrip<T> extends StatelessWidget {
  const MobileTabStrip(
      {super.key,
      required this.tabs,
      required this.selected,
      required this.onSelected,
      required this.color,
      this.compact = false});
  final List<({T value, String label})> tabs;
  final T selected;
  final ValueChanged<T> onSelected;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    final containerColor =
        hsl.withLightness((hsl.lightness * 0.72).clamp(0.0, 1.0)).toColor();
    final activeColor =
        hsl.withLightness((hsl.lightness * 1.35).clamp(0.0, 0.75)).toColor();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: compact ? 3 : 5),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (index, tab) in tabs.indexed) ...[
                    if (compact &&
                        index > 0 &&
                        tab.value != selected &&
                        tabs[index - 1].value != selected)
                      Container(
                        width: 1,
                        height: 16,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        color: Colors.white.withValues(alpha: .2),
                      ),
                    Semantics(
                      selected: tab.value == selected,
                      button: true,
                      child: Material(
                        color: tab.value == selected
                            ? activeColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => onSelected(tab.value),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: compact ? 32 : 40,
                              minWidth: compact ? 48 : 64,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 12 : 14,
                              ),
                              child: Center(
                                child: Text(
                                  tab.label,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: compact ? 13 : 14,
                                    fontWeight: tab.value == selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
