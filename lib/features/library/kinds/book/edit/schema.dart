import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/edit/schema/schema.dart';
import '../domain/book_metadata.dart';
import '../add/schema.dart';
import '../forms/catalog_form_field_ids.dart';
import 'draft.dart';

String bookEditHeaderTitle(BookCatalogMetadata metadata) {
  final author = metadata.creators.firstOrNull?.name.trim() ?? '';
  return author.isEmpty ? metadata.title : '${metadata.title} / $author';
}

final bookItemEditSchema = EditSchema<BookCatalogMetadata, BookItemEditDraft>(
  title: bookEditHeaderTitle,
  validate: (_, draft) =>
      bookAddSchemaFor<BookItemEditDraft>().validate?.call(draft),
  tabs: [
    for (final tab in [
      ('main', 'Main', AppIcons.book, bookMainFieldIds),
      ('details', 'Details', AppIcons.tabDetails, bookDetailsFieldIds),
      ('credits', 'Credits', AppIcons.tabCredits, bookCreditFieldIds),
    ])
      EditTabSpec<BookItemEditDraft>(
        id: tab.$1,
        label: tab.$2,
        icon: tab.$3,
        sections:
            bookAddSchemaFor<BookItemEditDraft>(fieldIds: tab.$4).sections,
      ),
  ],
);
