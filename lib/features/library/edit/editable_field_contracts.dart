import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/metadata/library_field_ownership.dart';

sealed class EditableFieldContract {
  const EditableFieldContract({
    required this.key,
    required this.label,
    required this.valueType,
    required this.ownership,
  });

  final String key;
  final String label;
  final String valueType;
  final LibraryFieldOwnership ownership;
}

class CoreMetadataFieldContract extends EditableFieldContract {
  const CoreMetadataFieldContract({
    required super.key,
    required super.label,
    required super.valueType,
    required this.kind,
  }) : super(ownership: LibraryFieldOwnership.canonicalMetadata);

  final String kind;
}

class PersonalFieldContract extends EditableFieldContract {
  const PersonalFieldContract({
    required super.key,
    required super.label,
    required super.valueType,
    required this.targetScope,
    this.syncable = false,
  }) : super(
          ownership: syncable
              ? LibraryFieldOwnership.syncablePersonal
              : LibraryFieldOwnership.personalLibrary,
        );

  final CustomFieldTargetScope targetScope;
  final bool syncable;
}

class CustomUserFieldContract extends EditableFieldContract {
  const CustomUserFieldContract({
    required super.key,
    required super.label,
    required super.valueType,
    required this.definitionId,
    required this.targetScope,
  }) : super(ownership: LibraryFieldOwnership.personalLibrary);

  final String definitionId;
  final CustomFieldTargetScope targetScope;
}
