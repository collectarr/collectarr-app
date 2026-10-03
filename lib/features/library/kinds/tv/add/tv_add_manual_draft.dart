import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';

final class TvAddManualDraft implements LibraryKindAddDraft {
  TvAddManualDraft({
    TvMetadata? metadata,
    this.catalogTitle = '',
  }) : metadata = metadata ?? const TvMetadata(title: '');

  TvMetadata metadata;
  @override
  String catalogTitle;

  @override
  void dispose() {}
}
