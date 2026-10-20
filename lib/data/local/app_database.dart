import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const int _version = 2;
  static const String _databaseName = 'neogym_local.db';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    _database = await openDatabase(
      path,
      version: _version,
      onCreate: _criarTabelas,
      onUpgrade: _atualizarBanco,
    );

    return _database!;
  }

  Future<void> _criarTabelas(
      Database db,
      int version,
      ) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS preferencias_hidratacao (
      usuario_id INTEGER PRIMARY KEY,
      meta_ml INTEGER NOT NULL DEFAULT 2500,
      passo_ml INTEGER NOT NULL DEFAULT 200,
      atualizado_em TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS hidratacao_diaria (
      usuario_id INTEGER NOT NULL,
      data TEXT NOT NULL,
      total_ml INTEGER NOT NULL DEFAULT 0,
      meta_ml INTEGER NOT NULL,
      atualizado_em TEXT NOT NULL,
      PRIMARY KEY (usuario_id, data)
    )
  ''');

    await db.execute('''
    CREATE INDEX IF NOT EXISTS idx_hidratacao_usuario_data
    ON hidratacao_diaria (usuario_id, data)
  ''');
  }

  Future<void> _atualizarBanco(
      Database db,
      int versaoAntiga,
      int versaoNova,
      ) async {
    await _criarTabelas(db, versaoNova);
  }
}