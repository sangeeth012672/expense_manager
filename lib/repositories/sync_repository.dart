import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/theme.dart';
import 'auth_repository.dart';
import 'category_repository.dart';
import 'transaction_repository.dart';

class SyncRepository {
  final http.Client client;
  final AuthRepository authRepository;
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;

  SyncRepository({
    required this.client,
    required this.authRepository,
    required this.categoryRepository,
    required this.transactionRepository,
  });

  Future<Map<String, String>> _headers() async {
    final token = await authRepository.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> performSync() async {
    final headers = await _headers();

    // STEP A: Clean up Deletions (Cloud Purge)
    // 1. Transactions
    final deletedTransactionIds = await transactionRepository.getDeletedTransactionsIds();
    if (deletedTransactionIds.isNotEmpty) {
      final response = await client.delete(
        Uri.parse('${AppConstants.baseUrl}/transactions/delete/'),
        headers: headers,
        body: jsonEncode({'ids': deletedTransactionIds}),
      );
      if (response.statusCode == 200) {
        await transactionRepository.permanentlyDelete(deletedTransactionIds);
      }
    }

    // 2. Categories
    final deletedCategoryIds = await categoryRepository.getDeletedCategoriesIds();
    if (deletedCategoryIds.isNotEmpty) {
      final response = await client.delete(
        Uri.parse('${AppConstants.baseUrl}/categories/delete/'),
        headers: headers,
        body: jsonEncode({'ids': deletedCategoryIds}),
      );
      if (response.statusCode == 200) {
        // Only after API confirms success, permanently delete.
         await categoryRepository.permanentlyDelete(deletedCategoryIds);
      }
    }

    // STEP B: Upload New Data (Cloud Backup)
    // 1. Sync Categories First
    final unsyncedCategories = await categoryRepository.getUnsyncedCategories();
    if (unsyncedCategories.isNotEmpty) {
      for (var cat in unsyncedCategories) {
        // The API specifies single add, but the wording mentions "Batch upload local categories".
        // The endpoint provided is /categories/add/ with single payload. Assuming multiple calls or batch if supported.
        // Based on docs:
        // { "category_id": "...", "name": "Food" }
        final response = await client.post(
          Uri.parse('${AppConstants.baseUrl}/categories/add/'),
          headers: headers,
          body: jsonEncode({
            'category_id': cat.id,
            'name': cat.name,
          }),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
            await categoryRepository.markAsSynced([cat.id]);
        }
      }
    }

    // 2. Sync Transactions Second
    final unsyncedTransactions = await transactionRepository.getUnsyncedTransactions();
    if (unsyncedTransactions.isNotEmpty) {
      // The API specifies a batch upload for transactions
      final payload = {
         'transactions': unsyncedTransactions.map((t) => {
            'id': t.id,
            'amount': t.amount,
            'note': t.note,
            'type': t.type,
            'category_id': t.categoryId,
            'timestamp': t.timestamp.replaceAll('T', ' ').split('.')[0], // Format 2023-10-27 10:00:00
         }).toList()
      };
      
      final response = await client.post(
        Uri.parse('${AppConstants.baseUrl}/transactions/add/'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
         final syncedIds = unsyncedTransactions.map((e) => e.id).toList();
         await transactionRepository.markAsSynced(syncedIds);
      }
    }
  }
}
