class Category {
  final String id;
  final String name;
  final int isSynced;
  final int isDeleted;

  Category({
    required this.id,
    required this.name,
    this.isSynced = 0,
    this.isDeleted = 0,
  });

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'is_synced': isSynced,
    'is_deleted': isDeleted,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    isSynced: json['is_synced'] as int,
    isDeleted: json['is_deleted'] as int,
  );
}
