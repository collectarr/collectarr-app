import 'dart:async';

import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/metadata/metadata_correction_schema.dart';
import 'package:flutter/material.dart';

/// Generic metadata correction host.
///
/// This widget owns form rendering, dirty state, validation, and save/cancel
/// mechanics. Semantic field definitions remain in the typed schema supplied
/// by the owning kind.
final class MetadataCorrectionHost<TModel, TDraft> extends StatelessWidget {
  const MetadataCorrectionHost({
    super.key,
    required this.schema,
    required this.model,
    required this.onSave,
    this.onCancel,
  });

  final MetadataCorrectionSchema<TModel, TDraft> schema;
  final TModel model;
  final FutureOr<void> Function(TDraft draft) onSave;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return EditSchemaRenderer<TModel, TDraft>(
      schema: schema.editSchema,
      model: model,
      draft: schema.createDraft(model),
      onSave: onSave,
      onCancel: onCancel,
    );
  }
}
