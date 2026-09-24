import 'package:flutter/foundation.dart';
import 'package:secure_document_manager/features/auth/data/models/user_model.dart';
import 'package:secure_document_manager/features/auth/data/services/auth_api_service.dart';


// this provider is like the manager of the current user 

class UserProvider extends ChangeNotifier {
  final AuthApiService _authApiService;

  UserProvider({
    AuthApiService? authApiService,
  }) : _authApiService =
            authApiService ?? AuthApiService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasUser => _user != null;

 Future<void> loadUser() async {
  _isLoading = true;
  _error = null;

  notifyListeners();

  try {
    _user = await _authApiService.getCurrentUser();
  } catch (e) {
    _error = e.toString();

    debugPrint('LOAD USER ERROR: $_error');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
}