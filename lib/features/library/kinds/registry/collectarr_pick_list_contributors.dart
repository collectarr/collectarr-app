import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_registry.dart';

/// Generated composition of the vocabulary contributors owned by each kind.
const defaultPickListDefinitionContributors =
    collectarrKindPickListDefinitionContributors;

const defaultPickListRegistry = PickListRegistry(
  contributors: defaultPickListDefinitionContributors,
);
