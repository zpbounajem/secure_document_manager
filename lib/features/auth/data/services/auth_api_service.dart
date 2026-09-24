import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:secure_document_manager/features/auth/data/models/user_model.dart';

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

  Future<Map<String, dynamic>> login({
    required String idToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {
      return Map<String, dynamic>.from(
        data['user'],
      );
    }

    throw Exception(
      data['message'] ??
          'Failed to complete login.',
    );
  }

  Future<UserModel> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated Firebase user found.',
      );
    }

    final idToken = await user.getIdToken();

    if (idToken == null) {
      throw Exception(
        'Unable to get Firebase ID token.',
      );
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {
      return UserModel.fromJson(
        Map<String, dynamic>.from(
          data['user'],
        ),
      );
    }

    throw Exception(
      data['message'] ??
          'Failed to get current user.',
    );
  }
}