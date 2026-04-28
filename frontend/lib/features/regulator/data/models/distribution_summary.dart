class DistributionSummary {
  const DistributionSummary({
    required this.totalTransactions,
    required this.totalLitersDistributed,
  });

  final int totalTransactions;
  final double totalLitersDistributed;

  factory DistributionSummary.fromJson(Map<String, dynamic> json) {
    return DistributionSummary(
      totalTransactions: json['total_transactions'] as int,
      totalLitersDistributed: (json['total_liters_distributed'] as num).toDouble(),
    );
  }
}
