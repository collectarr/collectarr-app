import 'dart:async';
import 'package:collectarr_app/features/collection/events/collection_event.dart';

class CollectionEventBus {
  final StreamController<CollectionEvent> _controller =
      StreamController<CollectionEvent>.broadcast();

  Stream<CollectionEvent> get stream => _controller.stream;

  Stream<T> on<T extends CollectionEvent>() {
    return stream.where((event) => event is T).cast<T>();
  }

  void emit(CollectionEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  void dispose() {
    _controller.close();
  }
}
