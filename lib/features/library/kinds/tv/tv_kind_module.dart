import 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';

final tvKindModule = LibraryKindModule(
  type: tvLibraryConfig,
  mediaAdapter: collectarrMediaAdapter(tvLibraryConfig),
  providerMapper: const TvLibraryKindProviderMapper(),
);
