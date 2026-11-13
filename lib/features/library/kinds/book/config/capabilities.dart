import '../selection/contribution.dart';
import 'package:collectarr_app/features/library/config/kind_toolbar_module.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import '../book_module_dependencies.dart';
import 'configuration.dart';
import '../data/book_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/metadata/common_personal_library_fields.dart';

final bookKindPersonalFieldContributor = LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.book,
  fields: [
    for (final field in commonPersonalLibraryFields)
      relabelPersonalLibraryField(
          field,
          const {
                'collection_status': 'Collection Status',
                'condition': 'Book Condition',
                'market_value_cents': 'My Value',
                'price_paid_cents': 'Purchase Price',
                'purchase_store': 'Purchase Store',
                'purchase_date': 'Purchase Date',
                'personal_notes': 'Notes',
                'rating': 'My Rating',
                'owner_label': 'Owner',
              }[field.key] ??
              field.label),
    const PersonalLibraryFieldSpec(
        key: 'quantity',
        label: 'Quantity',
        group: 'Collection state',
        syncable: true,
        inputKind: PersonalLibraryFieldEditor.integer,
        area: PersonalLibraryFieldArea.statusStrip,
        editOrder: 2,
        minimum: 0,
        defaultInteger: 1),
    const PersonalLibraryFieldSpec(
      key: 'signed_by',
      label: 'Signed by',
      group: 'Collection details',
      syncable: true,
    ),
  ],
);

final bookKindPresentation = bookLibraryMediaPresentation;

final bookKindPhysicalMediaFormats = bookPhysicalMediaFormats;

final bookKindTrackingProfile = bookTrackingProfile;

final bookKindUiPolicy = const LibraryUiPolicy();

final LibraryValueCapability? bookKindValue = null;

final LibraryRelationCapability? bookKindRelations = null;

const bookKindToolbar =
    LibraryKindToolbarModule(selectionActions: bookSelectionActions);

final bookKindSearchTargetOptions = const <LibrarySearchTarget>[];

final bookKindViewProfile = standardMediaWorkspaceViewProfile(
  CatalogMediaKind.book,
  const LibraryUiPolicy(),
);

final bookKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.book,
  singularLabel: 'Book',
  pluralLabel: 'Books',
  title: 'Books',
  icon: Icons.book_outlined,
  coverPlaceholderIcon: AppIcons.book,
  accent: Color(0xFF9B6296),
  preferencePrefix: 'books',
  routeSegments: ['books', 'book'],
  mediaFamily: 'print',
  toolbarActions: [
    ...kDefaultLibraryToolbarActions,
    LibraryToolbarActionId.readingQueue,
  ],
);

final bookKindMetadata = const LibraryMetadataCapability(
  catalogTransportCodec: BookCatalogTransportCodec(),
  searchQueryBuilder: bookMetadataSearchQuery,
);

final bookKindEntityVocabulary = const LibraryTargetVocabulary(
  catalogItem: LibraryTargetLabel(singular: 'Book', plural: 'Books'),
  libraryEntry: LibraryTargetLabel(singular: 'Entry', plural: 'Entries'),
);

final bookKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.read,
  writableTargets: {LibraryTrackingTarget.libraryEntry},
  aggregateTargets: {LibraryTrackingTarget.libraryEntry},
);

final bookKindActions = const LibraryTargetActionCapability(
  catalogItem: LibraryTargetActionSet.catalogItem,
  libraryEntry: LibraryTargetActionSet.libraryEntry,
);

final bookKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryTargetInspectorRegistry(
    catalogItem: LibraryTargetInspectorContributor(
      heroBuilder: buildBookCatalogItemInspectorHero,
      sectionsBuilder: buildBookCatalogItemInspectorSections,
    ),
    libraryEntry: LibraryTargetInspectorContributor(
      heroBuilder: buildBookLibraryEntryInspectorHero,
      sectionsBuilder: buildBookLibraryEntryInspectorSections,
    ),
  ),
  showsDefaultPersonalSection: false,
  showsActionBar: false,
  supportsLibraryEntryImages: true,
);

final bookKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<BookCatalogMetadata>(
  bookLinkedMetadata,
  bookLinkedMetadataValues,
);

final bookKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in bookTransferableFields) field.key,
  ],
  kindFields: [
    ...bookUniversalTransferableFields,
    ...bookTransferableFields,
  ],
);

final bookKindStats = const BookStatsCapability();
