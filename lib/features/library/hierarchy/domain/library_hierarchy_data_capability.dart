import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';

abstract interface class LibraryHierarchyDataCapability {
  Future<List<LibraryHierarchyNode>> fetchChildren({
    required String itemId,
    String? provider,
    String? providerItemId,
  });
}
