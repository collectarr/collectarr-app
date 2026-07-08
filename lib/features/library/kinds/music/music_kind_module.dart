import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';

final musicKindModule = LibraryKindModule(
  type: musicLibraryConfig,
  mediaAdapter: collectarrMediaAdapter(musicLibraryConfig),
  providerMapper: const MusicLibraryKindProviderMapper(),
);
