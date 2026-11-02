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
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final plural = widget.pluralLabel.toLowerCase();
    final choices = [
      if (widget.canScanCover)
        (
          method: MobileAddMethod.cover,
          icon: Icons.camera_alt_outlined,
          primaryText: 'by scanning',
          secondaryText: 'the cover',
        ),
      (
        method: MobileAddMethod.barcode,
        icon: Icons.qr_code_scanner,
        primaryText: 'by scanning',
        secondaryText: 'the barcode',
      ),
      (
        method: MobileAddMethod.search,
        icon: Icons.search,
        primaryText: 'by typing',
        secondaryText: plural == 'comics'
            ? 'series / issue'
            : widget.searchLabel.toLowerCase().replaceAll('search by ', ''),
      ),
    ];

    return AlertDialog(
      key: const Key('add.method-picker'),
      title: Text(
        'Add ${widget.pluralLabel} from Core',
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Adding $plural to the app is done by adding them from "Core", our central online ${plural.endsWith('s') ? plural.substring(0, plural.length - 1) : plural} database.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: palette.textMuted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'How do you want to add $plural?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (var i = 0; i < choices.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: _cardChoice(choices[i])),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                title: const Text(
                  "Don't show this again",
                  style: TextStyle(fontSize: 13),
                ),
                value: _remember,
                onChanged: (value) =>
                    setState(() => _remember = value ?? false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardChoice(
    ({
      MobileAddMethod method,
      IconData icon,
      String primaryText,
      String secondaryText,
    }) choice,
  ) {
    final palette = appPalette(context);
    final bg =
        palette.isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF2F6F9);
    final borderColor = palette.divider.withValues(alpha: 0.6);

    return Semantics(
      button: true,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          key: ValueKey('add.method.${choice.method.name}'),
          borderRadius: BorderRadius.circular(8),
          onTap: () => Navigator.of(context).pop<MobileAddChoice>(
            (method: choice.method, remember: _remember),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  choice.icon,
                  size: 34,
                  color: palette.utilityAction,
                ),
                const SizedBox(height: 8),
                Text(
                  choice.primaryText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: palette.textMuted,
                  ),
                ),
                Text(
                  choice.secondaryText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
