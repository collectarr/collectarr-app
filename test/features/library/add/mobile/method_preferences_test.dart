import 'package:collectarr_app/features/library/add/mobile/method_preferences.dart';
import 'package:collectarr_app/features/library/add/mobile_method_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('saved methods are per kind and unsupported cover opens the picker',
      () async {
    SharedPreferences.setMockInitialValues({
      'mobile.add.skipMethodPicker': true,
      mobileAddDefaultMethodKey('comic'): 'cover',
      mobileAddDefaultMethodKey('music'): 'barcode',
    });
    final prefs = await SharedPreferences.getInstance();
    expect(readMobileAddDefaultMethod(prefs, 'comic', canScanCover: true),
        MobileAddMethod.cover);
    expect(readMobileAddDefaultMethod(prefs, 'comic', canScanCover: false),
        isNull);
    expect(readMobileAddDefaultMethod(prefs, 'music', canScanCover: false),
        MobileAddMethod.barcode);
    expect(
        readMobileAddDefaultMethod(prefs, 'game', canScanCover: true), isNull);
    await prefs.setString(mobileAddDefaultMethodKey('comic'), 'search');
    expect(readMobileAddDefaultMethod(prefs, 'comic', canScanCover: true),
        MobileAddMethod.search);
    expect(readMobileAddDefaultMethod(prefs, 'music', canScanCover: true),
        MobileAddMethod.barcode);
  });
}
