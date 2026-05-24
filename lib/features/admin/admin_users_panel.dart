import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminUsersPanel extends ConsumerStatefulWidget {
  const AdminUsersPanel({super.key});

  @override
  ConsumerState<AdminUsersPanel> createState() => _AdminUsersPanelState();
}

class _AdminUsersPanelState extends ConsumerState<AdminUsersPanel> {
  final _queryController = TextEditingController();
  var _users = const <AdminUser>[];
  bool _isLoading = false;
  String? _savingUserId;
  String? _errorMessage;
  String? _statusMessage;
  String? _roleFilter;
  bool? _activeFilter;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<AdminUser> get _filteredUsers {
    final query = _queryController.text.trim().toLowerCase();
    return [
      for (final user in _users)
        if ((_roleFilter == null || user.role == _roleFilter) &&
            (_activeFilter == null || user.isActive == _activeFilter) &&
            (query.isEmpty ||
                user.email.toLowerCase().contains(query) ||
                user.label.toLowerCase().contains(query)))
          user,
    ];
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statusMessage = null;
    });
    try {
      final users = await ref.read(apiClientProvider).adminListUsers();
      if (!mounted) {
        return;
      }
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUser(
    AdminUser user, {
    String? role,
    bool? isActive,
    String? displayName,
    required String successMessage,
  }) async {
    if (role == null && isActive == null && displayName == null) {
      return;
    }
    setState(() {
      _savingUserId = user.id;
      _statusMessage = null;
      _errorMessage = null;
    });
    try {
      await ref.read(apiClientProvider).adminUpdateUser(
            user.id,
            role: role,
            isActive: isActive,
            displayName: displayName,
          );
      await _loadUsers();
      if (!mounted) {
        return;
      }
      setState(() {
        _savingUserId = null;
        _statusMessage = successMessage;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _savingUserId = null;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _toggleActive(AdminUser user) async {
    await _saveUser(
      user,
      isActive: !user.isActive,
      successMessage: user.isActive
          ? 'Deactivated ${user.email}.'
          : 'Reactivated ${user.email}.',
    );
  }

  Future<void> _editUser(AdminUser user) async {
    final draft = await showDialog<_AdminUserDraft>(
      context: context,
      builder: (context) => _AdminUserEditorDialog(user: user),
    );
    if (draft == null) {
      return;
    }
    final normalizedDisplayName = draft.displayName.trim();
    await _saveUser(
      user,
      role: draft.role == user.role ? null : draft.role,
      isActive: draft.isActive == user.isActive ? null : draft.isActive,
      displayName: normalizedDisplayName == (user.displayName ?? '').trim()
          ? null
          : normalizedDisplayName,
      successMessage: 'Updated ${user.email}.',
    );
  }

  void _changeRoleFilter(String? value) {
    setState(() {
      _roleFilter = value == null || value.isEmpty ? null : value;
    });
  }

  void _changeActiveFilter(bool? value) {
    setState(() {
      _activeFilter = value;
    });
  }

  Widget _buildFilterBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final queryField = TextField(
          controller: _queryController,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Search users',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        );
        final roleField = DropdownButtonFormField<String>(
          initialValue: _roleFilter ?? '',
          isExpanded: true,
          dropdownColor: kAppPanelRaised,
          borderRadius: kAppMenuBorderRadius,
          decoration: const InputDecoration(
            labelText: 'Role',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: '', child: Text('All roles')),
            DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
            DropdownMenuItem(value: 'editor', child: Text('Editor')),
            DropdownMenuItem(value: 'admin', child: Text('Admin')),
          ],
          onChanged: _changeRoleFilter,
        );
        final statusField = DropdownButtonFormField<String>(
          initialValue: switch (_activeFilter) {
            true => 'active',
            false => 'inactive',
            null => '',
          },
          isExpanded: true,
          dropdownColor: kAppPanelRaised,
          borderRadius: kAppMenuBorderRadius,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: '', child: Text('All statuses')),
            DropdownMenuItem(value: 'active', child: Text('Active')),
            DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
          ],
          onChanged: (value) {
            _changeActiveFilter(
              value == null || value.isEmpty ? null : value == 'active',
            );
          },
        );
        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              queryField,
              const SizedBox(height: 12),
              roleField,
              const SizedBox(height: 12),
              statusField,
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 3, child: queryField),
            const SizedBox(width: 12),
            Expanded(child: roleField),
            const SizedBox(width: 12),
            Expanded(child: statusField),
          ],
        );
      },
    );
  }

  Widget _buildSummary(List<AdminUser> users) {
    final active = users.where((user) => user.isActive).length;
    final inactive = users.length - active;
    final admins = users.where((user) => user.role == 'admin').length;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _UserSummaryChip(label: 'Visible', value: '${users.length}'),
        _UserSummaryChip(label: 'Active', value: '$active'),
        _UserSummaryChip(label: 'Inactive', value: '$inactive'),
        _UserSummaryChip(label: 'Admins', value: '$admins'),
      ],
    );
  }

  Widget _buildMessage(BuildContext context, String message, {required bool error}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: (error ? colorScheme.error : colorScheme.primary)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: error ? colorScheme.error : colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFilterBar(),
        const SizedBox(height: 12),
        _buildSummary(users),
        if (_statusMessage != null) ...[
          const SizedBox(height: 12),
          _buildMessage(context, _statusMessage!, error: false),
        ],
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          _buildMessage(context, _errorMessage!, error: true),
        ],
        const SizedBox(height: 12),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (users.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No users match the current filters.'),
          )
        else
          ...users.map(
            (user) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _UserRow(
                user: user,
                isSaving: _savingUserId == user.id,
                onEdit: () => _editUser(user),
                onToggleActive: () => _toggleActive(user),
              ),
            ),
          ),
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.isSaving,
    required this.onEdit,
    required this.onToggleActive,
  });

  final AdminUser user;
  final bool isSaving;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: user.isActive
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  child: Text(
                    _initials(user.label),
                    style: TextStyle(
                      color: user.isActive
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              decoration: user.isActive
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(user.email),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(user.role)),
                Chip(label: Text(user.isActive ? 'active' : 'inactive')),
                if (user.isAdmin) const Chip(label: Text('admin access')),
                Chip(label: Text('Created ${_formatShortDate(user.createdAt)}')),
                Chip(label: Text('Updated ${_formatShortDate(user.updatedAt)}')),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: isSaving ? null : onEdit,
                  icon: isSaving
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.edit_outlined),
                  label: const Text('Edit user'),
                ),
                FilledButton.tonalIcon(
                  onPressed: isSaving ? null : onToggleActive,
                  icon: Icon(
                    user.isActive
                        ? Icons.person_off_outlined
                        : Icons.person_add_alt_1,
                  ),
                  label: Text(user.isActive ? 'Deactivate' : 'Activate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UserSummaryChip extends StatelessWidget {
  const _UserSummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label $value'));
  }
}

class _AdminUserDraft {
  const _AdminUserDraft({
    required this.displayName,
    required this.role,
    required this.isActive,
  });

  final String displayName;
  final String role;
  final bool isActive;
}

class _AdminUserEditorDialog extends StatefulWidget {
  const _AdminUserEditorDialog({required this.user});

  final AdminUser user;

  @override
  State<_AdminUserEditorDialog> createState() => _AdminUserEditorDialogState();
}

class _AdminUserEditorDialogState extends State<_AdminUserEditorDialog> {
  late final TextEditingController _displayNameController;
  late String _role;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _displayNameController =
        TextEditingController(text: widget.user.displayName ?? '');
    _role = widget.user.role;
    _isActive = widget.user.isActive;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit user'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.user.email),
            const SizedBox(height: 12),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _role,
              isExpanded: true,
              dropdownColor: kAppPanelRaised,
              borderRadius: kAppMenuBorderRadius,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                DropdownMenuItem(value: 'editor', child: Text('Editor')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _role = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              title: const Text('User is active'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _AdminUserDraft(
                displayName: _displayNameController.text,
                role: _role,
                isActive: _isActive,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

String _initials(String value) {
  final parts = value.split(RegExp(r'[\s@.]+'));
  return parts
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

String _formatShortDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}
