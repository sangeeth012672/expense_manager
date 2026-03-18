part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthFtpSent extends AuthState {
   final String phone;

   const AuthFtpSent({required this.phone});

   @override
   List<Object> get props => [phone];
}

class AuthOtpSent extends AuthState {
  final String phone;
  final bool? userExists;
  final String? token;
  final String? nickname;

  const AuthOtpSent({
    required this.phone,
    this.userExists,
    this.token,
    this.nickname,
  });

  @override
  List<Object?> get props => [phone, userExists, token, nickname];
}

class AuthNeedsNickname extends AuthState {
  final String phone;

  const AuthNeedsNickname({required this.phone});

  @override
  List<Object> get props => [phone];
}

class AuthAuthenticated extends AuthState {
  final String token;
  final String? nickname;
  final String? phone;

  const AuthAuthenticated({required this.token, this.nickname, this.phone});

  @override
  List<Object?> get props => [token, nickname, phone];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String error;

  const AuthError({required this.error});

  @override
  List<Object> get props => [error];
}
