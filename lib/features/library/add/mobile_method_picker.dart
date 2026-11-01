import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';

enum MobileAddMethod { cover, barcode, search }

typedef MobileAddChoice = ({MobileAddMethod method, bool remember});

Future<MobileAddChoice?> showMobileAddMethodPicker(BuildContext context,
        {required String pluralLabel,
        required bool canScanCover,
        required String searchLabel}) =>
    showAppDialog<MobileAddChoice>(
        context: context,
        barrierDismissible: true,
        builder: (_) => _MobileAddMethodPicker(
            pluralLabel: pluralLabel,
            canScanCover: canScanCover,
            searchLabel: searchLabel));

class _MobileAddMethodPicker extends StatefulWidget {
  const _MobileAddMethodPicker(
      {required this.pluralLabel,
      required this.canScanCover,
      required this.searchLabel});
  final String pluralLabel;
  final bool canScanCover;
  final String searchLabel;
  @override
  State<_MobileAddMethodPicker> createState() => _MobileAddMethodPickerState();
}

class _MobileAddMethodPickerState extends State<_MobileAddMethodPicker> {
  bool _remember = false;
  @override
  Widget build(BuildContext context) => AlertDialog(
        key: const Key('add.method-picker'),
        title: Text('Add ${widget.pluralLabel} from Core'),
        content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              const Text('Find items in Core using one of these methods:'),
              const SizedBox(height: 16),
              if (widget.canScanCover)
                _choice(
                    MobileAddMethod.cover, Icons.camera_alt, 'Scan the cover'),
              _choice(MobileAddMethod.barcode, Icons.qr_code_scanner,
                  'Scan or enter a barcode'),
              _choice(MobileAddMethod.search, Icons.search, widget.searchLabel),
              CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Don't show this again"),
                  value: _remember,
                  onChanged: (value) =>
                      setState(() => _remember = value ?? false)),
            ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'))
        ],
      );
  Widget _choice(MobileAddMethod method, IconData icon, String label) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FilledButton.icon(
            key: ValueKey('add.method.${method.name}'),
            style: FilledButton.styleFrom(
                backgroundColor: appPalette(context).utilityAction,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54)),
            onPressed: () => Navigator.of(context)
                .pop<MobileAddChoice>((method: method, remember: _remember)),
            icon: Icon(icon),
            label: Text(label)),
      );
}
