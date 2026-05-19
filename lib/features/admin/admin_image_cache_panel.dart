import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminImageCachePanel extends ConsumerStatefulWidget {
  const AdminImageCachePanel({super.key});

  @override
  ConsumerState<AdminImageCachePanel> createState() =>
      _AdminImageCachePanelState();
}

class _AdminImageCachePanelState extends ConsumerState<AdminImageCachePanel> {
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  bool _isPurging = false;
  String? _errorMessage;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final stats = await api.adminImageCacheStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _purge({String? provider}) async {
    setState(() {
      _isPurging = true;
      _statusMessage = null;
      _errorMessage = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final result = await api.adminPurgeImageCache(provider: provider);
      if (!mounted) return;
      final deleted = result['deleted_entries'] ?? 0;
      final freed = result['freed_bytes'] ?? 0;
      setState(() {
        _isPurging = false;
        _statusMessage =
            'Purged $deleted entries, freed ${_formatBytes(freed)}';
      });
      await _loadStats();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPurging = false;
        _errorMessage = e.toString();
      });
    }
  }

  String _formatBytes(dynamic bytes) {
    final b = (bytes is int) ? bytes : int.tryParse('$bytes') ?? 0;
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
    if (b < 1024 * 1024 * 1024) {
      return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(b / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _stats == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null && _stats == null) {
      return Text(_errorMessage!, style: const TextStyle(color: Colors.red));
    }
    final stats = _stats;
    if (stats == null) return const SizedBox.shrink();

    final totalEntries = stats['total_entries'] ?? 0;
    final totalSize = stats['total_size_bytes'] ?? 0;
    final maxSize = stats['max_size_bytes'] ?? 0;
    final usagePct = (stats['usage_percent'] ?? 0.0).toDouble();
    final mirroring = stats['mirroring_enabled'] == true;
    final providers =
        (stats['providers'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_statusMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(_statusMessage!,
                style: const TextStyle(color: Colors.green)),
          ),
          const SizedBox(height: 8),
        ],
        if (_errorMessage != null && _stats != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child:
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 24,
          runSpacing: 8,
          children: [
            _StatChip(
              label: 'Entries',
              value: '$totalEntries',
            ),
            _StatChip(
              label: 'Size',
              value: _formatBytes(totalSize),
            ),
            _StatChip(
              label: 'Budget',
              value: _formatBytes(maxSize),
            ),
            _StatChip(
              label: 'Usage',
              value: '${usagePct.toStringAsFixed(1)}%',
            ),
            _StatChip(
              label: 'Mirroring',
              value: mirroring ? 'Enabled' : 'Disabled',
            ),
          ],
        ),
        if (providers.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Per-provider entries',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: providers.entries
                .map((e) => Chip(label: Text('${e.key}: ${e.value}')))
                .toList(),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _loadStats,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed:
                  _isPurging || totalEntries == 0 ? null : () => _purge(),
              icon: _isPurging
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_sweep_outlined, size: 18),
              label: const Text('Purge all'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}
