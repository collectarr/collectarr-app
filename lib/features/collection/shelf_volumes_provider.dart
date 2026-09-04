import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shelfVolumesProvider = FutureProvider.autoDispose
    .family<List<Season>, ({String itemId, bool canHydrateFromCore})>(
  (ref, params) async {
    if (!params.canHydrateFromCore) {
      return const <Season>[];
    }
    final api = ref.watch(apiClientProvider);
    return api.getItemVolumes(
      params.itemId,
      kind: CatalogMediaKind.manga.apiValue,
    );
  },
);
