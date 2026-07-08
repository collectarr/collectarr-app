import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';

final bookKindModule = LibraryKindModule(
  type: booksLibraryConfig,
  mediaAdapter: collectarrMediaAdapter(booksLibraryConfig),
);
