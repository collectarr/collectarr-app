import 'dart:async';
import 'dart:convert';

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/utils/image_url.dart';
import 'package:collectarr_app/features/admin/admin_image_cache_panel.dart';
import 'package:collectarr_app/features/admin/admin_page_data_loader.dart';
import 'package:collectarr_app/features/admin/admin_dashboard_widgets.dart';
import 'package:collectarr_app/features/admin/admin_primitives.dart';
import 'package:collectarr_app/features/admin/admin_kind_labels.dart';
import 'package:collectarr_app/features/admin/controllers/admin_catalog_search_controller.dart';
import 'package:collectarr_app/features/admin/widgets/admin_catalog_search_panel.dart';
import 'package:collectarr_app/features/admin/widgets/admin_catalog_item_list.dart';
import 'package:collectarr_app/features/admin/admin_diagnostics_panel.dart';
import 'package:collectarr_app/features/admin/admin_users_panel.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/features/library/metadata/metadata_correction_form_widgets.dart';
import 'package:collectarr_app/features/library/metadata/shared_metadata_editing_contract.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';
import 'package:collectarr_app/features/library/config/library_metadata_correction_source.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/settings/collection_schema_management_panel.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'admin_item_inspection.dart';
part 'admin_metadata_correction_dialog.dart';
part 'admin_page_sections.dart';
part 'admin_catalog_widgets.dart';
part 'admin_shared_widgets.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  late final _catalogSearchController = AdminCatalogSearchController(
    formatError: _adminErrorMessage,
  );

  final _catalogQueryController = TextEditingController();
  var _mediaTypes = const <CatalogMediaType>[];
  AdminCatalogSummary? _summary;
  AdminCatalogItemIntegrityReport? _catalogItemIntegrity;
  AdminImageCacheStats? _dashboardImageCacheStats;
  AdminSearchStatus? _searchStatus;
  AdminSearchReindexResult? _lastReindex;
  var _searchHistory = const <AdminSearchHistoryEntry>[];
  var _auditLogs = const <AdminAuditLogEntry>[];
  var _duplicates = const <AdminDuplicateCandidate>[];
  String? _dashboardErrorMessage;
  String? _duplicateStatusMessage;
  String? _duplicateErrorMessage;
  bool _isLoadingDashboard = false;
  bool _isReindexing = false;
  bool _isLoadingKinds = false;
  String? _inspectingItemId;
  String? _updatingCatalogItemId;
  String? _duplicateActionItemId;

  @override
  void initState() {
    super.initState();
    _catalogSearchController.addListener(_onFlowControllerChanged);
    _loadDashboard();
    _loadMediaTypes();
  }

  @override
  void dispose() {
    _catalogSearchController.dispose();
    _catalogQueryController.dispose();
    super.dispose();
  }

  void _onFlowControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final accent = LibraryAccentScope.accentOf(context);
    final animationDuration = LibraryAccentScope.animationDurationOf(context);
    final isAdmin = ref.watch(authControllerProvider).isAdmin;

    final tabs = <Tab>[
      if (isAdmin)
        const Tab(icon: Icon(Icons.dashboard_outlined), text: 'Dashboard'),
      if (isAdmin)
        const Tab(icon: Icon(Icons.bar_chart_outlined), text: 'Stats'),
      const Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Catalog'),
      if (isAdmin) const Tab(icon: Icon(Icons.history_outlined), text: 'Logs'),
      if (isAdmin)
        const Tab(icon: Icon(Icons.settings_outlined), text: 'System'),
    ];

    final tabViews = <Widget>[
      if (isAdmin) _buildDashboardTab(),
      if (isAdmin) _buildStatsTab(),
      _buildCatalogTab(context),
      if (isAdmin) _buildLogsTab(),
      if (isAdmin) _buildSystemTab(),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAdmin ? 'Admin' : 'Manage'),
          backgroundColor: libraryAccentChromeFallbackColor(accent),
          surfaceTintColor: Colors.transparent,
          flexibleSpace: LibraryAccentChrome(
            accent: accent,
            animationDuration: animationDuration,
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: tabs,
          ),
        ),
        body: TabBarView(children: tabViews),
      ),
    );
  }

  // ─── Dashboard tab (admin only) ───
  Widget _buildDashboardTab() {
    return AdminDashboardTab(
      isReindexing: _isReindexing,
      isLoadingDashboard: _isLoadingDashboard,
      db: ref.read(localDatabaseProvider),
      summary: _summary,
      searchStatus: _searchStatus,
      lastReindex: _lastReindex,
      catalogItemIntegrity: _catalogItemIntegrity,
      dashboardErrorMessage: _dashboardErrorMessage,
      onReindexSearch: _reindexSearch,
      onRefreshDashboard: _loadDashboard,
    );
  }

  Widget _buildStatsTab() {
    return AdminStatsTab(
      isLoadingDashboard: _isLoadingDashboard,
      summary: _summary,
      imageCacheStats: _dashboardImageCacheStats,
      dashboardErrorMessage: _dashboardErrorMessage,
      onRefreshDashboard: _loadDashboard,
    );
  }

  // ─── Catalog tab (all users) ───

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoadingDashboard = true;
      _dashboardErrorMessage = null;
    });
    try {
      final dashboard = await AdminPageDataLoader(
        ref.read(apiClientProvider),
      ).loadDashboard();
      if (!mounted) {
        return;
      }
      setState(() {
        _summary = dashboard.summary;
        _catalogItemIntegrity = dashboard.catalogItemIntegrity;
        _dashboardImageCacheStats = dashboard.imageCacheStats;
        _searchStatus = dashboard.searchStatus;
        _searchHistory = dashboard.searchHistory;
        _auditLogs = dashboard.auditLogs;
        _duplicates = dashboard.duplicateCandidates;
        _isLoadingDashboard = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingDashboard = false;
        _dashboardErrorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _searchCatalog() async {
    await _catalogSearchController.search(
      ref.read(apiClientProvider),
      query: _catalogQueryController.text,
    );
  }

  Future<void> _inspectCatalogItem(AdminMetadataItem item) async {
    setState(() {
      _inspectingItemId = item.id;
    });
    try {
      final api = ref.read(apiClientProvider);
      final fresh = await api.adminGetMetadataItem(
        kind: item.kind,
        id: item.id,
      );
      final auditLogs = await api.adminAuditLogs(
        entityType: 'catalog_item',
        entityId: item.id,
        limit: 8,
      );
      final metadataFields = await _adminMetadataFields(fresh);
      if (!mounted) {
        return;
      }
      setState(() {
        _inspectingItemId = null;
      });
      await _showCanonicalItemInspectionDialog(
        fresh,
        auditLogs,
        metadataFields,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _inspectingItemId = null;
      });
    }
  }

  Future<void> _showCanonicalItemInspectionDialog(
    AdminMetadataItem item,
    List<AdminAuditLogEntry> auditLogs,
    List<LibraryAdminCorrectionField> metadataFields,
  ) async {
    final result = await showDialog<_CanonicalInspectResult>(
      context: context,
      builder: (context) => _CanonicalItemInspectionDialog(
        item: item,
        auditLogs: auditLogs,
        metadataFields: metadataFields,
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    switch (result.action) {
      case _CanonicalInspectAction.edit:
        await _showMetadataCorrectionDialog(item);
        await _inspectCatalogItem(item);
      case _CanonicalInspectAction.covers:
        await _showCoverInspectionDialog(item);
        await _inspectCatalogItem(item);
      case null:
        return;
    }
  }

  Future<List<LibraryAdminCorrectionField>> _adminMetadataFields(
    AdminMetadataItem item,
  ) async {
    try {
      final fieldSchema = await ref
          .read(apiClientProvider)
          .metadataFieldSchema(editableOnly: true);
      final kind = catalogMediaKindFromApiValue(item.kind);
      final contributor = libraryAdminContributorForKind(kind);
      if (contributor == null) return const [];
      final detailsKeys = item.canonicalFieldValues.keys.toSet();
      return adminCorrectionFieldsForKind(
        schema: fieldSchema,
        kind: kind,
        contributor: contributor,
      )
          .where((field) => detailsKeys.contains(field.key))
          .toList(growable: false);
    } catch (_) {
      // Inspection remains available if the optional field schema is down.
      return const [];
    }
  }

  Future<void> _showMetadataCorrectionDialog(AdminMetadataItem item) async {
    final kind = catalogMediaKindFromApiValue(item.kind);
    final contributor = libraryAdminContributorForKind(kind);
    if (contributor == null) {
      setState(() {
        _catalogSearchController.errorMessage =
            'No Admin correction fields are registered for this kind.';
      });
      return;
    }
    late final MetadataFieldSchema fieldSchema;
    try {
      fieldSchema = await ref.read(apiClientProvider).metadataFieldSchema(
            editableOnly: true,
          );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _catalogSearchController.errorMessage = _adminErrorMessage(error);
      });
      return;
    }
    if (!mounted) return;
    final detailsKeys = item.canonicalFieldValues.keys.toSet();
    final correctionFields = adminCorrectionFieldsForKind(
      schema: fieldSchema,
      kind: kind,
      contributor: contributor,
    ).where((field) => detailsKeys.contains(field.key)).toList(growable: false);
    if (correctionFields.isEmpty) {
      setState(() {
        _catalogSearchController.errorMessage =
            'Core did not return editable canonical fields for this kind.';
      });
      return;
    }
    final physicalFormats = physicalMediaFormatsForKind(
      _mediaTypes.isEmpty ? fallbackMediaCatalog : _mediaTypes,
      kind,
    );
    final correction = await showDialog<_MetadataCorrectionResult>(
      context: context,
      builder: (context) => _MetadataCorrectionDialog(
        item: item,
        fields: correctionFields,
        physicalFormats: physicalFormats,
      ),
    );
    if (correction == null || !mounted) return;

    setState(() {
      _updatingCatalogItemId = item.id;
      _catalogSearchController.statusMessage = null;
      _catalogSearchController.errorMessage = null;
    });
    try {
      AdminMetadataItem? updated;
      final api = ref.read(apiClientProvider);
      final writer = LibraryAdminCorrectionWriter(
        updateCatalogFields: (fields) async {
          updated = await api.adminUpdateCatalogItemFields(
            kind: item.kind,
            id: item.id,
            fields: fields,
          );
        },
        updateRelatedFields: (relatedEntityId, fields) async {
          await api.adminUpdateSeriesFields(
            seriesId: relatedEntityId,
            fields: fields,
          );
        },
      );
      final catalogFields = <String, Object?>{};
      for (final field in correction.changedFields) {
        final value = correction.values.read(field.key);
        final save = field.save;
        if (save == null) {
          catalogFields[field.key] = value;
        } else {
          await save(item, value, writer);
        }
      }
      if (catalogFields.isNotEmpty) {
        await writer.updateCatalogFields(catalogFields);
      }
      if (!mounted) return;
      setState(() {
        _updatingCatalogItemId = null;
        _catalogSearchController.statusMessage = 'Metadata correction saved.';
        if (updated != null) {
          _catalogSearchController.replaceItem(updated!);
        }
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _updatingCatalogItemId = null;
        _catalogSearchController.errorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _showCoverInspectionDialog(AdminMetadataItem item) async {
    final contributor = libraryAdminContributorForKind(
      catalogMediaKindFromApiValue(item.kind),
    );
    if (contributor == null) return;
    final update = await showDialog<_CoverUpdate>(
      context: context,
      builder: (context) => _CoverInspectionDialog(item: item),
    );
    if (update == null || !mounted) {
      return;
    }
    setState(() {
      _updatingCatalogItemId = item.id;
      _catalogSearchController.statusMessage = null;
      _catalogSearchController.errorMessage = null;
    });
    try {
      final updated =
          await ref.read(apiClientProvider).adminUpdateCatalogItemFields(
                kind: item.kind,
                id: item.id,
                fields: contributor.serializeCoverCorrection(
                  coverImageUrl: update.coverImageUrl,
                  thumbnailImageUrl: update.thumbnailImageUrl,
                ),
              );
      if (!mounted) {
        return;
      }
      setState(() {
        _updatingCatalogItemId = null;
        _catalogSearchController.replaceItem(updated);
        _catalogSearchController.statusMessage = 'Cover URL updated.';
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _updatingCatalogItemId = null;
        _catalogSearchController.errorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _reindexSearch() async {
    setState(() {
      _isReindexing = true;
      _dashboardErrorMessage = null;
    });
    try {
      final result = await ref.read(apiClientProvider).adminReindexSearch();
      if (!mounted) {
        return;
      }
      setState(() {
        _lastReindex = result;
        _isReindexing = false;
        _dashboardErrorMessage =
            result.ok ? null : result.error ?? 'Search reindex failed.';
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isReindexing = false;
        _dashboardErrorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _inspectDuplicateCandidate(
    AdminDuplicateCandidate candidate,
  ) async {
    if (candidate.itemIds.isEmpty) {
      return;
    }
    final itemId = candidate.itemIds.first;
    setState(() {
      _inspectingItemId = itemId;
      _duplicateStatusMessage = null;
      _duplicateErrorMessage = null;
    });
    try {
      final item = await ref.read(apiClientProvider).adminGetMetadataItem(
            kind: candidate.kind,
            id: itemId,
          );
      final auditLogs = await ref.read(apiClientProvider).adminAuditLogs(
            entityType: 'catalog_item',
            entityId: itemId,
            limit: 8,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _inspectingItemId = null;
      });
      await _showCanonicalItemInspectionDialog(
        item,
        auditLogs,
        await _adminMetadataFields(item),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _inspectingItemId = null;
      });
    }
  }

  Future<void> _ignoreDuplicateCandidate(
    AdminDuplicateCandidate candidate,
  ) async {
    if (candidate.itemIds.length < 2) {
      return;
    }
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AccentAlertDialog(
            title: const Text('Ignore duplicate group?'),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _DestructiveWarning(
                    icon: Icons.visibility_off_outlined,
                    message:
                        'This hides the duplicate group from admin review. No catalog records are deleted, but the decision is audit logged.',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${candidate.itemIds.length} items will be marked as reviewed for ${candidate.displayTitle}.',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.visibility_off_outlined),
                label: const Text('Ignore group'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) {
      return;
    }
    setState(() {
      _duplicateActionItemId = candidate.itemIds.first;
      _duplicateStatusMessage = null;
      _duplicateErrorMessage = null;
    });
    try {
      final result =
          await ref.read(apiClientProvider).adminIgnoreDuplicateCandidate(
                itemIds: candidate.itemIds,
              );
      if (!mounted) {
        return;
      }
      setState(() {
        _duplicateActionItemId = null;
        _duplicateStatusMessage =
            'Ignored ${result.affectedItems} duplicate items.';
      });
      await _loadDashboard();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _duplicateActionItemId = null;
        _duplicateErrorMessage = _adminErrorMessage(error);
      });
    }
  }

  Future<void> _loadMediaTypes() async {
    setState(() => _isLoadingKinds = true);
    try {
      final mediaTypes = await ref.read(mediaCatalogProvider.future);
      if (!mounted) {
        return;
      }
      setState(() {
        _mediaTypes = mediaTypes;
        _isLoadingKinds = false;
      });
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'admin',
        message: 'Failed to load media types for admin page.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _mediaTypes = const [];
        _isLoadingKinds = false;
      });
    }
  }

  Map<String, String> _catalogKindLabels() => {
        for (final type in _mediaTypes)
          if (type.kind.isNotEmpty) type.kind: adminMediaTypeDisplayLabel(type),
      };

  List<String> _catalogKindOptions() => [
        for (final type in _mediaTypes)
          if (type.kind.isNotEmpty && type.isTopLevel) type.kind,
      ]..sort((left, right) =>
          compareAdminMediaKinds(left, right, _catalogKindLabels()));
}
