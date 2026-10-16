import 'package:flutter/widgets.dart';

/// Asks the visible library view to scroll an item into view, as a random
/// pick does.
class LibraryRevealController extends ChangeNotifier {
  String? _itemId;

  /// The item most recently asked for.
  String? get itemId => _itemId;

  void reveal(String itemId) {
    _itemId = itemId;
    notifyListeners();
  }
}

class LibraryRevealScope extends InheritedWidget {
  const LibraryRevealScope(
      {super.key, required this.controller, required super.child});

  final LibraryRevealController controller;

  static LibraryRevealController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<LibraryRevealScope>()
      ?.controller;

  @override
  bool updateShouldNotify(LibraryRevealScope oldWidget) =>
      controller != oldWidget.controller;
}

/// Lets a scrolling view honour reveal requests from [LibraryRevealScope].
///
/// The request is handled after the next frame, so the view has laid out the
/// selection that usually accompanies it.
mixin LibraryRevealListener<T extends StatefulWidget> on State<T> {
  LibraryRevealController? _revealController;

  /// Scrolls [itemId] into view when this view shows it.
  void revealItem(String itemId);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = LibraryRevealScope.maybeOf(context);
    if (controller == _revealController) return;
    _revealController?.removeListener(_handleReveal);
    _revealController = controller?..addListener(_handleReveal);
  }

  void _handleReveal() {
    final itemId = _revealController?.itemId;
    if (itemId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) revealItem(itemId);
    });
  }

  @override
  void dispose() {
    _revealController?.removeListener(_handleReveal);
    super.dispose();
  }
}

/// Scrolls [controller] so that the extent starting at [leading] with length
/// [extent] is visible, centring it when it was outside the viewport.
void revealScrollExtent(
  ScrollController controller, {
  required double leading,
  required double extent,
}) {
  if (!controller.hasClients) return;
  final position = controller.position;
  final viewport = position.viewportDimension;
  if (leading >= position.pixels &&
      leading + extent <= position.pixels + viewport) {
    return;
  }
  controller.jumpTo((leading - (viewport - extent) / 2)
      .clamp(position.minScrollExtent, position.maxScrollExtent));
}
