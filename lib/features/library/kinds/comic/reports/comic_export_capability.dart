import 'package:collectarr_app/features/library/config/library_export_capability.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/columns/columns.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/entry_schema.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

/// Exports offer the collection list columns, as the reference Export to
/// CSV / TXT does, starting from the default list columns. Images are not
/// exported.
final comicExportCapability = LibraryExportCapability(
  itemLabel: 'Comics',
  itemModeLabel: 'Comic list',
  itemFileName: 'export_comics',
  defaultSortColumnId: 'comic.series',
  pdfItemTitle: 'My Comics',
  itemColumns: [
    for (final column in _exportedColumns)
      ExportColumnDefinition(
        id: column.id.value,
        label: column.resolvedDisplayName,
        metadata: column.metadata,
        getValue: (item) => comicCollectionColumnText(
          column,
          LibraryProjectionContext<ComicWorkspaceDto>(
            item: item.source.item,
            personal: item.source.personal,
            dto: item.dto as ComicWorkspaceDto,
          ),
        ),
        defaultVisible: _defaultIds.contains(column.id.value),
      ),
  ],
);

final _defaultIds = [
  for (final id in comicLibraryEntryWorkspaceSchema.defaultVisibleColumns)
    id.value,
];

/// The default list columns in list order, then the others in chooser order.
List<LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, Object?>>
    get _exportedColumns {
  final columns = [
    for (final column in comicCollectionWorkspaceColumns)
      if (column.group != 'Images') column,
  ];
  int rank(LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, Object?> c) {
    final index = _defaultIds.indexOf(c.id.value);
    return index < 0 ? _defaultIds.length : index;
  }

  return [
    for (final (_, column) in [
      for (var i = 0; i < columns.length; i++) (i, columns[i]),
    ]..sort((a, b) {
        final byRank = rank(a.$2).compareTo(rank(b.$2));
        return byRank != 0 ? byRank : a.$1.compareTo(b.$1);
      }))
      column,
  ];
}
