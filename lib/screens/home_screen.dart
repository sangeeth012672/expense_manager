import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/transaction_bloc.dart';
import '../blocs/transaction_event.dart';
import '../blocs/transaction_state.dart';
import '../blocs/sync_bloc.dart';
import '../blocs/sync_event.dart';
import '../blocs/sync_state.dart';
import 'onboarding_screen.dart';
import 'category_screen.dart';
import 'transactions_screen.dart';
import 'add_transaction_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dispatch event to load data
    context.read<TransactionBloc>().add(LoadTransactions());

    return BlocListener<SyncBloc, SyncState>(
      listener: (context, state) {
        if (state is SyncSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Sync Completed Successfully'), backgroundColor: Colors.green),
          );
        } else if (state is SyncFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Sync Failed: ${state.error}'), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expense Manager'),
          actions: [
             BlocBuilder<SyncBloc, SyncState>(
                builder: (context, state) {
                   if (state is SyncInProgress) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      );
                   }
                   return IconButton(
                      icon: const Icon(Icons.sync),
                      onPressed: () => context.read<SyncBloc>().add(StartSync()),
                   );
                },
             ),
            IconButton(
              icon: const Icon(Icons.category),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen())),
            ),
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen())),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                 context.read<AuthBloc>().add(LogoutRequested());
                 Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                  (route) => false,
                );
              },
            )
          ],
        ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TransactionBloc>().add(LoadTransactions());
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildBalanceCard(context, state.totalIncome, state.totalExpense),
                  const SizedBox(height: 24),
                  const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...state.transactions.take(10).map((t) => TransactionCard(transaction: t)).toList(),
                  if (state.transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: Text('No transactions yet.', style: TextStyle(color: Colors.grey))),
                    )
                ],
              ),
            );
          } else if (state is TransactionError) {
             return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          return const Center(child: Text('Initial State'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => const AddTransactionSheet(),
           );
        },
        child: const Icon(Icons.add),
      ),
    ),
  );
}

  Widget _buildBalanceCard(BuildContext context, double income, double expense) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            '₹${(income - expense).toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               _buildIncomeExpenseRow('Income', income, Colors.greenAccent),
               _buildIncomeExpenseRow('Expense', expense, Colors.redAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseRow(String title, double amount, Color color) {
    return Column(
      children: [
        Row(
           children: [
             Icon(title == 'Income' ? Icons.arrow_downward : Icons.arrow_upward, color: color, size: 16),
             const SizedBox(width: 4),
             Text(title, style: const TextStyle(color: Colors.white70)),
           ]
        ),
        const SizedBox(height: 4),
        Text('₹${amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}
