/// Request payload for POST /api/login
class LoginRequest {
  final String contact;
  final String password;
  final String fcmToken;

  const LoginRequest({
    required this.contact,
    required this.password,
    this.fcmToken = '',
  });

  Map<String, dynamic> toJson() => {
        'contact': contact,
        'password': password,
        'fcm_token': fcmToken,
      };
}

/// Request payload for POST /api/register
class RegisterRequest {
  final String name;
  final String email;
  final String countryCode;
  final String phone;
  final String password;
  final String timezone;
  final String deviceId;
  final String fcmToken;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.countryCode,
    required this.phone,
    required this.password,
    required this.timezone,
    required this.deviceId,
    required this.fcmToken,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'country_code': countryCode,
        'phone': phone,
        'password': password,
        'timezone': timezone,
        'device_id': deviceId,
        'fcm_token': fcmToken,
      };
}

/// Response payload from POST /api/login
/// Shape: { "user": { ... }, "token": "..." }
class LoginResponse {
  final String token;
  final UserData user;

  const LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String? ?? '',
      user: UserData.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}

/// Request payload for PUT /api/user/update-profile
class UpdateProfileRequest {
  final String? name;
  final String? email;
  final String? countryCode;
  final String? phone;
  final String? password;
  final String? timezone;
  final String? deviceId;
  final String? fcmToken;

  const UpdateProfileRequest({
    this.name,
    this.email,
    this.countryCode,
    this.phone,
    this.password,
    this.timezone,
    this.deviceId,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (email != null) map['email'] = email;
    if (countryCode != null) map['country_code'] = countryCode;
    if (phone != null) map['phone'] = phone;
    if (password != null) map['password'] = password;
    if (timezone != null) map['timezone'] = timezone;
    if (deviceId != null) map['device_id'] = deviceId;
    if (fcmToken != null) map['fcm_token'] = fcmToken;
    return map;
  }
}

/// Request payload for POST /api/user/change-password
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String passwordConfirmation;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
        'current_password': currentPassword,
        'new_password': newPassword,
        'password_confirmation': passwordConfirmation,
      };
}

/// Request payload for DELETE /api/user/delete-account
class DeleteAccountRequest {
  final String password;

  const DeleteAccountRequest({required this.password});

  Map<String, dynamic> toJson() => {
        'password': password,
      };
}

class UserData {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? countryCode;
  final String? timezone;
  final String? deviceId;
  final String? parish;
  final String? role;
  final String? createdAt;

  // Counts
  final int totalCount;
  final int todayCount;
  final int rosaryPrayedTotal;
  final int rosaryBorrowedTotal;
  final int rosaryAvailable;
  final int rosaryTodayPrayed;
  final int rosaryTodayBorrowed;
  final int rosaryTodayAvailable;
  final int chapelPrayedTotal;
  final int chapelBorrowedTotal;
  final int chapelAvailable;
  final int chapelTodayPrayed;
  final int chapelTodayBorrowed;
  final int chapelTodayAvailable;

  const UserData({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.countryCode,
    this.timezone,
    this.deviceId,
    this.parish,
    this.role,
    this.createdAt,
    this.totalCount = 0,
    this.todayCount = 0,
    this.rosaryPrayedTotal = 0,
    this.rosaryBorrowedTotal = 0,
    this.rosaryAvailable = 0,
    this.rosaryTodayPrayed = 0,
    this.rosaryTodayBorrowed = 0,
    this.rosaryTodayAvailable = 0,
    this.chapelPrayedTotal = 0,
    this.chapelBorrowedTotal = 0,
    this.chapelAvailable = 0,
    this.chapelTodayPrayed = 0,
    this.chapelTodayBorrowed = 0,
    this.chapelTodayAvailable = 0,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      countryCode: json['country_code'] as String?,
      timezone: json['timezone'] as String?,
      deviceId: json['device_id'] as String?,
      parish: json['parish'] as String?,
      role: json['role'] as String?,
      createdAt: json['created_at'] as String?,
      totalCount: json['total_count'] as int? ?? 0,
      todayCount: json['today_count'] as int? ?? 0,
      rosaryPrayedTotal: json['rosary_prayed_total'] as int? ?? 0,
      rosaryBorrowedTotal: json['rosary_borrowed_total'] as int? ?? 0,
      rosaryAvailable: json['rosary_available'] as int? ?? 0,
      rosaryTodayPrayed: json['rosary_today_prayed'] as int? ?? 0,
      rosaryTodayBorrowed: json['rosary_today_borrowed'] as int? ?? 0,
      rosaryTodayAvailable: json['rosary_today_available'] as int? ?? 0,
      chapelPrayedTotal: json['chapel_prayed_total'] as int? ?? 0,
      chapelBorrowedTotal: json['chapel_borrowed_total'] as int? ?? 0,
      chapelAvailable: json['chapel_available'] as int? ?? 0,
      chapelTodayPrayed: json['chapel_today_prayed'] as int? ?? 0,
      chapelTodayBorrowed: json['chapel_today_borrowed'] as int? ?? 0,
      chapelTodayAvailable: json['chapel_today_available'] as int? ?? 0,
    );
  }
}
