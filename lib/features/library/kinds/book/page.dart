import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookLibraryPage extends GenericLibraryPage {
  const BookLibraryPage({
    super.key,
    required super.type,
    required super.topBar,
    required super.accent,
    required super.routeUri,
  }) : super();

  @override
  ConsumerState<GenericLibraryPage> createState() => BookLibraryPageState();
}

class BookLibraryPageState extends GenericLibraryPageState {
}
