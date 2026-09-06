import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details.dart';

class GenericOwnedDetailsDraft extends OwnedDetailsDraft {
  const GenericOwnedDetailsDraft();

  @override
  GenericOwnedDetails toDetails() => const GenericOwnedDetails();
}
