import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/transaction_bloc.dart';
import '../blocs/transaction_event.dart';
import '../blocs/transaction_state.dart';
import '../utils/app_colors.dart';
import '../widgets/transaction_card.dart';
import '../widgets/shimmer_loader.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  ...List.generate(8, (_) => const TransactionShimmer()),
                ],
              );
            }
            if (state is TransactionLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<TransactionBloc>().add(LoadTransactions());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: state.transactions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildHeader();
                    }
                    final transaction = state.transactions[index - 1];
                    return TransactionCard(transaction: transaction);
                  },
                ),
              );
            }
            return const Center(child: Text('Error loading transactions'));
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(top: 8.0, bottom: 24.0),
      child: Text(
        'Transactions',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
