import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:flutter/material.dart';

class ComicLibraryPage extends StatelessWidget {
  const ComicLibraryPage({
    super.key,
    required this.type,
    required this.topBar,
    required this.accent,
    required this.routeUri,
  });

  final LibraryTypeConfig type;
  final Widget topBar;
  final Color accent;
  final Uri routeUri;

  @override
  Widget build(BuildContext context) {
    return LibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
    );
  }
}