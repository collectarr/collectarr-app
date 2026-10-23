import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameHardwareLibraryPage extends GenericLibraryPage {
  const GameHardwareLibraryPage({
    super.key,
    required super.type,
    required super.topBar,
    required super.accent,
    required super.routeUri,
    super.switchLayoutSnapshot,
  });

  @override
  ConsumerState<GenericLibraryPage> createState() =>
      GameHardwareLibraryPageState();
}

class GameHardwareLibraryPageState extends GenericLibraryPageState {}
