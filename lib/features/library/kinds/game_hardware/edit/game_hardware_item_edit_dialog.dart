import 'dart:convert';

import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_draft_editor.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/data/game_hardware_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/edit/game_hardware_covers_tab.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/edit/game_hardware_item_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/edit/game_hardware_item_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/edit/game_hardware_personal_form_layout.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/edit/game_hardware_value_tab.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';

Widget buildGameHardwareItemEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _GameHardwareItemEditDialog(request: request);

final class _GameHardwareItemEditDialog extends StatefulWidget {
  const _GameHardwareItemEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_GameHardwareItemEditDialog> createState() =>
      _GameHardwareItemEditDialogState();
}

final class _GameHardwareItemEditDialogState
    extends State<_GameHardwareItemEditDialog> {
  late final GameHardwareCatalogMetadata _metadata;
  late final GameHardwareItemEditDraft _draft;
  late final String _initialJson;
  late Map<String, String?> _customFieldEdits;
  late final Map<String, String?> _initialCustomFieldEdits;
  List<ItemImageEdit> _imageEdits = const [];
  List<ItemImageEdit> _coverEdits = const [];

  @override
  void initState() {
    super.initState();
    _metadata = widget.request.kindItem.kindCapability
        .mapTransport(const GameHardwareCatalogTransportCodec().decode);
    _draft = GameHardwareItemEditDraft.fromMetadata(_metadata);
    // Saving fills derived values, so an untouched draft is compared with
    // its own first output rather than the stored item.
    _initialJson = jsonEncode(_draft.toMetadata().toJson());
    _initialCustomFieldEdits = {
      for (final value in widget.request.customFieldValues)
        value.fieldDefinitionId: value.value,
    };
    _customFieldEdits = Map.of(_initialCustomFieldEdits);
  }

  @override
  Widget build(BuildContext context) {
    final personal = LibraryEntryEditScope.maybeOf(context);
    final vocabularyEdits = personal?.vocabularyEdits ?? _draft.vocabularyEdits;
    _draft.vocabularyEdits = vocabularyEdits;
    final accent = widget.request.accent;
    return LibraryEditSchemaDialog<GameHardwareCatalogMetadata,
        GameHardwareItemEditDraft>(
      schema: gameHardwareItemEditSchema,
      model: _metadata,
      draft: _draft,
      maxDialogWidth: 1200,
      insetPadding: EdgeInsets.fromLTRB(
        MediaQuery.sizeOf(context).width <= 900 ? 0 : 24,
        kAppEditorTopInset,
        MediaQuery.sizeOf(context).width <= 900 ? 0 : 24,
        24,
      ),
      title: gameHardwareEditHeaderTitle(_metadata),
      icon: widget.request.type.identity.icon,
      mediaKind: widget.request.type.kind.apiValue,
      vocabularyAccumulator: vocabularyEdits,
      accent: accent,
      tabOrderKey: 'library_edit_tabs_game_hardware_v1',
      contributions: LibraryEditSchemaContributions(
        personal: LibraryEditPersonalTabContribution(
          icon: AppIcons.tabPersonal,
          afterTabId: 'value',
          layoutBuilder: gameHardwarePersonalFormLayout,
          additionalFieldsBuilder: gameHardwarePersonalAdditionalFields,
        ),
        customFields: LibraryEditCustomFieldsTabContribution(
          icon: AppIcons.tabCustomFields,
          definitions: widget.request.customFieldDefinitions,
          values: _customFieldEdits,
          onChanged: (values) =>
              setState(() => _customFieldEdits = Map.of(values)),
          onCustomValueChanged: (fieldDefinitionId, value) {
            final definition = widget.request.customFieldDefinitions
                .where((item) => item.id == fieldDefinitionId)
                .firstOrNull;
            _draft.vocabularyEdits.replaceValue(
              fieldId: 'custom:$fieldDefinitionId',
              listName: 'customField:$fieldDefinitionId',
              value: value,
              mediaKind:
                  definition?.mediaKind ?? widget.request.type.kind.apiValue,
            );
          },
        ),
        images: LibraryEditImagesTabContribution(
          icon: AppIcons.tabImages,
          afterTabId: 'covers',
          images: [
            for (final image in widget.request.itemImages)
              if (image.imageType != 'front_cover' &&
                  image.imageType != 'back_cover')
                image,
          ],
          onChanged: (edits) => setState(() => _imageEdits = edits),
        ),
      ),
      extraTabs: [
        if (personal != null)
          EditSchemaExtraTab(
            id: 'value',
            label: 'Value',
            icon: AppIcons.tabValue,
            content: GameHardwareValueTab(draft: personal),
          ),
        EditSchemaExtraTab(
          id: 'covers',
          label: 'Image',
          icon: AppIcons.tabCovers,
          content: GameHardwareCoversTab(
            images: [
              for (final image in widget.request.itemImages)
                if (image.imageType == 'front_cover' ||
                    image.imageType == 'back_cover')
                  image,
            ],
            coverImageUrl: _draft.values.coverImageUrl,
            originalCoverImageUrl: _metadata.coverImageUrl ?? '',
            onCoverImageUrlChanged: (value) =>
                _draft.values.coverImageUrl = value,
            onEdits: (edits) => setState(() => _coverEdits = edits),
          ),
        ),
        EditSchemaExtraTab(
          id: 'description',
          label: 'Description',
          icon: AppIcons.tabDescription,
          content: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: LibraryFormField(
              label: 'Description',
              child: LibraryTextFormControl(
                initialValue: _draft.values.description,
                minLines: 18,
                maxLines: 18,
                onChanged: (value) => _draft.values.description = value,
              ),
            ),
          ),
        ),
        EditSchemaExtraTab(
          id: 'links',
          label: 'Links',
          icon: AppIcons.tabLinks,
          content: _GameHardwareLinksTab(draft: _draft, accent: accent),
        ),
      ],
      coreCorrectionSourceBuilder: () {
        final coreRef = coreCatalogRefForEditRequest(widget.request);
        const codec = GameHardwareCatalogTransportCodec();
        return LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          coreCatalogRef: coreRef,
          originalFields: codec.encode(coreRef.id, _metadata).kindData,
          proposedFields:
              codec.encode(coreRef.id, _draft.toMetadata()).kindData,
        );
      },
      onCancel: () => Navigator.of(context).pop(),
      onPrevious: widget.request.onPrevious,
      onNext: widget.request.onNext,
      hasUnsavedChanges: () =>
          _initialJson != jsonEncode(_draft.toMetadata().toJson()) ||
          _imageEdits.isNotEmpty ||
          _coverEdits.isNotEmpty ||
          jsonEncode(_customFieldEdits) != jsonEncode(_initialCustomFieldEdits),
      onSave: (_) async {
        final updated = _draft.toMetadata();
        final candidate = personal == null
            ? widget.request.kindItem.kindCapability.mapTransport(
                (transport) => CatalogSearchCandidate.fromItem(
                  transport.replacingKindData(updated),
                  basedOn: widget.request.kindItem,
                ),
              )
            : widget.request.kindItem.kindCapability.replacingKindData(updated);
        await commitLibraryEdit(
          context,
          LibraryEditSelection(
            kindItem: candidate,
            customFieldEdits: Map.unmodifiable(_customFieldEdits),
            itemImageEdits: [..._imageEdits, ..._coverEdits],
            localChanges: [
              if (personal == null && !vocabularyEdits.isEmpty)
                vocabularyEdits.toEditChange(
                  defaultMediaKind: widget.request.type.kind.apiValue,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Reference Links tab: web links and YouTube trailers.
final class _GameHardwareLinksTab extends StatelessWidget {
  const _GameHardwareLinksTab({required this.draft, required this.accent});

  final GameHardwareItemEditDraft draft;
  final Color accent;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          LibraryExternalLinksEditSection(
            links: draft.links,
            accent: accent,
            onChanged: (links) => draft.links = links,
          ),
          const SizedBox(height: 18),
          LibraryExternalLinksEditSection(
            links: draft.trailers,
            accent: accent,
            addLabel: 'Add YouTube Trailer',
            emptyMessage: 'No YouTube trailers added.',
            onChanged: (links) => draft.trailers = links,
          ),
        ]),
      );
}
