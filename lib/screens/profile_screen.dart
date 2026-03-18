import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../utils/app_colors.dart';
import '../blocs/category_bloc.dart';
import '../blocs/category_event.dart';
import '../blocs/category_state.dart';
import '../blocs/sync_bloc.dart';
import '../blocs/sync_event.dart';
import '../blocs/sync_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile & Settings',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Nickname Section
                _buildSectionLabel('NICKNAME'),
                const SizedBox(height: 12),
                _buildNicknameCard(),
                
                const SizedBox(height: 32),
                
                // Alert Limit Section
                _buildSectionLabel('ALERT LIMIT (₹)'),
                const SizedBox(height: 12),
                _buildAlertLimitCard(),
                
                const SizedBox(height: 32),
                
                // Categories Section
                _buildSectionLabel('CATEGORIES'),
                const SizedBox(height: 12),
                _buildCategoriesCard(),
                
                const SizedBox(height: 32),
                
                // Cloud Sync Section
                _buildSectionLabel('CLOUD SYNC'),
                const SizedBox(height: 12),
                _buildCloudSyncCard(),
                
                const SizedBox(height: 32),
                
                // Logout Button
                _buildLogoutButton(),
                
                const SizedBox(height: 120), // Added padding for floating nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildNicknameCard() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String nickname = 'Naazley';
        if (state is AuthAuthenticated && state.nickname != null) {
          nickname = state.nickname!;
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF17171F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                nickname,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                ),
                child: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertLimitCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF17171F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Amount ( ₹ )',
                      hintStyle: TextStyle(color: AppColors.textHint),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  // TODO: Save limit
                },
                child: Container(
                  height: 54,
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4351FF), // Changed to Blue
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Set',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Current Limit: ₹1,000',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF17171F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _categoryController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'New category Name',
                      hintStyle: TextStyle(color: AppColors.textHint),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  if (_categoryController.text.isNotEmpty) {
                    context.read<CategoryBloc>().add(AddCategory(_categoryController.text));
                    _categoryController.clear();
                  }
                },
                child: Container(
                  height: 54,
                  width: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4351FF), // Changed to Blue
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoaded) {
                return Column(
                  children: state.categories.map((c) => _buildCategoryItem(c.name, c.id)).toList(),
                );
              }
              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, String id) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          GestureDetector(
            onTap: () {
              context.read<CategoryBloc>().add(DeleteCategory(id));
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C1616),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF421D1D)),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF5656), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudSyncCard() {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            context.read<SyncBloc>().add(StartSync());
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF17171F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider.withOpacity(0.5)),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF20295C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sync To Cloud',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state is SyncInProgress ? 'Syncing...' : 'Sync and update data to the backend',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 28),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF17171F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Log Out',
              style: TextStyle(color: Color(0xFFFF5656), fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: 12),
            Icon(Icons.power_settings_new_rounded, color: Color(0xFFFF5656), size: 20),
          ],
        ),
      ),
    );
  }
}
