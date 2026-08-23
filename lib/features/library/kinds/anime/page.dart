import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:collectarr_app/features/library/kinds/video/video_drilldown_library_page_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimeLibraryPage extends GenericLibraryPage {
  const AnimeLibraryPage({
    super.key,
    required super.type,
    required super.topBar,
    required super.accent,
    required super.routeUri,
    super.switchLayoutSnapshot,
  });

  @override
  ConsumerState<GenericLibraryPage> createState() => AnimeLibraryPageState();
}

class AnimeLibraryPageState extends VideoDrilldownLibraryPageState {}
