import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_ids.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_personal_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_workspace_fields.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:flutter/widgets.dart';

typedef _Catalog = GameToyCatalogWorkspaceFields;

List<LibraryColumnDefinition<GameToyKind, GameToyWorkspaceDto, Object?>>
    gameToyWorkspaceColumns({required bool personal}) => [
          for (final (field, type) in [
            (_Catalog.frontImage, 'front_cover'),
            (_Catalog.boxImage, 'back_cover')
          ])
            columnFromField(field,
                group: 'Images',
                defaultWidth: 48,
                minWidth: 44,
                allowSortInteraction: false,
                allowGroupInteraction: false,
                cellValue: (context) => SizedBox(
                    width: 32,
                    height: 32,
                    child: LibraryCoverImage(
                        title: context.dto.metadata.title,
                        imageUrl: type == 'front_cover'
                            ? context.dto.metadata.coverImageUrl
                            : null,
                        libraryEntryRef: context.dto.entry == null
                            ? null
                            : LibraryEntryRef(
                                kind: CatalogMediaKind.gameToy,
                                id: context.dto.entry!.id),
                        localImageType: type,
                        showPlaceholder: false,
                        borderRadius: 0))),
          for (final field in gameToyTextFields(personal: personal))
            columnFromField(field,
                group: gameToyFieldCategory(field),
                cellValue: field == _Catalog.releaseDate
                    ? (context) => Text(AppFormats.current.formatPartialDate(
                        context.dto.metadata.releaseDateParts))
                    : null,
                // Dates align right, as in the reference list.
                isNumeric: field == _Catalog.releaseDate ||
                    field == GameToyPersonalWorkspaceFields.purchaseDate,
                defaultWidth: field == _Catalog.title ? 260 : 140),
          if (personal)
            for (final field in GameToyPersonalWorkspaceFields.money)
              columnFromField(field,
                  group: 'Value',
                  isNumeric: true,
                  cellValue: (context) => Text(AppFormats.current.formatMoney(
                      field.getValue(context),
                      context.dto.entry?.personal.currency))),
        ];
