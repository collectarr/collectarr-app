import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_values.dart';
import 'package:flutter/material.dart';

final EditSchema<ComicMedia, ComicMediaFormValues> comicMediaEditSchema =
    EditSchema(
  title: (_) => 'Edit comic',
  validate: (_, values) {
    final pageCount = values.pageCount;
    if (pageCount != null && pageCount < 0) {
      return 'Page count cannot be negative';
    }
    return null;
  },
  tabs: [
    EditTabSpec<ComicMediaFormValues>(
      id: 'main',
      label: 'Main',
      icon: Icons.article,
      sections: [
        EditSectionSpec<ComicMediaFormValues>(
          id: 'catalog_snapshot',
          label: 'Issue',
          fields: comicMediaIdentityFields(
            values: (values) => values,
          ),
        ),
      ],
    ),
    EditTabSpec<ComicMediaFormValues>(
      id: 'details',
      label: 'Details',
      icon: Icons.search,
      sections: [
        EditSectionSpec<ComicMediaFormValues>(
          id: 'catalog_details',
          label: 'Publication details',
          fields: comicMediaPublicationFields(
            values: (values) => values,
          ),
        ),
      ],
    ),
    _customTab(
      id: 'creators',
      label: 'Creators',
      icon: Icons.group,
      sectionId: 'comic_creators',
      sectionLabel: 'Creator credits',
      fieldId: 'creator_credits',
      fieldLabel: 'Creators',
    ),
    _customTab(
      id: 'characters',
      label: 'Characters',
      icon: Icons.face,
      sectionId: 'comic_characters',
      sectionLabel: 'Character appearances',
      fieldId: 'character_appearances',
      fieldLabel: 'Characters',
    ),
    _customTab(
      id: 'links',
      label: 'Links',
      icon: Icons.public,
      sectionId: 'external_links',
      sectionLabel: 'External links',
      fieldId: 'external_links',
      fieldLabel: 'Links',
    ),
    _customTab(
      id: 'cover',
      label: 'Covers',
      icon: Icons.image,
      sectionId: 'cover_images',
      sectionLabel: 'Cover images',
      fieldId: 'cover_images',
      fieldLabel: 'Covers',
    ),
    _customTab(
      id: 'photos',
      label: 'My Images',
      icon: Icons.photo_library,
      sectionId: 'photos',
      sectionLabel: 'Personal images',
      fieldId: 'photos',
      fieldLabel: 'Photos',
    ),
  ],
);

EditTabSpec<ComicMediaFormValues> _customTab({
  required String id,
  required String label,
  required IconData icon,
  required String sectionId,
  required String sectionLabel,
  required String fieldId,
  required String fieldLabel,
}) =>
    EditTabSpec<ComicMediaFormValues>(
      id: id,
      label: label,
      icon: icon,
      sections: [
        EditSectionSpec<ComicMediaFormValues>(
          id: sectionId,
          label: sectionLabel,
          fields: [
            LibraryCustomFieldSpec<ComicMediaFormValues>(
              id: fieldId,
              label: fieldLabel,
              builder: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
