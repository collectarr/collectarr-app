import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';

enum MobileAddMethod { cover, barcode, search }

typedef MobileAddChoice = ({MobileAddMethod method, bool remember});

Future<MobileAddChoice?> showMobileAddMethodPicker(BuildContext context,
        {required String pluralLabel,
        required Color headerColor,
        String? description,
        required bool canScanCover,
        required String searchLabel}) =>
    showAppDialog<MobileAddChoice>(
        context: context,
        barrierDismissible: true,
        builder: (_) => _MobileAddMethodPicker(
            pluralLabel: pluralLabel,
            headerColor: headerColor,
            description: description,
            canScanCover: canScanCover,
            searchLabel: searchLabel));

class _MobileAddMethodPicker extends StatefulWidget {
  const _MobileAddMethodPicker(
      {required this.pluralLabel,
      required this.headerColor,
      this.description,
      required this.canScanCover,
      required this.searchLabel});
  final String pluralLabel;
  final Color headerColor;
  final String? description;
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
        secondaryText:
            widget.searchLabel.toLowerCase().replaceAll('search by ', ''),
      ),
    ];

    return Center(
      child: Dialog(
        key: const Key('add.method-picker'),
        alignment: Alignment.center,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        backgroundColor: palette.panelRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 380,
            maxHeight: MediaQuery.sizeOf(context).height - 32,
          ),
          child: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                color: widget.headerColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Add ${widget.pluralLabel} from CLR Core',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.description ??
                          'Add $plural by searching CLR Core, our central online catalog.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.textMuted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'How do you want to add $plural?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 240 ||
                          MediaQuery.textScalerOf(context).scale(1) > 1.4;
                      if (stacked) {
                        return Column(children: [
                          for (var i = 0; i < choices.length; i++) ...[
                            if (i > 0) const SizedBox(height: 8),
                            SizedBox(
                                width: double.infinity,
                                child: _cardChoice(choices[i])),
                          ],
                        ]);
                      }
                      return Row(children: [
                        for (var i = 0; i < choices.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(child: _cardChoice(choices[i])),
                        ],
                      ]);
                    }),
                    const SizedBox(height: 8),
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
            ],
          )),
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
    final bg = palette.utilityAction;

    return Semantics(
      button: true,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          key: ValueKey('add.method.${choice.method.name}'),
          borderRadius: BorderRadius.circular(7),
          onTap: () => Navigator.of(context).pop<MobileAddChoice>(
            (method: choice.method, remember: _remember),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  choice.icon,
                  size: 38,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  choice.primaryText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
                Text(
                  choice.secondaryText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
