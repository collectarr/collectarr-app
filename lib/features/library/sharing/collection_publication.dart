import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';

Map<String, dynamic> buildCollectionPublication({
  required LibraryKindRegistration type,
  required String title,
  required String visibility,
  required bool includePersonal,
  bool privateLinkEnabled = false,
  required List<LibraryProjectionView> items,
}) {
  final workspace = libraryKindWorkspaceForKind(type.kind);
  final publicIds = workspace.fields.fields
      .where(
          (field) => field.metadata.source != LibraryFieldSource.libraryEntry)
      .map((field) => field.id.value)
      .toSet();
  final columns =
      libraryExportCapabilityForKind(type.kind)?.itemColumns ?? const [];
  return {
    'title': title,
    'kind': type.kind.apiValue,
    'visibility': visibility,
    'include_personal': includePersonal && visibility != 'partial',
    'private_link_enabled': visibility == 'private' && privateLinkEnabled,
    'items': [
      for (final item in items)
        {
          'id': item.target.stableKey,
          'title': item.dto.primaryLabel,
          'subtitle': item.dto.secondaryLabel,
          if (Uri.tryParse(item.dto.imageUrl ?? '') case final uri?)
            if (uri.scheme == 'https' || uri.scheme == 'http')
              'cover_url': uri.toString(),
          'fields': {
            for (final column in columns)
              if (publicIds.contains(column.id) ||
                  publicIds.contains('${type.kind.apiValue}.${column.id}'))
                column.label: column.getValue(item)
          },
          'personal_fields': {
            if (includePersonal && visibility != 'partial')
              for (final column in columns)
                if (!publicIds.contains(column.id) &&
                    !publicIds.contains('${type.kind.apiValue}.${column.id}'))
                  column.label: column.getValue(item)
          },
        }
    ],
  };
}
