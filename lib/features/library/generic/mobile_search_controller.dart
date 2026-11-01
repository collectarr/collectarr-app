import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connects the mobile header to the library's existing search operations.
class MobileLibrarySearchController extends Notifier<bool> {
  MobileLibrarySearchController(this.kind);
  final String kind;
  late final TextEditingController textController;
  late final FocusNode focusNode;
  Object? _owner;
  ValueChanged<String>? _onChanged;
  ValueChanged<String>? _onSubmitted;
  VoidCallback? _onClear;

  @override
  bool build() {
    textController = TextEditingController();
    focusNode = FocusNode();
    ref.onDispose(focusNode.dispose);
    ref.onDispose(textController.dispose);
    return false;
  }

  void attach(Object owner,
      {required ValueChanged<String> onChanged,
      required ValueChanged<String> onSubmitted,
      required VoidCallback onClear}) {
    _owner = owner;
    _onChanged = onChanged;
    _onSubmitted = onSubmitted;
    _onClear = onClear;
  }

  void detach(Object owner) {
    if (_owner != owner) return;
    _owner = null;
    _onChanged = null;
    _onSubmitted = null;
    _onClear = null;
    Future.microtask(() {
      if (ref.mounted && _owner == null) {
        textController.clear();
        state = false;
      }
    });
  }

  void open() {
    state = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.mounted && state) focusNode.requestFocus();
    });
  }

  void close() {
    focusNode.unfocus();
    clear();
    state = false;
  }

  void change(String value) => _onChanged?.call(value);
  void submit(String value) => _onSubmitted?.call(value);
  void clear() {
    textController.clear();
    _onClear?.call();
  }
}

final mobileLibrarySearchProvider =
    NotifierProvider.family<MobileLibrarySearchController, bool, String>(
        MobileLibrarySearchController.new);
