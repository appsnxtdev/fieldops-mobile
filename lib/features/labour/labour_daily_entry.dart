class LabourDailyEntry {
  final String labourTypeId;
  final String labourTypeName;
  final double ratePerDay;
  final int count;
  final double amount;

  LabourDailyEntry({
    required this.labourTypeId,
    required this.labourTypeName,
    required this.ratePerDay,
    required this.count,
    required this.amount,
  });

  factory LabourDailyEntry.fromJson(Map<String, dynamic> json) {
    // Parse count - handle both int and String
    int parseCount(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    return LabourDailyEntry(
      labourTypeId: json['labour_type_id']?.toString() ?? '',
      labourTypeName: json['labour_type_name']?.toString() ?? '',
      ratePerDay: (json['rate_per_day'] as num?)?.toDouble() ?? 0.0,
      count: parseCount(json['count']),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'labour_type_id': labourTypeId,
      'labour_type_name': labourTypeName,
      'rate_per_day': ratePerDay,
      'count': count,
      'amount': amount,
    };
  }
}
