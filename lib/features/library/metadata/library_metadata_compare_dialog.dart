import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_metadata_capability.dart';
import 'package:collectarr_app/features/library/ui/library_dialog_scaffold.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showLibraryMetadataCompareDialog({
  required BuildContext context,
  required String itemId,
  required String itemTitle,
  required CatalogMediaKind kind,
  required Map<String, dynamic> localPayload,
  required MetadataCompareBuilder compareBuilder,
  required Color accent,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) => _LibraryMetadataCompareDialog(
      itemId: itemId,
      itemTitle: itemTitle,
      kind: kind,
      localPayload: localPayload,
      compareBuilder: compareBuilder,
      accent: accent,
    ),
  );
}

class _LibraryMetadataCompareDialog extends ConsumerStatefulWidget {
  const _LibraryMetadataCompareDialog({
    required this.itemId,
    required this.itemTitle,
    required this.kind,
    required this.localPayload,
    required this.compareBuilder,
    required this.accent,
  });

  final String itemId;
  final String itemTitle;
  final CatalogMediaKind kind;
  final Map<String, dynamic> localPayload;
  final MetadataCompareBuilder compareBuilder;
  final Color accent;

  @override
  ConsumerState<_LibraryMetadataCompareDialog> createState() =>
      _LibraryMetadataCompareDialogState();
}

class _LibraryMetadataCompareDialogState
    extends ConsumerState<_LibraryMetadataCompareDialog> {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _serverPayload;

  @override
  void initState() {
    super.initState();
    _loadServerItem();
  }

  Future<void> _loadServerItem() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final dto = await api.getTypedMetadataItem(
        kind: widget.kind,
        id: widget.itemId,
      );
      final payload = <String, dynamic>{
        ...dto.raw,
        'id': dto.id,
        'title': dto.title,
        if (dto.kind != null) 'kind': dto.kind,
      };
      if (!mounted) {
        return;
      }
      setState(() {
        _serverPayload = payload;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = _errorText(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _errorText(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 404) {
        return 'This item no longer exists on server metadata.';
      }
      if (statusCode == 422) {
        return 'Server rejected this compare request (422). '
            'This item likely has an unsupported metadata id format.';
      }
      final responseData = error.response?.data;
      if (responseData is Map && responseData['detail'] != null) {
        return responseData['detail'].toString();
      }
      final msg = error.message;
      if (msg != null && msg.trim().isNotEmpty) {
        return msg;
      }
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final serverPayload = _serverPayload;
    return LibraryDialogScaffold(
      title: Row(
        children: [
          const Icon(Icons.compare_arrows, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Metadata Compare — ${widget.itemTitle}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      onClose: () => Navigator.of(context).pop(),
      maxWidth: 1200,
      maxHeight: 820,
      padding: EdgeInsets.zero,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.redAccent),
                    ),
                  ),
                )
              : serverPayload == null
                  ? const SizedBox.shrink()
                  : Scrollbar(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: widget.compareBuilder(
                            context,
                            localPayload: widget.localPayload,
                            serverPayload: serverPayload,
                            accent: widget.accent,
                          ),
                        ),
                      ),
                    ),
    );
  }
}
