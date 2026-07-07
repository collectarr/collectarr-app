import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicLibraryPage extends GenericLibraryPage {
  const MusicLibraryPage({
    super.key,
    required super.type,
    required super.topBar,
    required super.accent,
    required super.routeUri,
    super.switchLayoutSnapshot,
  }) : super();

  @override
  ConsumerState<GenericLibraryPage> createState() => MusicLibraryPageState();
}

class MusicLibraryPageState extends GenericLibraryPageState {}
