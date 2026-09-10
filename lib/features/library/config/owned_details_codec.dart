import 'package:collectarr_app/core/models/json_encodable.dart';

/// Serialization-only boundary used by generic persistence and sync hosts.
///
/// The concrete codec remains owned by a kind. This erased surface is allowed
/// only because JSON decoding/default construction is a serialization
/// boundary; it does not expose any kind-specific fields or domain behavior.
abstract class OwnedDetailsPersistenceCodec<TDetails extends JsonEncodable> {
  const OwnedDetailsPersistenceCodec();

  TDetails fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson(TDetails details) => details.toJson();
  Map<String, dynamic> toSyncPayload(TDetails details) => details.toJson();

  TDetails defaultDetails();

  void validate(JsonEncodable details) {
    if (details is! TDetails) {
      throw ArgumentError(
        'Invalid owned details type "${details.runtimeType}". '
        'Expected "$TDetails".',
      );
    }
  }
}
