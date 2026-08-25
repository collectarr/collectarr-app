import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';

@immutable
class BoardgameOwnedDetails extends OwnedItemDetails {
  const BoardgameOwnedDetails({
    this.editionLanguage,
    this.editionRegion,
    this.componentCondition,
    this.componentCompleteness,
    this.missingPiecesNotes,
    this.isSleeved = false,
    this.hasCustomInsert = false,
    this.hasPaintedMiniatures = false,
    this.storageNotes,
  });

  final String? editionLanguage;
  final String? editionRegion;
  final String? componentCondition;
  final String? componentCompleteness;
  final String? missingPiecesNotes;
  final bool isSleeved;
  final bool hasCustomInsert;
  final bool hasPaintedMiniatures;
  final String? storageNotes;

  @override
  Map<String, dynamic> toJson() => {
        if (editionLanguage != null) 'edition_language': editionLanguage,
        if (editionRegion != null) 'edition_region': editionRegion,
        if (componentCondition != null)
          'component_condition': componentCondition,
        if (componentCompleteness != null)
          'component_completeness': componentCompleteness,
        if (missingPiecesNotes != null)
          'missing_pieces_notes': missingPiecesNotes,
        if (isSleeved) 'is_sleeved': true,
        if (hasCustomInsert) 'has_custom_insert': true,
        if (hasPaintedMiniatures) 'has_painted_miniatures': true,
        if (storageNotes != null) 'storage_notes': storageNotes,
      };

  factory BoardgameOwnedDetails.fromJson(Map<String, dynamic> json) =>
      BoardgameOwnedDetails(
        editionLanguage: json['edition_language'] as String?,
        editionRegion: json['edition_region'] as String?,
        componentCondition: json['component_condition'] as String?,
        componentCompleteness: json['component_completeness'] as String?,
        missingPiecesNotes: json['missing_pieces_notes'] as String?,
        isSleeved: json['is_sleeved'] as bool? ?? false,
        hasCustomInsert: json['has_custom_insert'] as bool? ?? false,
        hasPaintedMiniatures: json['has_painted_miniatures'] as bool? ?? false,
        storageNotes: json['storage_notes'] as String?,
      );

  BoardgameOwnedDetails copyWith({
    String? editionLanguage,
    String? editionRegion,
    String? componentCondition,
    String? componentCompleteness,
    String? missingPiecesNotes,
    bool? isSleeved,
    bool? hasCustomInsert,
    bool? hasPaintedMiniatures,
    String? storageNotes,
  }) {
    return BoardgameOwnedDetails(
      editionLanguage: editionLanguage ?? this.editionLanguage,
      editionRegion: editionRegion ?? this.editionRegion,
      componentCondition: componentCondition ?? this.componentCondition,
      componentCompleteness:
          componentCompleteness ?? this.componentCompleteness,
      missingPiecesNotes: missingPiecesNotes ?? this.missingPiecesNotes,
      isSleeved: isSleeved ?? this.isSleeved,
      hasCustomInsert: hasCustomInsert ?? this.hasCustomInsert,
      hasPaintedMiniatures: hasPaintedMiniatures ?? this.hasPaintedMiniatures,
      storageNotes: storageNotes ?? this.storageNotes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardgameOwnedDetails &&
          runtimeType == other.runtimeType &&
          editionLanguage == other.editionLanguage &&
          editionRegion == other.editionRegion &&
          componentCondition == other.componentCondition &&
          componentCompleteness == other.componentCompleteness &&
          missingPiecesNotes == other.missingPiecesNotes &&
          isSleeved == other.isSleeved &&
          hasCustomInsert == other.hasCustomInsert &&
          hasPaintedMiniatures == other.hasPaintedMiniatures &&
          storageNotes == other.storageNotes;

  @override
  int get hashCode => Object.hash(
        editionLanguage,
        editionRegion,
        componentCondition,
        componentCompleteness,
        missingPiecesNotes,
        isSleeved,
        hasCustomInsert,
        hasPaintedMiniatures,
        storageNotes,
      );
}

typedef BoardGameOwnedDetails = BoardgameOwnedDetails;
