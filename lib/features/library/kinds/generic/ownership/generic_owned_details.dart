import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

@immutable
class GenericOwnedDetails implements JsonEncodable {
  const GenericOwnedDetails();

  @override
  Map<String, dynamic> toJson() => const <String, dynamic>{};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenericOwnedDetails && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
