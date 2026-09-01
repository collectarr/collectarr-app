import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

import 'models/pick_list_definition.dart';
import 'models/pick_list_scope.dart';

class PickListRegistry {
  const PickListRegistry();

  static const _universalDefinitions = <PickListDefinition>[
    PickListDefinition(
      id: 'tags',
      listName: 'tags',
      label: 'Tags',
      scope: PickListScope.ownedCopy,
      valueMode: PickListValueMode.multi,
      controlType: PickListControlType.tagList,
      allowFoldering: true,
    ),
    PickListDefinition(
      id: 'conditions',
      listName: 'conditions',
      label: 'Condition',
      scope: PickListScope.ownedCopy,
      valueMode: PickListValueMode.single,
      controlType: PickListControlType.dropdown,
      allowMerge: true,
    ),
    PickListDefinition(
      id: 'grades',
      listName: 'grades',
      label: 'Grade',
      scope: PickListScope.ownedCopy,
      valueMode: PickListValueMode.single,
      controlType: PickListControlType.dropdown,
      allowMerge: true,
    ),
    PickListDefinition(
      id: 'owners',
      listName: 'owners',
      label: 'Owner',
      scope: PickListScope.ownedCopy,
      valueMode: PickListValueMode.single,
      controlType: PickListControlType.personList,
    ),
    PickListDefinition(
      id: 'collection_status',
      listName: 'collection_status',
      label: 'Collection status',
      scope: PickListScope.ownedCopy,
      valueMode: PickListValueMode.single,
    ),
    PickListDefinition(
      id: 'purchase_store',
      listName: 'purchase_store',
      label: 'Purchase store',
      scope: PickListScope.ownedCopy,
      valueMode: PickListValueMode.single,
    ),
    PickListDefinition(
      id: 'sold_to',
      listName: 'sold_to',
      label: 'Sold to',
      scope: PickListScope.ownedCopy,
      valueMode: PickListValueMode.single,
    ),
    PickListDefinition(
      id: 'borrower',
      listName: 'borrower',
      label: 'Borrower',
      scope: PickListScope.trackingEntry,
      valueMode: PickListValueMode.single,
    ),
  ];

  List<PickListDefinition> definitionsForKind(String? mediaKind) {
    final definitions = <PickListDefinition>[..._universalDefinitions];
    if (mediaKind == null || mediaKind.trim().isEmpty) {
      for (final runtime in defaultLibraryKindRegistry.allRuntimes) {
        definitions.addAll(_definitionsForRuntime(runtime));
      }
      return definitions;
    }

    final kind = catalogMediaKindFromApiValue(mediaKind);
    if (!kind.isUnknown) {
      definitions.addAll(
        _definitionsForRuntime(libraryKindRuntimeForKind(kind)),
      );
    }
    return definitions;
  }

  PickListDefinition? definitionForField({
    required String fieldKey,
    required String? mediaKind,
    required PickListScope scope,
  }) {
    final normalizedKey = fieldKey.trim().toLowerCase();
    final candidates = definitionsForKind(mediaKind);
    for (final definition in candidates) {
      if (definition.scope != scope) {
        continue;
      }
      if (definition.id == normalizedKey ||
          definition.listName == normalizedKey) {
        return definition;
      }
    }
    if (normalizedKey.startsWith('customfield:')) {
      return PickListDefinition(
        id: normalizedKey,
        listName: normalizedKey,
        label: fieldKey.substring('customField:'.length),
        mediaKind: mediaKind,
        scope: PickListScope.customField,
        valueMode: PickListValueMode.multi,
        controlType: PickListControlType.tagList,
        allowMerge: true,
      );
    }
    return null;
  }

  List<PickListDefinition> _definitionsForRuntime(
    LibraryKindRuntime runtime,
  ) {
    final vocabularies = runtime.edit.vocabularies;
    if (vocabularies == null) {
      return const [];
    }
    return [
      for (final vocabulary in vocabularies.definitions)
        PickListDefinition.fromVocabulary(
          vocabulary: vocabulary,
          mediaKind: runtime.kind.apiValue,
        ),
    ];
  }
}
