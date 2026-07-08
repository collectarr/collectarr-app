import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_comparisons.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

final musicKindModule = LibraryKindModule(
  type: musicLibraryConfig,
  mediaAdapter: collectarrMediaAdapter(musicLibraryConfig),
  providerMapper: const _MusicLibraryKindProviderMapper(),
);

class _MusicLibraryKindProviderMapper extends DefaultLibraryKindProviderMapper {
  const _MusicLibraryKindProviderMapper();

  @override
  LibraryMetadataItem metadataItemFromPreview(AdminProviderPreview preview) {
    return super.metadataItemFromPreview(preview).copyWith(
          music: preview.music,
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
    if (!sameTracks(edited.music?.tracks, preview.music?.tracks)) {
      corrections['tracks'] = edited.music?.tracks;
    }
    if (edited.music?.catalogNumber != preview.music?.catalogNumber) {
      corrections['catalog_number'] = edited.music?.catalogNumber;
    }
    if (edited.music?.releaseStatus != preview.music?.releaseStatus) {
      corrections['release_status'] = edited.music?.releaseStatus;
    }
    return corrections;
  }
}
