import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DbHelper {
  static final DbHelper dbHero = DbHelper._secretDBConstructor();
  static Database? _database;

  DbHelper._secretDBConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(),
        'windchime.db'); //Name of the database, change if you want another one
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _onUpgrade,
    );
  }

  void _createDatabase(Database db, int version) {
    db.execute('''
    CREATE TABLE meditation_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      duration INTEGER NOT NULL,
      meditation_type TEXT
    )
  ''');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < 2) {
      // Add meditation_type column to existing meditation_sessions table
      db.execute('''
        ALTER TABLE meditation_sessions
        ADD COLUMN meditation_type TEXT
      ''');
    }
  }

  Future<int> insertDb(Map<String, dynamic> row, String table) async {
    Database db = await dbHero.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> readDb(String table) async {
    Database db = await dbHero.database;
    return await db.query(table);
  }

  Future<int> updateDb(Map<String, dynamic> row, String table) async {
    Database db = await dbHero.database;
    dynamic id = row['id'];
    return await db.update(
      table,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteDb(dynamic id, String table) async {
    Database db = await dbHero.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
