import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';

@immutable
class BoardgameOwnedDetails extends OwnedItemDetails {
  const BoardgameOwnedDetails();

  @override
  Map<String, dynamic> toJson() => const <String, dynamic>{};

  factory BoardgameOwnedDetails.fromJson(Map<String, dynamic> json) =>
      const BoardgameOwnedDetails();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardgameOwnedDetails && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

// Alias if requested
typedef BoardGameOwnedDetails = BoardgameOwnedDetails;
