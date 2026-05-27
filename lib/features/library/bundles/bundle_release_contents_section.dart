import 'dart:async';

import 'package:collectarr_app/core/models/bundle_release.dart';
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
  BundleReleaseDetail? _detail;
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
      final detail =
          await ref.read(apiClientProvider).getBundleRelease(widget.bundleReleaseId);
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
            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              style: const TextStyle(color: kAppTextMuted, fontSize: 12),
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
                        style: const TextStyle(color: kAppTextMuted),
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

  String _bundleSummary(BundleReleaseDetail detail) {
    final parts = <String>[
      '${detail.contentSummary.totalItems} item${detail.contentSummary.totalItems == 1 ? '' : 's'}',
      if (detail.contentSummary.primaryCount > 0)
        '${detail.contentSummary.primaryCount} primary',
      if (detail.contentSummary.bonusCount > 0)
        '${detail.contentSummary.bonusCount} bonus',
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

  final BundleReleaseDetail detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final groupedMembers = _groupBundleMembers(detail.members);
    final summaryParts = <String>[
      if (detail.bundleType != null && detail.bundleType!.trim().isNotEmpty)
        detail.bundleType!,
      if (detail.packagingType != null && detail.packagingType!.trim().isNotEmpty)
        detail.packagingType!,
      if (detail.publisher != null && detail.publisher!.trim().isNotEmpty)
        detail.publisher!,
      '${detail.contentSummary.totalItems} items',
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x12000000),
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
                style: const TextStyle(
                  color: kAppTextMuted,
                  fontSize: 12,
                ),
              ),
            ],
            if (detail.members.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (final group in groupedMembers) ...[
                _BundleReleaseDiscSection(
                  group: group,
                  accent: accent,
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

String _bundleMemberTitle(BundleReleaseMember member) {
  final number = member.itemNumber;
  if (number != null && number.trim().isNotEmpty) {
    return '${member.title} #$number';
  }
  return member.title;
}

String _bundleMemberSubtitle(BundleReleaseMember member) {
  final parts = <String>[
    if (member.role.trim().isNotEmpty) member.role,
    if (member.seriesTitle != null && member.seriesTitle!.trim().isNotEmpty)
      member.seriesTitle!,
    if (member.volumeName != null && member.volumeName!.trim().isNotEmpty)
      member.volumeName!,
    if (member.discNumber != null) 'Disc ${member.discNumber}',
    if (member.quantity > 1) 'x${member.quantity}',
  ];
  return parts.join(' • ');
}

class _BundleReleaseDiscSection extends StatelessWidget {
  const _BundleReleaseDiscSection({
    required this.group,
    required this.accent,
  });

  final _BundleReleaseDiscGroup group;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x10000000),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.label,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            for (final member in group.members)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        member.sequenceNumber?.toString() ?? '•',
                        style: const TextStyle(
                          color: kAppTextMuted,
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
                            _bundleMemberTitle(member),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            _bundleMemberSubtitle(member),
                            style: const TextStyle(
                              color: kAppTextMuted,
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

class _BundleReleaseDiscGroup {
  const _BundleReleaseDiscGroup({
    required this.label,
    required this.members,
  });

  final String label;
  final List<BundleReleaseMember> members;
}

List<_BundleReleaseDiscGroup> _groupBundleMembers(
  List<BundleReleaseMember> members,
) {
  if (members.isEmpty) {
    return const <_BundleReleaseDiscGroup>[];
  }
  final grouped = <String, List<BundleReleaseMember>>{};
  final orderedKeys = <String>[];
  for (final member in members) {
    final key = member.discNumber != null
        ? 'disc:${member.discNumber}'
        : member.discLabel != null && member.discLabel!.trim().isNotEmpty
            ? 'label:${member.discLabel!.trim()}'
            : 'disc:none';
    if (!grouped.containsKey(key)) {
      grouped[key] = <BundleReleaseMember>[];
      orderedKeys.add(key);
    }
    grouped[key]!.add(member);
  }
  return [
    for (final key in orderedKeys)
      _BundleReleaseDiscGroup(
        label: _bundleDiscLabel(grouped[key]!.first),
        members: [...grouped[key]!]..sort((left, right) {
          final leftSequence = left.sequenceNumber ?? 999999;
          final rightSequence = right.sequenceNumber ?? 999999;
          return leftSequence.compareTo(rightSequence);
        }),
      ),
  ];
}

String _bundleDiscLabel(BundleReleaseMember member) {
  final discLabel = member.discLabel?.trim();
  if (discLabel != null && discLabel.isNotEmpty) {
    return discLabel;
  }
  final discNumber = member.discNumber;
  if (discNumber != null) {
    return 'Disc $discNumber';
  }
  return 'Main contents';
}