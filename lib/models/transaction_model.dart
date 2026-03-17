class TransactionModel {
  final String id;
  final double amount;
  final String note;
  final String type; // 'credit' or 'debit'
  final String categoryId;
  final String? categoryName; // Fetched via SQL JOIN
  final int isSynced;
  final int isDeleted;
  final String timestamp;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
    this.categoryName,
    this.isSynced = 0,
    this.isDeleted = 0,
    required this.timestamp,
  });

  Map<String, Object?> toJson() => {
    'id': id,
    'amount': amount,
    'note': note,
    'type': type,
    'category_id': categoryId,
    'is_synced': isSynced,
    'is_deleted': isDeleted,
    'timestamp': timestamp,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    id: json['id'] as String,
    amount: (json['amount'] as num).toDouble(),
    note: json['note'] as String,
    type: json['type'] as String,
    categoryId: json['category_id'] as String,
    categoryName: json['category_name'] as String?, // Nullable, populated via JOIN
    isSynced: json['is_synced'] as int,
    isDeleted: json['is_deleted'] as int,
    timestamp: json['timestamp'] as String,
  );
}
