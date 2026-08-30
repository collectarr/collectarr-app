import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/_shared/add/video_physical_release_draft.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MovieAddDraft extends LibraryAddKindDraft {
  const MovieAddDraft({
    this.release = const VideoPhysicalReleaseDraft(),
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

  final VideoPhysicalReleaseDraft release;

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
  CatalogMediaKind get kind => CatalogMediaKind.movie;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => MovieOwnedDetailsDraft(
        features: features,
        hdrFormats: hdrFormats,
        boxSetId: boxSetId,
        boxSetName: boxSetName,
        region: region,
        packaging: packaging,
        distributor: distributor,
      );
}
