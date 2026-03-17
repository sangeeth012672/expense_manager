import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../utils/app_colors.dart';
import 'category_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.surface,
                child: Icon(Icons.person_rounded, size: 50, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String name = 'User';
                  if (state is AuthAuthenticated) {
                    // Assuming nickname is available or fetch from prefs
                  }
                  return Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              _buildSettingTile(Icons.sync_rounded, 'Cloud Sync', trailing: Switch(value: true, onChanged: (v){}, activeColor: AppColors.primary)),
              _buildSettingTile(
                Icons.category_rounded, 
                'Categories', 
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen()));
                },
              ),
              _buildSettingTile(Icons.notifications_rounded, 'Notifications', onTap: () {}),
              _buildSettingTile(Icons.security_rounded, 'Privacy Policy', onTap: () {}),
              const SizedBox(height: 32),
              _buildSettingTile(
                Icons.logout_rounded, 
                'Logout', 
                color: AppColors.expense,
                onTap: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, {Widget? trailing, VoidCallback? onTap, Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primary),
        title: Text(title, style: TextStyle(color: color ?? AppColors.textPrimary, fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
