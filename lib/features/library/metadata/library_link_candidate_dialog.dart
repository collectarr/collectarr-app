import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:flutter/material.dart';

class LibraryLinkCandidateDialog extends StatefulWidget {
  const LibraryLinkCandidateDialog(
      {super.key, required this.title, required this.search});
  final String title;
  final Future<List<CatalogSearchCandidate>> Function(String) search;
  @override
  State<LibraryLinkCandidateDialog> createState() =>
      _LibraryLinkCandidateDialogState();
}

class _LibraryLinkCandidateDialogState
    extends State<LibraryLinkCandidateDialog> {
  late final _query = TextEditingController(text: widget.title);
  List<CatalogSearchCandidate>? _results;
  String? _error;
  bool _busy = false;
  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_busy || _query.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
      _results = null;
    });
    try {
      final results = await widget.search(_query.text.trim());
      if (mounted) setState(() => _results = results);
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not search Core: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AccentAlertDialog(
          headerIcon: AppIcons.link,
          title: const Text('Link manually'),
          content: SizedBox(
              width: 700,
              height: 420,
              child: Column(children: [
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: _query,
                          autofocus: true,
                          decoration:
                              const InputDecoration(labelText: 'Search Core'),
                          onSubmitted: (_) => _search())),
                  const SizedBox(width: 5),
                  DialogActionButton(
                      label: 'Search',
                      primary: true,
                      onPressed: _busy ? null : _search),
                ]),
                const SizedBox(height: 10),
                if (_busy) const LinearProgressIndicator(),
                if (_error != null) Text(_error!),
                if (_results?.isEmpty ?? false)
                  const Text('No matching catalog items found.'),
                Expanded(
                    child: ListView(children: [
                  for (final candidate
                      in _results ?? <CatalogSearchCandidate>[])
                    ListTile(
                        title: LinkItemSummary(
                            title: candidate.summary.primaryLabel,
                            subtitle: candidate.summary.subtitle,
                            imageUrl: candidate.summary.imageUrl),
                        trailing: DialogActionButton(
                            label: 'Link',
                            primary: true,
                            onPressed: () =>
                                Navigator.pop(context, candidate))),
                ])),
              ])),
          actions: [
            DialogActionButtons.cancel(onPressed: () => Navigator.pop(context))
          ]);
}

class LinkItemSummary extends StatelessWidget {
  const LinkItemSummary(
      {super.key, required this.title, this.subtitle, this.imageUrl});
  final String title;
  final String? subtitle;
  final String? imageUrl;
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (imageUrl?.isNotEmpty ?? false) ...[
          Image.network(imageUrl!,
              width: 45,
              height: 45,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const SizedBox.square(dimension: 45)),
          const SizedBox(width: 8),
        ],
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          if (subtitle?.isNotEmpty ?? false)
            Text(subtitle!, style: const TextStyle(fontSize: 14)),
        ])),
      ]);
}
