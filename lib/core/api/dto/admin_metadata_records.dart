part of 'admin_metadata.dart';

class AdminMetadataProposalSummary {
  const AdminMetadataProposalSummary({
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.total,
  });

  final int pending;
  final int approved;
  final int rejected;
  final int total;

  factory AdminMetadataProposalSummary.fromJson(Map<String, dynamic> json) {
    return AdminMetadataProposalSummary(
      pending: json['pending'] as int? ?? 0,
      approved: json['approved'] as int? ?? 0,
      rejected: json['rejected'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }
}

class AdminMetadataProposal {
  const AdminMetadataProposal({
    required this.id,
    required this.kind,
    required this.catalogItem,
    required this.status,
    this.reviewNote,
    this.createdAt,
  });

  final String id;
  final String kind;
  final Map<String, dynamic> catalogItem;
  final String status;
  final String? reviewNote;
  final DateTime? createdAt;

  String get displayTitle {
    final rawTitle = catalogItem['title'] ?? catalogItem['name'];
    final title = rawTitle is String ? rawTitle.trim() : null;
    if (title != null && title.isNotEmpty) {
      return title;
    }
    return 'Untitled ${kind.toUpperCase()} proposal';
  }

  bool get isPending => status == 'pending';

  factory AdminMetadataProposal.fromJson(Map<String, dynamic> json) {
    final rawItem = json['catalog_item'];
    return AdminMetadataProposal(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      catalogItem: rawItem is Map<String, dynamic>
          ? Map<String, dynamic>.unmodifiable(rawItem)
          : const <String, dynamic>{},
      status: json['status']?.toString() ?? 'pending',
      reviewNote: json['review_note'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.email,
    required this.isActive,
    required this.isAdmin,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;
  final bool isActive;
  final bool isAdmin;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get label {
    final value = displayName?.trim();
    return value == null || value.isEmpty ? email : value;
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['display_name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isAdmin: json['is_admin'] as bool? ?? false,
      role: json['role']?.toString() ?? 'viewer',
      createdAt: _adminDateTimeFromJson(json['created_at']),
      updatedAt: _adminDateTimeFromJson(json['updated_at']),
    );
  }
}
