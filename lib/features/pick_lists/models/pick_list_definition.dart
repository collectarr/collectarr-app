import 'pick_list_scope.dart';

class PickListDefinition {
  const PickListDefinition({
    required this.id,
    required this.listName,
    required this.label,
    this.mediaKind,
    required this.scope,
    required this.valueMode,
    this.controlType = PickListControlType.dropdown,
    this.includeGlobalValues = true,
    this.allowUserValues = true,
    this.allowMerge = true,
    this.allowFoldering = true,
    this.allowColumn = true,
    this.allowSort = true,
    this.isSystem = false,
  });

  final String id;
  final String listName;
  final String label;
  final String? mediaKind;
  final PickListScope scope;
  final PickListValueMode valueMode;
  final PickListControlType controlType;
  final bool includeGlobalValues;
  final bool allowUserValues;
  final bool allowMerge;
  final bool allowFoldering;
  final bool allowColumn;
  final bool allowSort;
  final bool isSystem;
}
