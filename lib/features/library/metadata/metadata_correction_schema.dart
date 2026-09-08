import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';

/// A structural correction form owned by the caller's domain integration.
///
/// The host only knows how to render an [EditSchema]. It does not inspect
/// catalog DTOs, payload keys, or kind-specific metadata.
final class MetadataCorrectionSchema<TModel, TDraft> {
  const MetadataCorrectionSchema({
    required this.editSchema,
    required this.createDraft,
  });

  final EditSchema<TModel, TDraft> editSchema;
  final TDraft Function(TModel model) createDraft;
}
