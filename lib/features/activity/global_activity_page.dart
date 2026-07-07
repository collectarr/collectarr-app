import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/features/activity/global_activity_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _fmtDate(DateTime dt) {
  final l = dt.toLocal();
  return '${_months[l.month - 1]} ${l.day}, ${l.year}';
}

String _fmtTime(DateTime dt) {
  final l = dt.toLocal();
  return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
}

enum _ActivityRange {
  week(7, 'Last 7 days'),
  month(30, 'Last 30 days'),
  quarter(90, 'Last 90 days'),
  all(null, 'All time');

  const _ActivityRange(this.days, this.label);
  final int? days;
  final String label;
}

/// Collection-wide activity timeline with kind / event-type / date filters.
class GlobalActivityPage extends ConsumerStatefulWidget {
  const GlobalActivityPage({super.key});

  @override
  ConsumerState<GlobalActivityPage> createState() => _GlobalActivityPageState();
}

class _GlobalActivityPageState extends ConsumerState<GlobalActivityPage> {
  final Set<String> _mediaTypes = <String>{};
  final Set<ActivityEventKind> _eventKinds = <ActivityEventKind>{};
  _ActivityRange _range = _ActivityRange.all;

  bool _matches(GlobalActivityEntry entry) {
    if (_mediaTypes.isNotEmpty && !_mediaTypes.contains(entry.mediaType)) {
      return false;
    }
    if (_eventKinds.isNotEmpty && !_eventKinds.contains(entry.event.kind)) {
      return false;
    }
    if (_range.days != null) {
      final cutoff = DateTime.now().subtract(Duration(days: _range.days!));
      if (entry.event.timestamp.isBefore(cutoff)) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final asyncEntries = ref.watch(globalActivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
      ),
      body: asyncEntries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load activity: $error',
              style: TextStyle(color: palette.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (entries) {
          final availableTypes = <String>{
            for (final e in entries)
              if (e.mediaType.isNotEmpty) e.mediaType,
          }.toList()
            ..sort();
          final availableKinds = <ActivityEventKind>{
            for (final e in entries) e.event.kind,
          }.toList()
            ..sort((a, b) => a.index.compareTo(b.index));
          final filtered =
              entries.where(_matches).toList(growable: false);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FilterBar(
                mediaTypes: availableTypes,
                eventKinds: availableKinds,
                selectedTypes: _mediaTypes,
                selectedKinds: _eventKinds,
                range: _range,
                onToggleType: (type) => setState(() {
                  _mediaTypes.contains(type)
                      ? _mediaTypes.remove(type)
                      : _mediaTypes.add(type);
                }),
                onToggleKind: (kind) => setState(() {
                  _eventKinds.contains(kind)
                      ? _eventKinds.remove(kind)
                      : _eventKinds.add(kind);
                }),
                onRangeChanged: (range) => setState(() => _range = range),
                onClear: (_mediaTypes.isEmpty &&
                        _eventKinds.isEmpty &&
                        _range == _ActivityRange.all)
                    ? null
                    : () => setState(() {
                          _mediaTypes.clear();
                          _eventKinds.clear();
                          _range = _ActivityRange.all;
                        }),
              ),
              const Divider(height: 1),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          entries.isEmpty
                              ? 'No activity recorded yet.'
                              : 'No activity matches the current filters.',
                          style: TextStyle(color: palette.textMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _GlobalActivityTile(
                          entry: filtered[index],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.mediaTypes,
    required this.eventKinds,
    required this.selectedTypes,
    required this.selectedKinds,
    required this.range,
    required this.onToggleType,
    required this.onToggleKind,
    required this.onRangeChanged,
    required this.onClear,
  });

  final List<String> mediaTypes;
  final List<ActivityEventKind> eventKinds;
  final Set<String> selectedTypes;
  final Set<ActivityEventKind> selectedKinds;
  final _ActivityRange range;
  final ValueChanged<String> onToggleType;
  final ValueChanged<ActivityEventKind> onToggleKind;
  final ValueChanged<_ActivityRange> onRangeChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<_ActivityRange>(
                  initialValue: range,
                  decoration: const InputDecoration(
                    labelText: 'Date range',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final r in _ActivityRange.values)
                      DropdownMenuItem(value: r, child: Text(r.label)),
                  ],
                  onChanged: (value) {
                    if (value != null) onRangeChanged(value);
                  },
                ),
              ),
              if (onClear != null) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                ),
              ],
            ],
          ),
          if (mediaTypes.length > 1) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final type in mediaTypes)
                  FilterChip(
                    label: Text(type),
                    selected: selectedTypes.contains(type),
                    onSelected: (_) => onToggleType(type),
                  ),
              ],
            ),
          ],
          if (eventKinds.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final kind in eventKinds)
                  FilterChip(
                    avatar: Icon(_iconFor(kind), size: 16),
                    label: Text(_labelFor(kind)),
                    selected: selectedKinds.contains(kind),
                    onSelected: (_) => onToggleKind(kind),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

IconData _iconFor(ActivityEventKind kind) => ActivityEvent(
      kind: kind,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
    ).icon;

String _labelFor(ActivityEventKind kind) => ActivityEvent(
      kind: kind,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
    ).label;

class _GlobalActivityTile extends StatelessWidget {
  const _GlobalActivityTile({required this.entry});

  final GlobalActivityEntry entry;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = Theme.of(context).colorScheme.primary;
    final event = entry.event;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.14),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Icon(event.icon, size: 16, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${event.label} · ${_fmtDate(event.timestamp)} · ${_fmtTime(event.timestamp)}',
                  style: TextStyle(color: palette.textMuted, fontSize: 12),
                ),
                if (event.detail != null)
                  Text(
                    event.detail!,
                    style: TextStyle(
                      color: accent.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                if (event.secondaryDetail != null)
                  Text(
                    event.secondaryDetail!,
                    style: TextStyle(color: palette.textMuted, fontSize: 11),
                  ),
              ],
            ),
          ),
          if (entry.mediaType.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                entry.mediaType,
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
