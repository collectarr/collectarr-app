import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_external_link_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';

/// Board Game Add state contains typed catalog values; schema renderers own inputs.
final class BoardgameAddManualDraft
    implements LibraryKindAddDraftWithResources {
  BoardgameAddManualDraft({
    BoardGameCatalogFormValues? values,
    this.catalogTitle = '',
  }) : values = values ?? BoardGameCatalogFormValues();

  final BoardGameCatalogFormValues values;
  final List<BoardGameExternalLinkDraft> externalLinks = [];
  @override
  String catalogTitle;

  @override
  void dispose() {
    for (final link in externalLinks) {
      link.dispose();
    }
  }
}
