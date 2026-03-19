import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/app_colors.dart';
import '../blocs/auth_bloc.dart';
import 'home_screen.dart';
import 'transactions_screen.dart';
import '../blocs/transaction_bloc.dart';
import '../blocs/transaction_state.dart';
import 'profile_screen.dart';
import 'add_transaction_sheet.dart';
import 'splash_screen.dart';
import '../blocs/category_bloc.dart';
import '../blocs/category_event.dart';
import '../blocs/transaction_event.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Refresh data when user enters the main area
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SplashScreen()),
                (route) => false,
              );
            }
          },
        ),
        BlocListener<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (state is TransactionLimitExceeded) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFFCC3300),
                  duration: const Duration(seconds: 5),
                  content: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Limit Exceeded! ₹${state.totalExpense.toStringAsFixed(0)} / ₹${state.limit.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  action: SnackBarAction(
                    label: 'VIEW',
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() => _selectedIndex = 1); // Go to Transactions
                    },
                  ),
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 24, left: 60, right: 60), // Narrower capsule
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF131313), // Match theme dark
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.pie_chart_rounded),
              _buildNavItem(1, Icons.sync_rounded),
              _buildNavItem(2, Icons.manage_accounts_rounded),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 0 
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80, right: 0),
              child: FloatingActionButton(
                onPressed: () => _showAddTransaction(context),
                backgroundColor: const Color(0xFF2FB73C),
                elevation: 4,
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
              ),
            )
          : null,
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4351FF) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: const AddTransactionSheet(),
      ),
    );
  }
}
