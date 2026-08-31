import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/settings/provider_csv_import_service.dart';

class TmdbFileImportCapability implements FileImportCapability {
  const TmdbFileImportCapability();

  @override
  Future<List<ProviderPersonalEntry>> parseFile(
    String content, {
    String? filename,
  }) async {
    return const ProviderCsvImportService().parsePayload(
      content,
      provider: ProviderId.tmdb,
    );
  }
}
