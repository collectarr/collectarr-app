import 'tv_domain.dart';

final class TvWorkspaceEntry {
  const TvWorkspaceEntry({
    required this.work,
    required this.release,
    required this.overlay,
  });

  final TvWork work;
  final TvRelease release;
  final TvPersonalOverlay overlay;
}

TvWorkspaceEntry buildTvWorkspaceEntry({
  required TvWork work,
  required TvRelease release,
  required TvPersonalOverlay overlay,
}) {
  return TvWorkspaceEntry(work: work, release: release, overlay: overlay);
}
