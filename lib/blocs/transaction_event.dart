import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final double amount;
  final String note;
  final String type;
  final String categoryId;

  const AddTransaction({
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
  });

  @override
  List<Object> get props => [amount, note, type, categoryId];
}

class DeleteTransaction extends TransactionEvent {
  final String id;

  const DeleteTransaction(this.id);

  @override
  List<Object> get props => [id];
}
