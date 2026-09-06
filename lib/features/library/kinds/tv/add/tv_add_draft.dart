import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_draft.dart';
import 'tv_release_add_draft.dart';
import 'package:flutter/foundation.dart';

@immutable
final class TvAddDraft extends LibraryAddKindDraft {
  const TvAddDraft({
    this.release = const TvReleaseAddDraft(),
    String? features,
    List<String>? hdrFormats,
    String? boxSetId,
    String? boxSetName,
    String? region,
    String? packaging,
    String? distributor,
  })  : _features = features,
        _hdrFormats = hdrFormats,
        _boxSetId = boxSetId,
        _boxSetName = boxSetName,
        _region = region,
        _packaging = packaging,
        _distributor = distributor;

  final TvReleaseAddDraft release;

  final String? _features;
  final List<String>? _hdrFormats;
  final String? _boxSetId;
  final String? _boxSetName;
  final String? _region;
  final String? _packaging;
  final String? _distributor;

  String? get features => _features ?? release.features;
  List<String> get hdrFormats => _hdrFormats ?? release.hdrFormats;
  String? get boxSetId => _boxSetId ?? release.boxSetId;
  String? get boxSetName => _boxSetName ?? release.boxSetName;
  String? get region => _region ?? release.region;
  String? get packaging => _packaging ?? release.packaging;
  String? get distributor => _distributor ?? release.distributor;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => TvOwnedDetailsDraft(
        features: features,
        hdrFormats: hdrFormats,
        boxSetId: boxSetId,
        boxSetName: boxSetName,
        region: region,
        packaging: packaging,
        distributor: distributor,
      );
}
