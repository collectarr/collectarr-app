part of 'media_adapters.dart';

final tvMediaAdapter = plannedMediaAdapter(
  tvLibraryConfig,
  entryAccessors: movieEntryAccessors,
  compareEntriesByColumn: compareMovieEntriesByColumn,
  workspaceCardBuilder: (context, entry, child) => VideoWorkspaceProgressCard(
    entry: entry,
    child: child,
  ),
);
