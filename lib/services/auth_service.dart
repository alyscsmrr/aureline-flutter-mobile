import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    return ApiService.post(
      '/api/auth/login',
      {
        'email': email,
        'password': password,
      },
    );
  }

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> profile,
    String password,
    String verificationToken,
  ) async {
    return ApiService.post(
      '/api/auth/register',
      {
        'profile': profile,
        'password': password,
        'verificationToken': verificationToken,
      },
    );
  }

  static Future<bool> checkEmailAvailable(String email) async {
    final response = await ApiService.getWithQuery(
      '/api/auth/check-email',
      {'email': email},
    );
    return response['available'] == true;
  }

  static Future<bool> checkPhoneAvailable(String phone) async {
    final response = await ApiService.getWithQuery(
      '/api/auth/check-phone',
      {'phone': phone},
    );
    return response['available'] == true;
  }

  static Future<bool> checkPassportAvailable(String passport) async {
    final response = await ApiService.getWithQuery(
      '/api/auth/check-passport',
      {'passport': passport},
    );
    return response['available'] == true;
  }

  static Future<void> sendOtp(String email, String purpose) async {
    await ApiService.post(
      '/api/otp/send',
      {
        'email': email,
        'purpose': purpose,
      },
    );
  }

  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
  ) async {
    return ApiService.post(
      '/api/otp/verify',
      {
        'email': email,
        'otp': otp,
      },
    );
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    return ApiService.get(
      '/api/profile',
      token: token,
    );
  }

  static Future<List<dynamic>> getReservations(String token) async {
    final response = await ApiService.getDynamic(
      '/api/reservations',
      token: token,
    );
    // The API returns a list directly
    if (response is List) {
      return response as List<dynamic>;
    }
    // If it's wrapped in an object, try to extract the list
    if (response is Map) {
      if (response.containsKey('reservations')) {
        return response['reservations'] as List<dynamic>;
      }
      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is List) return data as List<dynamic>;
      }
    }
    return [];
  }

  static Future<List<dynamic>> getRooms() async {
    final response = await ApiService.getDynamic('/api/rooms');
    // The API returns a list directly
    if (response is List) {
      return response as List<dynamic>;
    }
    // If it's wrapped in an object, try to extract the list
    if (response is Map) {
      if (response.containsKey('rooms')) {
        return response['rooms'] as List<dynamic>;
      }
      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is List) return data as List<dynamic>;
      }
    }
    return [];
  }

  static Future<List<dynamic>> searchRooms({
    required String checkIn,
    required String checkOut,
    required int guests,
    String? type,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'checkIn': checkIn,
      'checkOut': checkOut,
      'guests': guests.toString(),
    };
    if (type != null && type != 'All rooms') {
      queryParams['type'] = type;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await ApiService.getDynamic('/api/rooms?$queryString', token: token);
    // The API returns a list directly
    if (response is List) {
      return response as List<dynamic>;
    }
    // If it's wrapped in an object, try to extract the list
    if (response is Map) {
      if (response.containsKey('rooms')) {
        return response['rooms'] as List<dynamic>;
      }
      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is List) return data as List<dynamic>;
      }
    }
    return [];
  }

  static Future<Map<String, dynamic>> createReservation({
    required String roomId,
    required String checkIn,
    required String checkOut,
    required int guests,
    required String token,
  }) async {
    return ApiService.post(
      '/api/reservations',
      {
        'roomId': roomId,
        'checkIn': checkIn,
        'checkOut': checkOut,
        'guests': guests,
      },
      token: token,
    );
  }

  static Future<Map<String, dynamic>> updateReservationStatus({
    required String bookingId,
    required String status,
    required String token,
  }) async {
    return ApiService.patch(
      '/api/reservations/$bookingId/status',
      {'status': status},
      token: token,
    );
  }

  static Future<void> verifyPassword({
    required String currentPassword,
    required String token,
  }) async {
    await ApiService.post(
      '/api/auth/verify-password',
      {'currentPassword': currentPassword},
      token: token,
    );
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String token,
  }) async {
    await ApiService.put(
      '/api/auth/password',
      {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      token: token,
    );
  }

  static Future<Map<String, dynamic>> updateProfile({
    required Map<String, dynamic> data,
    required String token,
  }) async {
    return ApiService.patch(
      '/api/profile',
      data,
      token: token,
    );
  }
}
