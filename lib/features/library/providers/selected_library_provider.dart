import 'dart:async';

import 'package:collectarr_app/features/library/home/nav_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kSelectedLibraryKindKey = 'collectarr.library_nav.selected_kind';

String _startupLibraryKind = 'music';

/// Reads the last library before the first frame, so the app does not open on
/// Music and switch.
Future<void> loadStartupLibraryKind() async {
  final prefs = await SharedPreferences.getInstance();
  _startupLibraryKind =
      canonicalLibraryNavKind(prefs.getString(_kSelectedLibraryKindKey)) ??
          'music';
}

final selectedLibraryKindProvider =
    NotifierProvider<SelectedLibraryKind, String>(SelectedLibraryKind.new);

class SelectedLibraryKind extends Notifier<String> {
  @override
  String build() => _startupLibraryKind;

  /// Selects [kind]; [remember] keeps it for the next launch. A fallback to the
  /// first visible library, while the remembered one is hidden or the catalog
  /// is still loading, must not replace the choice.
  void select(String kind, {bool remember = true}) {
    state = canonicalLibraryNavKind(kind) ?? 'music';
    if (remember) unawaited(_save(state));
  }

  Future<void> _save(String kind) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelectedLibraryKindKey, kind);
  }
}
