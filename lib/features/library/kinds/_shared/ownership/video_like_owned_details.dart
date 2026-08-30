/// Abstract mixin that exposes the shared video physical-copy fields
/// (features, hdrFormats, boxSetId, boxSetName, region, packaging, distributor)
/// across Movie, TV and Anime [OwnedItemDetails] subtypes.
///
/// UI code that needs these fields without branching on the concrete kind
/// can accept [VideoLikeOwnedDetails].
abstract mixin class VideoLikeOwnedDetails {
  String? get features;
  List<String> get hdrFormats;
  String? get boxSetId;
  String? get boxSetName;
  String? get region;
  String? get packaging;
  String? get distributor;
}
