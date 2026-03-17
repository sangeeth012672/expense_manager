import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/transaction_bloc.dart';
import '../blocs/transaction_event.dart';
import '../blocs/transaction_state.dart';
import '../blocs/sync_bloc.dart';
import '../blocs/sync_state.dart';
import '../blocs/sync_event.dart';
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
                            limit: 50000.0,
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
                          ...state.transactions.take(5).map((t) => widgets.TransactionCard(transaction: t)).toList(),
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
        String name = 'User';
        if (state is AuthAuthenticated) {
          // fetch name logic
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const Text(
                  'Welcome,',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.sync_rounded, color: AppColors.textPrimary),
                  onPressed: () => context.read<SyncBloc>().add(StartSync()),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_rounded, color: AppColors.textPrimary),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCards(double income, double expense) {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard('Income', income, AppColors.income)),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard('Expense', expense, AppColors.expense)),
      ],
    );
  }

  Widget _buildSummaryCard(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  label == 'Income' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${amount.toInt()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
