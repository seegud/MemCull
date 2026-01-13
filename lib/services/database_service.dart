import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  static const String tableName = 'processed_photos';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'memcull.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id TEXT PRIMARY KEY,
            is_deleted INTEGER DEFAULT 0,
            processed_at INTEGER
          )
        ''');
      },
    );
  }

  /// 批量标记已处理的 ID
  Future<void> markAsProcessed(List<String> ids, {bool isDeleted = false}) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final id in ids) {
      batch.insert(
        tableName,
        {
          'id': id,
          'is_deleted': isDeleted ? 1 : 0,
          'processed_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// 获取所有已处理的 ID
  Future<Set<String>> getAllProcessedIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName, columns: ['id']);
    return maps.map((e) => e['id'] as String).toSet();
  }

  /// 获取回收站中的 ID
  Future<List<String>> getRecycleBinIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      columns: ['id'],
      where: 'is_deleted = ?',
      whereArgs: [1],
      orderBy: 'processed_at ASC',
    );
    return maps.map((e) => e['id'] as String).toList();
  }

  /// 从处理记录中移除（撤销）
  Future<void> removeRecord(String id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 批量从处理记录中移除（彻底删除后）
  Future<void> removeRecords(List<String> ids) async {
    final db = await database;
    final batch = db.batch();
    for (final id in ids) {
      batch.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }

  /// 清空所有记录
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(tableName);
  }
}
