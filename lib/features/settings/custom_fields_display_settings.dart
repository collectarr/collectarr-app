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

enum CustomFieldMultiValueControl {
  checkboxes('Check List'),
  dropdown('Name List'),
  personList('Person List'),
  tagList('Tag List');

  const CustomFieldMultiValueControl(this.label);
  final String label;
}

enum CustomFieldNumericStorage { decimal, number }

enum CustomFieldMultiValueDisplay { separator, list }

/// Labels and control choices do not alter a custom field's stored value type.
class CustomFieldDisplaySettings {
  const CustomFieldDisplaySettings({
    this.pluralName = '',
    this.currencyCode = 'USD',
    this.multiValueControl = CustomFieldMultiValueControl.dropdown,
    this.numericStorage = CustomFieldNumericStorage.decimal,
    this.multiValueDisplay = CustomFieldMultiValueDisplay.separator,
  });

  final String pluralName;
  final String currencyCode;
  final CustomFieldMultiValueControl multiValueControl;
  final CustomFieldNumericStorage numericStorage;
  final CustomFieldMultiValueDisplay multiValueDisplay;

  static String _key(String id) => 'collectarr.custom_field.$id';

  static Future<CustomFieldDisplaySettings> read(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return CustomFieldDisplaySettings(
      pluralName: prefs.getString('${_key(id)}.plural_name') ?? '',
      currencyCode: prefs.getString('${_key(id)}.currency_code') ?? 'USD',
      multiValueControl: CustomFieldMultiValueControl.values.firstWhere(
          (value) =>
              value.name == prefs.getString('${_key(id)}.multi_value_control'),
          orElse: () => CustomFieldMultiValueControl.dropdown),
      numericStorage: CustomFieldNumericStorage.values.firstWhere(
          (value) =>
              value.name == prefs.getString('${_key(id)}.numeric_storage'),
          orElse: () => CustomFieldNumericStorage.decimal),
      multiValueDisplay: CustomFieldMultiValueDisplay.values.firstWhere(
          (value) =>
              value.name == prefs.getString('${_key(id)}.multi_value_display'),
          orElse: () => CustomFieldMultiValueDisplay.separator),
    );
  }

  Future<void> save(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_key(id)}.plural_name', pluralName.trim());
    await prefs.setString('${_key(id)}.currency_code', currencyCode);
    await prefs.setString(
        '${_key(id)}.multi_value_control', multiValueControl.name);
    await prefs.setString('${_key(id)}.numeric_storage', numericStorage.name);
    await prefs.setString(
        '${_key(id)}.multi_value_display', multiValueDisplay.name);
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_key(id)}.plural_name');
    await prefs.remove('${_key(id)}.currency_code');
    await prefs.remove('${_key(id)}.multi_value_control');
    await prefs.remove('${_key(id)}.numeric_storage');
    await prefs.remove('${_key(id)}.multi_value_display');
  }
}
