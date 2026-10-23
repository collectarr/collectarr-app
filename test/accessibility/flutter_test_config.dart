import 'dart:async';
import '../support/accessibility/semantics_recording_binding.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  SemanticsRecordingTestBinding();
  await testMain();
}
