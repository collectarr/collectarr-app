import 'package:flutter/foundation.dart';

/// Structural serialization boundary for kind-owned copy details.
///
/// The core layer deliberately does not know which concrete kind owns a
/// details payload. Decoding and default construction belong to the owning
/// kind's codec at the feature boundary.
@immutable
abstract class OwnedItemDetails {
  const OwnedItemDetails();

  Map<String, dynamic> toJson();
}
