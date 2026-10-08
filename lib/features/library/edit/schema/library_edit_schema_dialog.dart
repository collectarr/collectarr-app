import 'dart:async';

import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_contributions.dart';
import 'package:collectarr_app/features/library/edit/session/library_vocabulary_edit_accumulator.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/sections/library_entry_personal_section.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_draft_editor.dart';

export 'package:collectarr_app/features/library/edit/schema/library_edit_schema_contributions.dart';

/// Mounts a typed schema renderer in the same dialog chrome used by the
/// regular Library edit flow.
///
/// The schema remains responsible for typed fields and validation. This
/// widget owns the shared dialog shell, composes standard tabs from kind
/// contributions, and forwards the shell's Save action to the renderer.
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
    this.vocabularyAccumulator,
    required this.tabOrderKey,
    this.extraTabs = const [],
    this.contributions = const LibraryEditSchemaContributions(),
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
  final LibraryVocabularyEditAccumulator? vocabularyAccumulator;
  final String tabOrderKey;
  final List<EditSchemaExtraTab> extraTabs;
  final LibraryEditSchemaContributions contributions;

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
    final personalContribution = widget.contributions.personal;
    final hasPersonal = widget.schema.tabs.any((tab) => tab.id == 'personal') ||
        extraTabs.any((tab) => tab.id == 'personal');
    if (!hasPersonal && (entry != null || personalContribution != null)) {
      if (entry != null) entry.used = true;
      final contribution = personalContribution;
      _insertExtraTab(
        extraTabs,
        EditSchemaExtraTab(
          id: contribution?.id ?? 'personal',
          label: contribution?.label ?? 'Personal',
          icon: contribution?.icon ?? Icons.person_outline,
          svgAsset: contribution?.svgAsset,
          content: entry == null
              ? const Text(
                  'Personal fields belong to your local library entry.',
                )
              : LibraryEntryPersonalSection(
                  draft: entry,
                  layoutBuilder: contribution?.layoutBuilder,
                  additionalFields:
                      contribution?.additionalFieldsBuilder?.call(entry) ??
                          const {},
                  history: contribution?.historyBuilder?.call(entry),
                ),
        ),
        afterTabId: contribution?.afterTabId,
      );
    }
    final customFields = widget.contributions.customFields;
    if (customFields != null &&
        !extraTabs.any((tab) => tab.id == customFields.id) &&
        !widget.schema.tabs.any((tab) => tab.id == customFields.id)) {
      _insertExtraTab(
        extraTabs,
        EditSchemaExtraTab(
          id: customFields.id,
          label: customFields.label,
          icon: customFields.icon,
          svgAsset: customFields.svgAsset,
          content: CustomFieldsEditSection(
            definitions: customFields.definitions,
            values: customFields.values,
            accent: widget.accent,
            mediaKind: widget.mediaKind,
            onChanged: customFields.onChanged,
            onCustomValueChanged: customFields.onCustomValueChanged,
          ),
        ),
        afterTabId: customFields.afterTabId,
      );
    }
    final images = widget.contributions.images;
    if (images != null &&
        !extraTabs.any((tab) => tab.id == images.id) &&
        !widget.schema.tabs.any((tab) => tab.id == images.id)) {
      _insertExtraTab(
        extraTabs,
        EditSchemaExtraTab(
          id: images.id,
          label: images.label,
          icon: images.icon,
          svgAsset: images.svgAsset,
          content: ItemImagesEditSection(
            images: images.images,
            accent: widget.accent,
            onChanged: images.onChanged,
            title: images.title,
            emptyMessage: images.emptyMessage,
            maximumImages: images.maximumImages,
            defaultImageType: images.defaultImageType,
            uniqueImageTypes: images.uniqueImageTypes,
            showCoverActions: images.showCoverActions,
            imageTypeFieldBuilder: images.imageTypeFieldBuilder,
            imageTypeLabelBuilder: images.imageTypeLabelBuilder,
          ),
        ),
        afterTabId: images.afterTabId,
      );
    }
    final links = widget.contributions.links;
    if (links != null &&
        !extraTabs.any((tab) => tab.id == links.id) &&
        !widget.schema.tabs.any((tab) => tab.id == links.id)) {
      _insertExtraTab(
        extraTabs,
        EditSchemaExtraTab(
          id: links.id,
          label: links.label,
          icon: links.icon,
          svgAsset: links.svgAsset,
          content: LibraryExternalLinksEditSection(
            links: links.links,
            accent: widget.accent,
            onChanged: links.onChanged,
            addLabel: links.addLabel,
            showTitleColumn: links.showTitleColumn,
            emptyMessage: links.emptyMessage,
          ),
        ),
        afterTabId: links.afterTabId,
      );
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
        fillAvailableHeight: true,
        tabAccent: widget.accent,
        tabNavigationEnabled: !_saving,
        tabOrderKey: widget.tabOrderKey,
        extraTabs: extraTabs,
        mediaKind: widget.mediaKind,
        vocabularyAccumulator: widget.vocabularyAccumulator,
        onCancel: _saving ? null : widget.onCancel,
        onSave: widget.onSave,
      ),
    );
  }

  void _insertExtraTab(
    List<EditSchemaExtraTab> tabs,
    EditSchemaExtraTab tab, {
    String? afterTabId,
  }) {
    final anchorIndex = afterTabId == null
        ? -1
        : tabs.indexWhere((candidate) => candidate.id == afterTabId);
    tabs.insert(anchorIndex < 0 ? tabs.length : anchorIndex + 1, tab);
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
