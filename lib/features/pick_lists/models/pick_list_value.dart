String normalizePickListValue(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

class PickListValue {
  const PickListValue({
    required this.id,
    required this.listName,
    this.mediaKind,
    required this.value,
    this.displayLabel,
    this.normalizedValue,
    this.aliases = const [],
    this.sortOrder = 0,
    this.isSystem = false,
    this.isHidden = false,
  });

  final String id;
  final String listName;
  final String? mediaKind;
  final String value;
  final String? displayLabel;
  final String? normalizedValue;
  final List<String> aliases;
  final int sortOrder;
  final bool isSystem;
  final bool isHidden;

  String get effectiveLabel => displayLabel?.trim().isNotEmpty == true
      ? displayLabel!.trim()
      : value.trim();

  String get effectiveNormalizedValue =>
      normalizedValue?.trim().isNotEmpty == true
          ? normalizePickListValue(normalizedValue!)
          : normalizePickListValue(value);

  bool get isGlobal => mediaKind == null || mediaKind!.trim().isEmpty;
}
