import 'package:collectarr_app/features/library/kinds/anime/config.dart';
import 'package:collectarr_app/features/library/kinds/anime/provider/anime_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';

final animeKindModule = LibraryKindModule(
  type: animeLibraryConfig,
  mediaAdapter: collectarrMediaAdapter(animeLibraryConfig),
  providerMapper: const AnimeLibraryKindProviderMapper(),
);
