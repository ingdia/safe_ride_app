import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_mock_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource);

  final AuthMockDatasource _datasource;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) => _datasource.login(email: email, password: password);

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) => _datasource.register(name: name, email: email, password: password);

  @override
  Future<void> forgotPassword({required String email}) =>
      _datasource.forgotPassword(email: email);
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(AuthMockDatasource()),
);
