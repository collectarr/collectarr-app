import 'package:collectarr_app/features/imports/framework/import_models.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/settings/anime_list_import_service.dart';

class AniListFileImportCapability implements FileImportCapability {
  const AniListFileImportCapability();

  @override
  Future<List<ProviderPersonalEntry>> parseFile(
    String content, {
    String? filename,
  }) async {
    return const AnimeListImportService().parsePayload(
      content,
      provider: ProviderId.aniList,
    );
  }
}
