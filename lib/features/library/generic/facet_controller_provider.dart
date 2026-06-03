import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryFacetControllerState {
  const LibraryFacetControllerState({
    this.bucketsByMode = const {},
    this.loadsInFlight = const {},
  });

  final Map<LibraryGroupMode, FacetBuckets> bucketsByMode;
  final Set<String> loadsInFlight;

  LibraryFacetControllerState copyWith({
    Map<LibraryGroupMode, FacetBuckets>? bucketsByMode,
    Set<String>? loadsInFlight,
  }) {
    return LibraryFacetControllerState(
      bucketsByMode: bucketsByMode ?? this.bucketsByMode,
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

  void setBuckets(LibraryGroupMode mode, FacetBuckets buckets) {
    final next = Map<LibraryGroupMode, FacetBuckets>.from(state.bucketsByMode)
      ..[mode] = buckets;
    state = state.copyWith(bucketsByMode: next);
  }
}

final libraryFacetControllerProvider = NotifierProvider.family<
    LibraryFacetControllerNotifier,
    LibraryFacetControllerState,
    String>(LibraryFacetControllerNotifier.new);
