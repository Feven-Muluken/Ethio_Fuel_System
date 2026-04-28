class StationTransactionRequest {
  const StationTransactionRequest({
    required this.vehicleId,
    required this.stationId,
    required this.liters,
  });

  final int vehicleId;
  final int stationId;
  final double liters;

  Map<String, dynamic> toJson() {
    return {
      'vehicle': vehicleId,
      'station': stationId,
      'liters': liters,
    };
  }
}
