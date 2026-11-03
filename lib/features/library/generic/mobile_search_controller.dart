import 'toolbar_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connects the mobile header to the library's existing search operations.
class MobileLibrarySearchController extends Notifier<bool> {
  MobileLibrarySearchController(this.kind);
  final String kind;
  late final TextEditingController textController;
  late final FocusNode focusNode;
  final selectionAvailable = ValueNotifier<bool>(false);
  Object? _owner;
  ValueChanged<String>? _onChanged;
  ValueChanged<String>? _onSubmitted;
  VoidCallback? _onClear;
  Future<void> Function()? _onScan;
  VoidCallback? _onToggleSelection;
  ValueChanged<LibraryCollectionStatusScope>? _onStatus;
  LibraryCollectionStatusScope Function()? _readStatus;

  @override
  bool build() {
    textController = TextEditingController();
    focusNode = FocusNode();
    ref.onDispose(focusNode.dispose);
    ref.onDispose(selectionAvailable.dispose);
    ref.onDispose(textController.dispose);
    return false;
  }

  void attach(Object owner,
      {required ValueChanged<String> onChanged,
      required ValueChanged<String> onSubmitted,
      required VoidCallback onClear,
      Future<void> Function()? onScan,
      VoidCallback? onToggleSelection,
      ValueChanged<LibraryCollectionStatusScope>? onStatus,
      LibraryCollectionStatusScope Function()? readStatus}) {
    _owner = owner;
    _onChanged = onChanged;
    _onSubmitted = onSubmitted;
    _onClear = onClear;
    _onScan = onScan;
    _onToggleSelection = onToggleSelection;
    _onStatus = onStatus;
    _readStatus = readStatus;
  }

  void detach(Object owner) {
    if (_owner != owner) return;
    _owner = null;
    _onChanged = null;
    _onSubmitted = null;
    _onClear = null;
    _onScan = null;
    _onToggleSelection = null;
    _onStatus = null;
    _readStatus = null;
    Future.microtask(() {
      if (ref.mounted && _owner == null) {
        selectionAvailable.value = false;
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

  Future<void> scan() async {
    focusNode.unfocus();
    await _onScan?.call();
  }

  void toggleSelection() => _onToggleSelection?.call();
  void setStatus(LibraryCollectionStatusScope status) =>
      _onStatus?.call(status);
  LibraryCollectionStatusScope get status =>
      _readStatus?.call() ?? kDefaultCollectionStatusScope;

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
