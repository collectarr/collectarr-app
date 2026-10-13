import 'package:collectarr_app/core/fonts/local_font_controller.dart';
import 'package:collectarr_app/core/fonts/local_font_face.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LocalFontSettingsPanel extends StatefulWidget {
  const LocalFontSettingsPanel({super.key, this.controller});
  final LocalFontController? controller;
  @override
  State<LocalFontSettingsPanel> createState() => _LocalFontSettingsPanelState();
}

class _LocalFontSettingsPanelState extends State<LocalFontSettingsPanel> {
  LocalFontController get controller =>
      widget.controller ?? LocalFontController.instance;
  bool _busy = false;
  String? _message;
  bool _error = false;

  Future<void> _run(Future<String?> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final message = await action();
      if (mounted) {
        setState(() {
          _message = message;
          _error = false;
        });
      }
    } catch (error, stack) {
      if (kDebugMode) debugPrint('Local font operation failed: $error\n$stack');
      if (mounted) {
        setState(() {
          _error = true;
          _message = error is FormatException
              ? error.message.toString()
              : error is StateError
                  ? error.message.toString()
                  : 'Font access failed. Check permission or import local files.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _import() async {
    final files = await openFiles(acceptedTypeGroups: const [
      XTypeGroup(label: 'Font files', extensions: [
        'ttf',
        'otf'
      ], uniformTypeIdentifiers: [
        'public.truetype-font',
        'public.opentype-font'
      ]),
    ]);
    if (files.isEmpty) return null;
    var total = 0;
    final faces = <LocalFontFace>[];
    for (final file in files) {
      total += await file.length();
      if (total > LocalFontController.maxImportedBytes) {
        throw const FormatException(
            'Select font files totalling at most 2 MB.');
      }
      faces.add(
          LocalFontFace.parse(await file.readAsBytes(), source: 'Imported'));
    }
    await controller.importFaces(faces);
    return 'Imported ${faces.length} Gilroy faces on this device.';
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final faces = {
          ...controller.faces,
          if (controller.normalTextFace case final normal?) 400: normal
        };
        final weights = {...faces.keys, 400, 500, 600, 700, 800, 900}.toList()
          ..sort();
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(controller.isGilroyActive
                  ? 'Active font: Gilroy'
                  : 'Active font: Plus Jakarta Sans'),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Use local Gilroy fonts'),
                value: controller.enabled,
                onChanged: _busy
                    ? null
                    : (value) => _run(() async {
                          await controller.setEnabled(value);
                          return null;
                        }),
              ),
              const Text(
                  'Fonts stay on this device. Normal text uses Gilroy Medium when available, matching CLZ. Missing weights use Plus Jakarta Sans.'),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final weight in weights)
                  Tooltip(
                    message:
                        faces[weight]?.name ?? 'No local face for this weight',
                    child: Chip(
                        label: Text(
                            '$weight · ${faces[weight]?.source ?? 'Fallback'}')),
                  ),
              ]),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.font_download_outlined),
                  label: const Text('Use installed Gilroy'),
                  onPressed: _busy || !controller.canDiscover
                      ? null
                      : () => _run(() async {
                            final count = await controller.discoverInstalled();
                            return 'Loaded $count installed Gilroy faces.';
                          }),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Import local fonts'),
                  onPressed: _busy ? null : () => _run(_import),
                ),
                if (controller.hasImported)
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => _run(() async {
                              await controller.removeImported();
                              return 'Imported fonts removed from this device.';
                            }),
                    child: const Text('Remove imported fonts'),
                  ),
              ]),
              if (!controller.canDiscover) ...[
                const SizedBox(height: 8),
                const Text(
                    'Installed font access is unavailable here. Import TTF or OTF files instead.'),
              ],
              if (_busy)
                const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator()),
              if (_message ?? controller.startupError case final message?)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(message,
                        style: TextStyle(
                            color: _error || controller.startupError != null
                                ? Theme.of(context).colorScheme.error
                                : null))),
            ]);
      });
}
