import 'library_field_entries.dart';

/// Reusable personal field specifications selected by each kind.
///
/// The registry does not apply these fields implicitly. A kind explicitly
/// includes them in its contributor so the final field set is composed from
/// kind-owned declarations.
const List<PersonalLibraryFieldSpec> commonPersonalLibraryFields = [
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
    key: 'index_number',
    label: 'Index number',
    group: 'Acquisition',
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
    key: 'purchase_store',
    label: 'Purchase store',
    group: 'Acquisition',
  ),
];
