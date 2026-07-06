import 'package:collectarr_app/core/db/local_database.dart';

import 'models/pick_list_definition.dart';
import 'models/pick_list_scope.dart';
import 'pick_list_registry.dart';
import 'pick_list_repository.dart';

class PickListService {
  PickListService(LocalDatabase db, {PickListRegistry? registry})
      : registry = registry ?? PickListRegistry(),
        repository = PickListRepository(db);

  final PickListRegistry registry;
  final PickListRepository repository;

  List<PickListDefinition> definitionsForKind(String? mediaKind) {
    return registry.definitionsForKind(mediaKind);
  }

  PickListDefinition? definitionForField({
    required String fieldKey,
    required String? mediaKind,
    required PickListScope scope,
  }) {
    return registry.definitionForField(
      fieldKey: fieldKey,
      mediaKind: mediaKind,
      scope: scope,
    );
  }
}
