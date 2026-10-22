import 'package:collectarr_app/ui/app_icons.dart';
import '../game_module_dependencies.dart';
import 'game_kind_configuration.dart';
import '../data/game_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/metadata/common_personal_library_fields.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';

final gameKindPresentation = gamesLibraryMediaPresentation;

final gameKindPhysicalMediaFormats = gamePhysicalMediaFormats;

final gameKindTrackingProfile = gameTrackingProfile;

final gameKindUiPolicy = const LibraryUiPolicy(coverAspectRatio: 0.7);

final LibraryRelationCapability? gameKindRelations = null;

final LibraryValueCapability? gameKindValue = null;

final gameKindToolbar = null;

final gameKindSearchTargetOptions = const <LibrarySearchTarget>[];

final gameKindViewProfile = standardMediaWorkspaceViewProfile(
  CatalogMediaKind.game,
  gameKindUiPolicy,
  defaultDetailsLayout: LibraryDetailsLayout.right,
  defaultDetailsWidth: 350,
);

final gameKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.game,
  singularLabel: 'Game',
  pluralLabel: 'Games',
  title: 'Games',
  icon: Icons.sports_esports,
  coverPlaceholderIcon: AppIcons.gamepad,
  accent: Color(0xFFE23149),
  preferencePrefix: 'games',
  routeSegments: ['games', 'game'],
  mediaFamily: 'game',
);

final gameKindMetadata = const LibraryMetadataCapability(
  catalogTransportCodec: GameCatalogTransportCodec(),
  searchQueryBuilder: gameMetadataSearchQuery,
);

final gameKindEntityVocabulary = const LibraryTargetVocabulary(
  catalogItem: LibraryTargetLabel(singular: 'Game', plural: 'Games'),
  libraryEntry: LibraryTargetLabel(singular: 'Entry', plural: 'Entries'),
);

final gameKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.play,
  writableTargets: {LibraryTrackingTarget.libraryEntry},
  aggregateTargets: {LibraryTrackingTarget.libraryEntry},
);

final gameKindPersonalFieldContributor = LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.game,
  fields: [
    for (final field in commonPersonalLibraryFields)
      relabelPersonalLibraryField(
          field,
          switch (field.key) {
            'market_value_cents' => 'Value',
            'price_paid_cents' => 'Purchase Price',
            'purchase_store' => 'Purchase Store',
            'purchase_date' => 'Purchase Date',
            'owner_label' => 'Owner',
            'rating' => 'My Rating',
            'personal_notes' => 'Notes',
            'collection_status' => 'Collection Status',
            _ => field.label,
          }),
    const PersonalLibraryFieldSpec(
        key: 'quantity',
        label: 'Quantity',
        group: 'Collection state',
        syncable: true,
        inputKind: PersonalLibraryFieldEditor.integer,
        area: PersonalLibraryFieldArea.statusStrip,
        editOrder: 2,
        minimum: 1,
        defaultInteger: 1),
    const PersonalLibraryFieldSpec(
      key: 'game_storage_device',
      label: 'Storage Device',
      group: 'Storage',
      syncable: true,
      inputKind: PersonalLibraryFieldEditor.singleVocabulary,
      area: PersonalLibraryFieldArea.personalFields,
      editOrder: 7,
      vocabularyListName: 'game.storage_device',
    ),
    for (final (key, label) in const [
      ('game_completeness', 'Completeness'),
      ('game_has_box', 'Box'),
      ('game_has_manual', 'Manual'),
      ('game_pricecharting_id', 'PriceCharting ID'),
      ('game_core_region', 'Core Region'),
      ('game_value_is_locked', 'Value Locked'),
      ('game_storage_slot', 'Storage Slot'),
      ('game_completed', 'Completed'),
      ('game_completed_date_parts', 'Completed Date'),
    ])
      PersonalLibraryFieldSpec(
        key: key,
        label: label,
        group: 'Games',
        syncable: true,
      ),
  ],
);

final gameKindActions = const LibraryTargetActionCapability(
  catalogItem: LibraryTargetActionSet.catalogItem,
  libraryEntry: LibraryTargetActionSet.libraryEntry,
);

final gameKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryTargetInspectorRegistry(
    catalogItem: LibraryTargetInspectorContributor(
      heroBuilder: buildGameInspectorHero,
      sectionsBuilder: buildGameInspectorSections,
    ),
    libraryEntry: LibraryTargetInspectorContributor(
      heroBuilder: buildGameInspectorHero,
      sectionsBuilder: buildGameInspectorSections,
    ),
  ),
  showsDefaultPersonalSection: false,
  showsActionBar: false,
  // The reference details show no My Images section.
  supportsLibraryEntryImages: false,
);

final gameKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<GameCatalogMetadata>(
  gameLinkedMetadata,
  gameLinkedMetadataValues,
);

final gameKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in gameTransferableFields) field.key,
  ],
  kindFields: [
    ...gameUniversalTransferableFields,
    ...gameTransferableFields,
  ],
);

final gameKindStats = const GameStatsCapability();
