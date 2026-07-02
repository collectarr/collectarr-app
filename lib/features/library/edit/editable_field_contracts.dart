import 'package:collectarr_app/core/models/custom_field.dart';

sealed class EditableFieldContract {
  const EditableFieldContract({
    required this.key,
    required this.label,
    required this.valueType,
  });

  final String key;
  final String label;
  final String valueType;
}

class CoreMetadataFieldContract extends EditableFieldContract {
  const CoreMetadataFieldContract({
    required super.key,
    required super.label,
    required super.valueType,
    required this.kind,
  });

  final String kind;
}

class PersonalFieldContract extends EditableFieldContract {
  const PersonalFieldContract({
    required super.key,
    required super.label,
    required super.valueType,
    required this.targetScope,
  });

  final CustomFieldTargetScope targetScope;
}

class CustomUserFieldContract extends EditableFieldContract {
  const CustomUserFieldContract({
    required super.key,
    required super.label,
    required super.valueType,
    required this.definitionId,
    required this.targetScope,
  });

  final String definitionId;
  final CustomFieldTargetScope targetScope;
}
