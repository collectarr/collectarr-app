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

/// Personal fields shared by every kind.
///
/// Kind-specific fields are intentionally not declared here. They are
/// contributed by the owning kind module and composed by the registry.
const List<PersonalLibraryFieldSpec> kUniversalPersonalLibraryFields = [
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
    syncable: true,
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
    syncable: true,
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
];
