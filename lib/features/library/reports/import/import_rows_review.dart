import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/framework/import_review_panel.dart';
import 'package:flutter/material.dart';

class ImportRowsReview extends StatelessWidget {
  const ImportRowsReview(
      {super.key, required this.rows, required this.onClear});
  final List<CollectionImportRow> rows;
  final VoidCallback? onClear;
  @override
  Widget build(BuildContext context) => ImportReviewPanel(
          title:
              '${rows.length} ${rows.length == 1 ? 'record' : 'records'} parsed: review before importing',
          onClearAll: onClear,
          items: [
            for (final row in rows.take(20))
              ImportReviewItem(
                  title: row.kindDisplayTitle ?? row.title!,
                  description: row.kindDisplaySubtitle?.isNotEmpty == true
                      ? row.kindDisplaySubtitle!
                      : 'Local library entry',
                  trailingLabel: row.isEntry ? 'Local Entry' : 'Wish List'),
            if (rows.length > 20)
              ImportReviewItem(
                  title: '${rows.length - 20} more records',
                  description:
                      'All ${rows.length} parsed records will be imported when you confirm.'),
          ]);
}
