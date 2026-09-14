import 'dart:async';

import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_scaffold.dart';
import 'package:flutter/material.dart';

/// Mounts a typed schema renderer in the same dialog chrome used by the
/// regular Library edit flow.
///
/// The schema remains responsible for typed fields and validation. This
/// widget only owns the shared dialog shell and forwards the shell's Save
/// action to the renderer.
final class LibraryEditSchemaDialog<TModel, TDraft> extends StatefulWidget {
  const LibraryEditSchemaDialog({
    super.key,
    required this.schema,
    required this.model,
    required this.draft,
    required this.title,
    required this.icon,
    required this.accent,
    required this.onSave,
    required this.onCancel,
    this.badges = const <Widget>[],
    this.onPrevious,
    this.onNext,
    this.chromeVariant = LibraryEditChromeVariant.standard,
    required this.tabOrderKey,
  });

  final EditSchema<TModel, TDraft> schema;
  final TModel model;
  final TDraft draft;
  final String title;
  final IconData icon;
  final Color accent;
  final List<Widget> badges;
  final FutureOr<void> Function(TDraft draft) onSave;
  final VoidCallback onCancel;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final LibraryEditChromeVariant chromeVariant;
  final String tabOrderKey;

  @override
  State<LibraryEditSchemaDialog<TModel, TDraft>> createState() =>
      _LibraryEditSchemaDialogState<TModel, TDraft>();
}

class _LibraryEditSchemaDialogState<TModel, TDraft>
    extends State<LibraryEditSchemaDialog<TModel, TDraft>> {
  final _formKey = GlobalKey<FormState>();
  final _rendererKey = GlobalKey<EditSchemaRendererState<TModel, TDraft>>();

  @override
  Widget build(BuildContext context) {
    return LibraryEditDialogScaffold(
      formKey: _formKey,
      accent: widget.accent,
      icon: widget.icon,
      title: widget.title,
      badges: widget.badges,
      onClose: widget.onCancel,
      onCancel: widget.onCancel,
      onSave: () => _rendererKey.currentState?.save(),
      onPrevious: widget.onPrevious,
      onNext: widget.onNext,
      chromeVariant: widget.chromeVariant,
      body: EditSchemaRenderer<TModel, TDraft>(
        key: _rendererKey,
        schema: widget.schema,
        model: widget.model,
        draft: widget.draft,
        showTitle: false,
        showFooter: false,
        tabAccent: widget.accent,
        tabOrderKey: widget.tabOrderKey,
        onCancel: widget.onCancel,
        onSave: widget.onSave,
      ),
    );
  }
}
