import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';

abstract final class UniversalVocabularyIds {
  static const tags = VocabularyId<String>('tags');
  static const owners = VocabularyId<String>('owners');
  static const collectionStatus = VocabularyId<String>('collection_status');
  static const purchaseStore = VocabularyId<String>('purchase_store');
  static const soldTo = VocabularyId<String>('sold_to');
  static const borrower = VocabularyId<String>('borrower');
}

abstract final class UniversalVocabularies {
  static const tags = VocabularyDefinition<String>(
    id: UniversalVocabularyIds.tags,
    label: 'Tags',
    multiValue: true,
  );

  static const owners = VocabularyDefinition<String>(
    id: UniversalVocabularyIds.owners,
    label: 'Owner',
  );

  static const collectionStatus = VocabularyDefinition<String>(
    id: UniversalVocabularyIds.collectionStatus,
    label: 'Collection status',
  );

  static const purchaseStore = VocabularyDefinition<String>(
    id: UniversalVocabularyIds.purchaseStore,
    label: 'Purchase store',
  );

  static const soldTo = VocabularyDefinition<String>(
    id: UniversalVocabularyIds.soldTo,
    label: 'Sold to',
  );

  static const borrower = VocabularyDefinition<String>(
    id: UniversalVocabularyIds.borrower,
    label: 'Borrower',
  );

  static const all = <VocabularyDefinition<dynamic>>[
    tags,
    owners,
    collectionStatus,
    purchaseStore,
    soldTo,
    borrower,
  ];
}
