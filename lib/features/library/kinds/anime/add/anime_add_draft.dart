import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/entries/anime_entry_details_draft.dart';
import 'package:flutter/foundation.dart';

@immutable
final class AnimeAddDraft extends LibraryAddKindDraft {
  const AnimeAddDraft({
    this.grade = 'Ungraded',
    this.features,
    this.hdrFormats = const [],
    this.boxSetId,
    this.boxSetName,
    this.region,
    this.packaging,
    this.distributor,
  });

  final String? grade;
  final String? features;
  final List<String> hdrFormats;
  final String? boxSetId;
  final String? boxSetName;
  final String? region;
  final String? packaging;
  final String? distributor;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  JsonEncodable toEntryDetailsDraft() => AnimeEntryDetailsDraft(
        features: features,
        hdrFormats: hdrFormats,
        boxSetId: boxSetId,
        boxSetName: boxSetName,
        region: region,
        packaging: packaging,
        distributor: distributor,
      );
}
