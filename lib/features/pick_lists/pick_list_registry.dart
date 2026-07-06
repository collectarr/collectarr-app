import 'models/pick_list_definition.dart';
import 'models/pick_list_scope.dart';

class PickListRegistry {
  static const _globalDefinitions = <PickListDefinition>[
    PickListDefinition(
      id: 'condition',
      listName: 'condition',
      label: 'Condition',
      scope: PickListScope.ownedCopy,
      valueMode: PickListValueMode.single,
      controlType: PickListControlType.dropdown,
      allowMerge: true,
    ),
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
      id: 'location',
      listName: 'location',
      label: 'Location',
      scope: PickListScope.ownedCopy,
      valueMode: PickListValueMode.single,
      controlType: PickListControlType.dropdown,
      allowFoldering: true,
      allowSort: true,
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

  static const _kindDefinitions = <String, List<PickListDefinition>>{
    'comic': [
      PickListDefinition(
        id: 'grade',
        listName: 'grade',
        label: 'Grade',
        mediaKind: 'comic',
        scope: PickListScope.ownedCopy,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'raw_or_slabbed',
        listName: 'raw_or_slabbed',
        label: 'Raw / slabbed',
        mediaKind: 'comic',
        scope: PickListScope.ownedCopy,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'grading_company',
        listName: 'grading_company',
        label: 'Grading company',
        mediaKind: 'comic',
        scope: PickListScope.ownedCopy,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'page_quality',
        listName: 'page_quality',
        label: 'Page quality',
        mediaKind: 'comic',
        scope: PickListScope.ownedCopy,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'key_category',
        listName: 'key_category',
        label: 'Key category',
        mediaKind: 'comic',
        scope: PickListScope.ownedCopy,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'key_severity',
        listName: 'key_severity',
        label: 'Key severity',
        mediaKind: 'comic',
        scope: PickListScope.ownedCopy,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'story_arc',
        listName: 'story_arc',
        label: 'Story arc',
        mediaKind: 'comic',
        scope: PickListScope.media,
        valueMode: PickListValueMode.multi,
      ),
    ],
    'book': [
      PickListDefinition(
        id: 'book_format',
        listName: 'book_format',
        label: 'Book format',
        mediaKind: 'book',
        scope: PickListScope.release,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'binding',
        listName: 'binding',
        label: 'Binding',
        mediaKind: 'book',
        scope: PickListScope.release,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'publisher',
        listName: 'publisher',
        label: 'Publisher',
        mediaKind: 'book',
        scope: PickListScope.media,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'read_status',
        listName: 'read_status',
        label: 'Read status',
        mediaKind: 'book',
        scope: PickListScope.trackingEntry,
        valueMode: PickListValueMode.single,
      ),
    ],
    'movie': [
      PickListDefinition(
        id: 'region',
        listName: 'region',
        label: 'Region',
        mediaKind: 'movie',
        scope: PickListScope.release,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'packaging',
        listName: 'packaging',
        label: 'Packaging',
        mediaKind: 'movie',
        scope: PickListScope.release,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'distributor',
        listName: 'distributor',
        label: 'Distributor',
        mediaKind: 'movie',
        scope: PickListScope.release,
        valueMode: PickListValueMode.single,
      ),
    ],
    'tv': [
      PickListDefinition(
        id: 'region',
        listName: 'region',
        label: 'Region',
        mediaKind: 'tv',
        scope: PickListScope.release,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'packaging',
        listName: 'packaging',
        label: 'Packaging',
        mediaKind: 'tv',
        scope: PickListScope.release,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'watch_source',
        listName: 'watch_source',
        label: 'Watch source',
        mediaKind: 'tv',
        scope: PickListScope.trackingEntry,
        valueMode: PickListValueMode.single,
      ),
    ],
    'game': [
      PickListDefinition(
        id: 'platform',
        listName: 'platform',
        label: 'Platform',
        mediaKind: 'game',
        scope: PickListScope.release,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'game_region',
        listName: 'game_region',
        label: 'Game region',
        mediaKind: 'game',
        scope: PickListScope.release,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'game_completeness',
        listName: 'game_completeness',
        label: 'Game completeness',
        mediaKind: 'game',
        scope: PickListScope.ownedCopy,
        valueMode: PickListValueMode.single,
      ),
    ],
    'boardgame': [
      PickListDefinition(
        id: 'mechanic',
        listName: 'mechanic',
        label: 'Mechanic',
        mediaKind: 'boardgame',
        scope: PickListScope.media,
        valueMode: PickListValueMode.multi,
      ),
      PickListDefinition(
        id: 'designer',
        listName: 'designer',
        label: 'Designer',
        mediaKind: 'boardgame',
        scope: PickListScope.media,
        valueMode: PickListValueMode.multi,
      ),
      PickListDefinition(
        id: 'play_status',
        listName: 'play_status',
        label: 'Play status',
        mediaKind: 'boardgame',
        scope: PickListScope.trackingEntry,
        valueMode: PickListValueMode.single,
      ),
    ],
    'music': [
      PickListDefinition(
        id: 'music_format',
        listName: 'music_format',
        label: 'Music format',
        mediaKind: 'music',
        scope: PickListScope.release,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'label',
        listName: 'label',
        label: 'Label',
        mediaKind: 'music',
        scope: PickListScope.media,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'pressing_type',
        listName: 'pressing_type',
        label: 'Pressing type',
        mediaKind: 'music',
        scope: PickListScope.release,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'media_condition',
        listName: 'media_condition',
        label: 'Media condition',
        mediaKind: 'music',
        scope: PickListScope.ownedCopy,
        valueMode: PickListValueMode.single,
      ),
      PickListDefinition(
        id: 'sleeve_condition',
        listName: 'sleeve_condition',
        label: 'Sleeve condition',
        mediaKind: 'music',
        scope: PickListScope.ownedCopy,
        valueMode: PickListValueMode.single,
      ),
    ],
    'anime': [
      PickListDefinition(
        id: 'anime_status',
        listName: 'anime_status',
        label: 'Watch status',
        mediaKind: 'anime',
        scope: PickListScope.trackingEntry,
        valueMode: PickListValueMode.single,
      ),
    ],
    'manga': [
      PickListDefinition(
        id: 'manga_status',
        listName: 'manga_status',
        label: 'Read status',
        mediaKind: 'manga',
        scope: PickListScope.trackingEntry,
        valueMode: PickListValueMode.single,
      ),
    ],
  };

  List<PickListDefinition> definitionsForKind(String? mediaKind) {
    final definitions = <PickListDefinition>[..._globalDefinitions];
    if (mediaKind == null || mediaKind.trim().isEmpty) {
      return definitions;
    }
    definitions.addAll(_kindDefinitions[mediaKind.trim().toLowerCase()] ?? const []);
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
      if (definition.id == normalizedKey || definition.listName == normalizedKey) {
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
}
