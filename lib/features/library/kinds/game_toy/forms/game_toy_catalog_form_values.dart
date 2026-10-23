import 'package:collectarr_app/core/models/partial_date.dart';
import '../domain/game_toy_metadata.dart';

final class GameToyCatalogFormValues {
  GameToyCatalogFormValues();
  String title = '';
  String sortTitle = '';
  String barcode = '';
  String series = '';
  String description = '';
  String coverImageUrl = '';
  String toyType = '';
  String toySubtype = '';
  PartialDate? releaseDateParts;
  factory GameToyCatalogFormValues.fromMetadata(
      GameToyCatalogMetadata metadata) {
    final values = GameToyCatalogFormValues();
    values.title = metadata.title;
    values.sortTitle = metadata.sortKey ?? '';
    values.barcode = metadata.barcode ?? '';
    values.series = metadata.seriesTitle ?? '';
    values.description = metadata.description ?? '';
    values.coverImageUrl = metadata.coverImageUrl ?? '';
    values.toyType = metadata.toyType ?? '';
    values.toySubtype = metadata.toySubtype ?? '';
    values.releaseDateParts = metadata.releaseDateParts;
    return values;
  }
  GameToyCatalogMetadata toMetadata(
          {required String title, List<GameToyCatalogLink> links = const []}) =>
      GameToyCatalogMetadata(
          title: title.trim(),
          sortKey: sortTitle.trim().isEmpty ? null : sortTitle.trim(),
          barcode: barcode.trim().isEmpty ? null : barcode.trim(),
          seriesTitle: series.trim().isEmpty ? null : series.trim(),
          description: description.trim().isEmpty ? null : description.trim(),
          coverImageUrl:
              coverImageUrl.trim().isEmpty ? null : coverImageUrl.trim(),
          toyType: toyType.trim().isEmpty ? null : toyType.trim(),
          toySubtype: toySubtype.trim().isEmpty ? null : toySubtype.trim(),
          releaseDateParts: releaseDateParts,
          links: links);
}
