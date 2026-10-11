import 'package:shared_preferences/shared_preferences.dart';

/// Presentation preferences; custom field definitions and values remain in DB.
class CustomFieldsDisplaySettings {
  const CustomFieldsDisplaySettings({
    this.tabName = 'Custom Fields',
    this.showEditTab = true,
  });

  final String tabName;
  final bool showEditTab;

  static String _key(String? kind) =>
      'collectarr.custom_fields.${kind ?? 'all'}';

  static Future<CustomFieldsDisplaySettings> read(String? kind) async {
    final prefs = await SharedPreferences.getInstance();
    return CustomFieldsDisplaySettings(
      tabName: prefs.getString('${_key(kind)}.tab_name') ??
          prefs.getString('${_key(null)}.tab_name') ??
          'Custom Fields',
      showEditTab: prefs.getBool('${_key(kind)}.show_edit_tab') ??
          prefs.getBool('${_key(null)}.show_edit_tab') ??
          true,
    );
  }

  Future<void> save(String? kind) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_key(kind)}.tab_name', tabName.trim());
    await prefs.setBool('${_key(kind)}.show_edit_tab', showEditTab);
  }
}

enum CustomFieldMultiValueControl { dropdown, checkboxes }

/// Labels and control choices do not alter a custom field's stored value type.
class CustomFieldDisplaySettings {
  const CustomFieldDisplaySettings({
    this.pluralName = '',
    this.multiValueControl = CustomFieldMultiValueControl.dropdown,
  });

  final String pluralName;
  final CustomFieldMultiValueControl multiValueControl;

  static String _key(String id) => 'collectarr.custom_field.$id';

  static Future<CustomFieldDisplaySettings> read(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return CustomFieldDisplaySettings(
      pluralName: prefs.getString('${_key(id)}.plural_name') ?? '',
      multiValueControl: prefs.getString('${_key(id)}.multi_value_control') ==
              CustomFieldMultiValueControl.checkboxes.name
          ? CustomFieldMultiValueControl.checkboxes
          : CustomFieldMultiValueControl.dropdown,
    );
  }

  Future<void> save(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_key(id)}.plural_name', pluralName.trim());
    await prefs.setString(
        '${_key(id)}.multi_value_control', multiValueControl.name);
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_key(id)}.plural_name');
    await prefs.remove('${_key(id)}.multi_value_control');
  }
}
