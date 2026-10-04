import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_credit_draft.dart';

final class TvAddManualDraft implements LibraryKindAddDraft {
  TvAddManualDraft({
    TvMetadata? metadata,
    this.catalogTitle = '',
  }) : metadata = metadata ?? const TvMetadata(title: '');

  TvMetadata metadata;
  final List<EditableTvCredit> castCredits = [];
  final List<EditableTvCredit> crewCredits = [];
  @override
  String catalogTitle;

  @override
  void dispose() {
    for (final credit in [...castCredits, ...crewCredits]) {
      credit.dispose();
    }
  }
}
