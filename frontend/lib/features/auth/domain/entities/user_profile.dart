class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.nationalId,
    required this.isStationOperator,
    required this.isRegulator,
  });

  final int id;
  final String username;
  final String nationalId;
  final bool isStationOperator;
  final bool isRegulator;
}
