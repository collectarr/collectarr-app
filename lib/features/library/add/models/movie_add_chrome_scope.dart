import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class MovieAddChromeScope extends InheritedWidget {
  const MovieAddChromeScope({
    super.key,
    required this.isWideChrome,
    required this.videoKindFilters,
    required this.showVideoKindFilters,
    required this.onVideoKindFilterChanged,
    required super.child,
  });

  final bool isWideChrome;
  final Set<String> videoKindFilters;
  final bool showVideoKindFilters;
  final void Function(String kind, bool checked) onVideoKindFilterChanged;

  static MovieAddChromeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MovieAddChromeScope>();
  }

  static MovieAddChromeScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'MovieAddChromeScope not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(MovieAddChromeScope oldWidget) {
    return isWideChrome != oldWidget.isWideChrome ||
        showVideoKindFilters != oldWidget.showVideoKindFilters ||
        !setEquals(videoKindFilters, oldWidget.videoKindFilters);
  }
}
