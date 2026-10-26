import 'package:collectarr_app/core/models/partial_date.dart';
import '../domain/game_hardware_metadata.dart';

final class GameHardwareCatalogFormValues {
  GameHardwareCatalogFormValues();
  String title = '';
  String sortTitle = '';
  String barcode = '';
  String series = '';
  String description = '';
  String coverImageUrl = '';
  String platform = '';
  String hardwareType = '';
  PartialDate? releaseDateParts;
  factory GameHardwareCatalogFormValues.fromMetadata(
      GameHardwareCatalogMetadata metadata) {
    final values = GameHardwareCatalogFormValues();
    values.title = metadata.title;
    values.sortTitle = metadata.sortKey ?? '';
    values.barcode = metadata.barcode ?? '';
    values.series = metadata.seriesTitle ?? '';
    values.description = metadata.description ?? '';
    values.coverImageUrl = metadata.coverImageUrl ?? '';
    values.platform = metadata.platform ?? '';
    values.hardwareType = metadata.hardwareType ?? '';
    values.releaseDateParts = metadata.releaseDateParts;
    return values;
  }
  GameHardwareCatalogMetadata toMetadata(
          {required String title,
          List<GameHardwareCatalogLink> links = const []}) =>
      GameHardwareCatalogMetadata(
          title: title.trim(),
          sortKey: sortTitle.trim().isEmpty ? null : sortTitle.trim(),
          barcode: barcode.trim().isEmpty ? null : barcode.trim(),
          seriesTitle: series.trim().isEmpty ? null : series.trim(),
          description: description.trim().isEmpty ? null : description.trim(),
          coverImageUrl:
              coverImageUrl.trim().isEmpty ? null : coverImageUrl.trim(),
          platform: platform.trim().isEmpty ? null : platform.trim(),
          hardwareType:
              hardwareType.trim().isEmpty ? null : hardwareType.trim(),
          releaseDateParts: releaseDateParts,
          links: links);
}
