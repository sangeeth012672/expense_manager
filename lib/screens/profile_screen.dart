import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../utils/app_colors.dart';
import '../blocs/category_bloc.dart';
import '../blocs/category_event.dart';
import '../blocs/category_state.dart';
import '../repositories/settings_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  final SettingsRepository _settingsRepository = SettingsRepository();
  double _currentLimit = 1000.0;
  bool _reminderEnabled = false;
  String _reminderTime = '09:00 AM';
  bool _isEditingNickname = false;
  final TextEditingController _nicknameController = TextEditingController();
  bool _cloudSyncEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final limit = await _settingsRepository.getBudgetLimit();
    final enabled = await _settingsRepository.getReminderEnabled();
    final timeRaw = await _settingsRepository.getReminderTime();
    final cloudSync = await _settingsRepository.getCloudSyncEnabled();
    
    // Format HH:mm to HH:mm AM/PM for display
    String formattedTime = timeRaw;
    try {
      final parts = timeRaw.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(0, 0, 0, hour, minute);
      formattedTime = TimeOfDay.fromDateTime(dt).format(context);
    } catch (_) {}

    setState(() {
      _currentLimit = limit;
      _limitController.text = limit.toInt().toString();
      _reminderEnabled = enabled;
      _reminderTime = formattedTime;
      _cloudSyncEnabled = cloudSync;
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _limitController.dispose();
    _nicknameController.dispose();
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
                _buildSectionLabel('MONTHLY BUDGET LIMIT'),
                const SizedBox(height: 12),
                _buildAlertLimitCard(),
                
                const SizedBox(height: 32),
                
                // Daily Timer Section
                _buildSectionLabel('DAILY TIMER'),
                const SizedBox(height: 12),
                _buildDailyTimerCard(),
                
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
    return Row(
      children: [
        const Icon(Icons.auto_awesome_rounded, color: Color(0xFF9E8DF0), size: 14),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9E8DF0),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildNicknameCard() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && !_isEditingNickname) {
           _nicknameController.text = state.nickname ?? '';
        }
      },
      builder: (context, state) {
        String nickname = 'Naazley';
        if (state is AuthAuthenticated && state.nickname != null) {
          nickname = state.nickname!;
        }

        if (!_isEditingNickname) {
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
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEditingNickname = true;
                      _nicknameController.text = nickname;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black, // Dark box like screenshot
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          );
        }

        // Editing State
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF17171F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nicknameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Nickname',
                          hintStyle: TextStyle(color: AppColors.textHint),
                        ),
                        autofocus: true,
                      ),
                    ),
                    const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF2FB73C), size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nicknameController.text.isNotEmpty) {
                      context.read<AuthBloc>().add(UpdateNicknameRequested(nickname: _nicknameController.text));
                      setState(() {
                         _isEditingNickname = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4351FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertLimitCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF17171F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MONTHLY EXPENSE LIMIT (₹)',
            style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      hintText: 'Enter Amount',
                      hintStyle: TextStyle(color: AppColors.textHint),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: const Color(0xFF7B66FF), // New purple/blue from screenshot
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final newLimit = double.tryParse(_limitController.text);
                    if (newLimit != null) {
                      await _settingsRepository.setBudgetLimit(newLimit);
                      setState(() {
                        _currentLimit = newLimit;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Budget limit updated!')),
                      );
                      FocusScope.of(context).unfocus();
                    }
                  },
                  child: Container(
                    height: 54,
                    width: 70,
                    alignment: Alignment.center,
                    child: const Text(
                      'Set',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Current limit: ₹${_currentLimit.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
            style: const TextStyle(color: Colors.white38, fontSize: 13),
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
              Material(
                color: const Color(0xFF4351FF),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (_categoryController.text.isNotEmpty) {
                      context.read<CategoryBloc>().add(AddCategory(_categoryController.text));
                      _categoryController.clear();
                      FocusScope.of(context).unfocus();
                    }
                  },
                  child: Container(
                    height: 54,
                    width: 60,
                    alignment: Alignment.center,
                    child: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
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
          Material(
            color: const Color(0xFF2C1616),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                context.read<CategoryBloc>().add(DeleteCategory(id));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF421D1D)),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF5656), size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudSyncCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF17171F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sync To Cloud',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Backup data when online',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              Switch(
                value: _cloudSyncEnabled,
                onChanged: (value) async {
                  await _settingsRepository.setCloudSyncEnabled(value);
                  setState(() {
                    _cloudSyncEnabled = value;
                  });
                },
                activeColor: const Color(0xFF4351FF),
                activeTrackColor: const Color(0xFF4351FF).withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2FB73C),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                if (_cloudSyncEnabled) ...[
                  const Icon(Icons.check_rounded, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  const Text(
                    'Connected & syncing',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ] else
                   const Text(
                    'Connected (sync disabled)',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your data syncs automatically when online. Works\noffline too — changes sync when you reconnect.',
            style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTimerCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF17171F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Reminder',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Get a daily nudge to log\nexpenses',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              Switch(
                value: _reminderEnabled,
                onChanged: (value) async {
                  await _settingsRepository.setReminderEnabled(value);
                  setState(() {
                    _reminderEnabled = value;
                  });
                },
                activeColor: const Color(0xFF4351FF),
                activeTrackColor: const Color(0xFF4351FF).withOpacity(0.5),
              ),
            ],
          ),
          if (_reminderEnabled) ...[
            const SizedBox(height: 24),
            const Text(
              'REMINDER TIME',
              style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 9, minute: 0),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Color(0xFF4351FF),
                          onPrimary: Colors.white,
                          surface: Color(0xFF1E1E1E),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (time != null) {
                  final timeStr = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                  await _settingsRepository.setReminderTime(timeStr);
                  setState(() {
                    _reminderTime = time.format(context);
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _reminderTime,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const Icon(Icons.access_time_rounded, color: Colors.white38, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Material(
      color: const Color(0xFF17171F),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
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
      ),
    );
  }
}
