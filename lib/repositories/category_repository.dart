import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import 'database_helper.dart';

class CategoryRepository {
  final _uuid = const Uuid();

  Future<Category> addCategory(String name) async {
    final db = await DatabaseHelper.instance.database;
    final category = Category(
      id: _uuid.v4(),
      name: name,
    );
    await db.insert('categories', category.toJson());
    return category;
  }

  Future<List<Category>> getActiveCategories() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'categories',
      where: 'is_deleted = ?',
      whereArgs: [0],
    );
    return maps.map((e) => Category.fromJson(e)).toList();
  }

  Future<int> deleteCategory(String id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'categories',
      {'is_deleted': 1, 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Used for syncing
  Future<List<Category>> getUnsyncedCategories() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'categories',
      where: 'is_synced = ? AND is_deleted = ?',
      whereArgs: [0, 0],
    );
    return maps.map((e) => Category.fromJson(e)).toList();
  }
  
  Future<List<String>> getDeletedCategoriesIds() async {
     final db = await DatabaseHelper.instance.database;
     final maps = await db.query(
      'categories',
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
      'categories',
      {'is_synced': 1},
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
  }

  Future<void> permanentlyDelete(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'categories',
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
  }
}
