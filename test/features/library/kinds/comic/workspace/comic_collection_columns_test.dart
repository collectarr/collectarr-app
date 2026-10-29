import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_creator.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/comic/reports/comic_export_capability.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/entry_schema.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_projection_context.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter_test/flutter_test.dart';

LibraryProjectionContext<ComicWorkspaceDto> _context(ComicCatalogItem comic,
    {ComicPersonalData personal = const ComicPersonalData()}) {
  final entry = ComicLibraryEntry(
    id: LibraryEntryId(comic.issueNumber ?? 'entry'),
    metadata: comic,
    personal: personal,
    updatedAt: DateTime.utc(2026),
  );
  return LibraryProjectionContext(
    item: WorkspaceItem(
        target: CatalogTargetRef(
            CatalogItemRef(kind: CatalogMediaKind.comic, id: entry.id.value))),
    personal: const PersonalOverlay(),
    sorting: const LibrarySortingOptions(),
    dto: ComicWorkspaceDto(
      common: WorkspaceCommonProjection(title: comic.title),
      personal: PersonalEntryProjection(),
      comic: comic,
      libraryEntry: entry,
    ),
  );
}

void main() {
  final registry = comicLibraryEntryWorkspaceSchema.toRegistry();
  final columns = {
    for (final column in registry.columns) column.id.value: column,
  };

  test('the collection list opens with the reference default columns', () {
    expect([
      for (final id in comicLibraryEntryWorkspaceSchema.defaultVisibleColumns)
        columns[id.value]!.resolvedDisplayName
    ], [
      'Series',
      'Issue',
      'Variant Description',
      'Publisher',
      'Release Date',
      'Storage Box',
      'Format',
      'Added Date',
    ]);
    expect(registry.defaultSort.value, 'comic.series');
    expect(registry.defaultGroup?.value, 'comic.series');
  });

  test('columns follow the reference chooser groups', () {
    expect(registry.columns.map((column) => column.group).toSet(), [
      'Images',
      'Main',
      'Value',
      'Edition',
      'Creators & Characters',
      'Personal',
      'Loan',
    ]);
  });

  test('collection columns read the comic and its copy', () {
    final context = _context(
      const ComicCatalogItem(
        title: '',
        seriesTitle: 'Example Series',
        issueNumber: '2',
        variant: 'A',
        variantDescription: 'Regular Cover',
        physicalFormat: 'Comic',
        releaseDateParts: PartialDate(year: 2024, month: 11),
        creators: [ComicCreator(name: 'Example Inker', role: 'Inker')],
      ),
      personal: const ComicPersonalData(quantity: 3, indexNumber: 7),
    );
    Object? value(String id) => columns[id]!.getValue(context);
    expect(value('comic.issue'), '2A');
    expect(value('comic.full_title'), 'Example Series #2A');
    expect(value('comic.variant_description'), 'Regular Cover');
    expect(value('comic.format'), 'Comic');
    expect(value('comic.release_date'), '2024-11');
    expect(value('comic.creator_inker'), 'Example Inker');
    expect(value('comic.quantity'), 3);
    expect(value('comic.index'), 7);
  });

  test('Issue sorts digit runs by value', () {
    final sort =
        registry.sorts.firstWhere((sort) => sort.id.value == 'comic.issue');
    final two = _context(
        const ComicCatalogItem(title: '', issueNumber: '2', variant: 'A'));
    final fifteen = _context(
        const ComicCatalogItem(title: '', issueNumber: '15', variant: 'B'));
    expect(sort.compare(two, fifteen), lessThan(0));
  });

  test('exports start from the list columns in list order', () {
    expect([
      for (final column in comicExportCapability.itemColumns)
        if (column.defaultVisible) column.label
    ], [
      'Series',
      'Issue',
      'Variant Description',
      'Publisher',
      'Release Date',
      'Storage Box',
      'Format',
      'Added Date',
    ]);
    expect(
        comicExportCapability.itemColumns
            .map((column) => column.label)
            .contains('Front Cover'),
        isFalse);
  });
}
