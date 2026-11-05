import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/tiles/card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/grading_options.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/slab.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/card_body.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a comic workspace item.
LibraryCardPresentation buildComicCardPresentation(
  LibraryProjectionView item, {
  required bool coverFocused,
}) {
  final comicDto =
      item.dto is ComicWorkspaceDto ? item.dto as ComicWorkspaceDto : null;
  final libraryEntry = item.dto is ComicWorkspaceDto
      ? (item.dto as ComicWorkspaceDto).libraryEntry
      : null;
  final comicDetails = libraryEntry?.personal.details;
  final badges = <LibraryCardBadge>[];

  if (comicDetails?.keyComic == true) {
    badges.add(
      LibraryCardBadge(
        icon: Icons.label_important,
        label: comicDetails?.keyReason?.isNotEmpty == true
            ? comicDetails!.keyReason!
            : 'Key item',
      ),
    );
  }

  final personal = libraryEntry?.personal;
  final slabbed = comicDetails?.isSlabbed == true;
  final fields = ComicCardFields(
    headline: comicDto?.seriesTitle ?? comicDto?.title,
    numberLabel: switch ('${comicDto?.itemNumber ?? ''}'
        '${comicDto?.variant ?? ''}') {
      '' => null,
      final number => '#$number',
    },
    date: switch (AppFormats.current.formatPartialDate(
        comicDto?.comic.releaseDateParts ?? comicDto?.comic.coverDateParts)) {
      '' => null,
      final date => date,
    },
    pill: personal == null
        ? null
        : comicGradeAndValuePill(
            grade: personal.grade,
            valueCents: personal.marketValueCents,
            currency: personal.currency,
            slabbed: slabbed,
            labelType: comicDetails?.labelType),
  );

  return LibraryCardPresentation(
    flowSubtitle: libraryFlowSubtitle([
      if (comicDto?.itemNumber?.trim().isNotEmpty ?? false)
        '#${comicDto?.itemNumber}',
      comicDto?.format,
      comicDto?.releaseDate?.year.toString()
    ]),
    horizontalBodyBuilder: (context, data) =>
        buildComicHorizontalCardBody(context, data, fields),
    verticalBodyBuilder: (context, data) =>
        buildComicVerticalCardBody(context, data, fields),
    itemNumber: comicDto?.itemNumber,
    variant: comicDto?.variant,
    releaseDate: comicDto?.releaseDate,
    format: comicDto?.format,
    synopsis: comicDto?.synopsis,
    seriesTitle: comicDto?.seriesTitle,
    identifierCode: comicDto?.identifierCode,
    currency: comicDto?.currency,
    contextFacts: [
      comicDto?.artist,
      comicDto?.publisher,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList(),
    coverOverlayBuilder: slabbed
        ? (child) => ComicSlab(
              grade: personal?.grade,
              gradingCompany: comicDetails?.gradingCompany,
              labelType: comicDetails?.labelType,
              customLabel: comicDetails?.customLabel,
              child: child,
            )
        : null,
    compactBadges: badges,
  );
}

/// The reference's grade and value ribbon: the grade's code, on the slab
/// label's colours with a slab mark when slabbed, then My Value; a dash
/// stands in for a missing grade.
LibraryCardPill? comicGradeAndValuePill({
  required String? grade,
  required int? valueCents,
  required String? currency,
  required bool slabbed,
  required String? labelType,
}) {
  final rawGrade = grade?.trim();
  final code = comicGradeCode(grade) ??
      (rawGrade != null &&
              comicGrades.any((option) => option.split(' ').first == rawGrade)
          ? rawGrade
          : null);
  if (code == null && valueCents == null) return null;
  return LibraryCardPill(
    lead: code ?? '–',
    leadIcon: slabbed ? Icons.crop_portrait : null,
    leadBackground:
        slabbed ? comicSlabLabelGradient(comicSlabLabel(labelType)) : null,
    value: valueCents == null
        ? null
        : AppFormats.current
            .formatMoney(valueCents, currency ?? AppFormats.current.currency),
    valueIcon: valueCents == null ? null : Icons.person,
  );
}
