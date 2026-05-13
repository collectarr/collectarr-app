import 'package:flutter/material.dart';

typedef LibraryGridItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
);

class LibraryWorkspaceGrid<T> extends StatelessWidget {
  const LibraryWorkspaceGrid({
    required this.items,
    required this.itemBuilder,
    required this.emptyBuilder,
    required this.maxCrossAxisExtent,
    required this.mainAxisExtent,
    this.crossAxisSpacing = 10,
    this.mainAxisSpacing = 10,
    this.padding = const EdgeInsets.all(10),
    this.backgroundColor = const Color(0xFF202020),
    super.key,
  });

  final List<T> items;
  final LibraryGridItemBuilder<T> itemBuilder;
  final WidgetBuilder emptyBuilder;
  final double maxCrossAxisExtent;
  final double mainAxisExtent;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return emptyBuilder(context);
    }
    return ColoredBox(
      color: backgroundColor,
      child: GridView.builder(
        padding: padding,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisExtent: mainAxisExtent,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => itemBuilder(context, items[index]),
      ),
    );
  }
}
