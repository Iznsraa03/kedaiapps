class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String email;
  final String fullName;
  final String password;
  final String? nra; // Nomor Registrasi Anggota (optional)

  const RegisterRequest({
    required this.email,
    required this.fullName,
    required this.password,
    this.nra,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email,
      'full_name': fullName,
      'password': password,
    };
    // Only include nra if provided (backend accepts null)
    if (nra != null && nra!.isNotEmpty) map['nra'] = nra;
    return map;
  }
}

/// Model yang merepresentasikan data user yang sedang login.
class UserModel {
  final int id;
  final String fullName;
  final String email;
  final int roleId;
  final String? nra;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roleId,
    this.nra,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      roleId: json['role_id'] as int? ?? 0,
      nra: json['nra'] as String?,
    );
  }

  /// Mengembalikan inisial dari nama lengkap (maks. 2 karakter).
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class AuthResponse {
  final String? token;
  final String? message;
  final bool success;
  final Map<String, dynamic>? data;
  final UserModel? user;

  const AuthResponse({
    this.token,
    this.message,
    required this.success,
    this.data,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Parse user object jika ada di response (dari endpoint /login)
    UserModel? parsedUser;
    if (json['user'] is Map<String, dynamic>) {
      parsedUser = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    }

    return AuthResponse(
      token: json['token'] as String?,
      message: json['message'] as String?,
      success: true,
      data: json,
      user: parsedUser,
    );
  }

  factory AuthResponse.error(String message) {
    return AuthResponse(success: false, message: message);
  }
}
