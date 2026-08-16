import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:flutter/foundation.dart';

@immutable
class LibraryAddSelectionState {
  const LibraryAddSelectionState({
    this.selectedResultId,
    this.selectedProviderCandidateId,
    this.selectedBundleReleaseId,
    this.selectedReferenceEditionId,
    this.selectedReferenceVariantId,
    this.checkedResultIds = const {},
    this.checkedProviderIds = const {},
    this.referenceType = LibraryAddReferenceType.media,
    this.showCoreResults = true,
    this.showProviderResults = true,
    this.showMediaResults = true,
    this.showSeasonResults = true,
    this.showReleaseResults = true,
    this.hideComicOwnedResults = false,
    this.hideComicVariantResults = false,
    this.compactComicIssues = true,
  });

  final String? selectedResultId;
  final String? selectedProviderCandidateId;
  final String? selectedBundleReleaseId;
  final String? selectedReferenceEditionId;
  final String? selectedReferenceVariantId;
  final Set<String> checkedResultIds;
  final Set<String> checkedProviderIds;
  final LibraryAddReferenceType referenceType;
  final bool showCoreResults;
  final bool showProviderResults;
  final bool showMediaResults;
  final bool showSeasonResults;
  final bool showReleaseResults;
  final bool hideComicOwnedResults;
  final bool hideComicVariantResults;
  final bool compactComicIssues;

  String? get selectedId => selectedResultId;

  LibraryAddSelectionState copyWith({
    String? selectedId,
    String? selectedResultId,
    bool clearSelectedResultId = false,
    String? selectedProviderCandidateId,
    bool clearSelectedProviderCandidateId = false,
    String? selectedBundleReleaseId,
    bool clearSelectedBundleReleaseId = false,
    String? selectedReferenceEditionId,
    bool clearSelectedReferenceEditionId = false,
    String? selectedReferenceVariantId,
    bool clearSelectedReferenceVariantId = false,
    Set<String>? checkedResultIds,
    Set<String>? checkedProviderIds,
    LibraryAddReferenceType? referenceType,
    bool? showCoreResults,
    bool? showProviderResults,
    bool? showMediaResults,
    bool? showSeasonResults,
    bool? showReleaseResults,
    bool? hideComicOwnedResults,
    bool? hideComicVariantResults,
    bool? compactComicIssues,
  }) {
    return LibraryAddSelectionState(
      selectedResultId: clearSelectedResultId
          ? null
          : (selectedId ?? selectedResultId ?? this.selectedResultId),
      selectedProviderCandidateId: clearSelectedProviderCandidateId
          ? null
          : (selectedProviderCandidateId ?? this.selectedProviderCandidateId),
      selectedBundleReleaseId: clearSelectedBundleReleaseId
          ? null
          : (selectedBundleReleaseId ?? this.selectedBundleReleaseId),
      selectedReferenceEditionId: clearSelectedReferenceEditionId
          ? null
          : (selectedReferenceEditionId ?? this.selectedReferenceEditionId),
      selectedReferenceVariantId: clearSelectedReferenceVariantId
          ? null
          : (selectedReferenceVariantId ?? this.selectedReferenceVariantId),
      checkedResultIds: checkedResultIds ?? this.checkedResultIds,
      checkedProviderIds: checkedProviderIds ?? this.checkedProviderIds,
      referenceType: referenceType ?? this.referenceType,
      showCoreResults: showCoreResults ?? this.showCoreResults,
      showProviderResults: showProviderResults ?? this.showProviderResults,
      showMediaResults: showMediaResults ?? this.showMediaResults,
      showSeasonResults: showSeasonResults ?? this.showSeasonResults,
      showReleaseResults: showReleaseResults ?? this.showReleaseResults,
      hideComicOwnedResults:
          hideComicOwnedResults ?? this.hideComicOwnedResults,
      hideComicVariantResults:
          hideComicVariantResults ?? this.hideComicVariantResults,
      compactComicIssues: compactComicIssues ?? this.compactComicIssues,
    );
  }
}
