import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:collectarr_app/features/library/kinds/movie/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimeLibraryPage extends GenericLibraryPage {
  const AnimeLibraryPage({
    super.key,
    required super.type,
    required super.topBar,
    required super.accent,
    required super.routeUri,
    super.switchLayoutSnapshot,
  }) : super();

  @override
  ConsumerState<GenericLibraryPage> createState() => AnimeLibraryPageState();
}

class AnimeLibraryPageState extends VideoDrilldownLibraryPageState {}
