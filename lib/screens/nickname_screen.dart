import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../utils/app_colors.dart';
import '../widgets/primary_button.dart';
import 'main_screen.dart';

class NicknameScreen extends StatefulWidget {
  final String phone;

  const NicknameScreen({Key? key, required this.phone}) : super(key: key);

  @override
  _NicknameScreenState createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: AppColors.expense),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        '👋 ',
                        style: TextStyle(fontSize: 28),
                      ),
                      Expanded(
                        child: Text(
                          'What should we call you?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This name stays only on your device.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _nicknameController,
                      onChanged: (value) => setState(() {}),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Eg: Johnnnie',
                        hintStyle: const TextStyle(color: AppColors.textHint),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        suffixIcon: _nicknameController.text.isNotEmpty
                            ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final bool isNotEmpty = _nicknameController.text.isNotEmpty;
                      return PrimaryButton(
                        text: 'Continue',
                        isLoading: state is AuthLoading,
                        onPressed: isNotEmpty ? () {
                          context.read<AuthBloc>().add(CreateAccountRequested(
                                phone: widget.phone,
                                nickname: _nicknameController.text,
                              ));
                        } : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
