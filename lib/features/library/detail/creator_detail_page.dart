import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _creatorDetailProvider = FutureProvider.autoDispose
    .family<_CreatorDetailData, String>((ref, creatorName) async {
  final api = ref.watch(apiClientProvider);
  final results = await api.searchCreators(
    query: creatorName,
    limit: 12,
  );
  if (results.isEmpty) {
    throw StateError('No creator metadata found for $creatorName.');
  }
  final creator = _pickBestCreator(results, creatorName);
  final credits = await api.getCreatorCredits(creator['id'].toString());
  return _CreatorDetailData(
    creator: creator,
    credits: credits,
    alternatives: results,
  );
});

class CreatorDetailPage extends ConsumerWidget {
  const CreatorDetailPage({
    super.key,
    required this.creatorName,
  });

  final String creatorName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_creatorDetailProvider(creatorName));
    return Scaffold(
      appBar: AppBar(
        title: Text(creatorName),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _CreatorDetailError(
          message: error.toString(),
          onRetry: () => ref.invalidate(_creatorDetailProvider(creatorName)),
        ),
        data: (data) => _CreatorDetailBody(data: data),
      ),
    );
  }
}

class _CreatorDetailData {
  const _CreatorDetailData({
    required this.creator,
    required this.credits,
    required this.alternatives,
  });

  final Map<String, dynamic> creator;
  final List<Map<String, dynamic>> credits;
  final List<Map<String, dynamic>> alternatives;
}

class _CreatorDetailBody extends StatelessWidget {
  const _CreatorDetailBody({required this.data});

  final _CreatorDetailData data;

  @override
  Widget build(BuildContext context) {
    final creator = data.creator;
    final description = creator['description']?.toString();
    final imageUrl = creator['image_url']?.toString();
    final itemCount = (creator['item_count'] as num?)?.toInt() ?? data.credits.length;
    final roleCounts = <String, int>{};
    for (final credit in data.credits) {
      final role = credit['role']?.toString().trim();
      if (role == null || role.isEmpty) {
        continue;
      }
      roleCounts[role] = (roleCounts[role] ?? 0) + 1;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CreatorPortrait(imageUrl: imageUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    creator['name']?.toString() ?? 'Creator',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _CreatorStatChip(
                        icon: Icons.edit_note_outlined,
                        label: '$itemCount credits',
                      ),
                      for (final entry in roleCounts.entries)
                        _CreatorStatChip(
                          icon: Icons.badge_outlined,
                          label: '${entry.key} ${entry.value}',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (description != null && description.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(description),
        ],
        const SizedBox(height: 20),
        Text(
          'Credits',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (data.credits.isEmpty)
          const Text('No creator credits were returned for this creator.')
        else
          for (final credit in data.credits)
            _CreatorCreditTile(credit: credit),
      ],
    );
  }
}

class _CreatorPortrait extends StatelessWidget {
  const _CreatorPortrait({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 120,
        height: 160,
        child: imageUrl == null || imageUrl!.trim().isEmpty
            ? const ColoredBox(
                color: Color(0x22000000),
                child: Icon(Icons.person_outline, size: 42),
              )
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ColoredBox(
                  color: Color(0x22000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => const ColoredBox(
                  color: Color(0x22000000),
                  child: Icon(Icons.broken_image_outlined, size: 42),
                ),
              ),
      ),
    );
  }
}

class _CreatorCreditTile extends StatelessWidget {
  const _CreatorCreditTile({required this.credit});

  final Map<String, dynamic> credit;

  @override
  Widget build(BuildContext context) {
    final title = credit['title']?.toString() ?? 'Untitled';
    final role = credit['role']?.toString() ?? 'creator';
    final series = credit['series_title']?.toString();
    final volume = credit['volume_name']?.toString();
    final itemNumber = credit['item_number']?.toString();
    final coverUrl = credit['cover_image_url']?.toString();
    final subtitle = [
      role,
      if (series != null && series.trim().isNotEmpty) series,
      if (volume != null && volume.trim().isNotEmpty) volume,
      if (itemNumber != null && itemNumber.trim().isNotEmpty) '#$itemNumber',
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 42,
            height: 56,
            child: coverUrl == null || coverUrl.trim().isEmpty
                ? const ColoredBox(
                    color: Color(0x22000000),
                    child: Icon(Icons.image_not_supported_outlined, size: 18),
                  )
                : CachedNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ColoredBox(
                      color: Color(0x22000000),
                    ),
                    errorWidget: (_, __, ___) => const ColoredBox(
                      color: Color(0x22000000),
                      child: Icon(Icons.broken_image_outlined, size: 18),
                    ),
                  ),
          ),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _CreatorStatChip extends StatelessWidget {
  const _CreatorStatChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _CreatorDetailError extends StatelessWidget {
  const _CreatorDetailError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> _pickBestCreator(
  List<Map<String, dynamic>> results,
  String query,
) {
  final normalizedQuery = _normalizeCreatorText(query);
  for (final result in results) {
    final name = _normalizeCreatorText(result['name']?.toString() ?? '');
    if (name == normalizedQuery) {
      return result;
    }
  }
  return results.first;
}

String _normalizeCreatorText(String value) {
  return value.trim().toLowerCase();
}