import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/imports/personal_lists/anime_list_import_service.dart';

class MyAnimeListPersonalListFileImportCapability
    implements PersonalListFileImportCapability {
  const MyAnimeListPersonalListFileImportCapability();

  @override
  Future<List<ProviderPersonalEntry>> parsePersonalListFile(
    String content, {
    String? filename,
  }) async {
    return const AnimeListImportService().parsePayload(
      content,
      provider: ProviderId.myAnimeList,
    );
  }
}
