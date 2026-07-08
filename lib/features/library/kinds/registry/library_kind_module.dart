import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';

class LibraryKindModule {
  const LibraryKindModule({
    required this.type,
    required this.mediaAdapter,
    this.workspaceBehavior = const LibraryKindWorkspaceBehavior(),
    this.add = const LibraryKindAddModule(),
    this.edit = const LibraryKindEditModule(),
    this.detail = const LibraryKindDetailModule(),
    this.toolbar = const LibraryKindToolbarModule(),
    this.providerMapper = const NoopLibraryKindProviderMapper(),
    this.facets = const LibraryFacetModule(),
  });

  final LibraryTypeConfig type;
  final LibraryMediaAdapter mediaAdapter;
  final LibraryKindWorkspaceBehavior workspaceBehavior;
  final LibraryKindAddModule add;
  final LibraryKindEditModule edit;
  final LibraryKindDetailModule detail;
  final LibraryKindToolbarModule toolbar;
  final LibraryKindProviderMapper providerMapper;
  final LibraryFacetModule facets;
}

class LibraryKindWorkspaceBehavior {
  const LibraryKindWorkspaceBehavior();
}

class LibraryKindAddModule {
  const LibraryKindAddModule({
    this.registerBuilders = _noop,
  });

  final void Function() registerBuilders;

  static void _noop() {}
}

class LibraryKindEditModule {
  const LibraryKindEditModule();
}

class LibraryKindDetailModule {
  const LibraryKindDetailModule();
}

class LibraryKindToolbarModule {
  const LibraryKindToolbarModule();
}

abstract class LibraryKindProviderMapper {
  const LibraryKindProviderMapper();
}

class NoopLibraryKindProviderMapper extends LibraryKindProviderMapper {
  const NoopLibraryKindProviderMapper();
}

class LibraryFacetModule {
  const LibraryFacetModule();
}
