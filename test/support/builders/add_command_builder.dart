import 'package:collectarr_app/features/library/kinds/game_hardware/add/draft.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/add/draft.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';

import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/draft.dart';

import 'catalog_item_builder.dart';

AddLibraryEntryCommand typedAddLibraryEntryCommand({
  required CatalogItemRef catalogRef,
  required LibraryAddCommonDraft common,
  required JsonEncodable details,
  String? grade,
  LibraryEntryCreatePayload? typedPayload,
  LibraryEntryTrackingDraft? tracking,
}) {
  if (typedPayload != null) {
    return AddLibraryEntryCommand(
      catalogRef: catalogRef,
      typedPayload: typedPayload,
      tracking: tracking,
    );
  }
  final add = libraryAddForKind(catalogRef.kind);
  return add.buildCommandFromDetails(
    CatalogSearchCandidate.fromItem(
      testCatalogItem(
        id: catalogRef.id,
        kind: catalogRef.kind.apiValue,
      ),
    ),
    LibraryAddCommonDraft(
      condition: common.condition,
      purchaseDate: common.purchaseDate,
      pricePaidCents: common.pricePaidCents,
      currency: common.currency,
      personalNotes: common.personalNotes,
      tags: common.tags,
      locationId: common.locationId,
      purchaseStore: common.purchaseStore,
      collectionStatus: common.collectionStatus,
      isDigital: common.isDigital,
    ),
    details,
    draft: _addDraftWithGrade(catalogRef.kind, grade),
    tracking: LibraryAddTrackingDraft(
      readStatus: mediaTrackingStatusToStorageValue(tracking?.status),
      rating: tracking?.rating,
      startedAt: tracking?.startedAt,
      finishedAt: tracking?.finishedAt,
      notes: tracking?.notes,
    ),
  );
}

LibraryAddKindDraft? _addDraftWithGrade(CatalogMediaKind kind, String? grade) {
  if (grade == null) return null;
  return switch (kind) {
    CatalogMediaKind.boardgame => BoardgameAddDraft(grade: grade),
    CatalogMediaKind.book => BookAddDraft(grade: grade),
    CatalogMediaKind.comic => ComicAddDraft(grade: grade),
    CatalogMediaKind.game => GameAddDraft(grade: grade),
    CatalogMediaKind.gameHardware => GameHardwareAddDraft(grade: grade),
    CatalogMediaKind.gameToy => GameToyAddDraft(grade: grade),
    CatalogMediaKind.movie => MovieAddDraft(grade: grade),
    CatalogMediaKind.music => MusicAddDraft(grade: grade),
    CatalogMediaKind.unknown => null,
  };
}
