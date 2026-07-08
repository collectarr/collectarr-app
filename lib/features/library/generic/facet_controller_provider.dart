import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryFacetControllerState {
  const LibraryFacetControllerState({
    this.bucketsByFacetId = const {},
    this.loadsInFlight = const {},
  });

  final Map<String, FacetBuckets> bucketsByFacetId;
  final Set<String> loadsInFlight;

  LibraryFacetControllerState copyWith({
    Map<String, FacetBuckets>? bucketsByFacetId,
    Set<String>? loadsInFlight,
  }) {
    return LibraryFacetControllerState(
      bucketsByFacetId: bucketsByFacetId ?? this.bucketsByFacetId,
      loadsInFlight: loadsInFlight ?? this.loadsInFlight,
    );
  }
}

class LibraryFacetControllerNotifier
    extends Notifier<LibraryFacetControllerState> {
  LibraryFacetControllerNotifier(this.kind);

  final String kind;

  @override
  LibraryFacetControllerState build() {
    return const LibraryFacetControllerState();
  }

  void clearAll() {
    state = const LibraryFacetControllerState();
  }

  void startLoad(String loadKey) {
    if (state.loadsInFlight.contains(loadKey)) {
      return;
    }
    final next = Set<String>.from(state.loadsInFlight)..add(loadKey);
    state = state.copyWith(loadsInFlight: next);
  }

  void finishLoad(String loadKey) {
    if (!state.loadsInFlight.contains(loadKey)) {
      return;
    }
    final next = Set<String>.from(state.loadsInFlight)..remove(loadKey);
    state = state.copyWith(loadsInFlight: next);
  }

  void setBuckets(String facetId, FacetBuckets buckets) {
    final next = Map<String, FacetBuckets>.from(state.bucketsByFacetId)
      ..[facetId] = buckets;
    state = state.copyWith(bucketsByFacetId: next);
  }
}

final libraryFacetControllerProvider = NotifierProvider.family<
    LibraryFacetControllerNotifier,
    LibraryFacetControllerState,
    String>(LibraryFacetControllerNotifier.new);
