import 'package:flutter/material.dart';

class TextControllerGroup {
  final Set<TextEditingController> _controllers = <TextEditingController>{};

  TextEditingController create({String text = ''}) {
    final controller = TextEditingController(text: text);
    _controllers.add(controller);
    return controller;
  }

  void track(TextEditingController controller) {
    _controllers.add(controller);
  }

  void disposeController(TextEditingController? controller) {
    if (controller == null) {
      return;
    }
    _controllers.remove(controller);
    controller.dispose();
  }

  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
  }
}