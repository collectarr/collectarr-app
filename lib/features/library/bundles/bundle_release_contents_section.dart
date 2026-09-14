import 'dart:async';

import 'package:collectarr_app/features/library/bundles/models/library_bundle_detail.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BundleReleaseContentsSection extends ConsumerStatefulWidget {
  const BundleReleaseContentsSection({
    super.key,
    required this.bundleReleaseId,
    required this.accent,
    this.title = 'Bundle contents',
  });

  final String bundleReleaseId;
  final Color accent;
  final String title;

  @override
  ConsumerState<BundleReleaseContentsSection> createState() =>
      _BundleReleaseContentsSectionState();
}

class _BundleReleaseContentsSectionState
    extends ConsumerState<BundleReleaseContentsSection> {
  LibraryBundleDetail? _detail;
  Object? _error;
  bool _loading = false;

  @override
  void didUpdateWidget(covariant BundleReleaseContentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bundleReleaseId != widget.bundleReleaseId) {
      _detail = null;
      _error = null;
      _loading = false;
    }
  }

  Future<void> _ensureLoaded() async {
    if (_detail != null || _loading) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final transportDetail = await ref
          .read(apiClientProvider)
          .getBundleRelease(widget.bundleReleaseId);
      final detail = LibraryBundleDetail.fromTransport(transportDetail);
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final detail = _detail;
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
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            iconColor: widget.accent,
            collapsedIconColor: widget.accent,
            textColor: widget.accent,
            collapsedTextColor: widget.accent,
            onExpansionChanged: (expanded) {
              if (expanded) {
                unawaited(_ensureLoaded());
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
              detail == null
                  ? 'Expand to load bundle members'
                  : _bundleSummary(detail),
              style: TextStyle(color: palette.textMuted, fontSize: 12),
            ),
            children: [
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Could not load bundle contents: $_error',
                        style: TextStyle(color: palette.textMuted),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _ensureLoaded,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (detail != null)
                BundleReleaseContentsCard(
                  detail: detail,
                  accent: widget.accent,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _bundleSummary(LibraryBundleDetail detail) {
    final parts = <String>[
      '${detail.memberCount} item${detail.memberCount == 1 ? '' : 's'}',
      if (detail.primaryMemberCount > 0) '${detail.primaryMemberCount} primary',
      if (detail.bonusMemberCount > 0) '${detail.bonusMemberCount} bonus',
    ];
    return parts.join(' • ');
  }
}

class BundleReleaseContentsCard extends StatelessWidget {
  const BundleReleaseContentsCard({
    super.key,
    required this.detail,
    required this.accent,
  });

  final LibraryBundleDetail detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final summaryParts = <String>[
      '${detail.memberCount} items',
      if (detail.primaryMemberCount > 0) '${detail.primaryMemberCount} primary',
      if (detail.bonusMemberCount > 0) '${detail.bonusMemberCount} bonus',
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (summaryParts.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                summaryParts.join(' • '),
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
            if (detail.members.isNotEmpty) ...[
              const SizedBox(height: 10),
              _BundleReleaseMembersSection(
                members: detail.members,
                accent: accent,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _bundleMemberSubtitle(LibraryBundleMemberSummary member) {
  final parts = <String>[
    if (member.role.trim().isNotEmpty) member.role,
    if (member.quantity > 1) 'x${member.quantity}',
  ];
  return parts.join(' • ');
}

class _BundleReleaseMembersSection extends StatelessWidget {
  const _BundleReleaseMembersSection({
    required this.members,
    required this.accent,
  });

  final List<LibraryBundleMemberSummary> members;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Members',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            for (final member in members)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        member.sequenceNumber?.toString() ?? '•',
                        style: TextStyle(
                          color: palette.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      member.isPrimary
                          ? Icons.radio_button_checked
                          : Icons.subdirectory_arrow_right,
                      size: 16,
                      color: member.isPrimary
                          ? accent
                          : accent.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            _bundleMemberSubtitle(member),
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
