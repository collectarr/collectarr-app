import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:collectarr_app/features/library/kinds/movie/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TvLibraryPage extends GenericLibraryPage {
  const TvLibraryPage({
    super.key,
    required super.type,
    required super.topBar,
    required super.accent,
    required super.routeUri,
  }) : super(
        );

  @override
  ConsumerState<GenericLibraryPage> createState() => TvLibraryPageState();
}

class TvLibraryPageState extends VideoDrilldownLibraryPageState {}