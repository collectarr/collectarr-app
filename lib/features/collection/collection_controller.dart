import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final collectionProvider = FutureProvider<List<OwnedItem>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final rows = await api.collection();
  return rows.map(OwnedItem.fromJson).toList();
});

