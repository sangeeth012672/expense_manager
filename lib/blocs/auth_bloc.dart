import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<CreateAccountRequested>(_onCreateAccountRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<UpdateNicknameRequested>(_onUpdateNicknameRequested);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await authRepository.getToken();
      final nickname = await authRepository.getNickname();
      if (token != null) {
        emit(AuthAuthenticated(token: token, nickname: nickname));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSendOtpRequested(SendOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.sendOtp(event.phone);
      // For testing, user_exists, nickname, token, and otp are returned
      emit(AuthOtpSent(
        phone: event.phone, 
        userExists: response.userExists, 
        token: response.token, 
        nickname: response.nickname,
        otp: response.otp,
      ));
    } catch (e) {
      emit(AuthError(error: e.toString()));
    }
  }

  Future<void> _onVerifyOtpRequested(VerifyOtpRequested event, Emitter<AuthState> emit) async {
    // In a real app we would call an API, but the challenge says:
    // "User enters OTP (displayed on-screen for testing)"
    // and based on user_exists:
    // If true, we already have token & nickname from the first step.
    if (event.userExists == true) {
      await authRepository.saveTokenAndNickname(event.token ?? '', event.nickname ?? '', event.phone);
      emit(AuthAuthenticated(token: event.token ?? '', nickname: event.nickname));
    } else {
      emit(AuthNeedsNickname(phone: event.phone));
    }
  }

  Future<void> _onCreateAccountRequested(CreateAccountRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.createAccount(event.phone, event.nickname);
      await authRepository.saveTokenAndNickname(response.token ?? '', event.nickname, event.phone);
      emit(AuthAuthenticated(token: response.token ?? '', nickname: event.nickname));
    } catch (e) {
      emit(AuthError(error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onUpdateNicknameRequested(UpdateNicknameRequested event, Emitter<AuthState> emit) async {
    try {
      final token = await authRepository.getToken();
      await authRepository.updateNickname(event.nickname);
      emit(AuthAuthenticated(token: token ?? '', nickname: event.nickname));
    } catch (e) {
      emit(AuthError(error: e.toString()));
    }
  }
}
