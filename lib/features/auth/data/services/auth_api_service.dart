import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthApiService {
  static const String baseUrl =
      'http://127.0.0.1:3000/api';

  Future<void> createUser({
    required String idToken,
    required String firstName,
    required String lastName,
    required String displayName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'displayName': displayName,
        'profileImage': null,
      }),
    );

    final data = jsonDecode(response.body);

    if ((response.statusCode == 200 ||
            response.statusCode == 201) &&
        data['success'] == true) {
      return;
    }

    throw Exception(
      data['message'] ??
          'Failed to create user profile.',
    );
  }

  Future<DateTime> sendVerificationCode({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verification/send'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {
      return DateTime.parse(
        data['expiresAt'],
      );
    }

    throw Exception(
      data['message'] ??
          'Failed to send verification code.',
    );
  }

  Future<DateTime> resendVerificationCode({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verification/resend'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {
      return DateTime.parse(
        data['expiresAt'],
      );
    }

    throw Exception(
      data['message'] ??
          'Failed to resend verification code.',
    );
  }

  Future<bool> verifyEmailCode({
    required String email,
    required String verificationCode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verification/verify'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'verificationCode': verificationCode,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {
      return true;
    }

    throw Exception(
      data['message'] ??
          'Invalid verification code.',
    );
  }
}