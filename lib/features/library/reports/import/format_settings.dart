import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum ImportFieldDelimiter {
  semicolon('Semicolon', ';'),
  comma('Comma', ','),
  tab('Tab', '\t'),
  space('Space', ' ');

  const ImportFieldDelimiter(this.label, this.char);
  final String label;
  final String char;
}

enum ImportFieldEnclosure {
  doubleQuote('Double Quote', '"'),
  singleQuote('Single Quote', "'"),
  none('None', '');

  const ImportFieldEnclosure(this.label, this.char);
  final String label;
  final String char;
}

enum ImportMultiFieldDelimiter {
  semicolon('Semicolon', ';'),
  comma('Comma', ','),
  tab('Tab', '\t'),
  space('Space', ' ');

  const ImportMultiFieldDelimiter(this.label, this.char);
  final String label;
  final String char;
}

class ImportFormatSettings extends StatelessWidget {
  const ImportFormatSettings(
      {super.key,
      required this.skipFirstRow,
      required this.delimiter,
      required this.enclosure,
      required this.multiDelimiter,
      required this.onSkipFirstRowChanged,
      required this.onDelimiterChanged,
      required this.onEnclosureChanged,
      required this.onMultiDelimiterChanged});
  final bool skipFirstRow;
  final ImportFieldDelimiter delimiter;
  final ImportFieldEnclosure enclosure;
  final ImportMultiFieldDelimiter multiDelimiter;
  final ValueChanged<bool> onSkipFirstRowChanged;
  final ValueChanged<ImportFieldDelimiter> onDelimiterChanged;
  final ValueChanged<ImportFieldEnclosure> onEnclosureChanged;
  final ValueChanged<ImportMultiFieldDelimiter> onMultiDelimiterChanged;
  @override
  Widget build(BuildContext context) =>
      _buildFormatSettingsSection(context, appPalette(context));
  Widget _buildFormatSettingsSection(
      BuildContext context, AppThemePalette palette) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 720
            ? (constraints.maxWidth - 60) / 4
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: constraints.maxWidth >= 720 ? 20 : 12,
          runSpacing: 12,
          children: [
            // Header
            SizedBox(
              width: cardWidth,
              child: _buildSettingsCard(
                context: context,
                palette: palette,
                title: 'Header',
                tooltip:
                    'Select whether to skip the first row of column headers',
                child: InkWell(
                  onTap: () {
                    onSkipFirstRowChanged(!skipFirstRow);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            key: const Key('import_format.skip_header'),
                            value: skipFirstRow,
                            activeColor: palette.utilityAction,
                            checkColor: Colors.white,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            onChanged: (val) {
                              onSkipFirstRowChanged(val ?? true);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Skip First Row',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: palette.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Field Delimiter
            SizedBox(
              width: cardWidth,
              child: _buildSettingsCard(
                context: context,
                palette: palette,
                title: 'Field Delimiter',
                tooltip: 'Character separating individual fields/columns',
                child: Column(
                  children: [
                    for (final d in ImportFieldDelimiter.values)
                      _buildDelimiterRadio(
                        context: context,
                        palette: palette,
                        label: d.label,
                        badge: d.char == '\t'
                            ? null
                            : (d.char == ' ' ? null : d.char),
                        selected: delimiter == d,
                        onTap: () {
                          onDelimiterChanged(d);
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Field Enclosure
            SizedBox(
              width: cardWidth,
              child: _buildSettingsCard(
                context: context,
                palette: palette,
                title: 'Field Enclosure',
                tooltip: 'Character quoting text fields',
                child: Column(
                  children: [
                    for (final e in ImportFieldEnclosure.values)
                      _buildDelimiterRadio(
                        context: context,
                        palette: palette,
                        label: e.label,
                        badge: e.char.isEmpty ? null : e.char,
                        selected: enclosure == e,
                        onTap: () {
                          onEnclosureChanged(e);
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Multi-Field Delimiter
            SizedBox(
              width: cardWidth,
              child: _buildSettingsCard(
                context: context,
                palette: palette,
                title: 'Multi-Field Delimiter',
                tooltip:
                    'Character separating values inside multi-value fields',
                child: Column(
                  children: [
                    for (final m in ImportMultiFieldDelimiter.values)
                      _buildDelimiterRadio(
                        context: context,
                        palette: palette,
                        label: m.label,
                        badge: m.char == '\t'
                            ? null
                            : (m.char == ' ' ? null : m.char),
                        selected: multiDelimiter == m,
                        onTap: () {
                          onMultiDelimiterChanged(m);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required AppThemePalette palette,
    required String title,
    required String tooltip,
    required Widget child,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 148),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: palette.isDark
                ? appManagementCanvasColor(context)
                : palette.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Tooltip(
                message: tooltip,
                child: Icon(
                  Icons.help,
                  size: 16,
                  color: palette.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildDelimiterRadio({
    required BuildContext context,
    required AppThemePalette palette,
    required String label,
    required String? badge,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: selected ? palette.utilityAction : palette.textMuted,
            ),
            const SizedBox(width: 8),
            Flexible(
                child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            )),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFC9302C),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
