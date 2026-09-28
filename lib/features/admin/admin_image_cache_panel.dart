import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminImageCachePanel extends ConsumerStatefulWidget {
  const AdminImageCachePanel({super.key});

  @override
  ConsumerState<AdminImageCachePanel> createState() =>
      _AdminImageCachePanelState();
}

class _AdminImageCachePanelState extends ConsumerState<AdminImageCachePanel> {
  AdminImageCacheStats? _stats;
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

  Future<void> _purge() async {
    setState(() {
      _isPurging = true;
      _statusMessage = null;
      _errorMessage = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final result = await api.adminPurgeImageCache();
      if (!mounted) return;
      setState(() {
        _isPurging = false;
        _statusMessage =
            'Purged ${result.deletedEntries} entries, freed ${_formatBytes(result.freedBytes)}';
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

    final totalEntries = stats.totalEntries;
    final totalSize = stats.totalSizeBytes;
    final maxSize = stats.maxSizeBytes;
    final usagePct = stats.usagePercent;
    final cacheEnabled = stats.cacheEnabled;

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
              label: 'Cache',
              value: cacheEnabled ? 'Enabled' : 'Disabled',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _loadStats,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
            ),
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
            style: TextStyle(
                fontSize: 12, color: appPalette(context).textSecondary)),
      ],
    );
  }
}
