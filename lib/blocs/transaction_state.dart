import 'package:equatable/equatable.dart';
import '../models/transaction_model.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
  
  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final double totalIncome;
  final double totalExpense;

  const TransactionLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  List<Object> get props => [transactions, totalIncome, totalExpense];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object> get props => [message];
}

class TransactionLimitExceeded extends TransactionState {
  final double totalExpense;
  final double limit;

  const TransactionLimitExceeded({required this.totalExpense, required this.limit});

  @override
  List<Object> get props => [totalExpense, limit];
}
