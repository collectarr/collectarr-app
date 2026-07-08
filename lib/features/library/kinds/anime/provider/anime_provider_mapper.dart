import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class AnimeLibraryKindProviderMapper extends CommonLibraryKindProviderMapper {
  const AnimeLibraryKindProviderMapper();

  @override
  LibraryMetadataItem metadataItemFromPreview(AdminProviderPreview preview) {
    return super.metadataItemFromPreview(preview).copyWith(
          video: preview.video,
        );
  }
}
