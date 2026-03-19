part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class SendOtpRequested extends AuthEvent {
  final String phone;

  const SendOtpRequested({required this.phone});

  @override
  List<Object> get props => [phone];
}

class VerifyOtpRequested extends AuthEvent {
  final String phone;
  final String otp;
  final bool? userExists;
  final String? token;
  final String? nickname;

  const VerifyOtpRequested({
    required this.phone,
    required this.otp,
    this.userExists,
    this.token,
    this.nickname,
  });

  @override
  List<Object> get props => [phone, otp];
}

class CreateAccountRequested extends AuthEvent {
  final String phone;
  final String nickname;

  const CreateAccountRequested({required this.phone, required this.nickname});

  @override
  List<Object> get props => [phone, nickname];
}

class LogoutRequested extends AuthEvent {}

class UpdateNicknameRequested extends AuthEvent {
  final String nickname;

  const UpdateNicknameRequested({required this.nickname});

  @override
  List<Object> get props => [nickname];
}
