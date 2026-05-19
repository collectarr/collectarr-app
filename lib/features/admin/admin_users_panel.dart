import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminUsersPanel extends ConsumerStatefulWidget {
  const AdminUsersPanel({super.key});

  @override
  ConsumerState<AdminUsersPanel> createState() => _AdminUsersPanelState();
}

class _AdminUsersPanelState extends ConsumerState<AdminUsersPanel> {
  var _users = const <Map<String, dynamic>>[];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final users = await api.adminListUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateRole(Map<String, dynamic> user, String newRole) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.adminUpdateUser(user['id'] as String, role: newRole);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated role for ${user['email']}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _toggleActive(Map<String, dynamic> user) async {
    final isActive = user['is_active'] as bool? ?? true;
    try {
      final api = ref.read(apiClientProvider);
      await api.adminUpdateUser(user['id'] as String, isActive: !isActive);
      await _loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: colorScheme.error),
            ),
          )
        else if (_users.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No users found'),
          )
        else
          ..._users.map((user) => _UserRow(
                user: user,
                onRoleChanged: (role) => _updateRole(user, role),
                onToggleActive: () => _toggleActive(user),
              )),
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.onRoleChanged,
    required this.onToggleActive,
  });

  final Map<String, dynamic> user;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final email = user['email'] as String? ?? '';
    final displayName = user['display_name'] as String?;
    final role = user['role'] as String? ?? 'viewer';
    final isActive = user['is_active'] as bool? ?? true;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isActive
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        child: Text(
          _initials(displayName ?? email),
          style: TextStyle(
            color: isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      title: Text(
        displayName ?? email,
        style: TextStyle(
          decoration: isActive ? null : TextDecoration.lineThrough,
        ),
      ),
      subtitle: Text(email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: role,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
              DropdownMenuItem(value: 'editor', child: Text('Editor')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
            ],
            onChanged: (value) {
              if (value != null && value != role) {
                onRoleChanged(value);
              }
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: isActive ? 'Deactivate' : 'Activate',
            onPressed: onToggleActive,
            icon: Icon(
              isActive ? Icons.person : Icons.person_off,
              color: isActive ? null : colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value.split(RegExp(r'[\s@.]+'));
    return parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
  }
}
