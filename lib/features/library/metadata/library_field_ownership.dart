import 'package:flutter/foundation.dart';

enum LibraryFieldOwnership {
  canonicalMetadata,
  personalLibrary,
  syncablePersonal,
}

@immutable
class PersonalLibraryFieldSpec {
  const PersonalLibraryFieldSpec({
    required this.key,
    required this.label,
    required this.group,
    this.syncable = false,
  });

  final String key;
  final String label;
  final String group;
  final bool syncable;
}

const List<PersonalLibraryFieldSpec> kPersonalLibraryFields = [
  PersonalLibraryFieldSpec(
    key: 'front_cover',
    label: 'Front cover',
    group: 'Images',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'back_cover',
    label: 'Back cover',
    group: 'Images',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'condition',
    label: 'Condition',
    group: 'Collection state',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'grade',
    label: 'Grade',
    group: 'Collection state',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'location_id',
    label: 'Location',
    group: 'Collection state',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'tags',
    label: 'Tags',
    group: 'Collection state',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'collection_status',
    label: 'Collection status',
    group: 'Collection state',
  ),
  PersonalLibraryFieldSpec(
    key: 'owner_user_id',
    label: 'Owner user ID',
    group: 'Collection state',
  ),
  PersonalLibraryFieldSpec(
    key: 'owner_label',
    label: 'Owner label',
    group: 'Collection state',
  ),
  PersonalLibraryFieldSpec(
    key: 'rating',
    label: 'Rating',
    group: 'Tracking',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'read_status',
    label: 'Read status',
    group: 'Tracking',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'started_at',
    label: 'Started at',
    group: 'Tracking',
  ),
  PersonalLibraryFieldSpec(
    key: 'finished_at',
    label: 'Finished at',
    group: 'Tracking',
  ),
  PersonalLibraryFieldSpec(
    key: 'progress_current',
    label: 'Progress current',
    group: 'Tracking',
  ),
  PersonalLibraryFieldSpec(
    key: 'progress_total',
    label: 'Progress total',
    group: 'Tracking',
  ),
  PersonalLibraryFieldSpec(
    key: 'times_completed',
    label: 'Times completed',
    group: 'Tracking',
  ),
  PersonalLibraryFieldSpec(
    key: 'notes',
    label: 'Notes',
    group: 'Tracking',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'season_number',
    label: 'Season number',
    group: 'Tracking',
  ),
  PersonalLibraryFieldSpec(
    key: 'episode_number',
    label: 'Episode number',
    group: 'Tracking',
  ),
  PersonalLibraryFieldSpec(
    key: 'episode_ratings',
    label: 'Episode ratings',
    group: 'Tracking',
  ),
  PersonalLibraryFieldSpec(
    key: 'purchase_date',
    label: 'Purchase date',
    group: 'Acquisition',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'price_paid_cents',
    label: 'Price paid',
    group: 'Acquisition',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'currency',
    label: 'Currency',
    group: 'Acquisition',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'personal_notes',
    label: 'Personal notes',
    group: 'Acquisition',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'quantity',
    label: 'Quantity',
    group: 'Acquisition',
  ),
  PersonalLibraryFieldSpec(
    key: 'index_number',
    label: 'Index number',
    group: 'Acquisition',
  ),
  PersonalLibraryFieldSpec(
    key: 'cover_price_cents',
    label: 'Cover price',
    group: 'Acquisition',
  ),
  PersonalLibraryFieldSpec(
    key: 'raw_or_slabbed',
    label: 'Raw or slabbed',
    group: 'Grading',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'grading_company',
    label: 'Grading company',
    group: 'Grading',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'grader_notes',
    label: 'Grader notes',
    group: 'Grading',
  ),
  PersonalLibraryFieldSpec(
    key: 'signed_by',
    label: 'Signed by',
    group: 'Grading',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'label_type',
    label: 'Label type',
    group: 'Grading',
  ),
  PersonalLibraryFieldSpec(
    key: 'custom_label',
    label: 'Custom label',
    group: 'Grading',
  ),
  PersonalLibraryFieldSpec(
    key: 'page_quality',
    label: 'Page quality',
    group: 'Grading',
  ),
  PersonalLibraryFieldSpec(
    key: 'certification_number',
    label: 'Certification number',
    group: 'Grading',
  ),
  PersonalLibraryFieldSpec(
    key: 'key_comic',
    label: 'Key comic',
    group: 'Comic flags',
  ),
  PersonalLibraryFieldSpec(
    key: 'key_reason',
    label: 'Key reason',
    group: 'Comic flags',
  ),
  PersonalLibraryFieldSpec(
    key: 'key_category',
    label: 'Key category',
    group: 'Comic flags',
  ),
  PersonalLibraryFieldSpec(
    key: 'key_severity',
    label: 'Key severity',
    group: 'Comic flags',
  ),
  PersonalLibraryFieldSpec(
    key: 'sold_at',
    label: 'Sold at',
    group: 'Trading',
  ),
  PersonalLibraryFieldSpec(
    key: 'sell_price_cents',
    label: 'Sell price',
    group: 'Trading',
  ),
  PersonalLibraryFieldSpec(
    key: 'sold_to',
    label: 'Sold to',
    group: 'Trading',
  ),
  PersonalLibraryFieldSpec(
    key: 'market_value_cents',
    label: 'Market value',
    group: 'Trading',
  ),
  PersonalLibraryFieldSpec(
    key: 'features',
    label: 'Features',
    group: 'Storage',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'hdr_formats',
    label: 'HDR formats',
    group: 'Storage',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'purchase_store',
    label: 'Purchase store',
    group: 'Storage',
  ),
  PersonalLibraryFieldSpec(
    key: 'box_set_id',
    label: 'Box set ID',
    group: 'Storage',
  ),
  PersonalLibraryFieldSpec(
    key: 'box_set_name',
    label: 'Box set name',
    group: 'Storage',
  ),
  PersonalLibraryFieldSpec(
    key: 'storage_device',
    label: 'Storage device',
    group: 'Storage',
  ),
  PersonalLibraryFieldSpec(
    key: 'storage_slot',
    label: 'Storage slot',
    group: 'Storage',
  ),
  PersonalLibraryFieldSpec(
    key: 'region',
    label: 'Region',
    group: 'Storage',
  ),
  PersonalLibraryFieldSpec(
    key: 'packaging',
    label: 'Packaging',
    group: 'Storage',
  ),
  PersonalLibraryFieldSpec(
    key: 'distributor',
    label: 'Distributor',
    group: 'Storage',
  ),
  PersonalLibraryFieldSpec(
    key: 'last_bag_board_date',
    label: 'Last bag/board date',
    group: 'Storage',
  ),
  PersonalLibraryFieldSpec(
    key: 'game_completeness',
    label: 'Game completeness',
    group: 'Games',
  ),
  PersonalLibraryFieldSpec(
    key: 'game_has_box',
    label: 'Game has box',
    group: 'Games',
  ),
  PersonalLibraryFieldSpec(
    key: 'game_has_manual',
    label: 'Game has manual',
    group: 'Games',
  ),
  PersonalLibraryFieldSpec(
    key: 'game_price_charting_id',
    label: 'Game PriceCharting ID',
    group: 'Games',
  ),
  PersonalLibraryFieldSpec(
    key: 'game_core_region',
    label: 'Game core region',
    group: 'Games',
  ),
  PersonalLibraryFieldSpec(
    key: 'game_value_is_locked',
    label: 'Game value locked',
    group: 'Games',
  ),
];

const List<PersonalLibraryFieldSpec> kSyncablePersonalFields = [
  PersonalLibraryFieldSpec(
    key: 'front_cover',
    label: 'Front Cover',
    group: 'Images',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'back_cover',
    label: 'Back Cover',
    group: 'Images',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'condition',
    label: 'Condition',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'grade',
    label: 'Grade',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'location_id',
    label: 'Location',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'tags',
    label: 'Tags',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'collection_status',
    label: 'Collection status',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'owner_label',
    label: 'Owner label',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'rating',
    label: 'Rating',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'read_status',
    label: 'Read Status',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'personal_notes',
    label: 'Notes',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'purchase_date',
    label: 'Date Purchased',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'price_paid_cents',
    label: 'Price Paid',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'currency',
    label: 'Currency',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'sold_at',
    label: 'Sold At',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'sell_price_cents',
    label: 'Sell Price',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'sold_to',
    label: 'Sold To',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'purchase_store',
    label: 'Purchase Store',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'features',
    label: 'Features',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'hdr_formats',
    label: 'HDR Formats',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'raw_or_slabbed',
    label: 'Raw or Slabbed',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'grading_company',
    label: 'Grading Company',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'signed_by',
    label: 'Signed By',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'game_completeness',
    label: 'Game Completeness',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'game_has_box',
    label: 'Game Has Box',
    group: 'Personal',
    syncable: true,
  ),
  PersonalLibraryFieldSpec(
    key: 'game_has_manual',
    label: 'Game Has Manual',
    group: 'Personal',
    syncable: true,
  ),
];

bool isPersonalLibraryField(String key) {
  return kPersonalLibraryFields.any((field) => field.key == key);
}

bool isSyncablePersonalField(String key) {
  return kSyncablePersonalFields.any((field) => field.key == key);
}
