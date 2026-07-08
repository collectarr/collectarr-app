import 'package:flutter/widgets.dart';

class ComicAddSearchOptionsScope extends InheritedWidget {
  const ComicAddSearchOptionsScope({
    super.key,
    required this.hideOwnedResults,
    required this.hideVariantResults,
    required this.compactIssues,
    required this.onHideOwnedResultsChanged,
    required this.onHideVariantResultsChanged,
    required this.onCompactIssuesChanged,
    required super.child,
  });

  final bool hideOwnedResults;
  final bool hideVariantResults;
  final bool compactIssues;
  final ValueChanged<bool> onHideOwnedResultsChanged;
  final ValueChanged<bool> onHideVariantResultsChanged;
  final ValueChanged<bool> onCompactIssuesChanged;

  static ComicAddSearchOptionsScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<
        ComicAddSearchOptionsScope>();
  }

  static ComicAddSearchOptionsScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'ComicAddSearchOptionsScope not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(ComicAddSearchOptionsScope oldWidget) {
    return hideOwnedResults != oldWidget.hideOwnedResults ||
        hideVariantResults != oldWidget.hideVariantResults ||
        compactIssues != oldWidget.compactIssues;
  }
}
