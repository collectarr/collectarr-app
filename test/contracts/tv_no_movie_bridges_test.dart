import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tv files do not import movie add or edit modules', () async {
    const files = <String>[
      'lib/features/library/kinds/tv/config.dart',
      'lib/features/library/kinds/tv/page.dart',
      'lib/features/library/kinds/tv/add_dialog.dart',
      'lib/features/library/kinds/tv/edit_dialog.dart',
      'lib/features/library/kinds/tv/presentation.dart',
      'lib/features/library/kinds/tv/presentation_builder.dart',
      'lib/features/library/kinds/tv/workspace_entry_builder.dart',
      'lib/features/library/kinds/tv/inspector_sections.dart',
    ];

    const banned = <String>[
      'features/library/kinds/movie/edit_dialog.dart',
      'features/library/kinds/movie/presentation.dart',
      'features/library/kinds/movie/page.dart',
      'features/library/kinds/movie/workspace_entry_builder.dart',
    ];

    for (final path in files) {
      final content = await File(path).readAsString();
      for (final pattern in banned) {
        expect(
          content.contains(pattern),
          isFalse,
          reason: '$path still contains $pattern',
        );
      }
    }
  });
}
