import 'dart:io';

import 'package:collectarr_app/features/updater/app_installer.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProcess implements Process {
  _FakeProcess();

  @override
  final int pid = 123;

  @override
  Future<int> get exitCode async => 0;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) => true;

  @override
  Stream<List<int>> get stderr => const Stream.empty();

  @override
  IOSink get stdin => throw UnimplementedError();

  @override
  Stream<List<int>> get stdout => const Stream.empty();
}

void main() {
  group('AppInstallers', () {
    test('WindowsAppInstaller waits for PowerShell to start the installer',
        () async {
      String? launchedExecutable;
      List<String>? launchedArgs;

      final installer = WindowsAppInstaller(
        processRunner: (exec, args) async {
          launchedExecutable = exec;
          launchedArgs = args;
          return ProcessResult(123, 0, '', '');
        },
      );

      await installer.install(r"C:\temp\it's\setup.exe");

      expect(launchedExecutable, 'powershell');
      expect(launchedArgs, [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        r"Start-Process -FilePath 'C:\temp\it''s\setup.exe' -ErrorAction Stop",
      ]);
    });

    test('WindowsAppInstaller reports an installer that cannot start',
        () async {
      final installer = WindowsAppInstaller(
        processRunner: (_, __) async => ProcessResult(
            123, 1, '', 'The operation was canceled by the user.'),
      );

      await expectLater(
        installer.install(r'C:\temp\setup.exe'),
        throwsA(isA<ProcessException>().having((e) => e.message, 'message',
            'The operation was canceled by the user.')),
      );
    });

    test('MacAppInstaller launches open detached process', () async {
      String? launchedExecutable;
      List<String>? launchedArgs;
      ProcessStartMode? launchedMode;

      final installer = MacAppInstaller(
        processStarter: (exec, args, {mode = ProcessStartMode.normal}) async {
          launchedExecutable = exec;
          launchedArgs = args;
          launchedMode = mode;
          return _FakeProcess();
        },
      );

      await installer.install('/tmp/update.dmg');

      expect(launchedExecutable, 'open');
      expect(launchedArgs, ['/tmp/update.dmg']);
      expect(launchedMode, ProcessStartMode.detached);
    });

    test('LinuxAppInstaller launches AppImage and makes it executable',
        () async {
      String? launchedExecutable;
      List<String>? launchedArgs;
      ProcessStartMode? launchedMode;
      String? chmodExecutable;
      List<String>? chmodArgs;

      final installer = LinuxAppInstaller(
        processStarter: (exec, args, {mode = ProcessStartMode.normal}) async {
          launchedExecutable = exec;
          launchedArgs = args;
          launchedMode = mode;
          return _FakeProcess();
        },
        processRunner: (exec, args) async {
          chmodExecutable = exec;
          chmodArgs = args;
          return ProcessResult(123, 0, '', '');
        },
      );

      await installer.install('/tmp/update.AppImage');

      expect(chmodExecutable, 'chmod');
      expect(chmodArgs, ['+x', '/tmp/update.AppImage']);
      expect(launchedExecutable, '/tmp/update.AppImage');
      expect(launchedArgs, isEmpty);
      expect(launchedMode, ProcessStartMode.detached);
    });

    test('AndroidAppInstaller launches activity manager intent', () async {
      String? launchedExecutable;
      List<String>? launchedArgs;
      ProcessStartMode? launchedMode;

      final installer = AndroidAppInstaller(
        processStarter: (exec, args, {mode = ProcessStartMode.normal}) async {
          launchedExecutable = exec;
          launchedArgs = args;
          launchedMode = mode;
          return _FakeProcess();
        },
      );

      await installer.install('/sdcard/Download/update.apk');

      expect(launchedExecutable, 'am');
      expect(
        launchedArgs,
        [
          'start',
          '-a',
          'android.intent.action.VIEW',
          '-d',
          'file:///sdcard/Download/update.apk'
        ],
      );
      expect(launchedMode, ProcessStartMode.detached);
    });
  });
}
