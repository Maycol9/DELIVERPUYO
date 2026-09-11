import '../models/auth_session.dart';
import '../services/api_service.dart';

class AuthRepository {
  const AuthRepository(this._apiService);

  final ApiService _apiService;

  Future<AuthSession> login({required String email, required String password}) {
    return _apiService.login(email: email, password: password);
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _apiService.register(name: name, email: email, password: password);
  }
}
