import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production modal panels use silent app routes', () {
    final materialModal = RegExp(
        r'\b(showDialog|showGeneralDialog|showModalBottomSheet)\s*(<[^>]+>)?\s*\(');
    final violations = <String>[];
    for (final file
        in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      if (materialModal.hasMatch(file.readAsStringSync())) {
        violations.add(file.path);
      }
    }
    expect(violations, isEmpty,
        reason:
            'Use showAppDialog/showAppBottomSheet so outside clicks stay silent and do not dismiss panels.');
  });
}
