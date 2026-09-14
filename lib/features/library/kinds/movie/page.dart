import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:collectarr_app/features/library/generic/kind_drilldown_library_page_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovieLibraryPage extends GenericLibraryPage {
  const MovieLibraryPage({
    super.key,
    required super.type,
    required super.topBar,
    required super.accent,
    required super.routeUri,
    super.switchLayoutSnapshot,
  });

  @override
  ConsumerState<GenericLibraryPage> createState() => MovieLibraryPageState();
}

class MovieLibraryPageState extends KindDrilldownLibraryPageState {}
