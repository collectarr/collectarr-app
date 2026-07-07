import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaLibraryPage extends GenericLibraryPage {
  const MangaLibraryPage({
    super.key,
    required super.type,
    required super.topBar,
    required super.accent,
    required super.routeUri,
    super.switchLayoutSnapshot,
  }) : super();

  @override
  ConsumerState<GenericLibraryPage> createState() => MangaLibraryPageState();
}

class MangaLibraryPageState extends GenericLibraryPageState {}
