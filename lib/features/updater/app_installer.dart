import 'dart:io';

abstract class AppInstaller {
  Future<void> install(String filePath);
}

typedef ProcessStarter = Future<Process> Function(
  String executable,
  List<String> arguments, {
  ProcessStartMode mode,
});

class WindowsAppInstaller implements AppInstaller {
  const WindowsAppInstaller({this.processRunner = Process.run});

  final Future<ProcessResult> Function(
      String executable, List<String> arguments) processRunner;

  /// PowerShell started detached exits without running its command, so this
  /// waits for it. Start-Process returns once the installer is running, or
  /// fails when the file cannot start or its elevation prompt is declined.
  @override
  Future<void> install(String filePath) async {
    final quoted = filePath.replaceAll("'", "''");
    final arguments = [
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      "Start-Process -FilePath '$quoted' -ErrorAction Stop",
    ];
    final result = await processRunner('powershell', arguments);
    if (result.exitCode != 0) {
      throw ProcessException(
          'powershell', arguments, '${result.stderr}'.trim(), result.exitCode);
    }
  }
}

class MacAppInstaller implements AppInstaller {
  const MacAppInstaller({this.processStarter = Process.start});

  final ProcessStarter processStarter;

  @override
  Future<void> install(String filePath) async {
    await processStarter(
      'open',
      [filePath],
      mode: ProcessStartMode.detached,
    );
  }
}

class LinuxAppInstaller implements AppInstaller {
  const LinuxAppInstaller({
    this.processStarter = Process.start,
    this.processRunner = Process.run,
  });

  final ProcessStarter processStarter;
  final Future<ProcessResult> Function(
      String executable, List<String> arguments) processRunner;

  @override
  Future<void> install(String filePath) async {
    if (filePath.endsWith('.AppImage')) {
      // Ensure execute permissions
      try {
        await processRunner('chmod', ['+x', filePath]);
      } catch (_) {}
      await processStarter(
        filePath,
        const [],
        mode: ProcessStartMode.detached,
      );
    } else {
      await processStarter(
        'xdg-open',
        [filePath],
        mode: ProcessStartMode.detached,
      );
    }
  }
}

class AndroidAppInstaller implements AppInstaller {
  const AndroidAppInstaller({this.processStarter = Process.start});

  final ProcessStarter processStarter;

  @override
  Future<void> install(String filePath) async {
    // On Android, launching package installer or viewer
    await processStarter(
      'am',
      ['start', '-a', 'android.intent.action.VIEW', '-d', 'file://$filePath'],
      mode: ProcessStartMode.detached,
    );
  }
}

class DefaultAppInstaller implements AppInstaller {
  const DefaultAppInstaller({
    WindowsAppInstaller? windowsInstaller,
    MacAppInstaller? macInstaller,
    LinuxAppInstaller? linuxInstaller,
    AndroidAppInstaller? androidInstaller,
  })  : _windowsInstaller = windowsInstaller ?? const WindowsAppInstaller(),
        _macInstaller = macInstaller ?? const MacAppInstaller(),
        _linuxInstaller = linuxInstaller ?? const LinuxAppInstaller(),
        _androidInstaller = androidInstaller ?? const AndroidAppInstaller();

  final WindowsAppInstaller _windowsInstaller;
  final MacAppInstaller _macInstaller;
  final LinuxAppInstaller _linuxInstaller;
  final AndroidAppInstaller _androidInstaller;

  @override
  Future<void> install(String filePath) async {
    if (Platform.isWindows) {
      return _windowsInstaller.install(filePath);
    }
    if (Platform.isMacOS) {
      return _macInstaller.install(filePath);
    }
    if (Platform.isLinux) {
      return _linuxInstaller.install(filePath);
    }
    if (Platform.isAndroid) {
      return _androidInstaller.install(filePath);
    }
    throw UnsupportedError(
      'Automatic installation is not supported on ${Platform.operatingSystem}',
    );
  }
}
