import 'dart:async';

import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/sections/library_entry_personal_section.dart';

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
    this.coreCorrectionSourceBuilder,
    this.badges = const <Widget>[],
    this.onPrevious,
    this.onNext,
    this.chromeVariant = LibraryEditChromeVariant.standard,
    this.mediaKind,
    required this.tabOrderKey,
    this.extraTabs = const [],
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
  final LibraryCoreCorrectionSource Function()? coreCorrectionSourceBuilder;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final LibraryEditChromeVariant chromeVariant;
  final String? mediaKind;
  final String tabOrderKey;
  final List<EditSchemaExtraTab> extraTabs;

  @override
  State<LibraryEditSchemaDialog<TModel, TDraft>> createState() =>
      _LibraryEditSchemaDialogState<TModel, TDraft>();
}

class _LibraryEditSchemaDialogState<TModel, TDraft>
    extends State<LibraryEditSchemaDialog<TModel, TDraft>> {
  final _formKey = GlobalKey<FormState>();
  final _rendererKey = GlobalKey<EditSchemaRendererState<TModel, TDraft>>();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final entry = LibraryEntryEditScope.maybeOf(context);
    final extraTabs = [...widget.extraTabs];
    final hasPersonal = widget.schema.tabs.any((tab) => tab.id == 'personal') ||
        extraTabs.any((tab) => tab.id == 'personal');
    if (entry != null && !hasPersonal) {
      entry.used = true;
      extraTabs.add(EditSchemaExtraTab(
        id: 'personal',
        label: 'Personal',
        icon: Icons.person_outline,
        content: LibraryEntryPersonalSection(draft: entry),
      ));
    }
    return LibraryEditDialogScaffold(
      formKey: _formKey,
      accent: widget.accent,
      icon: widget.icon,
      title: widget.title,
      badges: widget.badges,
      footerContent:
          entry == null ? null : LibraryEntryStatusStrip(draft: entry),
      isBusy: _saving,
      onClose: _cancelIfIdle,
      onCancel: _cancelIfIdle,
      onSave: _saving
          ? null
          : () async {
              if (!_formKey.currentState!.validate()) return;
              setState(() => _saving = true);
              try {
                await _rendererKey.currentState?.save();
              } finally {
                if (mounted) setState(() => _saving = false);
              }
            },
      onProposeToCore: _saving ||
              (entry != null && entry.record.sourceCatalogRef == null) ||
              widget.coreCorrectionSourceBuilder == null
          ? null
          : () => unawaited(_proposeToCore()),
      onPrevious: _saving ? null : widget.onPrevious,
      onNext: _saving ? null : widget.onNext,
      chromeVariant: widget.chromeVariant,
      body: EditSchemaRenderer<TModel, TDraft>(
        key: _rendererKey,
        schema: widget.schema,
        model: widget.model,
        draft: widget.draft,
        showTitle: false,
        showFooter: false,
        tabAccent: widget.accent,
        tabNavigationEnabled: !_saving,
        tabOrderKey: widget.tabOrderKey,
        extraTabs: extraTabs,
        mediaKind: widget.mediaKind,
        onCancel: _saving ? null : widget.onCancel,
        onSave: widget.onSave,
      ),
    );
  }

  void _cancelIfIdle() {
    if (_saving) return;
    widget.onCancel();
  }

  Future<void> _proposeToCore() async {
    final builder = widget.coreCorrectionSourceBuilder;
    if (builder == null) return;
    final sent = await showLibraryCoreCorrectionReview(
      context: context,
      source: builder(),
    );
    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposal sent to Core.')),
      );
    }
  }
}
