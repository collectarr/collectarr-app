import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';

export 'package:collectarr_app/features/catalog/transport/catalog_transport_summary_registry.dart'
    show libraryCatalogTransportCodecs;

List<CatalogKindLookup> libraryCatalogLookups(LocalDatabase database) => [
      MusicCatalogLookup(database),
    ];
