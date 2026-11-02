import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A native mobile page with one header and slots shared by library workflows.
class MobilePage extends StatelessWidget {
  const MobilePage(
      {super.key,
      required this.title,
      required this.onBack,
      required this.headerColor,
      required this.backgroundColor,
      required this.body,
      this.actions,
      this.canGoBack = true,
      this.contextBar,
      this.footer,
      this.overlay});

  final String title;
  final bool canGoBack;
  final VoidCallback onBack;
  final Color headerColor;
  final Color backgroundColor;
  final Widget body;
  final List<Widget>? actions;
  final Widget? contextBar;
  final Widget? footer;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) => IconButtonTheme(
      data: IconButtonThemeData(
          style: IconButton.styleFrom(backgroundColor: Colors.transparent)),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: MobilePageHeader(
            title: title,
            onBack: onBack,
            color: headerColor,
            canGoBack: canGoBack,
            actions: actions),
        body: SafeArea(
            top: false,
            child: Stack(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (contextBar != null) contextBar!,
                Expanded(child: body),
                if (footer != null) footer!,
              ]),
              if (overlay != null) Positioned.fill(child: overlay!),
            ])),
      ));
}

/// Header styling is scoped to native chrome, so desktop button fills and
/// title colors do not leak into mobile pages or recolor their form controls.
class MobilePageHeader extends StatelessWidget implements PreferredSizeWidget {
  const MobilePageHeader(
      {super.key,
      required this.title,
      required this.onBack,
      required this.color,
      this.actions,
      this.canGoBack = true});
  final String title;
  final VoidCallback onBack;
  final Color color;
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
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: color,
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
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
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
  Widget build(BuildContext context) => ColoredBox(
      color: color,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: compact ? 3 : 5),
        child: Center(
            child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DecoratedBox(
              decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                for (final (index, tab) in tabs.indexed) ...[
                  if (compact && index > 0)
                    Container(
                      width: 1,
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      color: Colors.white.withValues(alpha: .3),
                    ),
                  Semantics(
                      selected: tab.value == selected,
                      button: true,
                      child: Material(
                          color: tab.value == selected
                              ? Colors.white.withValues(alpha: .2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => onSelected(tab.value),
                              child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minHeight: compact ? 34 : 44,
                                      minWidth: compact ? 48 : 64),
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: compact ? 9 : 10),
                                      child: Center(
                                          child: Text(tab.label,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: compact ? 12 : 14,
                                                  fontWeight: tab.value ==
                                                          selected
                                                      ? FontWeight.w700
                                                      : FontWeight.w400)))))))),
                ],
              ])),
        )),
      ));
}
