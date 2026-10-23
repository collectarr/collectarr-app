import 'package:collectarr_app/features/library/kinds/game/data/game_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_value_summary.dart';
import 'package:collectarr_app/features/library/kinds/game/config/game_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_personal_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

typedef _GameSortValue = Comparable<Object?>? Function(
    LibraryProjectionContext<GameWorkspaceDto> context,
    GameLibraryEntry? entry);

final gameCatalogWorkspaceSorts = [
  sortFromField<GameKind, GameWorkspaceDto, String>(
      GameCatalogWorkspaceFields.platform),
  sortFromField<GameKind, GameWorkspaceDto, String>(
      GameCatalogWorkspaceFields.title),
  sortFromField<GameKind, GameWorkspaceDto, String>(
      GameCatalogWorkspaceFields.publisher),
  if (GameFieldIdentities.releaseDate.sortable)
    sortFromField<GameKind, GameWorkspaceDto, DateTime>(
      GameCatalogWorkspaceFields.releaseDate,
      defaultAscending: false,
    ),
  sortFromField<GameKind, GameWorkspaceDto, String>(
      GameCatalogWorkspaceFields.edition),
  if (GameFieldIdentities.barcode.sortable)
    sortFromField<GameKind, GameWorkspaceDto, String>(
      GameCatalogWorkspaceFields.barcode,
    ),
];

final gamePersonalWorkspaceSorts = [
  LibrarySortDefinition<GameKind, GameWorkspaceDto>(
    id: GameSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<GameWorkspaceDto> ctx) {
        if ((ctx.item.entrySummary != null)) return 0;
        if (ctx.personal.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
  sortFromField<GameKind, GameWorkspaceDto, num>(
    GamePersonalWorkspaceFields.loosePrice,
    defaultAscending: false,
  ),
  sortFromField<GameKind, GameWorkspaceDto, num>(
    GamePersonalWorkspaceFields.cibPrice,
    defaultAscending: false,
  ),
];

/// Catalog sort fields of the reference Games sort menu that the catalog
/// columns do not already provide.
final gameCatalogExtraSortDefinitions = [
  _sort('sort_title', 'Sort Title', 'Main',
      (context, _) => _text(context.dto.metadata.sortKey ?? context.dto.title)),
  _sort('series_sort', 'Series', 'Main',
      (context, _) => _text(context.dto.metadata.seriesTitle)),
  _sort('developer_sort', 'Developer', 'Main',
      (context, _) => _text(context.dto.metadata.developers.firstOrNull)),
  _sort('format_sort', 'Format', 'Edition',
      (context, _) => _text(context.dto.format)),
  _sort('region_sort', 'Region', 'Edition',
      (context, _) => _text(context.dto.metadata.releaseRegion)),
];

/// Copy sort fields of the reference Games sort menu.
final gamePersonalSortDefinitions = [
  _sort('completeness_sort', 'Completeness', 'Value', (_, entry) {
    final key = entry?.personal.details.completeness;
    final index =
        gameCompletenessOptions.indexWhere((option) => option.$1 == key);
    return index < 0 ? null : index;
  }),
  _sort('box', 'Box', 'Value',
      (_, entry) => _flag(entry?.personal.details.hasBox)),
  _sort('manual', 'Manual', 'Value',
      (_, entry) => _flag(entry?.personal.details.hasManual)),
  _sort(
      'value', 'Value', 'Value', (_, entry) => entry?.personal.marketValueCents,
      ascending: false),
  _sort('purchase_price', 'Purchase Price', 'Value',
      (_, entry) => entry?.personal.pricePaidCents,
      ascending: false),
  _sort('purchase_date_sort', 'Purchase Date', 'Value',
      (_, entry) => entry?.personal.purchaseDateParts?.isoString,
      ascending: false),
  _sort('purchase_store_sort', 'Purchase Store', 'Value',
      (_, entry) => _text(entry?.personal.purchaseStore)),
  _sort('pricecharting_id_sort', 'PriceCharting ID', 'Value',
      (_, entry) => _text(entry?.personal.details.priceChartingId)),
  _sort(
      'index', 'Index', 'Personal', (_, entry) => entry?.personal.indexNumber),
  _sort('quantity', 'Quantity', 'Personal',
      (_, entry) => entry?.personal.quantity),
  _sort('added_date_sort', 'Added Date/Time', 'Personal',
      (context, entry) => entry?.createdAt ?? context.addedAt,
      ascending: false),
  _sort('modified_date_sort', 'Modified Date/Time', 'Personal',
      (context, entry) => entry?.updatedAt ?? context.updatedAt,
      ascending: false),
  _sort('my_rating', 'My Rating', 'Personal',
      (_, entry) => entry?.personal.rating,
      ascending: false),
  _sort('completed_date_sort', 'Completed Date', 'Personal',
      (_, entry) => entry?.personal.details.completedDate?.isoString,
      ascending: false),
  _sort('owner_sort', 'Owner', 'Personal',
      (_, entry) => _text(entry?.personal.ownerLabel)),
  _sort('storage', 'Storage', 'Personal',
      (_, entry) => _text(entry?.personal.details.storageDevice)),
  _sort('storage_slot', 'Storage Slot', 'Personal',
      (_, entry) => _text(entry?.personal.details.storageSlot)),
  _sort('notes', 'Notes', 'Personal',
      (_, entry) => _text(entry?.personal.personalNotes)),
];

LibrarySortDefinition<GameKind, GameWorkspaceDto> _sort(
  String key,
  String label,
  String group,
  _GameSortValue value, {
  bool ascending = true,
}) =>
    LibrarySortDefinition<GameKind, GameWorkspaceDto>(
      id: LibrarySortId<GameKind>('game.$key'),
      label: label,
      group: group,
      defaultAscending: ascending,
      compare: (left, right) {
        Comparable<Object?>? of(
                LibraryProjectionContext<GameWorkspaceDto> context) =>
            value(
                context,
                GameLibraryEntryProjection.fromDispatch(
                    context.item.libraryEntryDispatch));
        final a = of(left);
        final b = of(right);
        // Items without a value follow those with one in either direction.
        if (a == null && b == null) {
          return left.dto.title.compareTo(right.dto.title);
        }
        if (a == null) return 1;
        if (b == null) return -1;
        final result = a.compareTo(b);
        return result != 0 ? result : left.dto.title.compareTo(right.dto.title);
      },
    );

String? _text(String? value) {
  final normalized = value?.trim().toLowerCase();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

int? _flag(bool? value) => value == null ? null : (value ? 1 : 0);
