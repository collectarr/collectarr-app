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
      this.contextBar,
      this.footer,
      this.overlay});

  final String title;
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
        appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: headerColor,
            foregroundColor: Colors.white,
            leading: BackButton(onPressed: onBack),
            title: Text(title),
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

/// Touch-sized segmented tabs, scrolling when text or tab count needs room.
class MobileTabStrip<T> extends StatelessWidget {
  const MobileTabStrip(
      {super.key,
      required this.tabs,
      required this.selected,
      required this.onSelected,
      required this.color});
  final List<({T value, String label})> tabs;
  final T selected;
  final ValueChanged<T> onSelected;
  final Color color;

  @override
  Widget build(BuildContext context) => ColoredBox(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Center(
            child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DecoratedBox(
              decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                for (final tab in tabs)
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
                                  constraints: const BoxConstraints(
                                      minHeight: 44, minWidth: 64),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Center(
                                          child: Text(tab.label,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: tab.value ==
                                                          selected
                                                      ? FontWeight.w700
                                                      : FontWeight.w400)))))))),
              ])),
        )),
      ));
}
