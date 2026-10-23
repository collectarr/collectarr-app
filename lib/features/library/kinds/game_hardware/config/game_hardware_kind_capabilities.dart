import '../stats/game_hardware_stats_capability.dart';
import 'game_hardware_kind_configuration.dart';
import '../game_hardware_module_dependencies.dart';

final gameHardwareKindIdentity = const LibraryKindIdentity(
    kind: CatalogMediaKind.gameHardware,
    singularLabel: 'Hardware',
    pluralLabel: 'Hardware',
    title: 'Games',
    icon: Icons.devices,
    coverPlaceholderIcon: Icons.devices,
    accent: Color(0xFFE23149),
    preferencePrefix: 'game_hardware',
    routeSegments: ['game-hardware', 'game_hardware'],
    mediaFamily: 'game',
    isTopLevel: false,
    collectionFamily: 'games',
    defaultCollectionName: 'Hardware');
final gameHardwareKindPhysicalMediaFormats = const <PhysicalMediaFormat>[];
final gameHardwareKindUiPolicy = const LibraryUiPolicy(coverAspectRatio: 0.7);
final gameHardwareKindToolbar = null;
final gameHardwareKindSearchTargetOptions = const <LibrarySearchTarget>[];
final gameHardwareKindTrackingProfile =
    const MediaTrackingProfile(name: 'Hardware', options: []);
final gameHardwareKindTrackingTopology = const LibraryTrackingTopology();
final gameHardwareKindViewProfile = standardMediaWorkspaceViewProfile(
    CatalogMediaKind.gameHardware, gameHardwareKindUiPolicy,
    defaultDetailsLayout: LibraryDetailsLayout.right, defaultDetailsWidth: 350);
final gameHardwareKindMetadata = const LibraryMetadataCapability(
    catalogTransportCodec: GameHardwareCatalogTransportCodec(),
    searchQueryBuilder: gameHardwareMetadataSearchQuery);
final gameHardwareKindEntityVocabulary = const LibraryTargetVocabulary(
    catalogItem: LibraryTargetLabel(singular: 'Hardware', plural: 'Hardware'),
    libraryEntry: LibraryTargetLabel(singular: 'Entry', plural: 'Entries'));
final gameHardwareKindPersonalFieldContributor =
    LibraryPersonalFieldContributor(
        kind: CatalogMediaKind.gameHardware,
        fields: [
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
        ('game_hardware_completeness', 'Completeness'),
        ('game_hardware_has_box', 'Box'),
        ('game_hardware_price_charting_id', 'PriceCharting ID'),
        ('game_hardware_value_is_locked', 'Value Locked'),
        ('game_hardware_has_manual', 'Manual'),
        ('game_hardware_serial_number', 'Serial No.'),
      ])
        PersonalLibraryFieldSpec(
            key: key, label: label, group: 'Hardware', syncable: true),
    ]);
final gameHardwareKindActions = const LibraryTargetActionCapability(
    catalogItem: LibraryTargetActionSet.catalogItem,
    libraryEntry: LibraryTargetActionSet.libraryEntry);
final gameHardwareKindInspector = LibraryInspectorCapability(
    entityRegistry: LibraryTargetInspectorRegistry(
        catalogItem: LibraryTargetInspectorContributor(
            heroBuilder: buildGameHardwareInspectorHero,
            sectionsBuilder: buildGameHardwareInspectorSections),
        libraryEntry: LibraryTargetInspectorContributor(
            heroBuilder: buildGameHardwareInspectorHero,
            sectionsBuilder: buildGameHardwareInspectorSections)),
    showsDefaultPersonalSection: false,
    showsActionBar: false,
    supportsLibraryEntryImages: false);
final gameHardwareKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<GameHardwareCatalogMetadata>(
        gameHardwareLinkedMetadata, gameHardwareLinkedMetadataValues);
final gameHardwareKindTransfer =
    LibraryTransferCapability(transferableFieldKeys: [
  ...kDefaultTransferableFieldKeys,
  for (final field in gameHardwareTransferableFields) field.key
], kindFields: [
  ...gameHardwareUniversalTransferableFields,
  ...gameHardwareTransferableFields
]);
final gameHardwareKindStats = const GameHardwareStatsCapability();
