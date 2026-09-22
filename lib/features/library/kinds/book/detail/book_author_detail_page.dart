import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_author_repository.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/error_card.dart';
import 'package:collectarr_app/ui/loading_indicator.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _bookAuthorDetailProvider = FutureProvider.autoDispose
    .family<BookAuthorDetail, String>((ref, authorName) async {
  final repository = BookAuthorRepository(ref.watch(apiClientProvider));
  final authors = await repository.searchAuthors(authorName);
  if (authors.isEmpty) {
    throw StateError('No book author metadata found for $authorName.');
  }
  final normalizedName = _normalizeAuthorName(authorName);
  BookAuthor author = authors.first;
  for (final candidate in authors) {
    if (_normalizeAuthorName(candidate.name) == normalizedName) {
      author = candidate;
      break;
    }
  }
  final credits = await repository.getBookCredits(author.id);
  return BookAuthorDetail(author: author, credits: credits);
});

final class BookAuthorDetail {
  const BookAuthorDetail({
    required this.author,
    required this.credits,
  });

  final BookAuthor author;
  final List<BookAuthorWorkCredit> credits;
}

class BookAuthorDetailPage extends ConsumerWidget {
  const BookAuthorDetailPage({
    super.key,
    required this.authorName,
  });

  final String authorName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_bookAuthorDetailProvider(authorName));
    return Scaffold(
      appBar: AppBar(title: Text(authorName)),
      body: detail.when(
        loading: () => const AppLoadingIndicator(),
        error: (error, _) => AppErrorCard(
          message: error.toString(),
          onRetry: () => ref.invalidate(_bookAuthorDetailProvider(authorName)),
        ),
        data: (data) => _BookAuthorDetailBody(data: data),
      ),
    );
  }
}

class _BookAuthorDetailBody extends StatelessWidget {
  const _BookAuthorDetailBody({required this.data});

  final BookAuthorDetail data;

  @override
  Widget build(BuildContext context) {
    final author = data.author;
    final description = author.description?.trim();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AuthorPortrait(imageUrl: author.imageUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    author.name.isEmpty ? 'Author' : author.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Chip(label: Text('${data.credits.length} book works')),
                ],
              ),
            ),
          ],
        ),
        if (description != null && description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Biography', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(description),
        ],
        const SizedBox(height: 20),
        Text('Book works', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (data.credits.isEmpty)
          const Text('No book works were returned for this author.')
        else
          for (final credit in data.credits)
            _BookWorkCreditTile(credit: credit),
      ],
    );
  }
}

class _AuthorPortrait extends StatelessWidget {
  const _AuthorPortrait({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final url = imageUrl?.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 120,
        height: 160,
        child: url == null || url.isEmpty
            ? ColoredBox(
                color: palette.surfaceSubtle.withValues(alpha: 0.82),
                child: const Icon(Icons.person_outline, size: 42),
              )
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => ColoredBox(
                  color: palette.surfaceSubtle.withValues(alpha: 0.82),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => ColoredBox(
                  color: palette.surfaceSubtle.withValues(alpha: 0.82),
                  child: const Icon(Icons.broken_image_outlined, size: 42),
                ),
              ),
      ),
    );
  }
}

class _BookWorkCreditTile extends StatelessWidget {
  const _BookWorkCreditTile({required this.credit});

  final BookAuthorWorkCredit credit;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final coverUrl = credit.coverImageUrl?.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 42,
            height: 56,
            child: coverUrl == null || coverUrl.isEmpty
                ? ColoredBox(
                    color: palette.surfaceSubtle.withValues(alpha: 0.82),
                    child: const Icon(Icons.menu_book_outlined, size: 18),
                  )
                : CachedNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => ColoredBox(
                      color: palette.surfaceSubtle.withValues(alpha: 0.82),
                    ),
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: palette.surfaceSubtle.withValues(alpha: 0.82),
                      child: const Icon(Icons.broken_image_outlined, size: 18),
                    ),
                  ),
          ),
        ),
        title: Text(credit.title),
        subtitle: Text(credit.role),
      ),
    );
  }
}

String _normalizeAuthorName(String value) => value.trim().toLowerCase();
