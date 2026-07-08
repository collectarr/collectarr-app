import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_comparisons.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

final gameKindModule = LibraryKindModule(
  type: gamesLibraryConfig,
  mediaAdapter: collectarrMediaAdapter(gamesLibraryConfig),
  providerMapper: const _GameLibraryKindProviderMapper(),
);

class _GameLibraryKindProviderMapper extends DefaultLibraryKindProviderMapper {
  const _GameLibraryKindProviderMapper();

  @override
  LibraryMetadataItem metadataItemFromPreview(AdminProviderPreview preview) {
    return super.metadataItemFromPreview(preview).copyWith(
          game: preview.game,
        );
  }

  @override
  Map<String, Object?> buildCorrections({
    required LibraryMetadataItem preview,
    required LibraryMetadataItem edited,
  }) {
    final corrections = super.buildCorrections(
      preview: preview,
      edited: edited,
    );
    if (!sameStringList(edited.game?.platforms, preview.game?.platforms)) {
      corrections['platforms'] = edited.game?.platforms;
    }
    return corrections;
  }
}
