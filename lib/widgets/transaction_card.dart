import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/transaction_model.dart';
import '../blocs/transaction_bloc.dart';
import '../blocs/transaction_event.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == 'debit';
    final date = DateTime.parse(transaction.timestamp);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF131313), // Same dark background as MonthlyLimitCard
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Category Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Slightly lighter dark for icon box
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(transaction.categoryName ?? ''),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          // Title and Category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  transaction.note,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.categoryName ?? 'Other',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Date and Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDate(date),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  '${isExpense ? '-' : '+'}₹${transaction.amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: TextStyle(
                    color: isExpense ? const Color(0xFFB10000) : const Color(0xFF2FB73C),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Delete Icon
          GestureDetector(
            onTap: () {
              context.read<TransactionBloc>().add(DeleteTransaction(transaction.id));
            },
            child: const Icon(Icons.delete_rounded, color: Color(0xFFB10000), size: 22),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    String day = date.day.toString();
    String suffix = 'th';
    if (day.endsWith('1') && day != '11') suffix = 'st';
    else if (day.endsWith('2') && day != '12') suffix = 'nd';
    else if (day.endsWith('3') && day != '13') suffix = 'rd';
    
    return "${day}$suffix ${DateFormat('MMM yyyy').format(date)}";
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.shopping_cart_rounded;
      case 'grocery': return Icons.shopping_cart_rounded;
      case 'bills': return Icons.water_drop_rounded;
      case 'transport': return Icons.directions_bus_rounded;
      case 'entertainment': return Icons.movie_rounded;
      case 'health': return Icons.medical_services_rounded;
      case 'salary': return Icons.payments_rounded;
      default: return Icons.category_rounded;
    }
  }
}
