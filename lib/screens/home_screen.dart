import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/transaction_bloc.dart';
import '../blocs/transaction_event.dart';
import '../blocs/transaction_state.dart';
import '../blocs/sync_bloc.dart';
import '../blocs/sync_state.dart';
import '../utils/app_colors.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/monthly_limit_card.dart';
import '../widgets/transaction_card.dart' as widgets;
import 'transactions_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<TransactionBloc>().add(LoadTransactions());

    return BlocListener<SyncBloc, SyncState>(
      listener: (context, state) {
        if (state is SyncSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Sync Completed Successfully'), backgroundColor: AppColors.income),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return ListView(
                      padding: const EdgeInsets.all(24.0),
                      children: List.generate(5, (_) => const TransactionShimmer()),
                    );
                  }
                  if (state is TransactionLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<TransactionBloc>().add(LoadTransactions());
                      },
                      child: ListView(
                        padding: const EdgeInsets.all(24.0),
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 24),
                          _buildSummaryCards(state.totalIncome, state.totalExpense),
                          const SizedBox(height: 24),
                          MonthlyLimitCard(
                            currentSpend: state.totalExpense,
                            limit: 1000.0,
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Transactions', 
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen())),
                                child: const Text('See All', style: TextStyle(color: AppColors.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...state.transactions.take(10).map((t) => widgets.TransactionCard(transaction: t)).toList(),
                          if (state.transactions.isEmpty) _buildEmptyState(),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('Error loading dashboard'));
                },
              ),
              BlocBuilder<SyncBloc, SyncState>(
                builder: (context, state) {
                  if (state is SyncInProgress) {
                    return Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 16),
                            Text('Syncing with cloud...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String name = 'Naazley';
        if (state is AuthAuthenticated && state.nickname != null) {
          name = state.nickname!;
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text(
            '👋 Welcome, $name!',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(double income, double expense) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Income', 
            income, 
            [const Color(0xFF007A1D), const Color(0xFF004D12)], // Green Gradient
            Icons.south_west_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total Expense', 
            expense, 
            [const Color(0xFFB10000), const Color(0xFF8B0000)], // Red Gradient
            Icons.north_east_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, double amount, List<Color> gradient, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 4),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '₹${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.surfaceLight),
            SizedBox(height: 16),
            Text('No transactions yet.', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
