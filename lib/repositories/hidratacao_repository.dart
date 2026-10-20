import 'package:sqflite/sqflite.dart';

import '../data/local/app_database.dart';
import '../models/hidratacao_local.dart';

class HidratacaoRepository {
  final AppDatabase _appDatabase;

  HidratacaoRepository({
    AppDatabase? appDatabase,
  }) : _appDatabase =
      appDatabase ?? AppDatabase.instance;

  Future<PreferenciasHidratacao?> buscarPreferencias(
      int usuarioId,
      ) async {
    final db = await _appDatabase.database;

    final resultado = await db.query(
      'preferencias_hidratacao',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return PreferenciasHidratacao.fromMap(
      resultado.first,
    );
  }

  Future<void> salvarPreferencias({
    required int usuarioId,
    required int metaMl,
    required int passoMl,
  }) async {
    final db = await _appDatabase.database;
    final agora = DateTime.now().toIso8601String();

    await db.insert(
      'preferencias_hidratacao',
      {
        'usuario_id': usuarioId,
        'meta_ml': metaMl,
        'passo_ml': passoMl,
        'atualizado_em': agora,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<HidratacaoDia?> buscarDia({
    required int usuarioId,
    required String data,
  }) async {
    final db = await _appDatabase.database;

    final resultado = await db.query(
      'hidratacao_diaria',
      where: 'usuario_id = ? AND data = ?',
      whereArgs: [usuarioId, data],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return HidratacaoDia.fromMap(
      resultado.first,
    );
  }

  Future<HidratacaoDia> obterOuCriarDia({
    required int usuarioId,
    required String data,
    required int metaMl,
  }) async {
    final existente = await buscarDia(
      usuarioId: usuarioId,
      data: data,
    );

    if (existente != null) {
      return existente;
    }

    await salvarDia(
      usuarioId: usuarioId,
      data: data,
      totalMl: 0,
      metaMl: metaMl,
    );

    return (await buscarDia(
      usuarioId: usuarioId,
      data: data,
    ))!;
  }

  Future<void> salvarDia({
    required int usuarioId,
    required String data,
    required int totalMl,
    required int metaMl,
  }) async {
    final db = await _appDatabase.database;

    await db.insert(
      'hidratacao_diaria',
      {
        'usuario_id': usuarioId,
        'data': data,
        'total_ml': totalMl,
        'meta_ml': metaMl,
        'atualizado_em': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HidratacaoDia>> buscarHistorico(
      int usuarioId, {
        int limite = 30,
      }) async {
    final db = await _appDatabase.database;

    final resultado = await db.query(
      'hidratacao_diaria',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'data DESC',
      limit: limite,
    );

    return resultado
        .map(HidratacaoDia.fromMap)
        .toList();
  }
}
