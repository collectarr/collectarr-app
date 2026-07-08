import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart'
    as comic_add;
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';

final comicKindModule = LibraryKindModule(
  type: comicsLibraryConfig,
  mediaAdapter: collectarrMediaAdapter(comicsLibraryConfig),
  add: LibraryKindAddModule(registerBuilders: comic_add.registerComicAddBuilders),
  providerMapper: const DefaultLibraryKindProviderMapper(),
);
