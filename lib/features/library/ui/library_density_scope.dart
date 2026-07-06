import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:flutter/material.dart';

class LibraryDensityScope extends InheritedWidget {
  const LibraryDensityScope({
    super.key,
    required this.density,
    required super.child,
  });

  final LibraryDensity density;

  static LibraryDensityScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LibraryDensityScope>();
  }

  static LibraryDensity of(BuildContext context) {
    return maybeOf(context)?.density ?? LibraryDensity.comfortable;
  }

  @override
  bool updateShouldNotify(LibraryDensityScope oldWidget) {
    return density != oldWidget.density;
  }
}
