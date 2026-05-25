import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shelfVolumesProvider =
    FutureProvider.autoDispose.family<List<Season>, String>((ref, itemId) async {
  final api = ref.watch(apiClientProvider);
  return api.getItemVolumes(itemId);
});
