class LabourType {
  final String id;
  final String tenantId;
  final String name;
  final double ratePerDay;
  final DateTime? createdAt;

  LabourType({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.ratePerDay,
    this.createdAt,
  });

  factory LabourType.fromJson(Map<String, dynamic> json) {
    return LabourType(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenant_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      ratePerDay: (json['rate_per_day'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']?.toString() ?? '')
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'rate_per_day': ratePerDay,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
