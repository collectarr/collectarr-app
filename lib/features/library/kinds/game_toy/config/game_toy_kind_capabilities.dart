import '../stats/game_toy_stats_capability.dart';
import 'game_toy_kind_configuration.dart';
import '../game_toy_module_dependencies.dart';

final gameToyKindIdentity = const LibraryKindIdentity(
    kind: CatalogMediaKind.gameToy,
    singularLabel: 'Toy',
    pluralLabel: 'Toys',
    title: 'Games',
    icon: Icons.smart_toy,
    coverPlaceholderIcon: Icons.smart_toy,
    accent: Color(0xFFE23149),
    preferencePrefix: 'game_toy',
    routeSegments: ['game-toys', 'game_toy'],
    mediaFamily: 'game',
    isTopLevel: false,
    collectionFamily: 'games',
    hasTrailers: true,
    defaultCollectionName: 'Toys');
final gameToyKindPhysicalMediaFormats = const <PhysicalMediaFormat>[];
final gameToyKindUiPolicy = const LibraryUiPolicy(coverAspectRatio: 0.7);
final gameToyKindToolbar = null;
final gameToyKindSearchTargetOptions = const <LibrarySearchTarget>[];
final gameToyKindTrackingProfile =
    const MediaTrackingProfile(name: 'Toys', options: []);
final gameToyKindTrackingTopology = const LibraryTrackingTopology();
final gameToyKindViewProfile = standardMediaWorkspaceViewProfile(
    CatalogMediaKind.gameToy, gameToyKindUiPolicy,
    defaultDetailsLayout: LibraryDetailsLayout.right, defaultDetailsWidth: 350);
final gameToyKindMetadata = const LibraryMetadataCapability(
    catalogTransportCodec: GameToyCatalogTransportCodec(),
    searchQueryBuilder: gameToyMetadataSearchQuery);
final gameToyKindEntityVocabulary = const LibraryTargetVocabulary(
    catalogItem: LibraryTargetLabel(singular: 'Toy', plural: 'Toys'),
    libraryEntry: LibraryTargetLabel(singular: 'Entry', plural: 'Entries'));
final gameToyKindPersonalFieldContributor =
    LibraryPersonalFieldContributor(kind: CatalogMediaKind.gameToy, fields: [
  for (final field in commonPersonalLibraryFields)
    relabelPersonalLibraryField(
        field,
        const {
              'market_value_cents': 'Value',
              'price_paid_cents': 'Purchase Price',
              'purchase_store': 'Purchase Store',
              'purchase_date': 'Purchase Date',
              'personal_notes': 'Notes',
              'rating': 'My Rating',
              'owner_label': 'Owner'
            }[field.key] ??
            field.label),
  const PersonalLibraryFieldSpec(
      key: 'quantity',
      label: 'Quantity',
      group: 'Collection state',
      syncable: true,
      inputKind: PersonalLibraryFieldEditor.integer,
      area: PersonalLibraryFieldArea.statusStrip,
      minimum: 1,
      defaultInteger: 1),
  for (final (key, label) in const [
    ('game_toy_completeness', 'Completeness'),
    ('game_toy_has_box', 'Box'),
    ('game_toy_price_charting_id', 'PriceCharting ID'),
    ('game_toy_value_is_locked', 'Value Locked'),
  ])
    PersonalLibraryFieldSpec(
        key: key, label: label, group: 'Toys', syncable: true),
]);
final gameToyKindActions = const LibraryTargetActionCapability(
    catalogItem: LibraryTargetActionSet.catalogItem,
    libraryEntry: LibraryTargetActionSet.libraryEntry);
final gameToyKindInspector = LibraryInspectorCapability(
    entityRegistry: LibraryTargetInspectorRegistry(
        catalogItem: LibraryTargetInspectorContributor(
            heroBuilder: buildGameToyInspectorHero,
            sectionsBuilder: buildGameToyInspectorSections),
        libraryEntry: LibraryTargetInspectorContributor(
            heroBuilder: buildGameToyInspectorHero,
            sectionsBuilder: buildGameToyInspectorSections)),
    showsDefaultPersonalSection: false,
    showsActionBar: false,
    supportsLibraryEntryImages: false);
final gameToyKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<GameToyCatalogMetadata>(
        gameToyLinkedMetadata, gameToyLinkedMetadataValues);
final gameToyKindTransfer = LibraryTransferCapability(transferableFieldKeys: [
  ...kDefaultTransferableFieldKeys,
  for (final field in gameToyTransferableFields) field.key
], kindFields: [
  ...gameToyUniversalTransferableFields,
  ...gameToyTransferableFields
]);
final gameToyKindStats = const GameToyStatsCapability();
