import 'package:collectarr_app/core/models/json_encodable.dart';

/// Structural edit/add draft contract for kind-owned copy details.
///
/// The concrete draft and its fields belong to the owning kind. Collection
/// only transports the draft to the kind's mutation boundary.
abstract class OwnedDetailsDraft {
  const OwnedDetailsDraft();

  JsonEncodable toDetails();
}
