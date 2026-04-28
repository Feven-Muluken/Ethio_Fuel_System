import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ApiClient.defaultClient()),
);

enum UserRole { buyer, station, regulator }

class AuthState {
  const AuthState({
    this.initialized = false,
    this.loading = false,
    this.accessToken,
    this.refreshToken,
    this.role = UserRole.buyer,
    this.errorMessage,
  });

  final bool initialized;
  final bool loading;
  final String? accessToken;
  final String? refreshToken;
  final UserRole role;
  final String? errorMessage;

  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;

  AuthState copyWith({
    bool? initialized,
    bool? loading,
    String? accessToken,
    String? refreshToken,
    UserRole? role,
    String? errorMessage,
    bool clearError = false,
    bool clearTokens = false,
  }) {
    return AuthState(
      initialized: initialized ?? this.initialized,
      loading: loading ?? this.loading,
      accessToken: clearTokens ? null : (accessToken ?? this.accessToken),
      refreshToken: clearTokens ? null : (refreshToken ?? this.refreshToken),
      role: role ?? this.role,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._client) : super(const AuthState()) {
    unawaited(initialize());
  }

  final ApiClient _client;
  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _buyerProfileKey = 'buyer_profile';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString(_accessTokenKey);
    final refresh = prefs.getString(_refreshTokenKey);

    if (access == null || refresh == null) {
      state = state.copyWith(initialized: true, clearTokens: true, clearError: true);
      return;
    }

    _client.setAccessToken(access);
    try {
      final meResponse = await _client.fetchMe();
      final role = _resolveRoleFromMe(meResponse.data as Map<String, dynamic>);
      state = state.copyWith(
        initialized: true,
        accessToken: access,
        refreshToken: refresh,
        role: role,
        loading: false,
        clearError: true,
      );
    } catch (_) {
      await _clearSession();
      state = state.copyWith(
        initialized: true,
        loading: false,
        clearTokens: true,
        clearError: true,
      );
    }
  }

  Future<void> login({required String username, required String password}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final tokenResponse = await _client.login(username: username, password: password);
      final tokenData = tokenResponse.data as Map<String, dynamic>;
      final access = tokenData['access'] as String;
      final refresh = tokenData['refresh'] as String;

      _client.setAccessToken(access);
      final meResponse = await _client.fetchMe();
      final role = _resolveRoleFromMe(meResponse.data as Map<String, dynamic>);
      await _persistSession(access: access, refresh: refresh);

      state = state.copyWith(
        loading: false,
        accessToken: access,
        refreshToken: refresh,
        role: role,
        initialized: true,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error.toString(),
        clearTokens: true,
      );
    }
  }

  Future<void> register({
    required String username,
    required String nationalId,
    required String phoneNumber,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final isStation = role == UserRole.station;
      final isRegulator = role == UserRole.regulator;
      final response = await _client.register(
        username: username,
        nationalId: nationalId,
        phoneNumber: phoneNumber,
        password: password,
        isStationOperator: isStation,
        isRegulator: isRegulator,
      );

      final data = response.data as Map<String, dynamic>;
      final access = data['access'] as String;
      final refresh = data['refresh'] as String;

      _client.setAccessToken(access);
      await _persistSession(access: access, refresh: refresh);

      state = state.copyWith(
        loading: false,
        accessToken: access,
        refreshToken: refresh,
        role: role,
        initialized: true,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error.toString(),
        clearTokens: true,
      );
    }
  }

  Future<void> registerBuyer({
    required String nationalId,
    required String phoneNumber,
    required String? email,
    required String licensePlate,
  }) async {
    final temporaryPassword = 'Pending#${DateTime.now().millisecondsSinceEpoch}';
    // Backend currently authenticates with username/password, so national ID is used as username.
    await register(
      username: nationalId,
      nationalId: nationalId,
      phoneNumber: phoneNumber,
      password: temporaryPassword,
      role: UserRole.buyer,
    );

    if (state.isAuthenticated) {
      await _persistBuyerProfile(
        BuyerProfile(
          nationalId: nationalId,
          phoneNumber: phoneNumber,
          email: email,
          licensePlate: licensePlate,
          verificationStatus: BuyerVerificationStatus.pending,
          rejectionReason: null,
          approvalNotificationSent: false,
          pinHash: null,
          pinSetupCompleted: false,
        ),
      );
      // Initial registration should remain in pending verification without
      // active user session until approval + PIN setup is completed.
      await _clearSession();
      state = state.copyWith(
        initialized: true,
        loading: false,
        clearTokens: true,
        clearError: true,
      );
    }
  }

  Future<void> loginBuyer({
    required String nationalId,
    required String licensePlate,
    required String pin,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final profile = await getBuyerProfile();
      if (profile == null) {
        state = state.copyWith(
          loading: false,
          errorMessage: 'No buyer registration found. Please register first.',
        );
        return;
      }

      if (profile.nationalId != nationalId || profile.licensePlate.toUpperCase() != licensePlate.toUpperCase()) {
        state = state.copyWith(
          loading: false,
          errorMessage: 'National ID or license plate does not match your registration.',
        );
        return;
      }

      if (profile.verificationStatus == BuyerVerificationStatus.rejected) {
        state = state.copyWith(
          loading: false,
          errorMessage: profile.rejectionReason == null
              ? 'Your registration request was rejected.'
              : 'Registration rejected: ${profile.rejectionReason}',
        );
        return;
      }

      if (profile.verificationStatus != BuyerVerificationStatus.approved) {
        state = state.copyWith(
          loading: false,
          errorMessage: 'Your registration is still pending verification.',
        );
        return;
      }

      if (!profile.pinSetupCompleted || profile.pinHash == null) {
        state = state.copyWith(
          loading: false,
          errorMessage: 'Please complete PIN setup before login.',
        );
        return;
      }

      if (_hashPin(pin) != profile.pinHash) {
        state = state.copyWith(
          loading: false,
          errorMessage: 'Invalid PIN. Please try again.',
        );
        return;
      }

      await login(username: nationalId, password: pin);
    } catch (error) {
      state = state.copyWith(loading: false, errorMessage: error.toString());
    }
  }

  Future<BuyerProfile?> getBuyerProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_buyerProfileKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return BuyerProfile.fromJson(data);
  }

  Future<void> approveBuyerRegistration() async {
    await setBuyerVerificationStatus(status: BuyerVerificationStatus.approved);
  }

  Future<void> rejectBuyerRegistration({required String reason}) async {
    await setBuyerVerificationStatus(
      status: BuyerVerificationStatus.rejected,
      reason: reason,
    );
  }

  Future<void> setBuyerVerificationStatus({
    required BuyerVerificationStatus status,
    String? reason,
  }) async {
    final profile = await getBuyerProfile();
    if (profile == null) {
      return;
    }
    await _persistBuyerProfile(
      profile.copyWith(
        verificationStatus: status,
        rejectionReason: status == BuyerVerificationStatus.rejected ? reason : null,
        clearRejectionReason: status != BuyerVerificationStatus.rejected,
        approvalNotificationSent: status == BuyerVerificationStatus.approved,
      ),
    );
  }

  Future<String?> setupBuyerPin({
    required String nationalId,
    required String licensePlate,
    required String pin,
  }) async {
    final profile = await getBuyerProfile();
    if (profile == null) {
      return 'No registration found. Please register first.';
    }
    if (profile.nationalId != nationalId || profile.licensePlate.toUpperCase() != licensePlate.toUpperCase()) {
      return 'National ID or license plate does not match your approved registration.';
    }
    if (profile.verificationStatus != BuyerVerificationStatus.approved) {
      return 'PIN setup is available only after verification approval.';
    }

    await _persistBuyerProfile(
      profile.copyWith(
        pinHash: _hashPin(pin),
        pinSetupCompleted: true,
      ),
    );
    return null;
  }

  Future<void> logout() async {
    await _clearSession();
    state = state.copyWith(clearTokens: true, clearError: true, role: UserRole.buyer, initialized: true);
  }

  String routeForRole(UserRole role) {
    switch (role) {
      case UserRole.station:
        return '/station';
      case UserRole.regulator:
        return '/regulator';
      case UserRole.buyer:
        return '/buyer';
    }
  }

  UserRole _resolveRoleFromMe(Map<String, dynamic> meData) {
    final isRegulator = meData['is_regulator'] == true;
    final isStationOperator = meData['is_station_operator'] == true;
    if (isRegulator) {
      return UserRole.regulator;
    }
    if (isStationOperator) {
      return UserRole.station;
    }
    return UserRole.buyer;
  }

  Future<void> _persistSession({required String access, required String refresh}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, access);
    await prefs.setString(_refreshTokenKey, refresh);
  }

  Future<void> _clearSession() async {
    _client.clearAccessToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  Future<void> _persistBuyerProfile(BuyerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_buyerProfileKey, jsonEncode(profile.toJson()));
  }

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }
}

enum BuyerVerificationStatus { pending, approved, rejected }

class BuyerProfile {
  const BuyerProfile({
    required this.nationalId,
    required this.phoneNumber,
    required this.email,
    required this.licensePlate,
    required this.verificationStatus,
    required this.rejectionReason,
    required this.approvalNotificationSent,
    required this.pinHash,
    required this.pinSetupCompleted,
  });

  final String nationalId;
  final String phoneNumber;
  final String? email;
  final String licensePlate;
  final BuyerVerificationStatus verificationStatus;
  final String? rejectionReason;
  final bool approvalNotificationSent;
  final String? pinHash;
  final bool pinSetupCompleted;

  bool get approved => verificationStatus == BuyerVerificationStatus.approved;

  BuyerProfile copyWith({
    String? nationalId,
    String? phoneNumber,
    String? email,
    String? licensePlate,
    BuyerVerificationStatus? verificationStatus,
    String? rejectionReason,
    bool? approvalNotificationSent,
    String? pinHash,
    bool? pinSetupCompleted,
    bool clearRejectionReason = false,
  }) {
    return BuyerProfile(
      nationalId: nationalId ?? this.nationalId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      licensePlate: licensePlate ?? this.licensePlate,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rejectionReason: clearRejectionReason ? null : (rejectionReason ?? this.rejectionReason),
      approvalNotificationSent: approvalNotificationSent ?? this.approvalNotificationSent,
      pinHash: pinHash ?? this.pinHash,
      pinSetupCompleted: pinSetupCompleted ?? this.pinSetupCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'national_id': nationalId,
      'phone_number': phoneNumber,
      'email': email,
      'license_plate': licensePlate,
      'verification_status': verificationStatus.name,
      'rejection_reason': rejectionReason,
      'approval_notification_sent': approvalNotificationSent,
      'pin_hash': pinHash,
      'pin_setup_completed': pinSetupCompleted,
    };
  }

  factory BuyerProfile.fromJson(Map<String, dynamic> json) {
    final status = json['verification_status'] as String?;
    final parsedStatus = BuyerVerificationStatus.values.where((e) => e.name == status).toList();
    return BuyerProfile(
      nationalId: json['national_id'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      licensePlate: json['license_plate'] as String,
      verificationStatus: parsedStatus.isNotEmpty
          ? parsedStatus.first
          : ((json['approved'] == true) ? BuyerVerificationStatus.approved : BuyerVerificationStatus.pending),
      rejectionReason: json['rejection_reason'] as String?,
      approvalNotificationSent: json['approval_notification_sent'] == true,
      pinHash: json['pin_hash'] as String?,
      pinSetupCompleted: json['pin_setup_completed'] == true,
    );
  }
}
