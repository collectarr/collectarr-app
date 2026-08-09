import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';

class LibraryAddSelectionState {
  String? selectedResultId;
  String? selectedProviderCandidateId;
  String? selectedBundleReleaseId;
  String? selectedReferenceEditionId;
  String? selectedReferenceVariantId;
  final checkedResultIds = <String>{};
  final checkedProviderIds = <String>{};
  LibraryAddReferenceType referenceType = LibraryAddReferenceType.media;
  bool showCoreResults = true;
  bool showProviderResults = true;
  bool showMediaResults = true;
  bool showSeasonResults = true;
  bool showReleaseResults = true;
  bool hideComicOwnedResults = false;
  bool hideComicVariantResults = false;
  bool compactComicIssues = true;
  String? get selectedId => selectedResultId;

  LibraryAddSelectionState copyWith({
    String? selectedId,
    String? selectedResultId,
    String? selectedProviderCandidateId,
  }) {
    final s = LibraryAddSelectionState();
    s.selectedResultId = selectedId ?? selectedResultId ?? this.selectedResultId;
    s.selectedProviderCandidateId = selectedProviderCandidateId ?? this.selectedProviderCandidateId;
    return s;
  }
}
