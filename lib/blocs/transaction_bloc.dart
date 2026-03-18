import 'package:bloc/bloc.dart';
import '../repositories/transaction_repository.dart';
import '../utils/notification_service.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';
import '../repositories/settings_repository.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;

  TransactionBloc({required this.repository}) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final transactions = await repository.getActiveTransactions();
      
      double income = 0;
      double expense = 0;
      
      for (var t in transactions) {
        if (t.type == 'credit') {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }

      emit(TransactionLoaded(
        transactions: transactions,
        totalIncome: income,
        totalExpense: expense,
      ));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      await repository.addTransaction(event.amount, event.note, event.type, event.categoryId);
      
      // Phase 4: Trigger local notification & state when limit exceeded.
      if (event.type == 'debit') {
         final totalDebits = await repository.getCurrentMonthDebits();
         final limit = await SettingsRepository().getBudgetLimit();
         
         if (totalDebits > limit) {
            await NotificationService().showLimitExceededNotification(totalDebits, limit);
            emit(TransactionLimitExceeded(totalExpense: totalDebits, limit: limit));
         }
      }

      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(DeleteTransaction event, Emitter<TransactionState> emit) async {
    try {
      await repository.deleteTransaction(event.id);
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
