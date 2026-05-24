import 'package:collectarr_app/core/models/admin_metadata.dart';
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
  AdminImageCacheStats? _stats;
  bool _isLoading = false;
  bool _isPurging = false;
  String? _purgingProvider;
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
      _purgingProvider = provider;
      _statusMessage = null;
      _errorMessage = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final result = await api.adminPurgeImageCache(provider: provider);
      if (!mounted) return;
      setState(() {
        _isPurging = false;
        _purgingProvider = null;
        _statusMessage = provider == null || provider.isEmpty
            ? 'Purged ${result.deletedEntries} entries, freed ${_formatBytes(result.freedBytes)}'
            : 'Purged ${result.deletedEntries} $provider entries, freed ${_formatBytes(result.freedBytes)}';
      });
      await _loadStats();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPurging = false;
        _purgingProvider = null;
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
    final mirroring = stats.mirroringEnabled;
    final providers = stats.providers.entries.toList(growable: false)
      ..sort((left, right) => right.value.compareTo(left.value));

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
          const Text(
            'Per-provider purge',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: providers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final provider = providers[index];
              final share = totalEntries == 0
                  ? 0
                  : ((provider.value / totalEntries) * 100).round();
              final isPurgingProvider = _purgingProvider == provider.key;
              return DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.key,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Chip(label: Text('${provider.value} entries')),
                                Chip(label: Text('$share% of cache')),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _isPurging || provider.value == 0
                            ? null
                            : () => _purge(provider: provider.key),
                        icon: isPurgingProvider
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.delete_outline, size: 18),
                        label: Text('Purge ${provider.key}'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
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
              icon: _purgingProvider == null && _isPurging
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
