import 'package:collectarr_app/features/library/kinds/music/domain/music_box_set_membership.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';

/// Flutter independent values for one concrete pressing or edition.
final class MusicReleaseFormValues {
  MusicReleaseFormValues({
    this.title = '',
    this.sortTitle = '',
    this.subtitle = '',
    this.releaseType = '',
    this.releaseStatus = '',
    this.releaseDate,
    this.publisher = '',
    this.countryCode = '',
    this.language = '',
    this.barcode = '',
    this.upc = '',
    this.catalogNumber = '',
    this.packaging = '',
    this.physicalFormat = '',
    this.physicalFormatLabel = '',
    this.boxSetName = '',
    this.coverImageUrl = '',
    this.boxSetMembership,
  });

  factory MusicReleaseFormValues.fromRelease(MusicRelease release) =>
      MusicReleaseFormValues(
        title: release.title,
        sortTitle: release.sortTitle ?? '',
        subtitle: release.subtitle ?? '',
        releaseType: release.releaseType ?? '',
        releaseStatus: release.releaseStatus ?? '',
        releaseDate: release.releaseDate,
        publisher: release.publisher ?? '',
        countryCode: release.countryCode ?? '',
        language: release.language ?? '',
        barcode: release.barcode ?? '',
        upc: release.upc ?? '',
        catalogNumber: release.catalogNumber ?? '',
        packaging: release.packaging ?? '',
        physicalFormat: release.physicalFormat ?? '',
        physicalFormatLabel: release.physicalFormatLabel ?? '',
        boxSetName: release.boxSetName ?? '',
        coverImageUrl: release.coverImageUrl ?? '',
        boxSetMembership: release.boxSetMembership,
      );

  String title;
  String sortTitle;
  String subtitle;
  String releaseType;
  String releaseStatus;
  DateTime? releaseDate;
  String publisher;
  String countryCode;
  String language;
  String barcode;
  String upc;
  String catalogNumber;
  String packaging;
  String physicalFormat;
  String physicalFormatLabel;
  String boxSetName;
  String coverImageUrl;
  MusicBoxSetMembership? boxSetMembership;
}
