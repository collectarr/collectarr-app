import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameToyLibraryPage extends GenericLibraryPage {
  const GameToyLibraryPage({
    super.key,
    required super.type,
    required super.topBar,
    required super.accent,
    required super.routeUri,
    super.switchLayoutSnapshot,
  });

  @override
  ConsumerState<GenericLibraryPage> createState() => GameToyLibraryPageState();
}

class GameToyLibraryPageState extends GenericLibraryPageState {}
