import 'package:collectarr_app/core/logging/app_log.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-featured log viewer shown inside the Settings → Logs tab.
class AppLogViewerPanel extends ConsumerStatefulWidget {
  const AppLogViewerPanel({super.key});

  @override
  ConsumerState<AppLogViewerPanel> createState() => _AppLogViewerPanelState();
}

class _AppLogViewerPanelState extends ConsumerState<AppLogViewerPanel> {
  AppLogLevel? _levelFilter;
  String? _sourceFilter;
  String? _expandedId;

  @override
  Widget build(BuildContext context) {
    final allEntries = ref.watch(appLogProvider);
    final sources = {for (final e in allEntries) e.source};
    final filtered = allEntries.where((e) {
      if (_levelFilter != null && e.level != _levelFilter) return false;
      if (_sourceFilter != null && e.source != _sourceFilter) return false;
      return true;
    }).toList();
    // Show newest first.
    final entries = filtered.reversed.toList();
    final filterControls = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<AppLogLevel?>(
          segments: const [
            ButtonSegment(value: null, label: Text('All')),
            ButtonSegment(
              value: AppLogLevel.error,
              icon: Icon(Icons.error_outline, size: 16),
              label: Text('Errors'),
            ),
            ButtonSegment(
              value: AppLogLevel.warning,
              icon: Icon(Icons.warning_amber, size: 16),
              label: Text('Warn'),
            ),
            ButtonSegment(
              value: AppLogLevel.info,
              icon: Icon(Icons.info_outline, size: 16),
              label: Text('Info'),
            ),
          ],
          selected: {_levelFilter},
          onSelectionChanged: (value) =>
              setState(() => _levelFilter = value.first),
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            textStyle: WidgetStatePropertyAll(
              Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
        if (sources.length > 1)
          DropdownButton<String?>(
            value: _sourceFilter,
            underline: const SizedBox.shrink(),
            isDense: true,
            dropdownColor: kAppPanelRaised,
            borderRadius: kAppMenuBorderRadius,
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All sources', style: TextStyle(fontSize: 12)),
              ),
              for (final source in sources.toList()..sort())
                DropdownMenuItem(
                  value: source,
                  child: Text(source, style: const TextStyle(fontSize: 12)),
                ),
            ],
            onChanged: (value) => setState(() => _sourceFilter = value),
          ),
      ],
    );
    final actionControls = Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            '${entries.length} entries',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kAppTextMuted,
                ),
          ),
        ),
        IconButton(
          tooltip: 'Copy all to clipboard',
          icon: const Icon(Icons.copy_outlined, size: 18),
          onPressed: entries.isEmpty
              ? null
              : () {
                  final buffer = StringBuffer();
                  for (final e in entries) {
                    buffer.writeln(
                      '[${_levelLabel(e.level)}] ${_formatTime(e.timestamp)} '
                      '[${e.source}] ${e.message}',
                    );
                    if (e.detail != null) {
                      buffer.writeln(e.detail);
                    }
                  }
                  Clipboard.setData(ClipboardData(text: buffer.toString()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Log copied')),
                  );
                },
        ),
        IconButton(
          tooltip: 'Clear log',
          icon: const Icon(Icons.delete_outline, size: 18),
          onPressed: entries.isEmpty
              ? null
              : () => ref.read(appLogProvider.notifier).clear(),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Toolbar ───────────────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 920;
            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  filterControls,
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: actionControls,
                  ),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: filterControls),
                const SizedBox(width: 8),
                actionControls,
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        // ── Entry list ────────────────────────────────────────
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                allEntries.isEmpty
                    ? 'No log entries yet'
                    : 'No entries match the current filter',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: kAppTextMuted,
                    ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final e = entries[index];
              final id = '${e.timestamp.microsecondsSinceEpoch}_$index';
              final isExpanded = _expandedId == id;
              return InkWell(
                onTap: e.detail != null
                    ? () => setState(() =>
                        _expandedId = isExpanded ? null : id)
                    : null,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _levelIcon(e.level),
                          const SizedBox(width: 6),
                          Text(
                            _formatTime(e.timestamp),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: kAppTextMuted),
                          ),
                          const SizedBox(width: 8),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: kAppPanelRaised,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              child: Text(
                                e.source,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: kAppTextMuted,
                                ),
                              ),
                            ),
                          ),
                          if (e.detail != null) ...[
                            const Spacer(),
                            Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 16,
                              color: kAppTextMuted,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        e.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: _levelColor(e.level),
                        ),
                      ),
                      if (isExpanded && e.detail != null) ...[
                        const SizedBox(height: 6),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: kAppField,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: SelectableText(
                              e.detail!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: kAppTextMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  static Widget _levelIcon(AppLogLevel level) {
    return switch (level) {
      AppLogLevel.error => Icon(
          Icons.error_outline,
          size: 15,
          color: Colors.red.shade300,
        ),
      AppLogLevel.warning => Icon(
          Icons.warning_amber,
          size: 15,
          color: Colors.orange.shade300,
        ),
      AppLogLevel.info => Icon(
          Icons.info_outline,
          size: 15,
          color: Colors.green.shade300,
        ),
    };
  }

  static Color _levelColor(AppLogLevel level) {
    return switch (level) {
      AppLogLevel.error => Colors.red.shade300,
      AppLogLevel.warning => Colors.orange.shade300,
      AppLogLevel.info => Colors.white70,
    };
  }

  static String _levelLabel(AppLogLevel level) {
    return switch (level) {
      AppLogLevel.error => 'ERROR',
      AppLogLevel.warning => 'WARN',
      AppLogLevel.info => 'INFO',
    };
  }

  static String _formatTime(DateTime t) {
    final local = t.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}';
  }
}
