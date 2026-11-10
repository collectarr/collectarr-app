import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/admin/admin_dashboard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('admin dashboard shows measured catalog table sizes',
      (tester) async {
    final summary = AdminCatalogSummary.fromJson({
      'items': 3,
      'items_by_kind': {'book': 3},
      'catalog_table_bytes_by_kind': {'book': 2048}
    });
    expect(summary.catalogTableBytesByKind['book'], 2048);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: AdminDashboardTab(
      isReindexing: false,
      isLoadingDashboard: false,
      summary: summary,
      searchStatus: null,
      lastReindex: null,
      normalizedMetadataDrift: null,
      metadataContractDrift: null,
      dashboardErrorMessage: null,
      proposalSummary: null,
      proposalHistory: const [],
      onReindexSearch: () {},
      onRefreshDashboard: () {},
    ))));
    expect(find.text('Catalog table storage'), findsOneWidget);
    expect(find.text('Books: 2.0 KiB'), findsOneWidget);
    expect(
        find.text(
            'Includes table data and indexes; excludes shared data and external images.'),
        findsOneWidget);
  });
}
