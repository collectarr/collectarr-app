import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

Map<String, dynamic> buildCollectionPublication({
  required LibraryKindRegistration type,
  required String title,
  required String visibility,
  required bool includePersonal,
  required List<LibraryProjectionView> items,
}) {
  final workspace = libraryKindWorkspaceForKind(type.kind);
  final publicIds =
      workspace.fields.fields.map((field) => field.id.value).toSet();
  final columns =
      libraryExportCapabilityForKind(type.kind)?.itemColumns ?? const [];
  return {
    'title': title,
    'kind': type.kind.apiValue,
    'visibility': visibility,
    'include_personal': includePersonal,
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
              if (publicIds.contains(column.id) || publicIds.contains('${type.kind.apiValue}.${column.id}'))
                column.label: column.getValue(item)
          },
          'personal_fields': {
            if (includePersonal)
              for (final column in columns)
                if (!publicIds.contains(column.id) && !publicIds.contains('${type.kind.apiValue}.${column.id}'))
                  column.label: column.getValue(item)
          },
        }
    ],
  };
}
