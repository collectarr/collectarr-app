import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/collections/library_collection_family.dart';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_stats_contributors.dart';
import 'package:collectarr_app/ui/app_management_content.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
import 'package:collectarr_app/ui/app_page_tabs.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A kind whose statistics fill one collection tab of a family page.
abstract interface class LibraryCollectionStatsContributor {
  /// The summary, charts and lists for the entries of one collection.
  Widget buildCollectionStats(
      BuildContext context, List<LibraryWorkspaceContext> entries);
}

/// Statistics of a collection family, such as Games, Hardware and Toys: one
/// tab per collection, each drawn by its own kind, as in the reference.
class LibraryFamilyStatsPage extends ConsumerStatefulWidget {
  const LibraryFamilyStatsPage(
      {super.key, required this.type, required this.state});
  final LibraryKindRegistration type;
  final ShelfState state;

  @override
  ConsumerState<LibraryFamilyStatsPage> createState() =>
      _LibraryFamilyStatsPageState();
}

class _LibraryFamilyStatsPageState
    extends ConsumerState<LibraryFamilyStatsPage> {
  String? _collectionId;

  @override
  Widget build(BuildContext context) {
    final kind = widget.type.kind.apiValue;
    final collections = ref.watch(libraryCollectionFamilyProvider(kind));
    final values =
        collections.asData?.value ?? const <LibraryCollectionSummary>[];
    final selected = values.where((c) => c.id == _collectionId).firstOrNull ??
        values.where((c) => c.kind == kind && c.isActive).firstOrNull ??
        values.where((c) => c.kind == kind).firstOrNull ??
        values.firstOrNull;
    return Scaffold(
      backgroundColor: appManagementCanvasColor(context),
      appBar: AppPageHeader(
          icon: Icons.bar_chart,
          title: const Text('Statistics'),
          leading: AppPageBackButton(
              key: const Key('stats.back'),
              onPressed: () => Navigator.of(context).pop())),
      body: AppManagementContent(
          maxWidth: 998,
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                  child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (collections.hasError)
                        const Text('Could not load collections.')
                      else if (selected != null) ...[
                        AppPageTabs(
                          tabs: [
                            for (final collection in values)
                              AppPageTab(label: collection.name),
                          ],
                          selectedIndex: values.indexOf(selected),
                          onSelected: (index) =>
                              setState(() => _collectionId = values[index].id),
                        ),
                        _collectionStats(context, selected),
                      ],
                    ]),
              )))),
    );
  }

  Widget _collectionStats(
      BuildContext context, LibraryCollectionSummary collection) {
    final contributor =
        libraryStatsForKind(catalogMediaKindFromApiValue(collection.kind));
    if (contributor is! LibraryCollectionStatsContributor) {
      return const SizedBox.shrink();
    }
    final entries = widget.state.entries
        .where((entry) =>
            entry.libraryEntryRef?.kind.apiValue == collection.kind &&
            collection.entryIds.contains(entry.libraryEntryRef?.id.value))
        .toList();
    return (contributor as LibraryCollectionStatsContributor)
        .buildCollectionStats(context, entries);
  }
}
