import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoardGameLibraryPage extends GenericLibraryPage {
  const BoardGameLibraryPage({
    super.key,
    required super.type,
    required super.topBar,
    required super.accent,
    required super.routeUri,
    super.switchLayoutSnapshot,
  });

  @override
  ConsumerState<GenericLibraryPage> createState() =>
      BoardGameLibraryPageState();
}

class BoardGameLibraryPageState extends GenericLibraryPageState {}
