import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

final shelfVolumesProvider =
    FutureProvider.autoDispose.family<List<Season>, String>((ref, itemId) async {
  if (!_uuidPattern.hasMatch(itemId)) {
    return const <Season>[];
  }
  final api = ref.watch(apiClientProvider);
  return api.getItemVolumes(itemId);
});
