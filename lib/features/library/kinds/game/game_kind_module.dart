import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/game/provider/game_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';

final gameKindModule = LibraryKindModule(
  type: gamesLibraryConfig,
  mediaAdapter: collectarrMediaAdapter(gamesLibraryConfig),
  providerMapper: const GameLibraryKindProviderMapper(),
);
