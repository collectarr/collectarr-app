import 'package:collectarr_app/core/fonts/local_font_access_io.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('desktop discovery includes user and system font locations', () {
    expect(
        localFontDirectories(
            'windows', {'LOCALAPPDATA': 'UserData', 'WINDIR': 'Windows'}),
        ['UserData/Microsoft/Windows/Fonts', 'Windows/Fonts']);
    expect(localFontDirectories('macos', {'HOME': '/Users/me'}),
        contains('/Users/me/Library/Fonts'));
    expect(
        localFontDirectories(
            'linux', {'HOME': '/home/me', 'XDG_DATA_HOME': '/data'}),
        containsAll([
          '/data/fonts',
          '/home/me/.local/share/fonts',
          '/usr/share/fonts'
        ]));
    expect(localFontDirectories('android', {}), isEmpty);
  });
}
