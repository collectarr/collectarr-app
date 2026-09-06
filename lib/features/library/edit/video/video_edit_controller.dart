import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/user_external_links_cache_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:collectarr_app/features/library/edit/video/video_edit_models.dart';

class VideoEditController {
  VideoEditController({
    this.ref,
    required this.itemId,
    this.initialRuntime = '',
    this.initialAgeRating = '',
    this.initialAudienceRating = '',
    this.initialGenres = '',
    this.initialEditionTitle = '',
    this.initialVariant = '',
    this.initialBarcode = '',
    this.initialPhysicalFormatLabel = '',
    this.initialPhysicalFormatId,
    this.initialPublisher = '',
    this.initialCountry = '',
    this.initialLanguage = '',
    this.initialReleaseDate = '',
    this.initialReleaseYear = '',
    this.initialCreators = const <Map<String, dynamic>>[],
    this.initialTrailerLinks = const <TrailerLink>[],
  })  : runtimeController = TextEditingController(text: initialRuntime),
        ageRatingController = TextEditingController(text: initialAgeRating),
        audienceRatingController =
            TextEditingController(text: initialAudienceRating),
        genresEditController = TextEditingController(text: initialGenres),
        editionTitleController =
            TextEditingController(text: initialEditionTitle),
        variantController = TextEditingController(text: initialVariant),
        barcodeController = TextEditingController(text: initialBarcode),
        physicalFormatLabelController =
            TextEditingController(text: initialPhysicalFormatLabel),
        physicalFormatId = initialPhysicalFormatId,
        publisherController = TextEditingController(text: initialPublisher),
        countryController = TextEditingController(text: initialCountry),
        languageController = TextEditingController(text: initialLanguage),
        releaseDateController = TextEditingController(text: initialReleaseDate),
        releaseYearController = TextEditingController(text: initialReleaseYear);

  final WidgetRef? ref;
  final String itemId;
  final String initialRuntime;
  final String initialAgeRating;
  final String initialAudienceRating;
  final String initialGenres;
  final String initialEditionTitle;
  final String initialVariant;
  final String initialBarcode;
  final String initialPhysicalFormatLabel;
  final String? initialPhysicalFormatId;
  final String initialPublisher;
  final String initialCountry;
  final String initialLanguage;
  final String initialReleaseDate;
  final String initialReleaseYear;
  final List<Map<String, dynamic>> initialCreators;
  final List<TrailerLink> initialTrailerLinks;

  final TextEditingController runtimeController;
  final TextEditingController ageRatingController;
  final TextEditingController audienceRatingController;
  final TextEditingController genresEditController;

  final TextEditingController editionTitleController;
  final TextEditingController variantController;
  final TextEditingController barcodeController;
  final TextEditingController physicalFormatLabelController;
  String? physicalFormatId;
  final TextEditingController publisherController;
  final TextEditingController countryController;
  final TextEditingController languageController;
  final TextEditingController releaseDateController;
  final TextEditingController releaseYearController;

  final List<EditableVideoCredit> castCredits = [];
  final List<EditableVideoCredit> crewCredits = [];
  final List<EditableUserExternalLink> userLinkEdits = [];
  final List<EditableUserExternalLink> userTrailerEdits = [];
  static final _dummyController = TextEditingController();

  TextEditingController get audioTracksController => _dummyController;
  TextEditingController get subtitlesController => _dummyController;
  TextEditingController get layersController => _dummyController;
  TextEditingController get colorController => _dummyController;
  TextEditingController get nrDiscsController => _dummyController;

  void initializeVideoEditors() {
    final creators = initialCreators;
    castCredits.addAll(
      splitVideoCredits(creators, kind: VideoCreditKind.cast),
    );
    crewCredits.addAll(
      splitVideoCredits(creators, kind: VideoCreditKind.crew),
    );
  }

  Future<void> loadUserExternalLinks() async {
    if (ref == null) {
      return;
    }
    final db = ref!.read(localDatabaseProvider);
    final repo = UserExternalLinksCacheRepository(db);
    final links = [
      ...await repo.listByItemId(itemId),
      for (final link in initialTrailerLinks.where((link) => !link.isAutomatic))
        UserExternalLink(
          id: 'seed-$itemId-${link.kind}-${link.url.hashCode}',
          itemId: itemId,
          label: link.title ?? link.description ?? link.url,
          url: link.url,
          kind: link.kind == 'trailer' ? 'trailer' : 'custom',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
    ];
    final seen = <String>{};
    for (final link in links) {
      final key = '${link.kind}|${link.label}|${link.url}';
      if (!seen.add(key)) {
        continue;
      }
      final editable = EditableUserExternalLink.fromUserExternalLink(link);
      if (editable.kind == 'trailer') {
        userTrailerEdits.add(editable);
      } else {
        userLinkEdits.add(editable);
      }
    }
  }

  void dispose() {
    runtimeController.dispose();
    ageRatingController.dispose();
    audienceRatingController.dispose();
    genresEditController.dispose();
    editionTitleController.dispose();
    variantController.dispose();
    barcodeController.dispose();
    physicalFormatLabelController.dispose();
    publisherController.dispose();
    countryController.dispose();
    languageController.dispose();
    releaseDateController.dispose();
    releaseYearController.dispose();
    for (final credit in castCredits) {
      credit.dispose();
    }
    for (final credit in crewCredits) {
      credit.dispose();
    }
    for (final link in userLinkEdits) {
      link.dispose();
    }
    for (final link in userTrailerEdits) {
      link.dispose();
    }
  }

  List<TrailerLink>? buildUpdatedTrailerUrls(List<TrailerLink> existing) {
    final preservedTrailers = existing
        .where((link) => link.isTrailerLink && link.isAutomatic)
        .toList(growable: false);
    final providerExternalLinks = existing
        .where((link) => link.isExternalLink && link.isAutomatic)
        .toList(growable: false);
    final merged = <TrailerLink>[
      ...preservedTrailers,
      ...providerExternalLinks,
    ];
    return merged.isEmpty ? null : List<TrailerLink>.unmodifiable(merged);
  }

  Future<void> persistUserExternalLinks() async {
    if (ref == null) {
      return;
    }
    final db = ref!.read(localDatabaseProvider);
    final repo = UserExternalLinksCacheRepository(db);
    final links = <UserExternalLink>[];
    for (final link in userLinkEdits) {
      final resolved = link.toUserExternalLink(itemId: itemId);
      if (resolved != null) {
        links.add(resolved);
      }
    }
    for (final link in userTrailerEdits) {
      final resolved = link.toUserExternalLink(itemId: itemId);
      if (resolved != null) {
        links.add(resolved);
      }
    }
    await repo.replaceForItem(itemId, links);
  }
}
