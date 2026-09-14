import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_media_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildTvMediaLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _TvMediaEditDialog(request: request);

class _TvMediaEditDialog extends StatefulWidget {
  const _TvMediaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_TvMediaEditDialog> createState() => _TvMediaEditDialogState();
}

class _TvMediaEditDialogState extends State<_TvMediaEditDialog> {
  late final TvSeries _series;
  late final TvMediaEditDraft _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.toTransport();
    final canonical = transport.kindMetadata;
    _series = canonical is TvSeries
        ? canonical
        : TvSeries.fromJson(transport.payload);
    _draft = TvMediaEditDraft.fromSeries(_series);
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      EditSchemaRenderer<TvSeries, TvMediaEditDraft>(
        schema: tvMediaEditSchema,
        model: _series,
        draft: _draft,
        title: tvMediaEditSchema.title?.call(_series),
        onCancel: () => Navigator.of(context).pop(),
        onSave: (_) {
          final updated = _draft.toSeries();
          final candidate = widget.request.kindItem.mapTransport(
            (transport) => CatalogSearchCandidate.fromItem(
              transport.withKindMetadata(updated),
            ),
          );
          Navigator.of(context).pop(
            LibraryEditSelection(
              item: candidate.editMetadata,
              kindItem: candidate,
              personal: null,
            ),
          );
        },
      );
}
