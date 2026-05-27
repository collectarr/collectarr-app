import 'dart:async';

import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/features/library/bundles/bundle_release_contents_section.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemBundleReleaseBrowserSection extends ConsumerStatefulWidget {
  const ItemBundleReleaseBrowserSection({
    super.key,
    required this.itemId,
    required this.accent,
    this.title = 'Collected editions',
  });

  final String itemId;
  final Color accent;
  final String title;

  @override
  ConsumerState<ItemBundleReleaseBrowserSection> createState() =>
      _ItemBundleReleaseBrowserSectionState();
}

class _ItemBundleReleaseBrowserSectionState
    extends ConsumerState<ItemBundleReleaseBrowserSection> {
  List<BundleReleaseSummary>? _summaries;
  Object? _summariesError;
  bool _summariesLoading = false;
  String? _selectedBundleReleaseId;
  final Map<String, BundleReleaseDetail> _detailsById =
      <String, BundleReleaseDetail>{};
  final Set<String> _loadingDetails = <String>{};
  final Map<String, Object> _detailErrors = <String, Object>{};

  @override
  void didUpdateWidget(covariant ItemBundleReleaseBrowserSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemId != widget.itemId) {
      _summaries = null;
      _summariesError = null;
      _summariesLoading = false;
      _selectedBundleReleaseId = null;
      _detailsById.clear();
      _loadingDetails.clear();
      _detailErrors.clear();
    }
  }

  static final _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  Future<void> _ensureSummariesLoaded() async {
    if (_summaries != null || _summariesLoading) {
      return;
    }
    if (!_uuidPattern.hasMatch(widget.itemId)) {
      setState(() {
        _summaries = const <BundleReleaseSummary>[];
        _summariesLoading = false;
      });
      return;
    }
    setState(() {
      _summariesLoading = true;
      _summariesError = null;
    });
    try {
      final summaries = await ref.read(apiClientProvider).getItemBundleReleases(
            widget.itemId,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _summaries = summaries;
        _summariesLoading = false;
        _selectedBundleReleaseId = summaries.isEmpty ? null : summaries.first.id;
      });
      if (summaries.isNotEmpty) {
        unawaited(_ensureDetailLoaded(summaries.first.id));
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _summariesError = error;
        _summariesLoading = false;
      });
    }
  }

  Future<void> _ensureDetailLoaded(String bundleReleaseId) async {
    if (_detailsById.containsKey(bundleReleaseId) ||
        _loadingDetails.contains(bundleReleaseId)) {
      return;
    }
    setState(() {
      _loadingDetails.add(bundleReleaseId);
      _detailErrors.remove(bundleReleaseId);
    });
    try {
      final detail = await ref.read(apiClientProvider).getBundleRelease(
            bundleReleaseId,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _detailsById[bundleReleaseId] = detail;
        _loadingDetails.remove(bundleReleaseId);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _detailErrors[bundleReleaseId] = error;
        _loadingDetails.remove(bundleReleaseId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = _selectedBundleReleaseId;
    final selectedDetail = selectedId == null ? null : _detailsById[selectedId];
    final selectedDetailError =
        selectedId == null ? null : _detailErrors[selectedId];
    final detailLoading =
        selectedId != null && _loadingDetails.contains(selectedId);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: appPalette(context).surfaceSubtle,
        border: Border.all(color: widget.accent.withValues(alpha: 0.33)),
      ),
      child: Material(
        color: Colors.transparent,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            iconColor: widget.accent,
            collapsedIconColor: widget.accent,
            textColor: widget.accent,
            collapsedTextColor: widget.accent,
            onExpansionChanged: (expanded) {
              if (expanded) {
                unawaited(_ensureSummariesLoaded());
              }
            },
            title: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: widget.accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
            ),
            subtitle: Text(
              _summaryLabel(),
              style: const TextStyle(color: kAppTextMuted, fontSize: 12),
            ),
            children: [
              if (_summariesLoading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_summariesError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Could not load collected editions: $_summariesError',
                        style: const TextStyle(color: kAppTextMuted),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _ensureSummariesLoaded,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if ((_summaries ?? const <BundleReleaseSummary>[]).isEmpty)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Core has not returned any collected editions for this title yet.',
                    style: TextStyle(color: kAppTextMuted),
                  ),
                )
              else ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final summary in _summaries!)
                      ChoiceChip(
                        label: Text(_bundleChipLabel(summary)),
                        selected: summary.id == selectedId,
                        selectedColor: widget.accent.withValues(alpha: 0.24),
                        onSelected: (_) {
                          setState(() {
                            _selectedBundleReleaseId = summary.id;
                          });
                          unawaited(_ensureDetailLoaded(summary.id));
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (detailLoading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (selectedDetailError != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Could not load edition contents: $selectedDetailError',
                          style: const TextStyle(color: kAppTextMuted),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: selectedId == null
                              ? null
                              : () => _ensureDetailLoaded(selectedId),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (selectedDetail != null)
                  BundleReleaseContentsCard(
                    detail: selectedDetail,
                    accent: widget.accent,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _summaryLabel() {
    if (_summaries == null) {
      return 'Expand to load collected editions';
    }
    final count = _summaries!.length;
    if (count == 0) {
      return 'No collected editions found';
    }
    return '$count collected edition${count == 1 ? '' : 's'}';
  }

  String _bundleChipLabel(BundleReleaseSummary summary) {
    final count = summary.contentSummary.totalItems;
    return '${summary.title} ($count item${count == 1 ? '' : 's'})';
  }
}