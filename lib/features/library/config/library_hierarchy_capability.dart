import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';

import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_data_capability.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';

/// Encapsulates content hierarchy and kind-owned child loading.
class LibraryHierarchyCapability implements LibraryHierarchyDataCapability {
  const LibraryHierarchyCapability({
    this.childrenTitleBuilder,
    this.fetchChildrenCallback,
    this.browserDelegateBuilder,
    this.contractDiagnosticLabelBuilder,
  });

  final String Function(int count)? childrenTitleBuilder;
  final Future<List<LibraryHierarchyNode>> Function({
    required ApiClient api,
    required String itemId,
    String? provider,
    String? providerItemId,
  })? fetchChildrenCallback;
  final LibraryKindBrowserDelegate Function()? browserDelegateBuilder;
  final String? Function(LibraryProjectionView item)?
      contractDiagnosticLabelBuilder;

  LibraryKindBrowserDelegate buildBrowserDelegate() {
    return browserDelegateBuilder?.call() ?? LibraryNoopBrowserDelegate();
  }

  @override
  Future<List<LibraryHierarchyNode>> fetchChildren({
    required ApiClient api,
    required String itemId,
    String? provider,
    String? providerItemId,
  }) async {
    if (fetchChildrenCallback != null) {
      return fetchChildrenCallback!(
        api: api,
        itemId: itemId,
        provider: provider,
        providerItemId: providerItemId,
      );
    }
    return const <LibraryHierarchyNode>[];
  }

  String childrenTitle(int count) =>
      childrenTitleBuilder?.call(count) ?? 'Contents ($count)';

  String? contractDiagnosticLabel(LibraryProjectionView item) =>
      contractDiagnosticLabelBuilder?.call(item);
}
