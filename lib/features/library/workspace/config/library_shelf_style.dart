import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LibraryShelfStyle {
  woodLight('Wood Light', Color(0xffb57e36), Color(0xffb77a30)),
  woodDark('Wood Dark', Color(0xff513b29), Color(0xff392619)),
  glass('Glass', Color(0xff383838), Color(0xffa6b3b5)),
  metal('Metal', Color(0xff353535), Color(0xff85898c)),
  carbon('Carbon', Color(0xff252525), Color(0xff424242)),
  white('White', Color(0xffe3e3e3), Color(0xfffafafa));

  const LibraryShelfStyle(this.label, this.background, this.plank);
  final String label;
  final Color background;
  final Color plank;
  Color get highlight => Color.alphaBlend(const Color(0x35ffffff), plank);
  bool get isWood => this == woodLight || this == woodDark;
}

final libraryShelfStyleProvider =
    AsyncNotifierProvider<LibraryShelfStyleController, LibraryShelfStyle>(
        LibraryShelfStyleController.new);

class LibraryShelfStyleController extends AsyncNotifier<LibraryShelfStyle> {
  static const preferenceKey = 'ui.shelf_style';

  @override
  Future<LibraryShelfStyle> build() async {
    final preferences = await SharedPreferences.getInstance();
    final name = preferences.getString(preferenceKey);
    return LibraryShelfStyle.values
            .where((style) => style.name == name)
            .firstOrNull ??
        LibraryShelfStyle.woodLight;
  }

  Future<void> select(LibraryShelfStyle style) async {
    state = AsyncData(style);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(preferenceKey, style.name);
  }
}
