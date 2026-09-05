import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/imports/personal_lists/provider_csv_import_service.dart';

class TmdbPersonalListFileImportCapability
    implements PersonalListFileImportCapability {
  const TmdbPersonalListFileImportCapability();

  @override
  Future<List<ProviderPersonalEntry>> parsePersonalListFile(
    String content, {
    String? filename,
  }) async {
    return const ProviderCsvImportService().parsePayload(
      content,
      provider: ProviderId.tmdb,
    );
  }
}
