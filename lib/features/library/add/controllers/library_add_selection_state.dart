part of '../library_add_dialog.dart';

class LibraryAddSelectionState {
  String? selectedResultId;
  String? selectedProviderCandidateId;
  String? selectedBundleReleaseId;
  String? selectedReferenceEditionId;
  String? selectedReferenceVariantId;
  String? error;
  bool searchedProvider = false;
  bool isSearching = false;
  bool isSearchingProvider = false;
  bool showCoreResults = true;
  bool showProviderResults = true;
  bool showMediaResults = true;
  bool showSeasonResults = true;
  bool showReleaseResults = true;
  bool hideComicOwnedResults = false;
  bool hideComicVariantResults = false;
  bool compactComicIssues = true;
}

