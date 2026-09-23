import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/admin/admin_kind_labels.dart';
import 'package:collectarr_app/features/admin/admin_primitives.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

sealed class AdminProviderAddRequest {
  const AdminProviderAddRequest({
    required this.kind,
    required this.provider,
    required this.showMediaResults,
    required this.showReleaseResults,
  });

  final String kind;
  final String provider;
  final bool showMediaResults;
  final bool showReleaseResults;
}

final class AdminProviderSearchRequest extends AdminProviderAddRequest {
  const AdminProviderSearchRequest({
    required super.kind,
    required super.provider,
    required super.showMediaResults,
    required super.showReleaseResults,
    required this.query,
  });

  final String query;
}

final class AdminProviderDirectIngestRequest extends AdminProviderAddRequest {
  const AdminProviderDirectIngestRequest({
    required super.kind,
    required super.provider,
    required super.showMediaResults,
    required super.showReleaseResults,
    required this.providerItemId,
  });

  final String providerItemId;
}

class AdminProviderSelector extends StatelessWidget {
  const AdminProviderSelector({
    required this.value,
    required this.providers,
    required this.isLoading,
    required this.onChanged,
  });

  final String value;
  final List<AdminProviderStatus> providers;
  final bool isLoading;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected =
        providers.any((provider) => provider.name == value) ? value : null;
    if (providers.isEmpty) {
      return TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Provider',
          prefixIcon: const Icon(Icons.extension_outlined),
          border: const OutlineInputBorder(),
          hintText:
              isLoading ? 'Loading providers...' : 'No searchable providers',
        ),
      );
    }
    return CompactSearchDropdownFormField<String>(
      key: ValueKey(selected),
      initialValue: selected,
      isExpanded: true,
      dropdownColor: appPalette(context).panelRaised,
      borderRadius: kAppMenuBorderRadius,
      hint: Text(isLoading ? 'Loading providers...' : 'Select provider'),
      decoration: const InputDecoration(
        labelText: 'Provider',
        prefixIcon: Icon(Icons.extension_outlined),
        border: OutlineInputBorder(),
      ),
      items: [
        for (final provider in providers)
          DropdownMenuItem(
            value: provider.name,
            child: Text(provider.displayName, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class AdminProviderKindSelector extends StatelessWidget {
  const AdminProviderKindSelector({
    required this.value,
    required this.kinds,
    required this.kindLabels,
    required this.isLoading,
    required this.onChanged,
  });

  final String? value;
  final List<String> kinds;
  final Map<String, String> kindLabels;
  final bool isLoading;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (kinds.isEmpty) {
      return TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Media kind',
          prefixIcon: const Icon(Icons.category_outlined),
          border: const OutlineInputBorder(),
          hintText: isLoading ? 'Loading kinds...' : 'No provider kinds',
        ),
      );
    }
    final selected = value != null && kinds.contains(value) ? value! : '';
    return CompactSearchDropdownFormField<String>(
      key: ValueKey('provider-kind-$selected'),
      initialValue: selected,
      isExpanded: true,
      dropdownColor: appPalette(context).panelRaised,
      borderRadius: kAppMenuBorderRadius,
      decoration: const InputDecoration(
        labelText: 'Media kind',
        prefixIcon: Icon(Icons.category_outlined),
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(
          value: '',
          child: Text('All media', overflow: TextOverflow.ellipsis),
        ),
        for (final kind in kinds)
          DropdownMenuItem(
            value: kind,
            child: Text(adminProviderKindLabel(kind, kindLabels),
                overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

enum _ProviderAddMode { search, direct }

class AdminProviderAddDialog extends StatefulWidget {
  const AdminProviderAddDialog({
    required this.providers,
    required this.kinds,
    required this.kindLabels,
    this.initialKind,
    this.initialProvider,
    this.initialQuery,
    this.initialProviderItemId,
    this.initialShowMediaResults = true,
    this.initialShowReleaseResults = true,
  });

  final List<AdminProviderStatus> providers;
  final List<String> kinds;
  final Map<String, String> kindLabels;
  final String? initialKind;
  final String? initialProvider;
  final String? initialQuery;
  final String? initialProviderItemId;
  final bool initialShowMediaResults;
  final bool initialShowReleaseResults;

  @override
  State<AdminProviderAddDialog> createState() => _AdminProviderAddDialogState();
}

class _AdminProviderAddDialogState extends State<AdminProviderAddDialog> {
  late _ProviderAddMode _mode;
  late String? _selectedKind;
  late String _selectedProvider;
  late final TextEditingController _queryController;
  late final TextEditingController _providerItemIdController;
  late bool _showMediaResults;
  late bool _showReleaseResults;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mode = _ProviderAddMode.search;
    _selectedKind = widget.initialKind;
    _selectedProvider = widget.initialProvider ?? '';
    _queryController = TextEditingController(text: widget.initialQuery ?? '');
    _providerItemIdController = TextEditingController(
      text: widget.initialProviderItemId ?? '',
    );
    _showMediaResults = widget.initialShowMediaResults;
    _showReleaseResults = widget.initialShowReleaseResults;
    _syncSelectedProvider();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _providerItemIdController.dispose();
    super.dispose();
  }

  List<AdminProviderStatus> get _availableProviders {
    return [
      for (final provider in widget.providers)
        if ((_mode == _ProviderAddMode.search
                ? provider.supportsSearch
                : provider.supportsIngest) &&
            (_selectedKind == null ||
                provider.effectiveKinds.contains(_selectedKind)))
          provider,
    ];
  }

  void _syncSelectedProvider() {
    final providers = _availableProviders;
    if (providers.any((provider) => provider.name == _selectedProvider)) {
      return;
    }
    _selectedProvider = providers.isEmpty ? '' : providers.first.name;
  }

  @override
  Widget build(BuildContext context) {
    final actionLabel =
        _mode == _ProviderAddMode.search ? 'Search provider' : 'Add to catalog';
    return AccentAlertDialog(
      shape: adminDialogShape,
      title: const Text('Add metadata from provider'),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                AdminMessageRow(message: _error!, isError: true),
                const SizedBox(height: 12),
              ],
              SegmentedButton<_ProviderAddMode>(
                segments: const [
                  ButtonSegment<_ProviderAddMode>(
                    value: _ProviderAddMode.search,
                    icon: Icon(Icons.manage_search_outlined),
                    label: Text('Search first'),
                  ),
                  ButtonSegment<_ProviderAddMode>(
                    value: _ProviderAddMode.direct,
                    icon: Icon(Icons.download_for_offline_outlined),
                    label: Text('Known ID'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) {
                  setState(() {
                    _mode = selection.first;
                    _error = null;
                    _syncSelectedProvider();
                  });
                },
              ),
              const SizedBox(height: 16),
              AdminProviderKindSelector(
                value: _selectedKind,
                kinds: widget.kinds,
                kindLabels: widget.kindLabels,
                isLoading: false,
                onChanged: (value) {
                  setState(() {
                    _selectedKind =
                        value == null || value.isEmpty ? null : value;
                    _error = null;
                    _syncSelectedProvider();
                  });
                },
              ),
              const SizedBox(height: 12),
              AdminProviderSelector(
                value: _selectedProvider,
                providers: _availableProviders,
                isLoading: false,
                onChanged: (value) {
                  setState(() {
                    _selectedProvider = value?.trim() ?? '';
                    _error = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              Text(
                _mode == _ProviderAddMode.search
                    ? 'Search for candidates inside the selected category before creating anything in the canonical catalog.'
                    : 'Use a known provider item ID when you already know the exact external record you want to ingest.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 8,
                children: [
                  AdminProviderEntityScopeToggle(
                    label: 'Media',
                    value: _showMediaResults,
                    onChanged: (value) {
                      if (!value && !_showReleaseResults) {
                        return;
                      }
                      setState(() {
                        _showMediaResults = value;
                      });
                    },
                  ),
                  AdminProviderEntityScopeToggle(
                    label: 'Releases',
                    value: _showReleaseResults,
                    onChanged: (value) {
                      if (!value && !_showMediaResults) {
                        return;
                      }
                      setState(() {
                        _showReleaseResults = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_mode == _ProviderAddMode.search)
                TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    labelText: 'Provider query',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submit(),
                )
              else
                TextField(
                  controller: _providerItemIdController,
                  decoration: const InputDecoration(
                    labelText: 'Provider item ID',
                    prefixIcon: Icon(Icons.tag_outlined),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: Icon(
            _mode == _ProviderAddMode.search
                ? Icons.manage_search_outlined
                : Icons.download_for_offline_outlined,
          ),
          label: Text(actionLabel),
        ),
      ],
    );
  }

  void _submit() {
    final kind = _selectedKind?.trim();
    if (kind == null || kind.isEmpty) {
      setState(() => _error = 'Choose a media category first.');
      return;
    }
    if (_selectedProvider.trim().isEmpty) {
      setState(() => _error = 'Choose a provider.');
      return;
    }
    if (_mode == _ProviderAddMode.search) {
      final query = _queryController.text.trim();
      if (query.isEmpty) {
        setState(() => _error = 'Enter a provider query.');
        return;
      }
      Navigator.of(context).pop(
        AdminProviderSearchRequest(
          kind: kind,
          provider: _selectedProvider,
          showMediaResults: _showMediaResults,
          showReleaseResults: _showReleaseResults,
          query: query,
        ),
      );
      return;
    }
    final providerItemId = _providerItemIdController.text.trim();
    if (providerItemId.isEmpty) {
      setState(() => _error = 'Enter a provider item ID.');
      return;
    }
    Navigator.of(context).pop(
      AdminProviderDirectIngestRequest(
        kind: kind,
        provider: _selectedProvider,
        showMediaResults: _showMediaResults,
        showReleaseResults: _showReleaseResults,
        providerItemId: providerItemId,
      ),
    );
  }
}

class AdminProviderEntityScopeToggles extends StatelessWidget {
  const AdminProviderEntityScopeToggles({
    required this.showMediaResults,
    required this.showReleaseResults,
    required this.onShowMediaResultsChanged,
    required this.onShowReleaseResultsChanged,
  });

  final bool showMediaResults;
  final bool showReleaseResults;
  final ValueChanged<bool> onShowMediaResultsChanged;
  final ValueChanged<bool> onShowReleaseResultsChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            AdminProviderEntityScopeToggle(
              label: 'Media',
              value: showMediaResults,
              onChanged: onShowMediaResultsChanged,
            ),
            AdminProviderEntityScopeToggle(
              label: 'Releases',
              value: showReleaseResults,
              onChanged: onShowReleaseResultsChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class AdminProviderEntityScopeToggle extends StatelessWidget {
  const AdminProviderEntityScopeToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 18,
              child: Checkbox(
                value: value,
                onChanged: (checked) => onChanged(checked ?? false),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
