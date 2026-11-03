import 'package:shared_preferences/shared_preferences.dart';
import '../mobile_method_picker.dart';

/// Preference key for a kind's remembered native Add method.
String mobileAddDefaultMethodKey(String kind) =>
    'mobile.add.defaultMethod.$kind';

MobileAddMethod? readMobileAddDefaultMethod(
    SharedPreferences preferences, String kind,
    {required bool canScanCover}) {
  final saved = preferences.getString(mobileAddDefaultMethodKey(kind));
  return MobileAddMethod.values
      .where((method) =>
          method.name == saved &&
          (method != MobileAddMethod.cover || canScanCover))
      .firstOrNull;
}
