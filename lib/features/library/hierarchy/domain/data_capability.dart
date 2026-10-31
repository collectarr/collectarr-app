import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/node.dart';

abstract interface class LibraryHierarchyDataCapability {
  Future<List<LibraryHierarchyNode>> fetchChildren({
    required ApiClient api,
    required String itemId,
  });
}
