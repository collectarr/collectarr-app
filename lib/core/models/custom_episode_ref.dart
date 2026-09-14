import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Structural identity for a kind-owned custom episode.
///
/// TV and Anime own separate custom-episode tables. A naked id cannot safely
/// select the owning table at a mixed-feature boundary.
final class CustomEpisodeRef {
  const CustomEpisodeRef({
    required this.kind,
    required this.id,
  });

  final CatalogMediaKind kind;
  final String id;

  String get key => '${kind.apiValue}:$id';

  @override
  bool operator ==(Object other) {
    return other is CustomEpisodeRef && other.kind == kind && other.id == id;
  }

  @override
  int get hashCode => Object.hash(kind, id);
}
