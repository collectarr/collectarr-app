import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import '../forms/game_hardware_catalog_form_values.dart';

final class GameHardwareAddManualDraft
    implements LibraryKindAddDraftWithResources {
  GameHardwareAddManualDraft();
  final values = GameHardwareCatalogFormValues();
  @override
  String catalogTitle = '';
  final List<LibraryExternalLinkDraftRow> externalLinks = [];
  final List<LibraryExternalLinkDraftRow> trailers = [];
  @override
  void dispose() {
    for (final link in [...externalLinks, ...trailers]) {
      link.dispose();
    }
  }
}
