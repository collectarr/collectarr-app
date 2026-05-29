import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedLibraryKindProvider =
    NotifierProvider<SelectedLibraryKind, String>(SelectedLibraryKind.new);

class SelectedLibraryKind extends Notifier<String> {
  @override
  String build() => 'comic';

  void select(String kind) => state = canonicalLibraryNavKind(kind) ?? 'comic';
}
