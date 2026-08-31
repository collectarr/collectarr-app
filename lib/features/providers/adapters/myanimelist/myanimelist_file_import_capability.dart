import 'package:collectarr_app/features/imports/framework/import_models.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/settings/anime_list_import_service.dart';

class MyAnimeListFileImportCapability implements FileImportCapability {
  const MyAnimeListFileImportCapability();

  @override
  Future<List<ProviderPersonalEntry>> parseFile(
    String content, {
    String? filename,
  }) async {
    final rows = const AnimeListImportService().parsePayload(
      content,
      provider: ProviderId.myAnimeList,
    );
    return [
      for (final row in rows)
        row.toProviderPersonalEntry(ProviderId.myAnimeList),
    ];
  }
}
