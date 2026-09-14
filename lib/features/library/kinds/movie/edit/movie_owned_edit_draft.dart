import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';

final class MovieOwnedEditDraft {
  factory MovieOwnedEditDraft.fromDetails(MovieOwnedDetails details) {
    return MovieOwnedEditDraft(
      featuresController: TextEditingController(text: details.features),
      boxSetIdController: TextEditingController(text: details.boxSetId),
      boxSetNameController: TextEditingController(text: details.boxSetName),
      regionController: TextEditingController(text: details.region),
      packagingController: TextEditingController(text: details.packaging),
      distributorController: TextEditingController(text: details.distributor),
      hdrFormats: List<String>.from(details.hdrFormats),
    );
  }

  MovieOwnedEditDraft({
    required this.featuresController,
    required this.boxSetIdController,
    required this.boxSetNameController,
    required this.regionController,
    required this.packagingController,
    required this.distributorController,
    required this.hdrFormats,
  });

  final TextEditingController featuresController;
  final TextEditingController boxSetIdController;
  final TextEditingController boxSetNameController;
  final TextEditingController regionController;
  final TextEditingController packagingController;
  final TextEditingController distributorController;
  List<String> hdrFormats;

  String? get features => _emptyToNull(featuresController.text);
  set features(String? value) => featuresController.text = value ?? '';
  String? get boxSetId => _emptyToNull(boxSetIdController.text);
  set boxSetId(String? value) => boxSetIdController.text = value ?? '';
  String? get boxSetName => _emptyToNull(boxSetNameController.text);
  set boxSetName(String? value) => boxSetNameController.text = value ?? '';
  String? get region => _emptyToNull(regionController.text);
  set region(String? value) => regionController.text = value ?? '';
  String? get packaging => _emptyToNull(packagingController.text);
  set packaging(String? value) => packagingController.text = value ?? '';
  String? get distributor => _emptyToNull(distributorController.text);
  set distributor(String? value) => distributorController.text = value ?? '';

  MovieOwnedDetails toDetails() => MovieOwnedDetails(
        features: features,
        hdrFormats: List.unmodifiable(hdrFormats),
        boxSetId: boxSetId,
        boxSetName: boxSetName,
        region: region,
        packaging: packaging,
        distributor: distributor,
      );

  void dispose() {
    featuresController.dispose();
    boxSetIdController.dispose();
    boxSetNameController.dispose();
    regionController.dispose();
    packagingController.dispose();
    distributorController.dispose();
  }
}

String? _emptyToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
