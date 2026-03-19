import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import 'database_helper.dart';
import 'auth_repository.dart';

class TransactionRepository {
  final _uuid = const Uuid();
  final AuthRepository authRepository;

  TransactionRepository({required this.authRepository});

  Future<TransactionModel> addTransaction(double amount, String note, String type, String categoryId) async {
    final db = await DatabaseHelper.instance.database;
    final phone = await authRepository.getPhone();
    final transaction = TransactionModel(
      id: _uuid.v4(),
      amount: amount,
      note: note,
      type: type,
      categoryId: categoryId,
      timestamp: DateTime.now().toIso8601String(),
    );
    final json = transaction.toJson();
    json['user_phone'] = phone;
    await db.insert('transactions', json);
    return transaction;
  }

  // The requested SQL JOIN fetching Transaction with Category Name
  Future<List<TransactionModel>> getActiveTransactions() async {
    final db = await DatabaseHelper.instance.database;
    final phone = await authRepository.getPhone();
    final maps = await db.rawQuery('''
      SELECT t.*, c.name as category_name 
      FROM transactions t 
      LEFT JOIN categories c ON t.category_id = c.id 
      WHERE t.is_deleted = 0 AND t.user_phone = ?
      ORDER BY t.timestamp DESC
    ''', [phone]);
    return maps.map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<int> deleteTransaction(String id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'transactions',
      {'is_deleted': 1, 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Used for syncing
  Future<List<TransactionModel>> getUnsyncedTransactions() async {
    final db = await DatabaseHelper.instance.database;
    final phone = await authRepository.getPhone();
    final maps = await db.query(
      'transactions',
      where: 'is_synced = ? AND is_deleted = ? AND user_phone = ?',
      whereArgs: [0, 0, phone],
    );
    return maps.map((e) => TransactionModel.fromJson(e)).toList();
  }
  
  Future<List<String>> getDeletedTransactionsIds() async {
    final db = await DatabaseHelper.instance.database;
    final phone = await authRepository.getPhone();
     final maps = await db.query(
      'transactions',
      columns: ['id'],
      where: 'is_deleted = ? AND user_phone = ?',
      whereArgs: [1, phone],
    );
    return maps.map((e) => e['id'] as String).toList();
  }

  Future<void> markAsSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'transactions',
      {'is_synced': 1},
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
  }

  Future<void> permanentlyDelete(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'transactions',
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
  }

  // Used for Phase 4 Limit Tracking
  Future<double> getCurrentMonthDebits() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final phone = await authRepository.getPhone();
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions 
      WHERE type = 'debit' AND is_deleted = 0 AND timestamp >= ? AND user_phone = ?
    ''', [startOfMonth, phone]);
    
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }
}
