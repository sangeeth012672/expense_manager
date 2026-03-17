import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import 'database_helper.dart';

class TransactionRepository {
  final _uuid = const Uuid();

  Future<TransactionModel> addTransaction(double amount, String note, String type, String categoryId) async {
    final db = await DatabaseHelper.instance.database;
    final transaction = TransactionModel(
      id: _uuid.v4(),
      amount: amount,
      note: note,
      type: type,
      categoryId: categoryId,
      timestamp: DateTime.now().toIso8601String(),
    );
    await db.insert('transactions', transaction.toJson());
    return transaction;
  }

  // The requested SQL JOIN fetching Transaction with Category Name
  Future<List<TransactionModel>> getActiveTransactions() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.rawQuery('''
      SELECT t.*, c.name as category_name 
      FROM transactions t 
      LEFT JOIN categories c ON t.category_id = c.id 
      WHERE t.is_deleted = 0 
      ORDER BY t.timestamp DESC
    ''');
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
    final maps = await db.query(
      'transactions',
      where: 'is_synced = ? AND is_deleted = ?',
      whereArgs: [0, 0],
    );
    return maps.map((e) => TransactionModel.fromJson(e)).toList();
  }
  
  Future<List<String>> getDeletedTransactionsIds() async {
     final db = await DatabaseHelper.instance.database;
     final maps = await db.query(
      'transactions',
      columns: ['id'],
      where: 'is_deleted = ?',
      whereArgs: [1],
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
    
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions 
      WHERE type = 'debit' AND is_deleted = 0 AND timestamp >= ?
    ''', [startOfMonth]);
    
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }
}
