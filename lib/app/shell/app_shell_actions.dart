import 'dart:async';
import 'package:collectarr_app/app/help/user_manual.dart';
import 'package:collectarr_app/app/help/help_links.dart';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/add/library_add_launcher.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/collections/library_collections_dialog.dart';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/duplicates/library_find_duplicates_page.dart';
import 'package:collectarr_app/features/library/keyboard/library_keyboard_shortcuts.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/reports/collection_report.dart';
import 'package:collectarr_app/features/library/reports/collection_export_csv_txt.dart';
import 'package:collectarr_app/features/library/reports/collection_import_data.dart';
import 'package:collectarr_app/features/library/reports/library_export_xml_flow.dart';
import 'package:collectarr_app/features/library/metadata/library_link_items_page.dart';
import 'package:collectarr_app/features/library/sharing/collection_cloud_sharing_page.dart';
import 'package:collectarr_app/features/library/stats/stats_dashboard.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_manager_page.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/settings/custom_fields_settings.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:collectarr_app/features/settings/settings_page.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_navigation_model.dart';
import 'package:collectarr_app/features/collection/projection/shelf_kind_projection.dart';

class AppShellActions {
  AppShellActions(
      {required this.ref,
      required this.shellContext,
      required this.isMounted,
      required this.selectedOverlay,
      required this.onSelectionChanged});
  final WidgetRef ref;
  final BuildContext Function() shellContext;
  final bool Function() isMounted;
  final DrawerAction? Function() selectedOverlay;
  final ValueChanged<DrawerAction?> onSelectionChanged;
  int _drawerRequestSequence = 0;
  bool get mounted => isMounted();
  BuildContext get context => shellContext();
  BuildContext get _pageContext =>
      appPageNavigatorKey.currentState?.overlay?.context ?? context;

  Future<void> handle(
    DrawerAction action, {
    required LibraryKindRegistration type,
    required Color accent,
  }) async {
    final destination = appDrawerDestination(action);
    final routed = destination.routesAway;
    final opensPage = destination.resetsToLibrary;
    if (opensPage) {
      // Sidebar destinations replace one another and always sit above Library.
      onSelectionChanged(null);
      context.go(AppRoutes.forKind(AppRoutes.libraries, type.kind.apiValue));
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      appPageNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
    }
    final previous = selectedOverlay();
    onSelectionChanged(routed ? null : action);
    try {
      await _performDrawerAction(action, type: type, accent: accent);
    } finally {
      if (mounted && !routed && selectedOverlay() == action) {
        onSelectionChanged(previous);
      }
    }
  }

  Future<void> _performDrawerAction(
    DrawerAction action, {
    required LibraryKindRegistration type,
    required Color accent,
  }) async {
    final context = _pageContext;
    switch (action) {
      case DrawerAction.addFromCore:
        unawaited(_openCoreAdd(type, accent));
        return;
      case DrawerAction.addManually:
        unawaited(_openCoreAdd(type, accent, startManually: true));
        return;
      case DrawerAction.managePickLists:
        await showPickListManagerDialog(
          context: context,
          db: ref.read(localDatabaseProvider),
          registry: defaultPickListRegistry,
          accent: accent,
          initialMediaKind: type.kind.apiValue,
        );
        return;
      case DrawerAction.manageCollections:
        await _showManageCollections(type);
        return;
      case DrawerAction.printToPdf:
        await _withShelf((shelf) {
          final items = libraryItemsForShelf(shelf, type);
          return printCollectionReport(
            context: context,
            title: type.identity.title,
            items: items,
            type: type,
            allShelfEntries: shelf.entries,
          );
        });
        return;
      case DrawerAction.statistics:
        await _withShelf((shelf) {
          return showStatsDashboardDialog(
            context,
            type: type,
            state: shelf.forKind(type.kind),
          );
        });
        return;
      case DrawerAction.findDuplicates:
        await _withShelf((shelf) {
          final entries = shelf.entries
              .where((entry) => entry.mediaKind == type.kind)
              .toList(growable: false);
          return Navigator.of(context).push<void>(MaterialPageRoute(
            builder: (_) => LibraryFindDuplicatesPage(
              type: type,
              entries: entries,
              accent: accent,
            ),
          ));
        });
        return;
      case DrawerAction.loanManager:
        context.go(AppRoutes.loansForKind(type.kind));
        return;
      case DrawerAction.manageCustomFields:
        await showCustomFieldsManagementPage(
          context: context,
          db: ref.read(localDatabaseProvider),
          accent: accent,
          mediaKind: type.kind.apiValue,
        );
        return;
      case DrawerAction.cloudSharing:
        await _withShelf(
            (shelf) => Navigator.of(context).push<void>(MaterialPageRoute(
                  builder: (_) => CollectionCloudSharingPage(
                      type: type, items: libraryItemsForShelf(shelf, type)),
                )));
        return;
      case DrawerAction.prefillSettings:
        await showPrefillSettingsDialog(
            context: context, accent: accent, kind: type.kind);
        return;
      case DrawerAction.settings:
        _goToSettingsSection(SettingsSection.appearance, type.kind);
        return;
      case DrawerAction.calendar:
        context.go(AppRoutes.forKind(AppRoutes.calendar, type.kind.apiValue));
        return;
      case DrawerAction.admin:
        context.go(AppRoutes.forKind(AppRoutes.admin, type.kind.apiValue));
        return;
      case DrawerAction.reassignIndex:
      case DrawerAction.transferFieldData:
        _openLibraryTool(action, type);
        return;
      case DrawerAction.backupRestore:
      case DrawerAction.clearDatabase:
        _goToSettingsSection(SettingsSection.data, type.kind);
        return;
      case DrawerAction.exportCsv:
        await _withShelf((shelf) {
          final items = libraryItemsForShelf(shelf, type);
          return exportCollectionCsvTxt(
            context: context,
            title: type.identity.title,
            items: items,
            type: type,
            allShelfEntries: shelf.entries,
          );
        });
        return;
      case DrawerAction.exportXml:
        await _withShelf((shelf) => exportLibraryEntriesXml(
              context: context,
              type: type,
              database: ref.read(localDatabaseProvider),
              entries: [
                for (final entry in shelf.entries)
                  if (entry.mediaKind == type.kind)
                    if (entry.libraryEntryRef case final entryRef?) entryRef
              ],
            ));
        return;
      case DrawerAction.importData:
        await _withShelf((shelf) {
          return importCollectionData(
            context: context,
            type: type,
            allShelfEntries: shelf.entries,
          );
        });
        return;
      case DrawerAction.linkItems:
        await _withShelf(
            (shelf) => Navigator.of(context).push<void>(MaterialPageRoute(
                  builder: (_) => LibraryLinkItemsPage(
                      type: type,
                      entries: shelf.entries
                          .where((entry) => entry.mediaKind == type.kind)
                          .toList()),
                )));
        return;
      case DrawerAction.userManual:
        await openUserManual(context, kind: type.kind);
        return;
      case DrawerAction.community:
        await openCommunity(context);
        return;
      case DrawerAction.contactSupport:
        await openContactSupport(context);
        return;
      case DrawerAction.whatsNew:
        await openWhatsNew(context);
        return;
      case DrawerAction.keyboardShortcuts:
        showKeyboardShortcutsDialog(context);
        return;
    }
  }

  Future<void> _showManageCollections(LibraryKindRegistration type) async {
    await showLibraryCollectionsDialog(_pageContext, kind: type.kind.apiValue);
    if (mounted) {
      ref.invalidate(libraryCollectionsProvider);
    }
  }

  Future<void> _openCoreAdd(LibraryKindRegistration type, Color accent,
      {bool startManually = false}) async {
    context.go(Uri(
        path: AppRoutes.libraries,
        queryParameters: {'kind': type.kind.apiValue}).toString());
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final pageContext = _pageContext;
    if (!pageContext.mounted) return;
    await showLibraryAddDialog(
        context: pageContext,
        type: type,
        accent: accent,
        startManually: startManually);
  }

  void _openLibraryTool(DrawerAction action, LibraryKindRegistration type) {
    context.go(Uri(path: AppRoutes.libraries, queryParameters: {
      'kind': type.kind.apiValue,
      'tool': action.name,
      'toolRequest': '${++_drawerRequestSequence}',
    }).toString());
  }

  void _goToSettingsSection(SettingsSection section, CatalogMediaKind kind) {
    context.go(AppRoutes.forKind(AppRoutes.settings, kind.apiValue,
        parameters: {'section': section.name}));
  }

  Future<void> _withShelf(
    Future<void> Function(ShelfState shelf) action,
  ) async {
    try {
      final shelf = await ref.read(shelfProvider.future);
      if (!mounted) return;
      await action(shelf);
    } catch (error) {
      if (!mounted) return;
      final errorContext = context;
      if (!errorContext.mounted) return;
      ScaffoldMessenger.of(errorContext).showSnackBar(
        SnackBar(content: Text('Could not load the collection: $error')),
      );
    }
  }
}
