import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/sharing/collection_publication.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollectionCloudSharingPage extends ConsumerStatefulWidget {
  const CollectionCloudSharingPage(
      {super.key, required this.type, required this.items});
  final LibraryKindRegistration type;
  final List<LibraryProjectionView> items;
  @override
  ConsumerState<CollectionCloudSharingPage> createState() =>
      _CollectionCloudSharingPageState();
}

class _CollectionCloudSharingPageState
    extends ConsumerState<CollectionCloudSharingPage> {
  List<LibraryCollectionSummary> _collections = [];
  final _visibility = <String, String>{};
  final _personal = <String, bool>{};
  final _privateLinks = <String, bool>{};
  final _urls = <String, String>{};
  bool _busy = true;
  bool _loaded = false;
  String? _error;
  String _globalVisibility = 'private';

  Dio _client() {
    final settings = ref.read(connectionSettingsProvider);
    final token = ref.read(apiAuthTokenProvider);
    return Dio(BaseOptions(
        baseUrl: settings.syncBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          if (settings.syncKey.isNotEmpty)
            'X-Collectarr-Sync-Key': settings.syncKey,
          if (token != null) 'Authorization': 'Bearer $token',
        }));
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final client = _client();
    try {
      final collections =
          await LibraryCollectionRepository(ref.read(localDatabaseProvider))
              .watch(widget.type.kind.apiValue)
              .first;
      final response = await client.get<List<dynamic>>('/sharing',
          queryParameters: {'kind': widget.type.kind.apiValue});
      if (!mounted) return;
      setState(() {
        _collections = collections;
        for (final collection in collections) {
          _visibility[collection.id] = 'private';
          _personal[collection.id] = false;
          _privateLinks[collection.id] = false;
        }
        for (final row in response.data ?? const []) {
          final data = Map<String, dynamic>.from(row as Map);
          final id = data['collection_id'] as String;
          _visibility[id] = data['visibility'] as String;
          _personal[id] = data['include_personal'] as bool;
          _privateLinks[id] = data['private_link_enabled'] as bool;
          if (data['token'] case final String token) {
            _urls[id] = _shareUrl(token);
          }
        }
        _loaded = true;
        final visibilities = _visibility.values.toSet();
        _globalVisibility =
            visibilities.length == 1 ? visibilities.single : 'mixed';
      });
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not load sharing settings: $error');
      }
    } finally {
      client.close();
      if (mounted) setState(() => _busy = false);
    }
  }

  String _shareUrl(String token) =>
      '${ref.read(connectionSettingsProvider).syncBaseUrl.replaceFirst(RegExp(r'/+$'), '')}/public/$token';

  Future<void> _save() async {
    if (!_loaded || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final client = _client();
    try {
      for (final collection in _collections) {
        final items = widget.items
            .where((item) => collection.entryIds
                .contains(item.source.libraryEntryRef?.id.value))
            .toList();
        final response = await client.put<Map<String, dynamic>>(
            '/sharing/${Uri.encodeComponent(collection.id)}',
            data: buildCollectionPublication(
                type: widget.type,
                title: collection.name,
                visibility: _visibility[collection.id]!,
                includePersonal: _personal[collection.id]!,
                privateLinkEnabled: _privateLinks[collection.id]!,
                items: items));
        if (!mounted) return;
        final token = response.data?['token'] as String?;
        setState(() {
          if (token == null) {
            _urls.remove(collection.id);
          } else {
            _urls[collection.id] = _shareUrl(token);
          }
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sharing settings saved')));
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not save sharing settings: $error');
      }
    } finally {
      client.close();
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _privacyPicker(String value, ValueChanged<String> changed) =>
      DropdownButton<String>(
          value: value,
          items: [
            if (value == 'mixed')
              const DropdownMenuItem(
                  value: 'mixed', enabled: false, child: Text('Mixed')),
            const DropdownMenuItem(value: 'private', child: Text('Private')),
            const DropdownMenuItem(value: 'partial', child: Text('Partial')),
            const DropdownMenuItem(value: 'public', child: Text('Public'))
          ],
          onChanged: _busy
              ? null
              : (value) {
                  if (value != null) changed(value);
                });

  @override
  Widget build(BuildContext context) => Theme(
        data:
            libraryAccentTheme(context, libraryAccentForKind(widget.type.kind)),
        child: Scaffold(
            appBar: AppBar(title: const Text('Cloud Sharing')),
            body: ListView(padding: const EdgeInsets.all(20), children: [
              const Text(
                  'Partial makes the collection public without personal fields. Private sharing links are optional. Save publishes the current collection snapshot.'),
              const SizedBox(height: 12),
              if (_busy) const LinearProgressIndicator(),
              if (_error != null) ...[
                Text(_error!),
                TextButton(
                    onPressed: _busy ? null : _load, child: const Text('Retry'))
              ],
              if (_loaded) ...[
                Row(children: [
                  const Expanded(child: Text('All collections')),
                  _privacyPicker(
                      _globalVisibility,
                      (value) => setState(() {
                            _globalVisibility = value;
                            for (final collection in _collections) {
                              _visibility[collection.id] = value;
                            }
                          }))
                ]),
                for (final collection in _collections)
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 16,
                                    children: [
                                      Text(
                                          '${collection.name} (${collection.count})'),
                                      _privacyPicker(
                                          _visibility[collection.id]!,
                                          (value) => setState(() {
                                                _visibility[collection.id] =
                                                    value;
                                                _globalVisibility = _visibility
                                                            .values
                                                            .toSet()
                                                            .length ==
                                                        1
                                                    ? value
                                                    : 'mixed';
                                              }))
                                    ]),
                                if (_visibility[collection.id] == 'private')
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text(
                                        'Enable private sharing link'),
                                    value: _privateLinks[collection.id]!,
                                    onChanged: _busy
                                        ? null
                                        : (value) => setState(() =>
                                            _privateLinks[collection.id] =
                                                value),
                                  ),
                                CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title:
                                        const Text('Include personal fields'),
                                    value:
                                        _visibility[collection.id] == 'partial'
                                            ? false
                                            : _personal[collection.id],
                                    onChanged: _busy ||
                                            _visibility[collection.id] ==
                                                'partial' ||
                                            (_visibility[collection.id] ==
                                                    'private' &&
                                                !_privateLinks[collection.id]!)
                                        ? null
                                        : (value) => setState(() =>
                                            _personal[collection.id] =
                                                value ?? false)),
                                if (_urls[collection.id] case final url?) ...[
                                  SelectableText(url),
                                  TextButton.icon(
                                      onPressed: () => Clipboard.setData(
                                          ClipboardData(text: url)),
                                      icon: const Icon(Icons.copy),
                                      label: const Text('Copy sharing link')),
                                ],
                              ]))),
                Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                        onPressed: _busy ? null : _save,
                        child: const Text('Save'))),
              ],
            ])),
      );
}
